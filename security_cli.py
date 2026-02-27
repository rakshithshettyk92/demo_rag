"""
security_cli.py
---------------
PURPOSE:
    Command-line tool to interact with the Security RAG system.
    Use this to ingest security PDFs and ask questions from your terminal.

COMMANDS:
    python security_cli.py quickstart                ← auto-scan ./pdfs/, ingest only new/changed
    python security_cli.py ingest ./pdfs/            ← force-ingest all PDFs in folder
    python security_cli.py ingest ./pdfs/nist.pdf    ← force-ingest one PDF
    python security_cli.py ask "What is XSS?"        ← ask a question
    python security_cli.py chat                       ← interactive chat mode
    python security_cli.py status                     ← check what's indexed
"""

import sys
import os
import json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Fix Windows console encoding for emoji/Unicode output
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

import argparse
from pathlib import Path
from rich.console import Console
from rich.panel import Panel
from rich.markdown import Markdown
from rich.rule import Rule
from rich.table import Table
from rich.prompt import Prompt

console = Console(highlight=False)

PDFS_FOLDER = os.getenv("PDFS_FOLDER", "./pdfs")


# ── Tracker helpers (shared by quickstart) ───────────────────────────────────

def _tracker_file(db_path: str) -> str:
    return os.path.join(db_path, "indexed_files.json")

def _load_tracker(db_path: str) -> dict:
    path = _tracker_file(db_path)
    if os.path.exists(path):
        with open(path) as f:
            return json.load(f)
    return {}

def _save_tracker(tracker: dict, db_path: str):
    os.makedirs(db_path, exist_ok=True)
    with open(_tracker_file(db_path), "w") as f:
        json.dump(tracker, f, indent=2)

def _is_changed(tracker: dict, file_path: Path) -> bool:
    """Return True if file is new or its size changed since last ingest."""
    entry = tracker.get(file_path.name)
    if not entry:
        return True
    if file_path.stat().st_size != entry.get("size_bytes", -1):
        console.print(f"  [yellow]♻️  {file_path.name} changed — will re-index[/yellow]")
        return True
    return False

def _mark_indexed(tracker: dict, file_path: Path, db_path: str):
    tracker[file_path.name] = {
        "size_bytes": file_path.stat().st_size,
        "indexed_at": str(file_path.stat().st_mtime),
        "full_path":  str(file_path.resolve()),
    }
    _save_tracker(tracker, db_path)


def cmd_quickstart(args):
    """
    Auto-scan ./pdfs/, ingest only new or changed PDFs, then run a test question.
    Skips files that haven't changed since last run.
    """
    from src.security.ingestor import SecurityIngestor

    db_path = args.db
    console.print(Panel(
        "[bold blue]Security RAG — Smart PDF Loader[/bold blue]\n\n"
        f"PDFs folder:  [cyan]{Path(PDFS_FOLDER).resolve()}[/cyan]\n"
        f"Vector store: [cyan]{Path(db_path).resolve()}[/cyan]",
        border_style="blue",
    ))

    # ── Scan folder ───────────────────────────────────────────
    console.print(Rule("[bold]Step 1: Scanning PDFs Folder[/bold]"))
    folder = Path(PDFS_FOLDER)
    folder.mkdir(parents=True, exist_ok=True)
    all_pdfs = sorted(folder.glob("*.pdf"))

    if not all_pdfs:
        console.print(f"\n[yellow]No PDFs found in:[/yellow] {folder.resolve()}")
        console.print(f"  Drop PDFs into [cyan]{folder.resolve()}[/cyan] and run again.")
        return

    tracker    = _load_tracker(db_path)
    new_pdfs   = [p for p in all_pdfs if _is_changed(tracker, p)]
    done_pdfs  = [p for p in all_pdfs if not _is_changed(tracker, p)]

    table = Table(show_header=True, header_style="bold")
    table.add_column("PDF File", style="cyan")
    table.add_column("Status", justify="center")
    for pdf in done_pdfs:
        table.add_row(pdf.name, "[green]No change — skip[/green]")
    for pdf in new_pdfs:
        table.add_row(pdf.name, "[yellow]New / changed — will index[/yellow]")
    console.print(table)

    if not new_pdfs:
        console.print("\n[green]✅ All PDFs already up to date. Nothing to ingest.[/green]")
        _run_test_question(db_path, args.provider)
        return

    # ── Ingest only new/changed ───────────────────────────────
    console.print(Rule(f"[bold]Step 2: Indexing {len(new_pdfs)} PDF(s)[/bold]"))
    try:
        ingestor = SecurityIngestor(persist_dir=db_path)
    except Exception as e:
        console.print(f"[red]Failed to initialise: {e}[/red]")
        return

    total_chunks = 0
    failed       = []

    for pdf in new_pdfs:
        console.print(f"\n  Processing: [cyan]{pdf.name}[/cyan]")
        try:
            result = ingestor.ingest_pdf(str(pdf))
            _mark_indexed(tracker, pdf, db_path)
            if result > 0:
                total_chunks += result
                console.print(f"  [green]Done — {result} chunks indexed[/green]")
            else:
                console.print(f"  [yellow]No extractable content (scanned PDF?)[/yellow]")
        except Exception as e:
            console.print(f"  [red]Failed: {e}[/red]")
            failed.append(pdf.name)

    console.print(Rule("[bold]Summary[/bold]"))
    console.print(f"  Newly indexed: {len(new_pdfs) - len(failed)} file(s), {total_chunks} chunks")
    console.print(f"  Skipped:       {len(done_pdfs)} file(s) (unchanged)")
    if failed:
        console.print(f"  [red]Failed: {', '.join(failed)}[/red]")

    _run_test_question(db_path, args.provider)


