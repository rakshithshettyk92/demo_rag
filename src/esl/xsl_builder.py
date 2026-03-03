"""
src/esl/xsl_builder.py
-----------------------
Deterministic converter: layout spec dict → Solum-compatible XSL string.

The XSL is assembled from three parts:
  1. Generated header   — stylesheet declaration + per-field XSL variables + FO page setup
  2. Generated SVG body — one <g> per textbox/rect, FO block-container per barcode
  3. Static helpers     — the 8000-line wordwrap/currency/barcode helper templates
                          (identical across all templates, extracted once from Solum designer output)
"""

import os
import math
import time

# Path to extracted static helper templates
_HELPERS_PATH = os.path.join(os.path.dirname(__file__), "static", "xsl_helpers.xsl")


def _load_helpers() -> str:
    with open(_HELPERS_PATH, "r", encoding="utf-8") as f:
        return f.read()


# ── Coordinate helpers ─────────────────────────────────────────────────────

def _cx(el) -> int:
    return round(el["x"] + el["width"] / 2)

def _cy(el) -> int:
    return round(el["y"] + el["height"] / 2)

def _half_w(el) -> int:
    return round(el["width"] / 2)

def _half_h(el) -> int:
    return round(el["height"] / 2)

def _text_anchor(align: str) -> str:
    return {"left": "start", "center": "middle", "right": "end"}.get(align, "start")

def _tspan_x(el) -> int:
    """Horizontal start of text relative to group center."""
    align = el.get("text_align", "left")
    if align == "center":
        return 0
    elif align == "right":
        return _half_w(el)
    else:  # left
        return -_half_w(el)

def _font_weight_f(fw: str) -> str:
    return "2.0f" if fw == "bold" else "1.0f"

def _font_style_f(fs: str) -> str:
    return "1.0f" if fs == "italic" else "0.0f"

def _line_height(font_size: int) -> float:
    return round(font_size * 1.3108, 4)

def _text_line_height(font_size: int) -> int:
    return round(font_size * 1.13)

def _var_name(field_name: str) -> str:
    """Convert FIELD_NAME to xsl variable name: field_name_1_1"""
    return field_name.lower() + "_1_1"

def _fill_to_rgb(fill: str) -> str:
    """Convert hex fill to rgb() string for SVG."""
    if fill == "transparent" or not fill:
        return "rgb(255,255,255)"
    fill = fill.lstrip("#")
    r, g, b = int(fill[0:2], 16), int(fill[2:4], 16), int(fill[4:6], 16)
    return f"rgb({r},{g},{b})"

def _fill_to_hex(fill: str) -> str:
    """Ensure fill is uppercase hex with #."""
    if not fill or fill == "transparent":
        return "#000000"
    return fill.upper() if fill.startswith("#") else f"#{fill.upper()}"


# ── Part 1: XSL header ─────────────────────────────────────────────────────

_XSL_HEADER = '''\
<?xml version="1.0" encoding="utf-8"?><xsl:stylesheet version="1.1" \
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" \
xmlns:fo="http://www.w3.org/1999/XSL/Format" \
xmlns:ext="http://exslt.org/common" \
xmlns:svg="http://www.w3.org/2000/svg" \
xmlns:dgext="xalan://com.diatoz.graphics.GraphicsUtils" \
exclude-result-prefixes="fo">\
<xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"/>\
<xsl:param name="versionParam" select="1.0"/>\
<xsl:decimal-format name="euro" decimal-separator="," grouping-separator="." NaN="0"/>\
<xsl:decimal-format name="usa" decimal-separator="." grouping-separator="," NaN="0"/>\
<xsl:variable name="uppercase" select="\'ABCDEFGHIJKLMNOPQRSTUVWXYZ\'"/>\
<xsl:variable name="smallcase" select="\'abcdefghijklmnopqrstuvwxyz\'"/>\
<xsl:variable name="FORCED_NL_TOKEN" select="\'__FORCED_NL__\'"/>'''


def _build_variables(elements: list) -> str:
    """Generate <xsl:variable> declarations for all dynamic field references."""
    seen = set()
    lines = ["<!-- Define variables -->"]
    for el in elements:
        field = el.get("field")
        if field and el.get("static_text") is None and field not in seen:
            seen.add(field)
            var = _var_name(field)
            lines.append(
                f'<xsl:variable name="{var}" '
                f'select="articles/article[@index=1]/data/{field}"/>'
            )
    return "".join(lines)


# ── Part 2: SVG element builders ───────────────────────────────────────────

