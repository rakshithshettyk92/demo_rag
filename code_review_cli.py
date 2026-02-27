"""
code_review_cli.py
-------------------
CLI for the RAG-powered code review tool.

Commands:
  ingest              Ingest built-in rules (Sonar, PEP8, OWASP) into vector store
  ingest --dir PATH   Ingest rules from a custom folder
  scan   PATH         Scan Python files and print a violation report
  fix    PATH         Scan + fix files in place using Ollama
  pr     PATH         Scan + fix + create a GitHub PR automatically

Examples:
  python code_review_cli.py ingest
  python code_review_cli.py ingest --dir ./my_company_rules
  python code_review_cli.py scan ./src
  python code_review_cli.py fix ./src
  python code_review_cli.py pr ./src --base main
"""

import argparse
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Fix Windows console encoding for emoji output
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")


# ── Tracker helpers ───────────────────────────────────────────────────────────

def _cr_db_path() -> str:
    return os.getenv("CODE_REVIEW_STORE_PATH", "./vectorstore/code_review")

def _tracker_file() -> str:
    return os.path.join(_cr_db_path(), "rule_tracker.json")

def _load_tracker() -> dict:
    path = _tracker_file()
    if os.path.exists(path):
        with open(path) as f:
            return json.load(f)
    return {}

def _save_tracker(tracker: dict):
    os.makedirs(_cr_db_path(), exist_ok=True)
    with open(_tracker_file(), "w") as f:
        json.dump(tracker, f, indent=2)

def _is_changed(tracker: dict, file_path: Path) -> bool:
    """Return True if file is new or size changed since last ingest."""
    entry = tracker.get(file_path.name)
    if not entry:
        return True
    if file_path.stat().st_size != entry.get("size_bytes", -1):
        print(f"  ♻️  {file_path.name} changed — will re-ingest")
        return True
    return False

def _mark_indexed(tracker: dict, file_path: Path):
    tracker[file_path.name] = {
        "size_bytes": file_path.stat().st_size,
        "indexed_at": str(file_path.stat().st_mtime),
        "full_path":  str(file_path.resolve()),
    }
    _save_tracker(tracker)


# ── Commands ──────────────────────────────────────────────────────────────────

def cmd_ingest(args):
    from src.code_review.ingestor import CodeReviewIngestor, DEFAULT_RULES_DIR

    rules_dir = Path(args.dir) if args.dir else DEFAULT_RULES_DIR
    if not rules_dir.exists():
        print(f"⚠️  Rules folder not found: {rules_dir}")
        return

    # Collect rule files (exclude README)
    all_files = [
        f for f in sorted(rules_dir.glob("*"))
        if f.suffix.lower() in (".md", ".pdf")
        and f.name.lower() != "readme.md"
    ]

    if not all_files:
        print(f"⚠️  No rule files found in: {rules_dir}")
        return

    tracker   = _load_tracker()
    new_files = [f for f in all_files if _is_changed(tracker, f)]
    done      = [f for f in all_files if not _is_changed(tracker, f)]

    print(f"\n📋 Rules folder: {rules_dir.resolve()}")
    for f in done:
        print(f"  ✅ {f.name}  [no change — skip]")
    for f in new_files:
        print(f"  🆕 {f.name}  [new / changed — will ingest]")

    if not new_files:
        print(f"\n✅ All rules already up to date. Nothing to ingest.")
        print(f"   Total rule chunks: {CodeReviewIngestor().count_rules()}")
        print(f"\n📌 Ready to scan. Run: python code_review_cli.py scan ./src")
        return

    print(f"\n🔄 Ingesting {len(new_files)} file(s)...\n")
    ingestor = CodeReviewIngestor()
    total    = 0

    for f in new_files:
        chunks = ingestor.ingest_file(str(f))
        if chunks > 0:
            _mark_indexed(tracker, f)
            total += chunks
            print(f"  ✅ {f.name} → {chunks} chunks")
        else:
            print(f"  ⚠️  {f.name} → nothing indexed")

    print(f"\n✅ Done! {total} new rule chunks indexed into 'code_review_rules'")
    print(f"   Skipped: {len(done)} unchanged file(s)")
    if total > 0:
        print(f"\n📌 Ready to scan. Run: python code_review_cli.py scan ./src")