def _run_test_question(db_path: str, provider: str = None):
    """Run a quick test question to confirm the pipeline works."""
    from src.security.rag_chain import SecurityRAGChain
    console.print(Rule("[bold]Step 3: Test Question[/bold]"))
    try:
        rag      = SecurityRAGChain(llm_provider=provider or "ollama", persist_dir=db_path)
        question = "Give me a brief summary of the main security topics in these documents."
        console.print(f"[bold cyan]Q:[/bold cyan] {question}\n")
        result   = rag.ask(question, return_sources=True)
        console.print(Panel(result["answer"], title="[green]Answer[/green]", border_style="green"))
        for s in result.get("sources", []):
            console.print(f"  [dim]{s['source']} (page {s['page']})[/dim]")
    except Exception as e:
        console.print(f"[red]Test question failed: {e}[/red]")
        console.print("[dim]Make sure Ollama is running: ollama serve[/dim]")
    console.print(Rule("[bold green]Done![/bold green]"))
    console.print("\n  Add more PDFs: drop into [cyan].\\pdfs\\[/cyan] and run [cyan]python security_cli.py quickstart[/cyan] again")
    console.print("  Chat mode:     [cyan]python security_cli.py chat[/cyan]")
    console.print("  Browser UI:    [cyan]python app.py[/cyan]  →  http://localhost:7860\n")


def cmd_ingest(args):
    """Force-ingest PDF(s) — bypasses change detection."""
    from src.security.ingestor import SecurityIngestor

    console.print(f"\n[bold blue]📥 Starting ingestion...[/bold blue]")
    ingestor = SecurityIngestor(persist_dir=args.db)

    if os.path.isdir(args.path):
        count = ingestor.ingest_folder(args.path)
    else:
        count = ingestor.ingest_pdf(args.path)

    console.print(f"\n[bold green]✅ Ingestion complete! {count} chunks stored.[/bold green]")
    console.print(f"[dim]You can now ask questions with: python security_cli.py ask \"your question\"[/dim]")


def cmd_ask(args):
    """Ask a single question."""
    from src.security.rag_chain import SecurityRAGChain

    console.print(f"\n[bold cyan]❓ Question:[/bold cyan] {args.question}\n")
    console.print("[dim]Searching documents and generating answer...[/dim]\n")

    rag = SecurityRAGChain(llm_provider=args.provider, persist_dir=args.db)
    result = rag.ask(args.question, return_sources=True)

    # Print the answer
    console.print(Panel(
        Markdown(result["answer"]),
        title="[bold green]🔐 Security Answer[/bold green]",
        border_style="green",
    ))

    # Print sources
    if result.get("sources"):
        table = Table(title="📚 Retrieved from these document sections", show_lines=True)
        table.add_column("Document", style="cyan", max_width=30)
        table.add_column("Page", style="yellow", justify="center")
        table.add_column("Excerpt", style="white", max_width=60)

        for s in result["sources"]:
            table.add_row(s["source"], str(s["page"]), s["excerpt"])

        console.print(table)


