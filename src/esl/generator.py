"""
src/esl/generator.py
---------------------
AI-powered ESL layout spec generator.

Takes product fields (JSON) + natural language description and returns a
structured layout spec that xsl_builder.py converts deterministically to XSL.

Includes auto-retry with JSON repair so local models (Llama, Gemma) work
reliably without needing a paid API key.
"""

import json
import re
from langchain_core.messages import HumanMessage, SystemMessage

# ── ESL size registry ──────────────────────────────────────────────────────
ESL_SIZES = {
    "2.5\" (296×152)": {"width": 296, "height": 152, "label": "2.5_4C"},
    # Add more sizes here as you on-board them
}

DEFAULT_SIZE = "2.5\" (296×152)"
MAX_RETRIES  = 3


# ── System prompt ──────────────────────────────────────────────────────────
_SYSTEM_PROMPT = """You are an ESL (Electronic Shelf Label) layout designer.
Your job is to convert a natural language layout description into a precise JSON layout spec.

STRICT RULES:
- Output ONLY the JSON object. No explanation, no markdown, no code fences, no comments.
- First character of your response must be { and last character must be }
- All property names and string values must use double quotes, not single quotes.
- No trailing commas.
- No JavaScript-style comments (//).

COORDINATE SYSTEM:
- Top-left corner is (0, 0)
- X increases to the right, Y increases downward
- All values are in pixels (integers)

CANVAS SIZE: You will be given the canvas width and height.

ELEMENT TYPES:
1. textbox  — displays a product data field or static text
2. rect     — a drawn rectangle (border or background block)
3. barcode  — a barcode (code128)

OUTPUT SCHEMA:
{
  "canvas": { "width": <int>, "height": <int>, "background_color": "#FFFFFF" },
  "elements": [
    {
      "type": "textbox",
      "field": "FIELD_NAME",
      "static_text": null,
      "x": <int>, "y": <int>, "width": <int>, "height": <int>,
      "font_family": "Arial",
      "font_size": <int>,
      "font_weight": "bold",
      "font_style": "normal",
      "text_align": "center",
      "text_vert_align": "middle",
      "fill": "#000000",
      "background_color": "transparent",
      "fit_text": false
    },
    {
      "type": "rect",
      "x": <int>, "y": <int>, "width": <int>, "height": <int>,
      "fill": "transparent",
      "stroke": "#000000",
      "stroke_width": 1
    },
    {
      "type": "barcode",
      "field": "FIELD_NAME",
      "barcode_type": "code128",
      "x": <int>, "y": <int>, "width": <int>, "height": <int>
    }
  ]
}

LAYOUT RULES:
- Keep ALL elements within canvas bounds
- Price fields: font_size 28-48, bold, prominent
- Product name: spans most of the width, fit_text true
- Barcode: height 15-22px, width 80-160px
- Minimum 4px margin from canvas edges
- Static labels (e.g. "UNIT PRICE") use static_text field, set field to null
- font_family options: "Arial", "Helvetica", "Times New Roman"

EXAMPLE OUTPUT for 296x152 label:
{"canvas":{"width":296,"height":152,"background_color":"#FFFFFF"},"elements":[{"type":"textbox","field":"ITEM_NAME","static_text":null,"x":4,"y":4,"width":288,"height":36,"font_family":"Arial","font_size":20,"font_weight":"bold","font_style":"normal","text_align":"center","text_vert_align":"middle","fill":"#000000","background_color":"transparent","fit_text":true},{"type":"textbox","field":"LIST_PRICE","static_text":null,"x":148,"y":50,"width":140,"height":60,"font_family":"Arial","font_size":40,"font_weight":"bold","font_style":"normal","text_align":"center","text_vert_align":"middle","fill":"#000000","background_color":"transparent","fit_text":false},{"type":"barcode","field":"ITEM_ID","barcode_type":"code128","x":4,"y":128,"width":140,"height":18}]}"""


# ── JSON repair utilities ──────────────────────────────────────────────────

def _extract_json_block(text: str) -> str:
    """
    Extract the outermost {...} block from text.
    Handles cases where the model adds explanation before/after the JSON.
    """
    # Find the first { and last } that form a balanced block
    start = text.find("{")
    if start == -1:
        raise ValueError("No JSON object found in response")

    depth = 0
    in_string = False
    escape_next = False

    for i, ch in enumerate(text[start:], start=start):
        if escape_next:
            escape_next = False
            continue
        if ch == "\\" and in_string:
            escape_next = True
            continue
        if ch == '"' and not escape_next:
            in_string = not in_string
            continue
        if in_string:
            continue
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return text[start:i + 1]

    raise ValueError("Unbalanced JSON braces in response")


def _repair_json(text: str) -> str:
    """
    Fix common issues local models produce:
    - Strip markdown fences
    - Remove JavaScript // comments
    - Remove trailing commas before } or ]
    - Extract the JSON block from surrounding prose
    """
    # Strip markdown code fences
    text = re.sub(r"^```[a-z]*\s*", "", text, flags=re.MULTILINE)
    text = re.sub(r"```\s*$", "", text, flags=re.MULTILINE)
    text = text.strip()

    # Remove JS-style // comments (outside strings — approximate but catches most cases)
    text = re.sub(r'//[^\n"]*\n', '\n', text)

    # Remove trailing commas before closing bracket/brace
    text = re.sub(r",\s*(\})", r"\1", text)
    text = re.sub(r",\s*(\])", r"\1", text)

    # Extract just the JSON block
    text = _extract_json_block(text)

    return text


