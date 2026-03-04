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
from src.esl.label_registry import (
    LABEL_REGISTRY, DEFAULT_LABEL_KEY,
    available_colors as _label_colors,
    font_size_guide,
)

# ── ESL size registry — built from label_registry ──────────────────────────
ESL_SIZES: dict[str, dict] = {
    key: {"width": info["width"], "height": info["height"], "label": info["label"]}
    for key, info in LABEL_REGISTRY.items()
}

DEFAULT_SIZE = DEFAULT_LABEL_KEY
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
1. textbox      — displays a product data field or static text
2. rect         — a drawn rectangle (solid fill or border only)
3. rounded_rect — a rectangle with rounded corners; add border_radius field (pixels, e.g. 8)
4. circle       — a circle or ellipse; bounding box defined by x,y,width,height; set width==height for true circle
5. line         — a straight line from (x1,y1) to (x2,y2); use x1/y1/x2/y2 fields, not x/y/width/height
6. image        — a logo or product image placeholder; x,y,width,height define the bounding box
7. barcode      — a barcode element. Set barcode_type to one of:

   LINEAR barcodes (rectangular, height-based):
     code128          width 160px  height 18px  — general purpose, most common
     code39           width 239px  height 18px  — alphanumeric
     ean128           width 143px  height 18px  — GS1-128 / logistics
     ean13            width 113px  height 18px  — retail EAN-13 (12-digit data)
     ean8             width  85px  height 18px  — compact EAN-8 (7-digit data)
     UPC              width 113px  height 18px  — UPC-A (11-digit data)
     UPCE             width  69px  height 18px  — UPC-E compressed (7-digit data)
     interleaved2of5  width 155px  height 18px  — numeric pairs only
     codabar          width  34px  height 18px  — library / medical
     pdf417           width 123px  height 18px  — stacked 2D, high-capacity text

   2D / SQUARE barcodes (set width = height):
     qrCode           width  50px  height  50px — QR Code
     datamatrix       width  34px  height  34px — Data Matrix
     azteccode        width  69px  height  69px — Aztec Code

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
      "fit_text": false,
      "currency_code": null,
      "currency_format": null,
      "underline": false,
      "line_through": false,
      "overline": false,
      "upper_case": false,
      "lower_case": false,
      "letter_spacing": 0,
      "overflow_hide": false,
      "text_fit_min": 5,
      "text_fit_max": 100
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
      "x": <int>, "y": <int>, "width": <int>, "height": <int>,
      "human_readable": "none",
      "barcode_align": "left"
    },
    {
      "type": "rounded_rect",
      "x": <int>, "y": <int>, "width": <int>, "height": <int>,
      "fill": "transparent",
      "stroke": "#000000",
      "stroke_width": 1,
      "border_radius": 8
    },
    {
      "type": "circle",
      "x": <int>, "y": <int>, "width": <int>, "height": <int>,
      "fill": "transparent",
      "stroke": "#000000",
      "stroke_width": 1
    },
    {
      "type": "line",
      "x1": <int>, "y1": <int>, "x2": <int>, "y2": <int>,
      "stroke": "#000000",
      "stroke_width": 1
    },
    {
      "type": "image",
      "x": <int>, "y": <int>, "width": <int>, "height": <int>
    }
  ]
}

LAYOUT RULES:
- Keep ALL elements within canvas bounds
- Price fields: font_size 28-48, bold, prominent
- Product name: spans most of the width, fit_text true
- Barcode 1D (linear): height 15-22px; use the default width for the chosen type
- Barcode 2D (qrCode/datamatrix/azteccode): width must equal height (square); minimum 34px
- Minimum 4px margin from canvas edges
- Static labels (e.g. "UNIT PRICE") use static_text field, set field to null
- font_family options: "Arial", "Helvetica", "Times New Roman"
- Default to code128 when no specific barcode type is requested
- rounded_rect: use for visually soft section separators or info boxes with soft corners
- circle: use for promotional badges or decorative accents; prefer width == height for true circle
- line: use horizontal dividers to separate label sections (set y1 == y2 for horizontal)
- upper_case/lower_case: use for display text formatting; never use both simultaneously
- overflow_hide: set true when text must not overflow its bounding box
- barcode human_readable: "none" (clean default), "bottom" (text below bars), "top" (text above bars)
- barcode_align: "left" (default), "center", or "right" within the barcode bounding box
- image: include at most one image element when the description requests a logo; position per instructions

