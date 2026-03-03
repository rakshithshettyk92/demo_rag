"""
src/esl/profile_store.py
-------------------------
Manages company field-mapping profiles for the ESL template generator.

Each profile is stored as:
    src/esl/profiles/{COMPANY_CODE}.json

Profile file format:
    {
        "company_code": "ACME",
        "company_name": "ACME Corp",          # optional display name
        "saved_at": "2026-03-03T10:00:00",
        "fields": {
            "PROD_DESC": "string",
            "SELL_PRICE": "decimal",
            "ITEM_NO": "string",
            ...
        }
    }
"""

import json
import os
import re
from datetime import datetime

_PROFILES_DIR = os.path.join(os.path.dirname(__file__), "profiles")


def _ensure_dir():
    os.makedirs(_PROFILES_DIR, exist_ok=True)


def _profile_path(company_code: str) -> str:
    return os.path.join(_PROFILES_DIR, f"{company_code.upper()}.json")


def _validate_code(company_code: str):
    code = company_code.strip().upper()
    if not code:
        raise ValueError("Company code cannot be empty.")
    if not re.match(r'^[A-Z0-9_\-]{1,20}$', code):
        raise ValueError(
            "Company code must be 1–20 characters: letters, digits, _ or - only."
        )
    return code


# ── Public API ─────────────────────────────────────────────────────────────

def save_profile(company_code: str, fields_json: str, company_name: str = "") -> str:
    """
    Save a field mapping profile for a company.

    Args:
        company_code:  short identifier, e.g. "ACME" or "RETAILCO_SAP"
        fields_json:   JSON string of product fields
        company_name:  optional human-readable name

    Returns:
        Success message string.
    Raises:
        ValueError on bad input.
    """
    code = _validate_code(company_code)

    try:
        fields = json.loads(fields_json)
        if not isinstance(fields, dict):
            raise ValueError("Fields must be a JSON object { \"FIELD\": \"type\", ... }")
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON: {e}") from e

    _ensure_dir()

    profile = {
        "company_code": code,
        "company_name": company_name.strip() or code,
        "saved_at": datetime.now().isoformat(timespec="seconds"),
        "fields": fields,
    }

    with open(_profile_path(code), "w", encoding="utf-8") as f:
        json.dump(profile, f, indent=2, ensure_ascii=False)

    return f"Profile saved for {code}"


def load_profile(company_code: str) -> dict:
    """
    Load a saved profile.

    Returns:
        Profile dict with keys: company_code, company_name, saved_at, fields
    Raises:
        FileNotFoundError if the code doesn't exist.
    """
    code = _validate_code(company_code)
    path = _profile_path(code)
    if not os.path.exists(path):
        raise FileNotFoundError(f"No profile found for company code: {code}")
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def list_profiles() -> list[dict]:
    """
    Return all saved profiles as a list, sorted by company_code.

    Each item: { company_code, company_name, saved_at, field_count }
    """
    _ensure_dir()
    profiles = []
    for fname in sorted(os.listdir(_PROFILES_DIR)):
        if not fname.endswith(".json"):
            continue
        try:
            with open(os.path.join(_PROFILES_DIR, fname), "r", encoding="utf-8") as f:
                p = json.load(f)
            profiles.append({
                "company_code": p.get("company_code", fname[:-5]),
                "company_name": p.get("company_name", ""),
                "saved_at":     p.get("saved_at", ""),
                "field_count":  len(p.get("fields", {})),
            })
        except Exception:
            continue
    return profiles


def list_profile_choices() -> list[str]:
    """
    Return choices for a Gradio dropdown.
    Format: "ACME — ACME Corp  (7 fields)"
    """
    choices = []
    for p in list_profiles():
        label = p["company_code"]
        if p["company_name"] and p["company_name"] != p["company_code"]:
            label += f"  —  {p['company_name']}"
        label += f"  ({p['field_count']} fields)"
        choices.append(label)
    return choices


def delete_profile(company_code: str) -> str:
    """Delete a profile. Returns status message."""
    code = _validate_code(company_code)
    path = _profile_path(code)
    if not os.path.exists(path):
        raise FileNotFoundError(f"No profile found for: {code}")
    os.remove(path)
    return f"Profile deleted: {code}"


def fields_json_from_profile(company_code: str) -> str:
    """Load a profile and return just the fields as a formatted JSON string."""
    profile = load_profile(company_code)
    return json.dumps(profile["fields"], indent=2, ensure_ascii=False)