def _build_textbox_svg(el: dict, element_id: int) -> str:
    cx, cy = _cx(el), _cy(el)
    hw, hh = _half_w(el), _half_h(el)
    font_size = el.get("font_size", 14)
    font_family = el.get("font_family", "Arial")
    font_weight = el.get("font_weight", "normal")
    font_style = el.get("font_style", "normal")
    text_align = el.get("text_align", "left")
    text_vert_align = el.get("text_vert_align", "top")
    fill_color = _fill_to_rgb(el.get("fill", "#000000"))
    fit_text = str(el.get("fit_text", False)).lower()

    fw_str = "bold" if font_weight == "bold" else ""
    style = (
        "stroke: none; stroke-width: 1; stroke-dasharray: none; "
        "stroke-linecap: butt; stroke-linejoin: miter; stroke-miterlimit: 4; "
        f"fill: {fill_color}; fill-rule: nonzero;  white-space: pre;"
    )

    # Dynamic field or static text
    field = el.get("field")
    static_text = el.get("static_text")

    if static_text:
        # Static label — no XSL variable, just a value
        product_field_value = f'"{static_text}"'
        value_attr = f'select="{static_text}"'
    else:
        var = _var_name(field)
        value_attr = f'select="${var}"'

    fw_bold_attr = f' font-weight="{fw_str}"' if fw_str else ""
    fi_italic_attr = ' font-style="italic"' if font_style == "italic" else ""

    q = "&quot;"

    lines = [
        f'\n\t<g id="{element_id}" transform="translate({cx} {cy})">',
        f'\t\t<rect opacity="0" fill="rgb(255,255,255)" x="-{hw}" y="-{hh}" width="{el["width"]}" height="{el["height"]}"></rect>',
        f'\t\t<text id="0" xml:space="preserve" font-family="\'{font_family}\'" font-size="{font_size}" '
        f'letter-spacing="0em"{fw_bold_attr}{fi_italic_attr} style="{style}" text-rendering="optimizeLegibility">'
        f'<xsl:call-template name="wordwrap">',
        f'          \n<xsl:with-param name="productFieldValue" {value_attr}></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyPosition" select="{q}start{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencySign" select="{q}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyFormat" select="{q}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyFormatType" select="{q}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyCode" select="{q}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="textAnchor" select="{q}{_text_anchor(text_align)}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="fontFamily" select="{q}{font_family}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="fontWeight" select="{_font_weight_f(font_weight)}"></xsl:with-param>',
        f'         \n<xsl:with-param name="fontStyle" select="{_font_style_f(font_style)}"></xsl:with-param>',
        f'         \n<xsl:with-param name="fontSize" select="{font_size}"></xsl:with-param>',
        f'         \n<xsl:with-param name="textWidth" select="{el["width"]}"></xsl:with-param>',
        f'         \n<xsl:with-param name="textHeight" select="{el["height"]}"></xsl:with-param>',
        f'         \n<xsl:with-param name="lineHeight" select="{_line_height(font_size)}"></xsl:with-param>',
        f'         \n<xsl:with-param name="textLineHeight" select="{_text_line_height(font_size)}"></xsl:with-param>',
        f'         \n<xsl:with-param name="tspanX" select="{_tspan_x(el)}"></xsl:with-param>',
        f'         \n<xsl:with-param name="tspanY" select="1.0"></xsl:with-param>',
        f'         \n<xsl:with-param name="textVertAlign" select="{q}{text_vert_align}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="zeroformatEnabled" select="{q}true{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="isToApplyUpperCase" select="{q}false{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="isToApplyLowerCase" select="{q}false{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="letterSpacing" select="{q}0{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="hideFieldByDefault" select="{q}false{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="customCurrencyThousandSeparator" select="{q}true{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencySignDisplacementRatioWithFontSizeX" select="{q}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencySignDisplacementRatioWithFontSizeY" select="{q}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyIsDecimalSeperatorVisible" select="{q}true{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeX" select="{q}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyDecimalSeperatorDisplacementRatioWithFontSizeY" select="{q}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyIsDecimalPortionVisible" select="{q}true{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeX" select="{q}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyDecimalPortionDisplacementRatioWithFontSizeY" select="{q}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="isCustomCurrencyFormat" select="{q}false{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencySizeRatioWithFontSize" select="{q}1{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyDecimalSeperatorSizeRatioWithFontSize" select="{q}1{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="currencyDecimalPortionSizeRatioWithFontSize" select="{q}1{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="isScalingTextFit" select="{q}{fit_text}{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="isScalingTextFitUpscalingAllowed" select="{q}false{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="isSplitting" select="{q}false{q}"></xsl:with-param>',
        f'         \n<xsl:with-param name="splitBy" select="{q}{q}"></xsl:with-param>',
        f'          \n</xsl:call-template></text>',
        '\t</g>',
    ]
    return "".join(lines)


