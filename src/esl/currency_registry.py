"""
src/esl/currency_registry.py
-----------------------------
Currency registry derived from Solum designer currency data.

Each entry captures:
  icon          — the currency symbol character(s)
  decimal_sep   — decimal separator used in price display ('.' or ',')
  thousand_sep  — thousand grouping separator (',' or '.')
  indian        — True for INR grouping (lakhs/crores)
  formats       — list of supported currencyFormatType codes

Format visual guide:
  format1   12.34 ¤         value·decimal·symbol-superscript-after
  format2   12^34 ¤         large-whole·superscript-cents·symbol-after
  format3   ¤ 12.34         symbol·space·value  (or value symbol for some)
  format4   ¤12.^34        superscript-symbol-before·whole·small-cents
  format5   ¤ 12.34         symbol·space·value  (USD prefix style)
  format6   12,34 ¤         European value·decimal·symbol (no-sign variant)
  format7   12^34           split-no-symbol  (None currency)
  format8   ^¤12,^34        superscript-symbol·whole·superscript-cents (EU)
  format9   12,^34          European split-no-symbol
  format10  12.^34          split-no-symbol with period decimal
  format11  ¤ 12.34         symbol·space·value (GBP/EUR/JPY/KRW prefix)
  format12  ^¤12^.56        superscript-symbol·large-whole·superscript-cents
"""

# ── Currency registry ───────────────────────────────────────────────────────

CURRENCY_REGISTRY: dict[str, dict] = {
    "USD": {
        "name": "US Dollar",
        "icon": "$",
        "decimal_sep": ".",
        "thousand_sep": ",",
        "indian": False,
        "formats": ["format1", "format2", "format3", "format4", "format5", "format12"],
    },
    "GBP": {
        "name": "Great British Pound",
        "icon": "£",
        "decimal_sep": ".",
        "thousand_sep": ",",
        "indian": False,
        "formats": ["format1", "format2", "format3", "format4", "format11", "format12"],
    },
    "EUR": {
        "name": "Euro",
        "icon": "€",
        "decimal_sep": ",",
        "thousand_sep": ".",
        "indian": False,
        "formats": ["format1", "format2", "format3", "format4", "format11", "format12"],
    },
    "JPY": {
        "name": "Japan Yen",
        "icon": "¥",
        "decimal_sep": ".",
        "thousand_sep": ",",
        "indian": False,
        "formats": ["format1", "format2", "format3", "format4", "format11", "format12"],
    },
    "CNY": {
        "name": "Chinese Yuan",
        "icon": "¥",
        "decimal_sep": ".",
        "thousand_sep": ",",
        "indian": False,
        "formats": ["format1", "format2", "format3", "format4", "format11", "format12"],
    },
    "KRW": {
        "name": "Korean Won",
        "icon": "₩",
        "decimal_sep": ".",
        "thousand_sep": ",",
        "indian": False,
        "formats": ["format1", "format2", "format3", "format4", "format11", "format12"],
    },
    "INR": {
        "name": "Indian Rupee",
        "icon": "₹",
        "decimal_sep": ".",
        "thousand_sep": ",",
        "indian": True,
        "formats": ["format1", "format2", "format3", "format4", "format11", "format12"],
    },
    "VND": {
        "name": "Vietnamese Dong",
        "icon": "₫",
        "decimal_sep": ",",
        "thousand_sep": ".",
        "indian": False,
        "formats": ["format1", "format2", "format3", "format4", "format11", "format12"],
    },
    "TRY": {
        "name": "Turkish Lira",
        "icon": "₺",
        "decimal_sep": ",",
        "thousand_sep": ".",
        "indian": False,
        "formats": ["format1", "format2", "format3", "format4", "format11", "format12"],
    },
    "PC": {
        "name": "Peso Chileno",
        "icon": "$",
        "decimal_sep": ".",
        "thousand_sep": ".",
        "indian": False,
        "formats": ["format1", "format3", "format4", "format11", "format12"],
    },
    "LA": {
        "name": "Latin America Dollar",
        "icon": "$",
        "decimal_sep": ",",
        "thousand_sep": ".",
        "indian": False,
        "formats": ["format1", "format2", "format3", "format4", "format11", "format12"],
    },
    "Rp":  {"name": "Indonesian Rupiah",   "icon": "Rp", "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "CR":  {"name": "Cambodian Riel",       "icon": "៛",  "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "Ft":  {"name": "Hungarian Forint",     "icon": "Ft", "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "THB": {"name": "Thai Baht",            "icon": "฿",  "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "ILS": {"name": "Israeli Shekel",       "icon": "₪",  "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "TWD": {"name": "Taiwan Dollar",        "icon": "元", "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "PLN": {"name": "Polish Zloty",         "icon": "zł", "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "UAH": {"name": "Ukrainian Hryvnia",    "icon": "грн","decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "YEN": {"name": "Japanese Yen (alt)",   "icon": "円", "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "BRL": {"name": "Brazilian Real",       "icon": "R$", "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "SAR": {"name": "Saudi Riyal",          "icon": "﷼",  "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "MYR": {"name": "Malaysian Ringgit",    "icon": "RM", "decimal_sep": ".", "thousand_sep": ",", "indian": False, "formats": []},
    "None":{"name": "No currency sign",     "icon": "",   "decimal_sep": ".", "thousand_sep": ",", "indian": False,
            "formats": ["format1", "format2", "format4", "format5", "format6", "format7", "format8", "format9", "format10", "format12"]},
}

# Currencies that use European-style separators (comma decimal, period thousands)
EURO_STYLE_CURRENCIES: frozenset[str] = frozenset(
    code for code, info in CURRENCY_REGISTRY.items()
    if info["decimal_sep"] == ","
)


def get_currency(code: str) -> dict | None:
    """Return registry entry for a currency code, or None if not found."""
    return CURRENCY_REGISTRY.get(code)


def default_format(code: str) -> str:
    """Return the first available format for a currency, or empty string."""
    entry = CURRENCY_REGISTRY.get(code, {})
    formats = entry.get("formats", [])
    return formats[0] if formats else ""


def valid_currency_codes() -> list[str]:
    return list(CURRENCY_REGISTRY.keys())
