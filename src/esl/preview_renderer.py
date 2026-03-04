"""
src/esl/preview_renderer.py
----------------------------
Renders an ESL layout spec as a PIL Image for live preview.

Reference data (field name → sample value) is substituted into textbox
elements so the preview reflects how the printed label will actually look.
"""

import os
from PIL import Image, ImageDraw, ImageFont

# ── Color helpers ─────────────────────────────────────────────────────────────

_NAMED_COLORS: dict[str, tuple | None] = {
    "black":       (0,   0,   0),
    "white":       (255, 255, 255),
    "red":         (220, 30,  30),
    "yellow":      (255, 215, 0),
    "orange":      (255, 140, 0),
    "green":       (0,   160, 0),
    "blue":        (0,   0,   220),
    "pink":        (255, 150, 180),
    "gray":        (128, 128, 128),
    "transparent": None,
}


def _parse_color(color: str) -> tuple | None:
    """Return (R, G, B) tuple or None for transparent."""
    if not color:
        return None
    c = color.strip().lower()
    if c in _NAMED_COLORS:
        return _NAMED_COLORS[c]
    c = c.lstrip("#")
    if len(c) == 6:
        try:
            return (int(c[0:2], 16), int(c[2:4], 16), int(c[4:6], 16))
        except ValueError:
            pass
    return (0, 0, 0)


# ── Font cache ────────────────────────────────────────────────────────────────

_FONT_CACHE: dict = {}

_FONT_DIRS = [
    "C:/Windows/Fonts",
    "/usr/share/fonts/truetype/msttcorefonts",
    "/usr/share/fonts/truetype/dejavu",
    "/usr/share/fonts/truetype",
    "/usr/share/fonts",
    "/System/Library/Fonts",
    "/Library/Fonts",
    os.path.join(os.path.dirname(__file__), "fonts"),
]

_FONT_NAMES = {
    (False, False): ["arial.ttf", "Arial.ttf", "DejaVuSans.ttf",          "LiberationSans-Regular.ttf"],
    (True,  False): ["arialbd.ttf", "Arial_Bold.ttf",  "DejaVuSans-Bold.ttf",    "LiberationSans-Bold.ttf"],
    (False, True ): ["ariali.ttf",  "Arial_Italic.ttf","DejaVuSans-Oblique.ttf",  "LiberationSans-Italic.ttf"],
    (True,  True ): ["arialbi.ttf", "Arial_Bold_Italic.ttf", "DejaVuSans-BoldOblique.ttf"],
}


def _get_font(size: int, bold: bool = False, italic: bool = False) -> ImageFont.FreeTypeFont:
    key = (size, bold, italic)
    if key in _FONT_CACHE:
        return _FONT_CACHE[key]

    names = _FONT_NAMES.get((bold, italic), _FONT_NAMES[(False, False)])
    font = None
    for name in names:
        for d in _FONT_DIRS:
            path = os.path.join(d, name)
            if os.path.exists(path):
                try:
                    font = ImageFont.truetype(path, size)
                    break
                except Exception:
                    pass
        if font:
            break

    if font is None:
        try:
            font = ImageFont.load_default(size=size)
        except TypeError:
            font = ImageFont.load_default()

    _FONT_CACHE[key] = font
    return font


# ── Element renderers ─────────────────────────────────────────────────────────

def _draw_textbox(draw: ImageDraw.ImageDraw, el: dict, ref_data: dict, scale: float):
    x = el["x"] * scale
    y = el["y"] * scale
    w = el["width"] * scale
    h = el["height"] * scale

    font_size  = max(6, round(el.get("font_size", 14) * scale))
    bold       = el.get("font_weight") == "bold"
    italic     = el.get("font_style") == "italic"
    fill       = _parse_color(el.get("fill", "black")) or (0, 0, 0)
    bg         = _parse_color(el.get("background_color", "transparent"))
    text_align = el.get("text_align", "left")
    vert_align = el.get("text_vert_align", "top")

    if bg:
        draw.rectangle([x, y, x + w, y + h], fill=bg)

    # Resolve display value
    field  = el.get("field")
    static = el.get("static_text")
    if static:
        text = str(static)
    elif field and field in ref_data:
        text = str(ref_data[field])
    elif field:
        text = f"[{field}]"
    else:
        text = ""

    if el.get("upper_case"):
        text = text.upper()
    elif el.get("lower_case"):
        text = text.lower()

    if not text:
        return

    font = _get_font(font_size, bold, italic)

    try:
        bbox = draw.textbbox((0, 0), text, font=font)
        tw   = bbox[2] - bbox[0]
        th   = bbox[3] - bbox[1]
    except Exception:
        tw = font_size * len(text) * 0.55
        th = font_size * 1.2

    # Horizontal position
    if text_align == "center":
        tx = x + (w - tw) / 2
    elif text_align == "right":
        tx = x + w - tw - 2
    else:
        tx = x + 2

    # Vertical position
    if vert_align == "middle":
        ty = y + (h - th) / 2
    elif vert_align == "bottom":
        ty = y + h - th - 2
    else:
        ty = y + 2

    draw.text((tx, ty), text, font=font, fill=fill)