CURRENCY FORMATTING (for price/decimal textbox fields):
When the description mentions a currency or the field type is "decimal", set currency_code and currency_format.
Leave both null for non-price fields or when no currency is specified.

currency_code values and their symbols:
  USD=$  GBP=£  EUR=€  JPY=¥  CNY=¥  KRW=₩  INR=₹  VND=₫  TRY=₺
  PC=Chile($)  LA=LatAm($)  THB=฿  ILS=₪  TWD=元  PLN=zł  BRL=R$
  MYR=RM  SAR=﷼  UAH=грн  Rp=Rp  Ft=Ft  YEN=円  CR=៛  None=no-symbol

currency_format visual patterns (¤ = symbol):
  format1   → 12.34 ¤          value with decimal, symbol suffix
  format2   → 12^34 ¤          large whole, superscript cents, symbol suffix
  format4   → ¤ 12.^34         superscript symbol prefix, whole, small cents
  format5   → ¤ 12.34          symbol prefix then value (USD/standard)
  format11  → ¤ 12.34          symbol prefix then value (GBP/EUR/JPY/KRW)
  format12  → ^¤ 12 ^.56       superscript symbol, large whole, superscript cents (best for big price display)

Decimal separator rules:
  EUR/VND/TRY/LA use comma decimal (1.234,56) — "euro" style
  All others use period decimal (1,234.56) — "usa" style

Use format12 for the main large price display. Use format5/format11 for smaller prices.

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


_MIN_ELEMENT_SIZE = 4   # pixels — smallest allowed width / height after clamping


def _clamp_layout(layout: dict, canvas_w: int, canvas_h: int):
    """
    Silently clip any element that overflows the canvas back into bounds.
    Called before validation so coordinate overflows never cause retries.

    - For boxed elements (x,y,width,height): the right/bottom edge is clipped.
    - For line elements (x1,y1,x2,y2): each endpoint is clamped independently.
    - Negative x/y are shifted to 0 (shrinking the dimension to compensate).
    """
    for el in layout.get("elements", []):
        t = el.get("type")
        if t == "line":
            el["x1"] = max(0, min(int(el.get("x1", 0)), canvas_w))
            el["y1"] = max(0, min(int(el.get("y1", 0)), canvas_h))
            el["x2"] = max(0, min(int(el.get("x2", 0)), canvas_w))
            el["y2"] = max(0, min(int(el.get("y2", 0)), canvas_h))
        elif t in ("textbox", "rect", "rounded_rect", "circle", "image", "barcode"):
            x = max(0, int(el.get("x", 0)))
            y = max(0, int(el.get("y", 0)))
            w = max(_MIN_ELEMENT_SIZE, int(el.get("width",  _MIN_ELEMENT_SIZE)))
            h = max(_MIN_ELEMENT_SIZE, int(el.get("height", _MIN_ELEMENT_SIZE)))
            # Clip right/bottom edges to stay within canvas
            w = min(w, canvas_w - x)
            h = min(h, canvas_h - y)
            # Ensure minimum size is preserved even after clipping
            w = max(w, _MIN_ELEMENT_SIZE)
            h = max(h, _MIN_ELEMENT_SIZE)
            el["x"], el["y"], el["width"], el["height"] = x, y, w, h


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
        if t not in ("textbox", "rect", "barcode", "circle", "line", "rounded_rect", "image"):
            raise ValueError(
                f"Element {i}: unknown type '{t}'. "
                f"Must be textbox, rect, rounded_rect, circle, line, image, or barcode"
            )

        if t == "line":
            # line uses x1,y1,x2,y2 instead of x,y,width,height
            for key in ("x1", "y1", "x2", "y2"):
                if key not in el:
                    raise ValueError(f"Element {i} (line): missing required key '{key}'")
                if not isinstance(el[key], (int, float)):
                    raise ValueError(f"Element {i} (line): '{key}' must be a number, got {type(el[key]).__name__}")
        else:
            for key in ("x", "y", "width", "height"):
                if key not in el:
                    raise ValueError(f"Element {i} ({t}): missing required key '{key}'")
                if not isinstance(el[key], (int, float)):
                    raise ValueError(f"Element {i} ({t}): '{key}' must be a number, got {type(el[key]).__name__}")

            # Sanity check after clamping (should always pass, but guards against NaN etc.)
            x, y, w, h = el["x"], el["y"], el["width"], el["height"]
            if w < _MIN_ELEMENT_SIZE or h < _MIN_ELEMENT_SIZE:
                raise ValueError(
                    f"Element {i} ({t}): width/height too small after clamping ({w}x{h}). "
                    f"Canvas is {canvas_w}x{canvas_h} — element may be positioned outside it."
                )

        if t == "textbox":
            if el.get("field") is None and el.get("static_text") is None:
                raise ValueError(f"Element {i} (textbox): must have either 'field' or 'static_text'")
            if el.get("font_size", 0) <= 0:
                raise ValueError(f"Element {i} (textbox): font_size must be positive")

        if t == "barcode":
            if not el.get("field"):
                raise ValueError(f"Element {i} (barcode): missing 'field'")
            valid_barcode_types = {
                "code128", "code39", "ean128", "ean13", "ean8",
                "UPC", "UPCE", "interleaved2of5", "codabar", "pdf417",
                "qrCode", "datamatrix", "azteccode",
            }
            btype = el.get("barcode_type", "code128")
            if btype not in valid_barcode_types:
                raise ValueError(
                    f"Element {i} (barcode): unknown barcode_type '{btype}'. "
                    f"Valid types: {', '.join(sorted(valid_barcode_types))}"
                )