def cmd_scan(args):
    from src.code_review.scanner import CodeReviewScanner
    scanner = CodeReviewScanner(llm_provider=args.provider)
    results = scanner.scan_project(args.path)
    print("\n" + scanner.format_report(results))

    total = sum(len(v) for v in results.values())
    if total > 0:
        print(f"\n💡 To auto-fix: python code_review_cli.py fix {args.path}")
        print(f"💡 To fix + PR: python code_review_cli.py pr {args.path}")


def cmd_fix(args):
    from src.code_review.scanner import CodeReviewScanner
    from src.code_review.fixer import CodeReviewFixer

    scanner = CodeReviewScanner(llm_provider=args.provider)
    results = scanner.scan_project(args.path)

    total = sum(len(v) for v in results.values())
    if total == 0:
        print("\n✅ No violations found — nothing to fix.")
        return

    print("\n" + scanner.format_report(results))

    if not args.yes:
        answer = input(f"\n❓ Apply fixes to {len(results)} file(s)? [y/N] ").strip().lower()
        if answer != "y":
            print("Aborted.")
            return

    fixer = CodeReviewFixer(llm_provider=args.provider)
    fixer.fix_project(results, auto_apply=True)


def cmd_pr(args):
    from src.code_review.scanner import CodeReviewScanner
    from src.code_review.fixer import CodeReviewFixer
    from src.code_review.pr_creator import PRCreator

    # Step 1: Scan
    scanner = CodeReviewScanner(llm_provider=args.provider)
    results = scanner.scan_project(args.path)

    total = sum(len(v) for v in results.values())
    if total == 0:
        print("\n✅ No violations found — no PR needed.")
        return

    print("\n" + scanner.format_report(results))

    # Step 2: Confirm
    if not args.yes:
        answer = input(
            f"\n❓ Fix {total} violation(s) in {len(results)} file(s) and create a PR? [y/N] "
        ).strip().lower()
        if answer != "y":
            print("Aborted.")
            return

    # Step 3: Fix
    fixer       = CodeReviewFixer(llm_provider=args.provider)
    fixed_files = fixer.fix_project(results, auto_apply=True)

    if not fixed_files:
        print("⚠️  No files were fixed successfully.")
        return

    # Step 4: Create PR
    creator = PRCreator(repo_root=".")
    pr_url  = creator.create_pr(fixed_files, results, base_branch=args.base)

    if pr_url:
        print(f"\n🎉 Done! PR: {pr_url}")


# ── Argument parser ───────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="RAG-powered code review — scan, fix, and create PRs using local rules.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # ── ingest ────────────────────────────────────────────────────────────────
    p_ingest = subparsers.add_parser("ingest", help="Ingest rules into the vector store")
    p_ingest.add_argument(
        "--dir", metavar="PATH", default=None,
        help="Custom rules folder (default: src/code_review/rules/)",
    )
    p_ingest.set_defaults(func=cmd_ingest)

    # ── scan ──────────────────────────────────────────────────────────────────
    p_scan = subparsers.add_parser("scan", help="Scan files and print a violation report")
    p_scan.add_argument("path", help="File or folder to scan")
    p_scan.add_argument("--provider", default=None, help="LLM provider (ollama, gemma, anthropic, openai)")
    p_scan.set_defaults(func=cmd_scan)

    # ── fix ───────────────────────────────────────────────────────────────────
    p_fix = subparsers.add_parser("fix", help="Scan and auto-fix violations in place")
    p_fix.add_argument("path", help="File or folder to scan and fix")
    p_fix.add_argument("--provider", default=None, help="LLM provider")
    p_fix.add_argument("-y", "--yes", action="store_true", help="Skip confirmation prompt")
    p_fix.set_defaults(func=cmd_fix)

    # ── pr ────────────────────────────────────────────────────────────────────
    p_pr = subparsers.add_parser("pr", help="Scan + fix + create a GitHub PR")
    p_pr.add_argument("path", help="File or folder to scan and fix")
    p_pr.add_argument("--provider", default=None, help="LLM provider")
    p_pr.add_argument("--base", default="main", help="Base branch for PR (default: main)")
    p_pr.add_argument("-y", "--yes", action="store_true", help="Skip confirmation prompt")
    p_pr.set_defaults(func=cmd_pr)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
