"""
cli.py
------
PURPOSE:
    Command-line tool to interact with the Security RAG system.
    Use this to ingest PDFs and ask questions from your terminal.

COMMANDS:
    python cli.py ingest ./pdfs/            ← ingest all PDFs in folder
    python cli.py ingest ./pdfs/nist.pdf    ← ingest one PDF
    python cli.py ask "What is XSS?"        ← ask a question
    python cli.py chat                       ← interactive chat mode
    python cli.py status                     ← check what's indexed
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import argparse
from rich.console import Console
from rich.panel import Panel
from rich.markdown import Markdown
from rich.table import Table
from rich.prompt import Prompt

console = Console()


def cmd_ingest(args):
    """Ingest PDF(s) into the vector store."""
    from src.security.ingestor import SecurityIngestor

    console.print(f"\n[bold blue]📥 Starting ingestion...[/bold blue]")
    ingestor = SecurityIngestor(persist_dir=args.db)

    if os.path.isdir(args.path):
        count = ingestor.ingest_folder(args.path)
    else:
        count = ingestor.ingest_pdf(args.path)

    console.print(f"\n[bold green]✅ Ingestion complete! {count} chunks stored.[/bold green]")
    console.print(f"[dim]You can now ask questions with: python cli.py ask \"your question\"[/dim]")


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
        console.print("[dim]Run: python cli.py ingest ./pdfs/[/dim]")


def main():
    parser = argparse.ArgumentParser(
        description="🔐 Security RAG — LangChain-powered Q&A over security docs"
    )
    parser.add_argument("--db",       default="./vectorstore", help="Vector store path")
    parser.add_argument("--provider", default=None, help="LLM provider: ollama | gemma | anthropic | openai")

    sub = parser.add_subparsers(dest="command", required=True)

    # ingest command
    p_ingest = sub.add_parser("ingest", help="Ingest PDF file(s)")
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
