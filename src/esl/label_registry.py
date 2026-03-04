"""
src/esl/label_registry.py
--------------------------
Complete Solum ESL label size registry, built from the idlabeltype dataset.

Each entry key matches the Solum dimension string exactly.
Values provide everything needed by the generator, XSL builder, and Fabric JSON builder.
"""

# ── Color support type → available color names ──────────────────────────────

COLOR_SUPPORT_TYPES: dict[str, list[str]] = {
    "BINARY":  ["transparent", "black", "white"],
    "RED":     ["transparent", "black", "white", "red"],
    "YELLOW":  ["transparent", "black", "white", "yellow"],
    "PINK":    ["transparent", "black", "white", "pink"],
    "4_COLOR": ["transparent", "black", "white", "red", "yellow"],
    "5_COLOR": ["transparent", "black", "white", "red", "yellow", "orange"],
    "4C_O_GY": ["transparent", "black", "white", "red", "yellow", "orange", "gray"],
    "6_COLOR": ["transparent", "black", "white", "green", "blue", "red", "yellow"],
    "7_COLOR": ["transparent", "black", "white", "red", "yellow", "orange", "blue", "green"],
}

# Richest → most capable color type (used to pick the design default)
_COLOR_PRIORITY = [
    "7_COLOR", "6_COLOR", "5_COLOR", "4C_O_GY",
    "4_COLOR", "PINK", "YELLOW", "RED", "BINARY",
]


def best_color_type(color_types: list[str]) -> str:
    """Return the richest color type from a supported list."""
    for ct in _COLOR_PRIORITY:
        if ct in color_types:
            return ct
    return color_types[0] if color_types else "4_COLOR"


# ── Label registry ──────────────────────────────────────────────────────────
# Key  = dimension string shown in the Solum UI / used as dropdown key
# label = layoutDeviceName used inside XSL / Fabric JSON
# orientation ∈ {landscape, portrait, square}

def _e(label, w, h, dpi, colors, pages, svg_type):
    """Build a registry entry."""
    ori_map = {
        "normalLandscape": "landscape",
        "bigLandscape":    "landscape",
        "normalPortrait":  "portrait",
        "bigPortrait":     "portrait",
        "sqLayout":        "square",
    }
    return {
        "label":       label,
        "width":       w,
        "height":      h,
        "dpi":         dpi,
        "color_types": colors,
        "best_color":  best_color_type(colors),
        "pages":       pages,
        "orientation": ori_map.get(svg_type, "landscape"),
        "svg_type":    svg_type,
    }


