"""
quickstart.py
-------------
PURPOSE:
    - Scans ./pdfs/ folder automatically (no hardcoding filenames)
    - Tracks which PDFs have already been indexed
    - Only ingests NEW PDFs (skips already loaded ones)
    - Then asks a test question to verify everything works

HOW TO USE:
    1. Drop any PDFs into the ./pdfs/ folder
    2. Run: python quickstart.py
    3. It will only index PDFs not yet in ChromaDB
    4. Run again anytime after dropping new PDFs in -- it skips already-done ones

ADDING NEW PDFs LATER:
    Just drop the new PDF into ./pdfs/ and run python quickstart.py again.
    Already-indexed files are skipped automatically.
"""

import os
import sys
import json
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from rich.console import Console
from rich.panel import Panel
from rich.rule import Rule
from rich.table import Table

console = Console()

PDFS_FOLDER  = os.getenv("PDFS_FOLDER", "./pdfs")
DB_PATH      = os.getenv("VECTORSTORE_PATH", "./vectorstore")

# This JSON file lives inside ./vectorstore/ and tracks what's been indexed
TRACKER_FILE = os.path.join(DB_PATH, "indexed_files.json")


# ─────────────────────────────────────────────────────────────
#  Tracker helpers
# ─────────────────────────────────────────────────────────────

def load_tracker() -> dict:
    """
    Load the tracker JSON that remembers which PDFs are already indexed.
    Example contents:
    {
        "nist_framework.pdf": {"size_bytes": 204800, "indexed_at": "..."},
        "owasp_top10.pdf":    {"size_bytes": 102400, "indexed_at": "..."}
    }
    """
    if os.path.exists(TRACKER_FILE):
        with open(TRACKER_FILE, "r") as f:
            return json.load(f)
    return {}


def save_tracker(tracker: dict):
    """Save updated tracker to disk."""
    os.makedirs(DB_PATH, exist_ok=True)
    with open(TRACKER_FILE, "w") as f:
        json.dump(tracker, f, indent=2)


def mark_as_indexed(tracker: dict, pdf_path: Path):
    """Record this PDF as successfully indexed."""
    tracker[pdf_path.name] = {
        "size_bytes": pdf_path.stat().st_size,
        "indexed_at": str(pdf_path.stat().st_mtime),
        "full_path":  str(pdf_path.resolve()),
    }
    save_tracker(tracker)


def is_already_indexed(tracker: dict, pdf_path: Path) -> bool:
    """
    Return True if this PDF was already indexed AND hasn't changed.
    If the file size changed (i.e. you replaced it), it will re-index.
    """
    name = pdf_path.name
    if name not in tracker:
        return False
    current_size = pdf_path.stat().st_size
    tracked_size = tracker[name].get("size_bytes", -1)
    if current_size != tracked_size:
        console.print(f"  [yellow]♻️  {name} has changed (size differs) -- will re-index[/yellow]")
        return False
    return True


# ─────────────────────────────────────────────────────────────
#  Scan pdfs/ folder
# ─────────────────────────────────────────────────────────────

def scan_pdfs_folder():
    """
    Scans ./pdfs/ for all PDF files.
    Returns:
        new_pdfs      -- PDFs not yet indexed (will be processed)
        already_done  -- PDFs already indexed (will be skipped)
    """
    folder = Path(PDFS_FOLDER)
    folder.mkdir(parents=True, exist_ok=True)

    all_pdfs = sorted(folder.glob("*.pdf"))
    tracker  = load_tracker()

    new_pdfs     = []
    already_done = []

    for pdf in all_pdfs:
        if is_already_indexed(tracker, pdf):
            already_done.append(pdf)
        else:
            new_pdfs.append(pdf)

    return new_pdfs, already_done


# ─────────────────────────────────────────────────────────────
#  Main
# ─────────────────────────────────────────────────────────────