def _draw_rect(draw: ImageDraw.ImageDraw, el: dict, scale: float):
    x  = el["x"] * scale
    y  = el["y"] * scale
    w  = el["width"] * scale
    h  = el["height"] * scale
    fill   = _parse_color(el.get("fill", "transparent"))
    stroke = _parse_color(el.get("stroke", "black"))
    sw     = max(1, round(el.get("stroke_width", 1) * scale))
    br     = round(el.get("border_radius", 0) * scale)

    if br > 0:
        draw.rounded_rectangle(
            [x, y, x + w, y + h], radius=br,
            fill=fill, outline=stroke, width=sw if stroke else 0,
        )
    else:
        draw.rectangle(
            [x, y, x + w, y + h],
            fill=fill, outline=stroke, width=sw if stroke else 0,
        )


def _draw_circle(draw: ImageDraw.ImageDraw, el: dict, scale: float):
    x  = el["x"] * scale
    y  = el["y"] * scale
    w  = el["width"] * scale
    h  = el["height"] * scale
    fill   = _parse_color(el.get("fill", "transparent"))
    stroke = _parse_color(el.get("stroke", "black"))
    sw     = max(1, round(el.get("stroke_width", 1) * scale))
    draw.ellipse([x, y, x + w, y + h], fill=fill, outline=stroke, width=sw if stroke else 0)


def _draw_line(draw: ImageDraw.ImageDraw, el: dict, scale: float):
    x1 = el.get("x1", 0) * scale
    y1 = el.get("y1", 0) * scale
    x2 = el.get("x2", 0) * scale
    y2 = el.get("y2", 0) * scale
    stroke = _parse_color(el.get("stroke", "black")) or (0, 0, 0)
    sw     = max(1, round(el.get("stroke_width", 1) * scale))
    draw.line([(x1, y1), (x2, y2)], fill=stroke, width=sw)


def _draw_barcode(draw: ImageDraw.ImageDraw, el: dict, scale: float):
    x = el["x"] * scale
    y = el["y"] * scale
    w = el["width"] * scale
    h = el["height"] * scale

    draw.rectangle([x, y, x + w, y + h], fill=(255, 255, 255), outline=(0, 0, 0), width=1)

    # Simulated barcode bars
    n_bars = max(10, round(w / (2.5 * scale)))
    bar_w  = w / (n_bars * 2)
    for i in range(n_bars):
        bx = x + i * 2 * bar_w
        draw.rectangle([bx, y + 1, bx + bar_w, y + h - 2], fill=(0, 0, 0))

    # Field label at bottom
    field = el.get("field", "BARCODE")
    fs    = max(6, round(7 * scale))
    try:
        font = _get_font(fs)
        draw.text((x + 2, y + h - fs - 2), field, font=font, fill=(80, 80, 80))
    except Exception:
        pass


def _draw_image_el(img: Image.Image, el: dict, logo: "Image.Image | None", scale: float):
    x = round(el["x"] * scale)
    y = round(el["y"] * scale)
    w = round(el["width"] * scale)
    h = round(el["height"] * scale)
    if w <= 0 or h <= 0:
        return

    if logo:
        resized = logo.resize((w, h), Image.LANCZOS)
        if resized.mode == "RGBA":
            img.paste(resized, (x, y), resized)
        else:
            img.paste(resized, (x, y))
    else:
        draw = ImageDraw.Draw(img)
        draw.rectangle([x, y, x + w, y + h], fill=(230, 230, 230), outline=(180, 180, 180), width=1)
        try:
            font = _get_font(max(8, round(9 * scale)))
            draw.text((x + 4, y + 4), "LOGO", font=font, fill=(150, 150, 150))
        except Exception:
            pass


# ── Main entry point ──────────────────────────────────────────────────────────

def render_preview(
    layout: dict,
    ref_data: dict | None = None,
    logo: "Image.Image | None" = None,
    scale: float | None = None,
) -> Image.Image:
    """
    Render a layout spec dict as a PIL RGB Image.

    Args:
        layout:   Layout spec produced by ESLGenerator.generate().
        ref_data: Mapping of field_name → sample value string.
        logo:     Optional dithered logo image; used for 'image' type elements.
        scale:    Pixel multiplier.  Auto-computed to target ~800 px width if None.

    Returns:
        PIL Image (RGB).
    """
    if ref_data is None:
        ref_data = {}

    canvas = layout["canvas"]
    cw, ch = canvas["width"], canvas["height"]

    # Auto-scale: target ~800px wide, clamped to [1.5 × , 4.0 ×]
    if scale is None:
        scale = min(4.0, max(1.5, 800 / max(cw, 1)))

    w  = round(cw * scale)
    h  = round(ch * scale)
    bg = _parse_color(canvas.get("background_color", "#FFFFFF")) or (255, 255, 255)

    img  = Image.new("RGB", (w, h), bg)
    draw = ImageDraw.Draw(img)

    # Subtle border to delineate the label boundary
    draw.rectangle([0, 0, w - 1, h - 1], outline=(180, 180, 180), width=max(1, round(scale * 0.4)))

    for el in layout.get("elements", []):
        etype = el.get("type")
        try:
            if etype == "textbox":
                _draw_textbox(draw, el, ref_data, scale)
            elif etype in ("rect", "rounded_rect"):
                _draw_rect(draw, el, scale)
            elif etype == "circle":
                _draw_circle(draw, el, scale)
            elif etype == "line":
                _draw_line(draw, el, scale)
            elif etype == "barcode":
                _draw_barcode(draw, el, scale)
            elif etype == "image":
                _draw_image_el(img, el, logo, scale)
        except Exception as e:
            print(f"[preview_renderer] skipping element type={etype!r}: {e}")

    return img
