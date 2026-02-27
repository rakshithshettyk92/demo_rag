"""
src/code_review/scanner.py
---------------------------
Scans source files against rules stored in the 'code_review_rules' vector store.

Auto-detects language from file extension and retrieves only relevant rules:
  .py          → python rules + general rules
  .java        → java rules + general rules
  .js / .ts    → javascript rules + general rules
  .jsx / .tsx  → react rules + general rules

Usage:
    from src.code_review.scanner import CodeReviewScanner
    scanner = CodeReviewScanner()
    violations = scanner.scan_file("app.py")
    report     = scanner.scan_project("./src")
"""

import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import List, Dict, Optional

from dotenv import load_dotenv
from langchain_chroma import Chroma
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from src.llm_config import get_llm, get_embeddings

load_dotenv()

DB_PATH         = os.getenv("CODE_REVIEW_STORE_PATH", "./vectorstore/code_review")
COLLECTION_NAME = "code_review_rules"
TOP_K           = int(os.getenv("TOP_K_RESULTS", 8))

# ── Language map: extension → language tag ────────────────────────────────────
LANGUAGE_MAP: Dict[str, str] = {
    ".py":   "python",
    ".java": "java",
    ".js":   "javascript",
    ".ts":   "javascript",
    ".jsx":  "react",
    ".tsx":  "react",
}

# Human-readable language names for prompts
LANGUAGE_NAMES: Dict[str, str] = {
    "python":     "Python",
    "java":       "Java",
    "javascript": "JavaScript/TypeScript",
    "react":      "React (JSX/TSX)",
    "general":    "general",
}


# ── Violation dataclass ───────────────────────────────────────────────────────

@dataclass
class Violation:
    file:        str
    line:        str
    rule_id:     str
    severity:    str
    description: str
    suggestion:  str
    language:    str = "unknown"

    def __str__(self):
        return (
            f"  [{self.severity}] {self.rule_id} @ line {self.line}\n"
            f"    {self.description}\n"
            f"    Fix: {self.suggestion}"
        )


# ── Scan prompt ───────────────────────────────────────────────────────────────

SCAN_PROMPT = """\
You are an expert {language_name} code reviewer. \
Analyse the {language_name} code below strictly against the coding rules provided.

Rules context:
{rules_context}

Code to review — file: {filename}
{code}

Instructions:
- Check the code against EVERY rule in the context.
- List each violation on a separate line using EXACTLY this format:
  LINE <number> | RULE <id> | SEVERITY <level> | <short description> | FIX: <one-line suggestion>
- Use line number "?" if you cannot determine the exact line.
- If the code has NO violations at all, reply with exactly: NO_VIOLATIONS
- Do not add any other text, headings, or explanation.
"""


# ── Scanner ───────────────────────────────────────────────────────────────────

