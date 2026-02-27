"""
src/code_review/fixer.py
-------------------------
Takes Violation objects from the scanner and uses Ollama to apply fixes
to the source files.

Usage:
    from src.code_review.fixer import CodeReviewFixer
    from src.code_review.scanner import CodeReviewScanner

    scanner    = CodeReviewScanner()
    violations = scanner.scan_project("./src")

    fixer      = CodeReviewFixer()
    fixed      = fixer.fix_project(violations)
"""

import sys
from pathlib import Path
from typing import Dict, List

from dotenv import load_dotenv
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from src.llm_config import get_llm
from src.code_review.scanner import Violation

load_dotenv()

FIX_PROMPT = """\
You are an expert Python developer applying code review fixes.

The following violations were found in the file "{filename}":
{violations_text}

Original file content:
```python
{code}
```

Instructions:
- Fix EVERY violation listed above.
- Return ONLY the complete corrected Python file content.
- Do NOT include any explanation, markdown fences, or extra text.
- Preserve all logic, comments, and structure that are not related to the violations.
- If a fix requires a new import, add it at the top of the file.
"""


class CodeReviewFixer:
    def __init__(self, llm_provider: str = None):
        print("🔧 Initialising Code Review Fixer...")
        self.llm    = get_llm(llm_provider)
        self.prompt = ChatPromptTemplate.from_template(FIX_PROMPT)
        self.chain  = self.prompt | self.llm | StrOutputParser()
        print("✅ Fixer ready!\n")

    # ── Fix a single file ─────────────────────────────────────────────────────

    def fix_file(self, file_path: str, violations: List[Violation]) -> str:
        """
        Apply AI fixes for all violations in one file.

        Args:
            file_path:  Path to the Python file.
            violations: List of Violation objects for this file.

        Returns:
            Fixed file content as a string.
        """
        path = Path(file_path)
        code = path.read_text(encoding="utf-8", errors="replace")

        violations_text = "\n".join(
            f"- Line {v.line} [{v.severity}] {v.rule_id}: {v.description} → {v.suggestion}"
            for v in violations
        )

        print(f"  🔨 Fixing {path.name} ({len(violations)} violation(s))...")

        fixed_code = self.chain.invoke({
            "filename":        path.name,
            "violations_text": violations_text,
            "code":            code,
        })

        # Strip accidental markdown code fences if LLM added them
        fixed_code = _strip_fences(fixed_code)
        return fixed_code

    # ── Write fixed content back to file ──────────────────────────────────────

    def apply_fix(self, file_path: str, fixed_code: str):
        """Write fixed content back to the file."""
        Path(file_path).write_text(fixed_code, encoding="utf-8")
        print(f"  ✅ Written: {file_path}")

    # ── Fix entire project ────────────────────────────────────────────────────

    def fix_project(
        self,
        results: Dict[str, List[Violation]],
        auto_apply: bool = True,
    ) -> List[str]:
        """
        Fix all violations across an entire project scan result.

        Args:
            results:    Dict of file_path → violations (from scanner.scan_project).
            auto_apply: If True, write fixes directly to disk.
                        If False, only print diffs (dry run).

        Returns:
            List of file paths that were fixed.
        """
        if not results:
            print("✅ Nothing to fix.")
            return []

        fixed_files = []
        print(f"\n🔨 Fixing {len(results)} file(s)...\n")

        for file_path, violations in results.items():
            try:
                fixed_code = self.fix_file(file_path, violations)

                if auto_apply:
                    self.apply_fix(file_path, fixed_code)
                    fixed_files.append(file_path)
                else:
                    print(f"\n--- DRY RUN: {file_path} ---")
                    print(fixed_code[:500] + "...\n")

            except Exception as e:
                print(f"  ⚠️  Failed to fix {file_path}: {e}")

        if auto_apply:
            print(f"\n✅ Fixed {len(fixed_files)} file(s).")
        else:
            print(f"\n[Dry run] {len(results)} file(s) would be fixed.")

        return fixed_files


# ── Helpers ───────────────────────────────────────────────────────────────────

def _strip_fences(text: str) -> str:
    """Remove markdown code fences that LLMs sometimes add."""
    text = text.strip()
    if text.startswith("```"):
        lines = text.splitlines()
        # Remove first line (```python or ```) and last line (```)
        if lines[-1].strip() == "```":
            lines = lines[1:-1]
        else:
            lines = lines[1:]
        text = "\n".join(lines)
    return text