def main():
    console.print(Panel(
        "[bold blue]Security RAG -- Auto PDF Loader[/bold blue]\n\n"
        f"Watching folder:  [cyan]{Path(PDFS_FOLDER).resolve()}[/cyan]\n"
        f"Vector store:     [cyan]{Path(DB_PATH).resolve()}[/cyan]",
        border_style="blue",
    ))

    # ── Step 1: Scan folder ───────────────────────────────────
    console.print(Rule("[bold]Step 1: Scanning PDFs Folder[/bold]"))
    new_pdfs, already_done = scan_pdfs_folder()

    if not new_pdfs and not already_done:
        console.print(f"\n[yellow]No PDFs found in:[/yellow] {Path(PDFS_FOLDER).resolve()}")
        console.print("\n[bold]What to do:[/bold]")
        console.print(f"  1. Copy your PDF files into:  [cyan]{Path(PDFS_FOLDER).resolve()}[/cyan]")
        console.print(f"  2. Run this script again:     [cyan]python quickstart.py[/cyan]")
        return

    # Show what was found
    table = Table(show_header=True, header_style="bold")
    table.add_column("PDF File", style="cyan")
    table.add_column("Status", justify="center")
    for pdf in already_done:
        table.add_row(pdf.name, "[green]Already indexed -- will skip[/green]")
    for pdf in new_pdfs:
        table.add_row(pdf.name, "[yellow]New -- will index now[/yellow]")
    console.print(table)

    # ── Step 2: Nothing new? ──────────────────────────────────
    if not new_pdfs:
        console.print(f"\n[green]All PDFs already indexed. Nothing new to process.[/green]")
        console.print("[dim]Drop new PDFs into the pdfs/ folder and run again to index them.[/dim]")
        ask_test_question()
        return

    # ── Step 3: Ingest only the new PDFs ─────────────────────
    console.print(Rule(f"[bold]Step 2: Indexing {len(new_pdfs)} New PDF(s)[/bold]"))

    tracker = load_tracker()

    try:
        from src.security.ingestor import SecurityIngestor
        ingestor = SecurityIngestor(persist_dir=DB_PATH)
    except Exception as e:
        console.print(f"[red]Failed to initialize: {e}[/red]")
        console.print("[dim]Run: pip install -r requirements.txt[/dim]")
        return

    total_chunks = 0
    failed       = []
    skipped_ocr  = []

    for pdf in new_pdfs:
        console.print(f"\n  Processing: [cyan]{pdf.name}[/cyan]")
        try:
            result = ingestor.ingest_pdf(str(pdf))
            if result == -1:
                mark_as_indexed(tracker, pdf)
                skipped_ocr.append(pdf.name)
            else:
                mark_as_indexed(tracker, pdf)
                total_chunks += result
                console.print(f"  [green]Done -- {result} chunks indexed[/green]")
        except Exception as e:
            console.print(f"  [red]Failed: {e}[/red]")
            failed.append(pdf.name)

    console.print(Rule("[bold]Summary[/bold]"))
    console.print(f"  Newly indexed:    {len(new_pdfs) - len(failed) - len(skipped_ocr)} file(s), {total_chunks} total chunks")
    console.print(f"  Skipped (done):   {len(already_done)} file(s)")
    if skipped_ocr:
        console.print(f"  [yellow]Needs OCR (scanned PDF): {chr(44).join(skipped_ocr)}[/yellow]")
        console.print(f"  [dim]  Convert free at: https://www.ilovepdf.com/ocr-pdf[/dim]")
    if failed:
        console.print(f"  [red]Failed: {chr(44).join(failed)}[/red]")

    # ── Step 4: Test question ─────────────────────────────────
    ask_test_question()


def ask_test_question():
    """Ask a generic question to confirm the full pipeline works."""
    console.print(Rule("[bold]Step 3: Test Question via Ollama[/bold]"))
    console.print("[dim]Connecting to Ollama...[/dim]\n")

    try:
        from src.security.rag_chain import SecurityRAGChain
        rag = SecurityRAGChain(llm_provider="ollama", persist_dir=DB_PATH)

        question = "Give me a brief summary of the main security topics in these documents."
        console.print(f"[bold cyan]Test question:[/bold cyan] {question}\n")

        result = rag.ask(question, return_sources=True)

        console.print(Panel(
            result["answer"],
            title="[bold green]Answer (Ollama)[/bold green]",
            border_style="green",
        ))

        if result.get("sources"):
            console.print("[dim]Sources used:[/dim]")
            for s in result["sources"]:
                console.print(f"  {s['source']} (page {s['page']})")

    except Exception as e:
        console.print(f"[red]Could not connect to Ollama: {e}[/red]")
        console.print("\n[yellow]Make sure:[/yellow]")
        console.print("  1. Open a separate Windows terminal")
        console.print("  2. Run: [bold]ollama serve[/bold]")
        console.print("  3. Run this script again")

    console.print(Rule("[bold green]Done![/bold green]"))
    console.print("\n  Add more PDFs: drop files into [cyan].\\pdfs\\[/cyan] and run [cyan]python quickstart.py[/cyan] again")
    console.print("  Chat mode:     [cyan]python cli.py chat[/cyan]")
    console.print("  Browser UI:    [cyan]python app.py[/cyan]  ->  http://localhost:7860\n")


if __name__ == "__main__":
    main()