LABEL_REGISTRY: dict[str, dict] = {
    '0.97" : 184 X 88':    _e("0.97",          184,  88,  210, ["BINARY","RED","YELLOW"],                                       3, "normalLandscape"),
    '1.3" : 200 X 144':    _e("1.3",            200, 144,  153, ["BINARY","RED","YELLOW"],                                       7, "normalLandscape"),
    '1.3_Vertical" : 144 X 200': _e("1.3_Vertical", 144, 200, 153, ["BINARY","RED","YELLOW","4_COLOR"],                          7, "normalPortrait"),
    '1.3_4C" : 200 X 144': _e("1.3_4C",         200, 144,  188, ["RED","4_COLOR"],                                               7, "normalLandscape"),
    '1.54" : 200 X 200':   _e("1.54",           200, 200,  184, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "sqLayout"),
    '1.6" : 152 X 152':    _e("1.6",            152, 152,   91, ["BINARY","RED","YELLOW"],                                       3, "sqLayout"),
    '1.6" : 168 X 168':    _e("1.6",            168, 168,  144, ["4_COLOR","5_COLOR"],                                           7, "sqLayout"),
    '1.6_HD" : 200 X 200': _e("1.6_HD",         200, 200,  184, ["BINARY","RED","YELLOW","PINK","4_COLOR"],                      7, "sqLayout"),
    '2.0_4C" : 152 X 200': _e("2.0_4C",         152, 200,  130, ["4_COLOR"],                                                    7, "normalLandscape"),
    '2.1_4C" : 248 X 128': _e("2.1_4C",         248, 128,  270, ["4_COLOR"],                                                    7, "bigLandscape"),
    '2.13" : 250 X 122':   _e("2.13",           250, 122,  130, ["BINARY","RED","YELLOW","4_COLOR"],                             3, "sqLayout"),
    '2.15" : 296 X 160':   _e("2.15",           296, 160,  156, ["BINARY","RED","YELLOW","PINK","4_COLOR"],                      7, "normalLandscape"),
    '2.2" : 212 X 104':    _e("2.2",            212, 104,  111, ["BINARY","RED","YELLOW"],                                       3, "normalLandscape"),
    '2.2" : 250 X 122':    _e("2.2",            250, 122,  130, ["BINARY","RED","YELLOW"],                                       7, "normalLandscape"),
    '2.2_HD" : 296 X 160': _e("2.2_HD",         296, 160,  111, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalLandscape"),
    '2.4" : 296 X 168':    _e("2.4",            296, 168,  144, ["4_COLOR","5_COLOR"],                                           7, "normalLandscape"),
    '2.5_4C" : 296 X 152': _e("2.5_4C",         296, 152,  270, ["4_COLOR"],                                                    7, "bigLandscape"),
    '2.6" : 296 X 152':    _e("2.6",            296, 152,  125, ["BINARY","RED","YELLOW"],                                       3, "normalLandscape"),
    '2.6_Vertical" : 152 X 296': _e("2.6_Vertical", 152, 296, 125, ["BINARY","RED","YELLOW"],                                   3, "normalPortrait"),
    '2.6_HD" : 360 X 184': _e("2.6_HD",         360, 184,  152, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalLandscape"),
    '2.66" : 360 X 184':   _e("2.66",           360, 184,  152, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalLandscape"),
    '2.7" : 264 X 176':    _e("2.7",            264, 176,  117, ["BINARY","RED","YELLOW"],                                       3, "normalLandscape"),
    '2.7_HD" : 300 X 200': _e("2.7_HD",         300, 200,  133, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalLandscape"),
    '2.8_4C" : 296 X 128': _e("2.8_4C",         296, 128,  270, ["4_COLOR"],                                                    7, "bigLandscape"),
    '2.9" : 296 X 128':    _e("2.9",            296, 128,  112, ["BINARY","RED","YELLOW"],                                       7, "normalLandscape"),
    '2.9_4C" : 296 X 128': _e("2.9_4C",         296, 128,  111, ["4_COLOR"],                                                    7, "normalLandscape"),
    '2.9_HD" : 384 X 168': _e("2.9_HD",         384, 168,  144, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalLandscape"),
    '3.0" : 400 X 168':    _e("3.0",            400, 168,  144, ["4_COLOR","5_COLOR"],                                           7, "normalLandscape"),
    '3.3" : 300 X 200':    _e("3.3",            300, 200,  110, ["BINARY","RED","YELLOW"],                                       3, "normalLandscape"),
    '3.5" : 384 X 180':    _e("3.5",            384, 180,  120, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalLandscape"),
    '3.5_MD" : 480 X 224': _e("3.5_MD",         480, 224,  155, ["4_COLOR"],                                                    7, "normalLandscape"),
    '3.5_MD_FREEZER" : 480 X 224': _e("3.5_MD_FREEZER", 480, 224, 153, ["BINARY"],                                              7, "normalLandscape"),
    '3.7" : 240 X 416':    _e("3.7",            240, 416,  129, ["BINARY","RED","YELLOW"],                                       7, "normalPortrait"),
    '4.0_6C" : 600 X 400': _e("4.0_6C",         600, 400,  180, ["6_COLOR"],                                                    7, "normalLandscape"),
    '4.2" : 400 X 300':    _e("4.2",            400, 300,  120, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalLandscape"),
    '4.3" : 522 X 152':    _e("4.3",            522, 152,  125, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalLandscape"),
    '4.3_Vertical" : 152 X 522': _e("4.3_Vertical", 152, 522, 125, ["BINARY","RED","YELLOW"],                                   7, "normalLandscape"),
    '4.4" : 512 X 368':    _e("4.4",            512, 368,  144, ["4_COLOR","5_COLOR"],                                           7, "normalLandscape"),
    '4.5" : 480 X 176':    _e("4.5",            480, 176,  117, ["BINARY","4_COLOR"],                                            7, "normalLandscape"),
    '5.7" : 600 X 200':    _e("5.7",            600, 200,  110, ["BINARY","RED","YELLOW"],                                       3, "normalLandscape"),
    '5.79" : 792 X 272':   _e("5.79",           792, 272,  145, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalLandscape"),
    '5.85" : 792 X 272':   _e("5.85",           792, 272,  145, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalLandscape"),
    '6.0" : 600 X 448':    _e("6.0",            600, 448,  132, ["BINARY","RED","YELLOW","4_COLOR","7_COLOR"],                   7, "normalLandscape"),
    '6.0_NEW" : 648 X 480':_e("6.0_NEW",        648, 480,  138, ["BINARY","RED","YELLOW"],                                       3, "normalLandscape"),
    '6.0_HD" : 1024 X 758':_e("6.0_HD",        1024, 758,  212, ["BINARY"],                                                     3, "bigLandscape"),
    '6.1" : 648 X 480':    _e("6.1",            648, 480,  138, ["4_COLOR"],                                                    7, "normalLandscape"),
    '7.3" : 480 X 800':    _e("7.3",            480, 800,  144, ["BINARY","RED","YELLOW","4_COLOR","5_COLOR","7_COLOR"],          7, "normalPortrait"),
    '7.3_6C" : 480 X 800': _e("7.3_6C",         480, 800,  127, ["6_COLOR"],                                                    7, "normalPortrait"),
    '7.4" : 480 X 800':    _e("7.4",            480, 800,  126, ["BINARY","RED","YELLOW","4_COLOR","5_COLOR","7_COLOR"],          3, "normalPortrait"),
    '7.5" : 384 X 640':    _e("7.5",            384, 640,  100, ["BINARY","RED","YELLOW"],                                       3, "normalPortrait"),
    '7.5_HD" : 528 X 880': _e("7.5_HD",         528, 880,  137, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalPortrait"),
    '7.5_HR" : 480 X 800': _e("7.5_HR",         480, 800,  126, ["BINARY","RED","YELLOW","4_COLOR","5_COLOR","7_COLOR"],          7, "normalPortrait"),
    '8.2" : 576 X 1024':   _e("8.2",            576,1024,  144, ["4_COLOR","5_COLOR","6_COLOR"],                                 3, "bigPortrait"),
    '9.7" : 672 X 960':    _e("9.7",            672, 960,  121, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "normalPortrait"),
    '9.7_6C" : 784 X 1120':_e("9.7_6C",         784,1120,  141, ["6_COLOR"],                                                    3, "normalPortrait"),
    '11.6" : 640 X 960':   _e("11.6 ",          640, 960,  100, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "bigPortrait"),
    '12.2" : 768 X 960':   _e("12.2",           768, 960,  103, ["BINARY","RED","YELLOW","4_COLOR"],                             7, "bigPortrait"),
    '13.3" : 1200 X 1600': _e("13.3",          1200,1600,  150, ["BINARY","RED","YELLOW","6_COLOR"],                             3, "bigPortrait"),
    '32_6C" : 2560 X 1440':_e("32_6C",         2560,1440,   94, ["6_COLOR"],                                                    3, "bigLandscape"),
}

# Default label key (most commonly used 2.5" 4-colour label)
DEFAULT_LABEL_KEY = '2.5_4C" : 296 X 152'


# ── Helper functions ─────────────────────────────────────────────────────────

def all_label_keys() -> list[str]:
    """Return all label dimension keys sorted by size (landscape first)."""
    return list(LABEL_REGISTRY.keys())


def get_label(key: str) -> dict | None:
    return LABEL_REGISTRY.get(key)


def available_colors(key: str) -> list[str]:
    """Return the list of renderable color names for a given label key."""
    info = LABEL_REGISTRY.get(key, {})
    color_type = info.get("best_color", "4_COLOR")
    return COLOR_SUPPORT_TYPES.get(color_type, ["transparent", "black", "white"])


def font_size_guide(height_px: int) -> str:
    """Return a brief font-size guidance string scaled to the label height."""
    if height_px < 130:
        return "price 16-24pt, text 8-13pt, label 7-10pt"
    elif height_px < 200:
        return "price 24-40pt, text 10-18pt, label 8-12pt"
    elif height_px < 400:
        return "price 36-60pt, text 14-24pt, label 10-16pt"
    elif height_px < 800:
        return "price 48-80pt, text 18-32pt, label 12-20pt"
    else:
        return "price 64-120pt, text 24-48pt, label 16-28pt"