# ── Main generator class ───────────────────────────────────────────────────

class ESLGenerator:
    def __init__(self, llm_provider: str = "ollama"):
        self.llm_provider = llm_provider
        self._llm = None

    def _get_llm(self):
        if self._llm is None:
            from src.llm_config import get_llm
            # Local models: deterministic output + JSON grammar mode (no fences, no preamble)
            json_mode = self.llm_provider in ("ollama", "gemma")
            self._llm = get_llm(self.llm_provider, temperature=0.0, json_mode=json_mode)
        return self._llm

    @staticmethod
    def _invoke_or_stream(llm, messages, stream_fn=None) -> str:
        """
        Call the LLM either via streaming (if stream_fn provided) or invoke().
        Returns the raw response string.
        """
        if stream_fn is not None:
            parts = []
            for chunk in llm.stream(messages):
                token = chunk.content if hasattr(chunk, "content") else str(chunk)
                parts.append(token)
                stream_fn(token)
            return "".join(parts).strip()
        else:
            return llm.invoke(messages).content.strip()

    def generate(
        self,
        fields: dict,
        description: str,
        size_key: str = DEFAULT_SIZE,
        stream_fn=None,
    ) -> dict:
        """
        Generate a layout spec from natural language description.
        Auto-retries up to MAX_RETRIES times with error feedback on failure.

        Args:
            fields:      dict of product field names → types
            description: natural language label layout description
            size_key:    key from ESL_SIZES
            stream_fn:   optional callback(token: str) called for each streamed token

        Returns:
            Validated layout spec dict ready for xsl_builder.py
        """
        canvas = dict(ESL_SIZES[size_key])  # copy so we can annotate it
        reg    = LABEL_REGISTRY.get(size_key, {})
        canvas["available_colors"] = _label_colors(size_key)
        canvas["orientation"]      = reg.get("orientation", "landscape")
        canvas["dpi"]              = reg.get("dpi", 150)
        llm = self._get_llm()

        user_msg = self._build_user_message(fields, description, canvas)
        messages = [
            SystemMessage(content=_SYSTEM_PROMPT),
            HumanMessage(content=user_msg),
        ]

        last_error = None

        for attempt in range(1, MAX_RETRIES + 1):
            try:
                raw = self._invoke_or_stream(llm, messages, stream_fn)

                # Repair common model output issues
                cleaned = _repair_json(raw)

                # Parse
                layout = json.loads(cleaned)

                # Clamp any overflowing coordinates before validation
                _clamp_layout(layout, canvas["width"], canvas["height"])

                # Validate structure and required fields
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
        w, h = canvas["width"], canvas["height"]
        orientation = canvas.get("orientation", "landscape")
        colors      = canvas.get("available_colors", ["transparent", "black", "white"])
        font_guide  = font_size_guide(h)

        return (
            f"CANVAS: {w}x{h} pixels  |  orientation: {orientation}  |  DPI: {canvas.get('dpi', 150)}\n"
            f"AVAILABLE COLORS (use ONLY these for fill/stroke/background): {', '.join(colors)}\n"
            f"FONT SIZE GUIDE for this label height: {font_guide}\n\n"
            f"PRODUCT FIELDS (use ONLY these field names):\n"
            f"{json.dumps(fields, indent=2)}\n\n"
            f"LAYOUT DESCRIPTION:\n{description}\n\n"
            f"Return ONLY the JSON object. No explanation. "
            f"Start with {{ and end with }}."
        )

    def refine(
        self,
        current_layout: dict,
        instruction: str,
        stream_fn=None,
    ) -> dict:
        """
        Apply a natural language refinement instruction to an existing layout spec.

        The AI receives the current layout JSON and the instruction, and returns
        the complete updated spec with only the requested changes applied.

        Args:
            current_layout: Existing validated layout spec dict.
            instruction:    Natural language change, e.g. "move price to center-left".
            stream_fn:      optional callback(token: str) called for each streamed token

        Returns:
            Updated validated layout spec dict.
        """
        cw = current_layout["canvas"]["width"]
        ch = current_layout["canvas"]["height"]

        user_msg = (
            f"Below is an existing ESL layout spec. Apply ONLY the requested change "
            f"and return the complete updated spec.\n\n"
            f"CANVAS: {cw}x{ch} pixels\n\n"
            f"CURRENT LAYOUT SPEC:\n{json.dumps(current_layout, indent=2)}\n\n"
            f"REQUESTED CHANGE:\n{instruction}\n\n"
            f"RULES:\n"
            f"- Preserve ALL elements not mentioned in the change\n"
            f"- Only modify / add / remove what the instruction asks for\n"
            f"- Keep all coordinates within the {cw}x{ch} canvas\n"
            f"- Return the COMPLETE updated JSON object. Start with {{ and end with }}."
        )

        llm = self._get_llm()
        messages = [
            SystemMessage(content=_SYSTEM_PROMPT),
            HumanMessage(content=user_msg),
        ]

        last_error = None
        for attempt in range(1, MAX_RETRIES + 1):
            try:
                raw     = self._invoke_or_stream(llm, messages, stream_fn)
                cleaned = _repair_json(raw)
                layout  = json.loads(cleaned)
                _clamp_layout(layout, cw, ch)
                _validate_layout(layout, cw, ch)
                if attempt > 1:
                    print(f"ESL refine: succeeded on attempt {attempt}")
                return layout

            except (json.JSONDecodeError, ValueError) as e:
                last_error = str(e)
                print(f"ESL refine attempt {attempt}/{MAX_RETRIES} failed: {last_error}")
                if attempt < MAX_RETRIES:
                    messages.append(HumanMessage(content=(
                        f"Your response had an error: {last_error}\n"
                        f"Fix it and return ONLY the complete corrected JSON. "
                        f"Start with {{ and end with }}."
                    )))

        raise ValueError(
            f"Could not apply refinement after {MAX_RETRIES} attempts. "
            f"Last error: {last_error}"
        )

    def switch_provider(self, provider: str):
        self.llm_provider = provider
        self._llm = None