class CodeReviewScanner:
    def __init__(self, llm_provider: str = None, persist_dir: str = DB_PATH):
        print("🔧 Building Code Review Scanner...")

        self.llm        = get_llm(llm_provider)
        self.embeddings = get_embeddings(llm_provider)
        self.persist_dir = persist_dir

        self.vectorstore = Chroma(
            persist_directory=persist_dir,
            embedding_function=self.embeddings,
            collection_name=COLLECTION_NAME,
        )

        rule_count = self.vectorstore._collection.count()
        print(f"📚 Rule store: {rule_count} chunks in '{COLLECTION_NAME}'")
        print(f"📂 Store path: {persist_dir}")

        if rule_count == 0:
            print("⚠️  WARNING: No rules indexed yet! Run: python code_review_cli.py ingest")

        self.prompt = ChatPromptTemplate.from_template(SCAN_PROMPT)
        print("✅ Scanner ready!\n")

    # ── Language detection ────────────────────────────────────────────────────

    @staticmethod
    def detect_language(file_path: str) -> Optional[str]:
        """Return language tag for a file, or None if unsupported."""
        return LANGUAGE_MAP.get(Path(file_path).suffix.lower())

    # ── Rule retrieval (language-filtered) ───────────────────────────────────

    def _retrieve_rules(self, code: str, language: str) -> str:
        """
        Retrieve rules relevant to the code, filtered to the detected language
        plus general rules (e.g. OWASP).
        """
        query    = f"{language} code review rules for: {code[:500]}"
        retriever = self.vectorstore.as_retriever(
            search_type="mmr",
            search_kwargs={
                "k":        TOP_K,
                "fetch_k":  TOP_K * 3,
                "filter":   {"language": {"$in": [language, "general"]}},
            },
        )
        docs = retriever.invoke(query)

        if not docs:
            # Fallback: no filter — return any rules
            retriever_all = self.vectorstore.as_retriever(
                search_type="mmr",
                search_kwargs={"k": TOP_K, "fetch_k": TOP_K * 3},
            )
            docs = retriever_all.invoke(query)

        if not docs:
            return "[NO RULES FOUND — run: python code_review_cli.py ingest]"

        parts = []
        for i, doc in enumerate(docs, 1):
            parts.append(f"[Rule {i}]\n{doc.page_content.strip()}")
        return "\n\n---\n\n".join(parts)

    # ── Parse LLM response ────────────────────────────────────────────────────

    def _parse_violations(
        self, response: str, file_path: str, language: str
    ) -> List[Violation]:
        if "NO_VIOLATIONS" in response.upper():
            return []

        violations = []
        pattern = re.compile(
            r"LINE\s+(\S+)\s*\|\s*RULE\s+(\S+)\s*\|\s*SEVERITY\s+(\S+)\s*\|"
            r"\s*(.+?)\s*\|\s*FIX:\s*(.+)",
            re.IGNORECASE,
        )
        for line in response.strip().splitlines():
            m = pattern.search(line)
            if m:
                violations.append(Violation(
                    file=file_path,
                    line=m.group(1),
                    rule_id=m.group(2),
                    severity=m.group(3).capitalize(),
                    description=m.group(4).strip(),
                    suggestion=m.group(5).strip(),
                    language=language,
                ))
        return violations

    # ── Scan a single file ────────────────────────────────────────────────────

    def scan_file(self, file_path: str, language: str = None) -> List[Violation]:
        """
        Scan a single file. Language is auto-detected from extension if not given.

        Args:
            file_path: Path to the file to scan.
            language:  Override language detection (e.g. "python", "java").

        Returns:
            List of Violation objects.
        """
        path = Path(file_path)
        if not path.exists():
            print(f"  ⚠️  File not found: {file_path}")
            return []

        # Auto-detect language
        lang = language or self.detect_language(file_path)
        if lang is None:
            print(f"  ⏭  Skipping {path.name} — unsupported extension '{path.suffix}'")
            return []

        code = path.read_text(encoding="utf-8", errors="replace")
        if not code.strip():
            return []

        language_name = LANGUAGE_NAMES.get(lang, lang)
        rules_context = self._retrieve_rules(code, lang)

        chain = self.prompt | self.llm | StrOutputParser()

        response = chain.invoke({
            "language_name": language_name,
            "rules_context": rules_context,
            "filename":      path.name,
            "code":          code,
        })

        return self._parse_violations(response, file_path, lang)

    # ── Scan a project folder ─────────────────────────────────────────────────

    def scan_project(
        self,
        project_path: str,
        exclude_dirs: List[str] = None,
    ) -> Dict[str, List[Violation]]:
        """
        Recursively scan all supported files in a folder.
        Language is auto-detected per file from its extension.

        Supported: .py  .java  .js  .ts  .jsx  .tsx

        Args:
            project_path: Root folder to scan.
            exclude_dirs: Directory names to skip.

        Returns:
            Dict mapping file_path → list of Violation objects.
        """
        if exclude_dirs is None:
            exclude_dirs = {
                ".venv", "venv", "env", "__pycache__", ".git",
                "node_modules", "dist", "build", ".idea", ".vscode",
                "vectorstore",
            }

        supported_exts = set(LANGUAGE_MAP.keys())
        root    = Path(project_path)
        results = {}

        all_files = [
            f for f in root.rglob("*")
            if f.is_file()
            and f.suffix.lower() in supported_exts
            and not any(part in exclude_dirs for part in f.parts)
        ]

        if not all_files:
            print(f"⚠️  No supported files found in: {project_path}")
            print(f"   Supported extensions: {', '.join(sorted(supported_exts))}")
            return results

        # Group by language for a cleaner summary
        lang_counts: Dict[str, int] = {}
        for f in all_files:
            lang = LANGUAGE_MAP.get(f.suffix.lower(), "unknown")
            lang_counts[lang] = lang_counts.get(lang, 0) + 1

        print(f"🔍 Scanning {len(all_files)} file(s) in {project_path}")
        for lang, count in sorted(lang_counts.items()):
            print(f"   {LANGUAGE_NAMES.get(lang, lang)}: {count} file(s)")
        print()

        for f in all_files:
            lang = LANGUAGE_MAP.get(f.suffix.lower())
            lang_label = LANGUAGE_NAMES.get(lang, lang)
            print(f"  📄 [{lang_label}] {f.relative_to(root)}")
            violations = self.scan_file(str(f), language=lang)
            if violations:
                results[str(f)] = violations
                print(f"     → {len(violations)} violation(s) found")
            else:
                print(f"     → ✅ No violations")

        return results

    # ── Summary report ────────────────────────────────────────────────────────

    @staticmethod
    def format_report(results: Dict[str, List[Violation]]) -> str:
        if not results:
            return "✅ No violations found across all scanned files."

        total = sum(len(v) for v in results.values())
        lines = [f"📋 Code Review Report — {total} violation(s) in {len(results)} file(s)\n"]
        lines.append("=" * 70)

        severity_order = {"Critical": 0, "Major": 1, "Minor": 2, "Info": 3}

        for file_path, violations in results.items():
            lang = violations[0].language if violations else "unknown"
            lang_label = LANGUAGE_NAMES.get(lang, lang)
            lines.append(
                f"\n📄 {file_path}  [{lang_label}]  ({len(violations)} issue(s))"
            )
            lines.append("-" * 60)
            for v in sorted(violations, key=lambda v: severity_order.get(v.severity, 9)):
                lines.append(str(v))

        lines.append("\n" + "=" * 70)
        c = sum(1 for vs in results.values() for v in vs if v.severity == "Critical")
        m = sum(1 for vs in results.values() for v in vs if v.severity == "Major")
        lines.append(f"Critical: {c}  |  Major: {m}  |  Total: {total}")
        return "\n".join(lines)