def _validate_layout(layout: dict, canvas_w: int, canvas_h: int):
    """
    Check the layout spec has the required structure and sane values.
    Raises ValueError with a clear message if anything is wrong —
    that message is fed back to the model on retry.
    """
    if "canvas" not in layout:
        raise ValueError("Missing 'canvas' key in layout")
    if "elements" not in layout or not isinstance(layout["elements"], list):
        raise ValueError("Missing or empty 'elements' list in layout")
    if not layout["elements"]:
        raise ValueError("'elements' list is empty — the label has no content")

    for i, el in enumerate(layout["elements"]):
        t = el.get("type")
        if t not in ("textbox", "rect", "barcode"):
            raise ValueError(f"Element {i}: unknown type '{t}'. Must be textbox, rect, or barcode")

        for key in ("x", "y", "width", "height"):
            if key not in el:
                raise ValueError(f"Element {i} ({t}): missing required key '{key}'")
            if not isinstance(el[key], (int, float)):
                raise ValueError(f"Element {i} ({t}): '{key}' must be a number, got {type(el[key]).__name__}")

        # Bounds check
        x, y, w, h = el["x"], el["y"], el["width"], el["height"]
        if w <= 0 or h <= 0:
            raise ValueError(f"Element {i} ({t}): width and height must be positive")
        if x < 0 or y < 0 or x + w > canvas_w + 5 or y + h > canvas_h + 5:
            raise ValueError(
                f"Element {i} ({t}): position ({x},{y}) size {w}x{h} goes outside "
                f"canvas {canvas_w}x{canvas_h}"
            )

        if t == "textbox":
            if el.get("field") is None and el.get("static_text") is None:
                raise ValueError(f"Element {i} (textbox): must have either 'field' or 'static_text'")
            if el.get("font_size", 0) <= 0:
                raise ValueError(f"Element {i} (textbox): font_size must be positive")

        if t == "barcode" and not el.get("field"):
            raise ValueError(f"Element {i} (barcode): missing 'field'")


# ── Main generator class ───────────────────────────────────────────────────

class ESLGenerator:
    def __init__(self, llm_provider: str = "ollama"):
        self.llm_provider = llm_provider
        self._llm = None

    def _get_llm(self):
        if self._llm is None:
            from src.llm_config import get_llm
            self._llm = get_llm(self.llm_provider, temperature=0.1)
        return self._llm

    def generate(
        self,
        fields: dict,
        description: str,
        size_key: str = DEFAULT_SIZE,
    ) -> dict:
        """
        Generate a layout spec from natural language description.
        Auto-retries up to MAX_RETRIES times with error feedback on failure.

        Args:
            fields:      dict of product field names → types
            description: natural language label layout description
            size_key:    key from ESL_SIZES

        Returns:
            Validated layout spec dict ready for xsl_builder.py
        """
        canvas = ESL_SIZES[size_key]
        llm = self._get_llm()

        user_msg = self._build_user_message(fields, description, canvas)
        messages = [
            SystemMessage(content=_SYSTEM_PROMPT),
            HumanMessage(content=user_msg),
        ]

        last_error = None

        for attempt in range(1, MAX_RETRIES + 1):
            try:
                response = llm.invoke(messages)
                raw = response.content.strip()

                # Repair common model output issues
                cleaned = _repair_json(raw)

                # Parse
                layout = json.loads(cleaned)

                # Validate structure and bounds
                _validate_layout(layout, canvas["width"], canvas["height"])

                if attempt > 1:
                    print(f"ESL generator: succeeded on attempt {attempt}")

                return layout

            except (json.JSONDecodeError, ValueError) as e:
                last_error = str(e)
                print(f"ESL generator attempt {attempt}/{MAX_RETRIES} failed: {last_error}")

                if attempt < MAX_RETRIES:
                    # Feed the error back so the model can self-correct
                    messages = [
                        SystemMessage(content=_SYSTEM_PROMPT),
                        HumanMessage(content=user_msg),
                        # Previous bad response
                        messages[-1] if len(messages) > 2 else HumanMessage(content=user_msg),
                        HumanMessage(content=(
                            f"Your previous response had this error: {last_error}\n\n"
                            f"Please fix it and return ONLY the corrected JSON object. "
                            f"No explanation. Start your response with {{ and end with }}."
                        )),
                    ]

        raise ValueError(
            f"Could not generate a valid layout after {MAX_RETRIES} attempts. "
            f"Last error: {last_error}. "
            f"Try switching to a more capable model (Claude or GPT-4o) for better results."
        )

    def _build_user_message(self, fields: dict, description: str, canvas: dict) -> str:
        return (
            f"CANVAS: {canvas['width']}x{canvas['height']} pixels\n\n"
            f"PRODUCT FIELDS (use ONLY these field names):\n"
            f"{json.dumps(fields, indent=2)}\n\n"
            f"LAYOUT DESCRIPTION:\n{description}\n\n"
            f"Return ONLY the JSON object. No explanation. "
            f"Start with {{ and end with }}."
        )

    def switch_provider(self, provider: str):
        self.llm_provider = provider
        self._llm = None