def _build_rect_svg(el: dict, element_id: int) -> str:
    cx, cy = _cx(el), _cy(el)
    hw, hh = _half_w(el), _half_h(el)
    fill = el.get("fill", "transparent")
    stroke = el.get("stroke", "#000000")
    stroke_width = el.get("stroke_width", 1)

    svg_fill = "none" if fill == "transparent" else fill
    return (
        f'\n\t<g id="{element_id}" transform="translate({cx} {cy})">'
        f'\n\t\t<rect x="-{hw}" y="-{hh}" width="{el["width"]}" height="{el["height"]}" '
        f'fill="{svg_fill}" stroke="{stroke}" stroke-width="{stroke_width}"></rect>'
        f'\n\t</g>'
    )


def _build_barcode_fo(el: dict) -> str:
    """Generate Apache FOP barcode4j block-container (outside the SVG)."""
    field = el.get("field", "ITEM_ID")
    var = _var_name(field)
    x = el.get("x", 0)
    y = el.get("y", 0)
    w = el.get("width", 160)
    h = el.get("height", 18)
    # Convert px height to mm (approx: 1px ≈ 0.2646mm at 96dpi)
    h_mm = round(h * 0.2646, 1)

    return (
        f'<fo:block-container position="absolute" reference-orientation="0" '
        f' top="{y}px" left="{x}px">'
        f'<fo:block text-align=\'left\' line-height=\'0.9\'>'
        f'<xsl:if test="${var}!= \'\'">'
        f'<fo:instream-foreign-object background-color=\'white\'>'
        f'<barcode:barcode xmlns:barcode="http://barcode4j.krysalis.org/ns" '
        f'message="{{{var}}}" orientation="">'
        f'<barcode:code128>'
        f'<barcode:height>{h_mm}mm</barcode:height>'
        f'<barcode:quiet-zone enabled="false">10mw</barcode:quiet-zone>'
        f'<barcode:module-width>1pt</barcode:module-width>'
        f'<barcode:wide-factor>4</barcode:wide-factor>'
        f'<barcode:human-readable><barcode:placement>none</barcode:placement></barcode:human-readable>'
        f'<barcode:encoding>UTF-8</barcode:encoding>'
        f'</barcode:code128></barcode:barcode>'
        f'</fo:instream-foreign-object></xsl:if>'
        f'</fo:block></fo:block-container>'
    )


# ── Main builder ───────────────────────────────────────────────────────────

def build_xsl(layout: dict) -> str:
    """
    Convert a layout spec dict into a complete Solum-compatible XSL string.

    Args:
        layout: dict as produced by ESLGenerator.generate()

    Returns:
        Complete XSL string ready to be saved as a .xsl file
    """
    canvas = layout["canvas"]
    width = canvas["width"]
    height = canvas["height"]
    bg_color = canvas.get("background_color", "#FFFFFF").upper()
    elements = layout["elements"]

    # Assign unique numeric IDs to each element
    base_id = int(time.time() * 1000)

    # ── Part 1: Header + variables ─────────────────────────────────────────
    header = _XSL_HEADER
    variables = _build_variables(elements)

    # ── Part 2: Main template — FO page + SVG + barcodes ──────────────────
    svg_elements = []
    fo_barcodes = []

    for i, el in enumerate(elements):
        eid = base_id + i
        etype = el.get("type")
        if etype == "textbox":
            svg_elements.append(_build_textbox_svg(el, eid))
        elif etype == "rect":
            svg_elements.append(_build_rect_svg(el, eid))
        elif etype == "barcode":
            fo_barcodes.append(_build_barcode_fo(el))

    svg_body = "".join(svg_elements)
    barcode_body = "".join(fo_barcodes)

    main_template = (
        f'<xsl:template match="articles[@page=1]">'
        f'<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">'
        f'<fo:layout-master-set>'
        f'<fo:simple-page-master master-name="simpleA4" '
        f'page-height="{height}px" page-width="{width}px">'
        f'<fo:region-body/></fo:simple-page-master>'
        f'</fo:layout-master-set>'
        f'<fo:page-sequence master-reference="simpleA4">'
        f'<fo:flow flow-name="xsl-region-body">'
        f'<fo:block-container position="absolute" overflow="hidden" '
        f'width="{width}px" height="{height}px" top="0px" left="0px" '
        f'color="#000000" background-color="{bg_color}">'
        f'<fo:block line-height="0.9">'
        f'<fo:instream-foreign-object>'
        f'<svg xmlns="http://www.w3.org/2000/svg" '
        f'xmlns:xlink="http://www.w3.org/1999/xlink" '
        f'version="1.1" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" xml:space="preserve">'
        f'\n\n\n'
        f'{svg_body}'
        f'\n</svg>'
        f'</fo:instream-foreign-object></fo:block></fo:block-container>'
        f'{barcode_body}'
        f'</fo:flow></fo:page-sequence></fo:root></xsl:template>'
    )

    # ── Part 3: Static helper templates ────────────────────────────────────
    helpers = _load_helpers()

    return header + variables + main_template + helpers