def cmd_chat(args):
    """
    Interactive chat mode — have a conversation with your security docs.
    Type 'exit' to quit, 'switch <provider>' to change AI.
    """
    from src.security.rag_chain import SecurityRAGChain

    console.print(Panel(
        "[bold]🔐 Security RAG — Interactive Chat[/bold]\n\n"
        "Commands:\n"
        "  [cyan]exit[/cyan]              → quit\n"
        "  [cyan]switch ollama[/cyan]     → use Llama (free)\n"
        "  [cyan]switch gemma[/cyan]      → use Gemma (free, Google)\n"
        "  [cyan]switch anthropic[/cyan]  → use Claude (needs API key)\n"
        "  [cyan]switch openai[/cyan]     → use OpenAI (needs API key)\n"
        "  [cyan]sources[/cyan]           → list indexed documents",
        border_style="blue",
    ))

    rag = SecurityRAGChain(llm_provider=args.provider, persist_dir=args.db)
    history = []

    while True:
        try:
            question = Prompt.ask("\n[bold cyan]You[/bold cyan]").strip()
        except (KeyboardInterrupt, EOFError):
            console.print("\n[dim]Goodbye![/dim]")
            break

        if not question:
            continue

        # Handle special commands
        if question.lower() in ("exit", "quit", "q"):
            console.print("[dim]Goodbye![/dim]")
            break

        if question.lower() == "sources":
            from src.security.ingestor import SecurityIngestor
            ingestor = SecurityIngestor(persist_dir=args.db)
            sources = ingestor.list_sources()
            if sources:
                console.print("[bold]Indexed documents:[/bold]")
                for s in sources:
                    console.print(f"  • {s}")
            else:
                console.print("[yellow]No documents indexed yet.[/yellow]")
            continue

        if question.lower().startswith("switch "):
            provider = question.split(" ", 1)[1].strip()
            rag.switch_provider(provider)
            continue

        # Ask the question with streaming output
        console.print("\n[bold green]Assistant:[/bold green] ", end="")
        try:
            full_answer = ""
            for token in rag.ask_stream(question):
                print(token, end="", flush=True)
                full_answer += token
            print()  # newline after streaming

            history.append({"question": question, "answer": full_answer})

        except Exception as e:
            console.print(f"\n[red]Error: {e}[/red]")
            console.print("[dim]Make sure Ollama is running: ollama serve[/dim]")


def cmd_status(args):
    """Show status of the vector store."""
    from src.security.ingestor import SecurityIngestor

    ingestor = SecurityIngestor(persist_dir=args.db)
    count = ingestor.count_documents()
    sources = ingestor.list_sources()

    console.print(Panel(
        f"[bold]Vector Store Status[/bold]\n\n"
        f"📦 Path: {args.db}\n"
        f"🔢 Total chunks: {count}\n"
        f"📄 Indexed files: {len(sources)}",
        border_style="blue",
    ))

    if sources:
        console.print("\n[bold]Indexed documents:[/bold]")
        for s in sources:
            console.print(f"  • {s}")
    else:
        console.print("\n[yellow]No documents indexed yet.[/yellow]")
        console.print("[dim]Run: python security_cli.py quickstart[/dim]")


def main():
    parser = argparse.ArgumentParser(
        description="🔐 Security RAG — LangChain-powered Q&A over security docs"
    )
    parser.add_argument("--db",       default=os.getenv("SECURITY_STORE_PATH", "./vectorstore/security"), help="Vector store path")
    parser.add_argument("--provider", default=None, help="LLM provider: ollama | gemma | anthropic | openai")

    sub = parser.add_subparsers(dest="command", required=True)

    # quickstart command
    p_qs = sub.add_parser("quickstart", help="Auto-scan ./pdfs/, ingest only new/changed PDFs")
    p_qs.set_defaults(func=cmd_quickstart)

    # ingest command (force — bypasses tracker)
    p_ingest = sub.add_parser("ingest", help="Force-ingest a specific PDF file or folder")
    p_ingest.add_argument("path", help="PDF file or folder of PDFs")
    p_ingest.set_defaults(func=cmd_ingest)

    # ask command
    p_ask = sub.add_parser("ask", help="Ask a single question")
    p_ask.add_argument("question", help="Your security question")
    p_ask.set_defaults(func=cmd_ask)

    # chat command
    p_chat = sub.add_parser("chat", help="Interactive chat mode")
    p_chat.set_defaults(func=cmd_chat)

    # status command
    p_status = sub.add_parser("status", help="Show vector store status")
    p_status.set_defaults(func=cmd_status)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
