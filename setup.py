"""
setup.py — SOLUM AI Platform — One-time Setup Script
------------------------------------------------------
Run this ONCE to set up the entire platform automatically:

    python setup.py

What it does (in order):
  1.  Check Python version (3.9+)
  2.  Install Python dependencies (requirements.txt)
  3.  Create .env from .env.example (if .env doesn't exist)
  4.  Create required directories (pdfs/, vectorstore/)
  5.  Check Ollama is installed
  6.  Start Ollama server if not running
  7.  Pull required Ollama models (llama3.2, nomic-embed-text, llava, gemma3)
  8.  Ingest code review rules into vector store
  9.  Ingest any PDFs found in ./pdfs/ into security vector store
  10. Verify the full pipeline with a test question
  11. Print launch instructions
"""

import os
import sys
import shutil
import subprocess
import time
import platform
from pathlib import Path

# ── Bootstrap: install rich if missing so we get pretty output ─────────────────
try:
    from rich.console import Console
    from rich.panel import Panel
    from rich.progress import Progress, SpinnerColumn, TextColumn
    from rich.rule import Rule
    from rich.table import Table
except ImportError:
    print("Installing 'rich' for prettier output...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "rich", "-q"])
    from rich.console import Console
    from rich.panel import Panel
    from rich.progress import Progress, SpinnerColumn, TextColumn
    from rich.rule import Rule
    from rich.table import Table

console = Console(highlight=False)

# ── Helpers ───────────────────────────────────────────────────────────────────

def ok(msg):   console.print(f"  [green]✅ {msg}[/green]")
def warn(msg): console.print(f"  [yellow]⚠️  {msg}[/yellow]")
def err(msg):  console.print(f"  [red]❌ {msg}[/red]")
def info(msg): console.print(f"  [cyan]ℹ️  {msg}[/cyan]")
def step(msg): console.print(f"\n[bold white]{msg}[/bold white]")


def run(cmd: list, capture=False, timeout=300) -> subprocess.CompletedProcess:
    """Run a command, returning the result."""
    return subprocess.run(
        cmd,
        capture_output=capture,
        text=True,
        timeout=timeout,
        encoding="utf-8",
        errors="replace",
    )


def pip_install(packages: list):
    """Install pip packages quietly."""
    run([sys.executable, "-m", "pip", "install", "-q"] + packages)


ROOT = Path(__file__).parent

# ── Step 1: Python version ────────────────────────────────────────────────────

def check_python():
    step("Step 1/10 — Checking Python version")
    v = sys.version_info
    if v < (3, 9):
        err(f"Python 3.9+ required. You have {v.major}.{v.minor}. Please upgrade.")
        sys.exit(1)
    ok(f"Python {v.major}.{v.minor}.{v.micro}")


# ── Step 2: Python dependencies ───────────────────────────────────────────────

def install_dependencies():
    step("Step 2/10 — Installing Python dependencies")
    req = ROOT / "requirements.txt"
    if not req.exists():
        err("requirements.txt not found!")
        sys.exit(1)

    console.print("  Installing packages (this may take a minute on first run)...")
    result = run([sys.executable, "-m", "pip", "install", "-r", str(req), "-q"])
    if result.returncode != 0:
        err("pip install failed. Check your internet connection.")
        sys.exit(1)

    # Optional extras (non-fatal if unavailable)
    console.print("  Installing optional extras (OCR + vision support)...")
    run([sys.executable, "-m", "pip", "install", "-q",
         "pymupdf", "pytesseract", "Pillow", "ollama",
         "langchain-anthropic", "langchain-openai",
         "langchain-huggingface", "sentence-transformers"])
    ok("All dependencies installed")


# ── Step 3: .env file ─────────────────────────────────────────────────────────

def setup_env():
    step("Step 3/10 — Setting up configuration (.env)")
    env_file     = ROOT / ".env"
    env_example  = ROOT / ".env.example"

    if env_file.exists():
        ok(".env already exists — skipping (not overwriting your config)")
        return

    if not env_example.exists():
        warn(".env.example not found — creating a minimal .env")
        env_file.write_text(
            "LLM_PROVIDER=ollama\n"
            "OLLAMA_BASE_URL=http://localhost:11434\n"
            "OLLAMA_LLM_MODEL=llama3.2\n"
            "OLLAMA_EMBED_MODEL=nomic-embed-text\n"
            "OLLAMA_VISION_MODEL=llava\n"
            "GEMMA_MODEL=gemma3\n"
            "CHUNK_SIZE=800\n"
            "CHUNK_OVERLAP=150\n"
            "TOP_K_RESULTS=8\n"
            "SECURITY_STORE_PATH=./vectorstore/security\n"
            "CODE_REVIEW_STORE_PATH=./vectorstore/code_review\n"
            "PDFS_FOLDER=./pdfs\n"
            "ADMIN_PASSWORD=solum-admin\n",
            encoding="utf-8",
        )
    else:
        shutil.copy(env_example, env_file)
        # Ensure new vars are present
        content = env_file.read_text(encoding="utf-8")
        additions = []
        if "SECURITY_STORE_PATH" not in content:
            additions.append("SECURITY_STORE_PATH=./vectorstore/security")
        if "CODE_REVIEW_STORE_PATH" not in content:
            additions.append("CODE_REVIEW_STORE_PATH=./vectorstore/code_review")
        if "OLLAMA_VISION_MODEL" not in content:
            additions.append("OLLAMA_VISION_MODEL=llava")
        if "GEMMA_MODEL" not in content:
            additions.append("GEMMA_MODEL=gemma3")
        if "ADMIN_PASSWORD" not in content:
            additions.append("ADMIN_PASSWORD=solum-admin")
        if additions:
            with open(env_file, "a", encoding="utf-8") as f:
                f.write("\n# Added by setup.py\n")
                for line in additions:
                    f.write(line + "\n")

    ok(".env created from .env.example")
    info("Edit .env to add API keys or change settings")


# ── Step 4: Directories ───────────────────────────────────────────────────────

def create_dirs():
    step("Step 4/10 — Creating required directories")
    dirs = [
        ROOT / "pdfs",
        ROOT / "vectorstore" / "security",
        ROOT / "vectorstore" / "code_review",
    ]
    for d in dirs:
        d.mkdir(parents=True, exist_ok=True)
        ok(f"  {d.relative_to(ROOT)}")


# ── Step 5: Ollama installed? ─────────────────────────────────────────────────

def check_ollama_installed():
    step("Step 5/10 — Checking Ollama installation")
    if shutil.which("ollama"):
        result = run(["ollama", "--version"], capture=True)
        ok(f"Ollama found: {result.stdout.strip()}")
        return True

    err("Ollama is not installed or not in PATH.")
    console.print()
    console.print("  [bold]Please install Ollama:[/bold]")
    if platform.system() == "Windows":
        console.print("  👉  Download from: [link]https://ollama.com/download[/link]")
        console.print("      Run the installer, then re-run this script.")
    elif platform.system() == "Darwin":
        console.print("  👉  Run: [cyan]brew install ollama[/cyan]")
        console.print("      Then re-run this script.")
    else:
        console.print("  👉  Run: [cyan]curl -fsSL https://ollama.com/install.sh | sh[/cyan]")
        console.print("      Then re-run this script.")
    sys.exit(1)


# ── Step 6: Ollama running? ───────────────────────────────────────────────────

def ensure_ollama_running():
    step("Step 6/10 — Ensuring Ollama server is running")

    def _is_running() -> bool:
        try:
            import urllib.request
            urllib.request.urlopen("http://localhost:11434/api/tags", timeout=3)
            return True
        except Exception:
            return False

    if _is_running():
        ok("Ollama server already running")
        return

    info("Starting Ollama server in the background...")
    if platform.system() == "Windows":
        subprocess.Popen(
            ["ollama", "serve"],
            creationflags=subprocess.CREATE_NEW_CONSOLE,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    else:
        subprocess.Popen(
            ["ollama", "serve"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    # Wait up to 15 s for it to come up
    for i in range(15):
        time.sleep(1)
        if _is_running():
            ok("Ollama server started")
            return
        if i % 5 == 4:
            console.print(f"  Waiting for Ollama... ({i+1}s)")

    err("Ollama server didn't start in 15 seconds.")
    info("Try running 'ollama serve' in a separate terminal, then re-run setup.py")
    sys.exit(1)


# ── Step 7: Pull Ollama models ────────────────────────────────────────────────

REQUIRED_MODELS = [
    ("nomic-embed-text", "Embedding model (required for document search)"),
    ("llama3.2",         "Default chat model (free, local)"),
    ("llava",            "Vision model (reads diagrams & tables in PDFs)"),
    ("gemma3",           "Alternative chat model (Google, via Ollama)"),
]


def pull_models():
    step("Step 7/10 — Pulling Ollama models")

    # Get currently available models
    try:
        import urllib.request, json
        with urllib.request.urlopen("http://localhost:11434/api/tags", timeout=10) as r:
            data = json.loads(r.read())
        installed = {m["name"].split(":")[0] for m in data.get("models", [])}
    except Exception:
        installed = set()

    for model, description in REQUIRED_MODELS:
        if model in installed:
            ok(f"{model:25s} already installed")
            continue

        console.print(f"  Pulling [cyan]{model}[/cyan] ({description})...")
        result = run(["ollama", "pull", model], timeout=600)
        if result.returncode == 0:
            ok(f"{model} pulled successfully")
        else:
            warn(f"{model} pull failed — you can pull it later with: ollama pull {model}")


# ── Step 8: Ingest code review rules ─────────────────────────────────────────

def ingest_code_review_rules():
    step("Step 8/10 — Ingesting code review rules")

    os.chdir(ROOT)
    sys.path.insert(0, str(ROOT))

    result = run(
        [sys.executable, "code_review_cli.py", "ingest"],
        capture=False,
        timeout=300,
    )
    if result.returncode == 0:
        ok("Code review rules indexed")
    else:
        warn("Code review ingest had issues — check output above")


# ── Step 9: Ingest security PDFs ──────────────────────────────────────────────

def ingest_security_pdfs():
    step("Step 9/10 — Ingesting security PDFs")

    pdfs_dir = ROOT / "pdfs"
    pdfs = list(pdfs_dir.glob("*.pdf"))

    if not pdfs:
        warn(f"No PDFs found in {pdfs_dir}/")
        info("Drop your security PDFs into the pdfs/ folder and run:")
        info("  python security_cli.py quickstart")
        return

    console.print(f"  Found {len(pdfs)} PDF(s) to index:")
    for p in pdfs:
        console.print(f"    • {p.name}")

    result = run(
        [sys.executable, "-u", "security_cli.py",
         "--db", "./vectorstore/security", "quickstart"],
        capture=False,
        timeout=3600,   # large PDFs with vision can take a long time
    )
    if result.returncode == 0:
        ok("Security PDFs indexed")
    else:
        warn("PDF ingestion had issues — check output above")


# ── Step 10: Verify pipeline ──────────────────────────────────────────────────

def verify_pipeline():
    step("Step 10/10 — Verifying the pipeline")

    os.chdir(ROOT)
    sys.path.insert(0, str(ROOT))

    try:
        # Load .env
        from dotenv import load_dotenv
        load_dotenv(ROOT / ".env")

        from src.llm_config import get_embeddings
        console.print("  Testing embeddings...")
        emb = get_embeddings("ollama")
        vec = emb.embed_query("security incident response")
        if len(vec) > 0:
            ok(f"Embeddings working (vector dim: {len(vec)})")
        else:
            warn("Embeddings returned empty vector")
    except Exception as e:
        warn(f"Embedding test failed: {e}")

    try:
        from src.security.ingestor import SecurityIngestor
        ingestor = SecurityIngestor(persist_dir=str(ROOT / "vectorstore" / "security"))
        count = ingestor.count_documents()
        sources = ingestor.list_sources()
        if count > 0:
            ok(f"Security vector store: {count} chunks, {len(sources)} document(s)")
        else:
            warn("Security vector store is empty — add PDFs to pdfs/ and run: python security_cli.py quickstart")
    except Exception as e:
        warn(f"Vector store check failed: {e}")

    try:
        from src.code_review.ingestor import CodeReviewIngestor
        cr = CodeReviewIngestor()
        count = cr._store._collection.count() if hasattr(cr, "_store") else 0
        if count > 0:
            ok(f"Code review rules store: {count} chunks")
        else:
            warn("Code review rules store is empty")
    except Exception as e:
        warn(f"Code review store check failed: {e}")


# ── Final summary ─────────────────────────────────────────────────────────────

def print_summary():
    console.print()
    console.print(Rule("[bold green]Setup Complete![/bold green]"))
    console.print()

    table = Table(show_header=True, header_style="bold cyan", box=None, padding=(0, 2))
    table.add_column("What to run", style="cyan")
    table.add_column("What it does")

    table.add_row("python app.py",
                  "Launch the browser UI at http://localhost:7860")
    table.add_row("python security_cli.py chat",
                  "Interactive terminal chat with your security docs")
    table.add_row("python security_cli.py ask \"question\"",
                  "Ask a single question from the terminal")
    table.add_row("python security_cli.py status",
                  "Check how many documents are indexed")
    table.add_row("python security_cli.py quickstart",
                  "Re-scan pdfs/ and index any new PDFs")
    table.add_row("python code_review_cli.py scan ./src",
                  "Run code review on your source files")

    console.print(table)
    console.print()

    console.print(Panel(
        "[bold]Admin Mode (UI)[/bold]\n"
        "Click [cyan]🔒[/cyan] in the Security chat header\n"
        f"Password: [yellow]{os.getenv('ADMIN_PASSWORD', 'solum-admin')}[/yellow]  "
        "(change via [cyan]ADMIN_PASSWORD[/cyan] in .env)\n\n"
        "[bold]Add more PDFs[/bold]\n"
        "Drop PDFs into [cyan]pdfs/[/cyan] and run: [cyan]python security_cli.py quickstart[/cyan]",
        title="[bold green]Quick Reference[/bold green]",
        border_style="green",
    ))


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    console.print(Panel(
        "[bold]SOLUM AI Platform — Automated Setup[/bold]\n\n"
        "This script will set up everything you need to run the platform.\n"
        "It is safe to run multiple times — it skips steps that are already done.",
        border_style="blue",
        title="[bold blue]setup.py[/bold blue]",
    ))

    check_python()
    install_dependencies()
    setup_env()
    create_dirs()
    check_ollama_installed()
    ensure_ollama_running()
    pull_models()
    ingest_code_review_rules()
    ingest_security_pdfs()
    verify_pipeline()
    print_summary()


if __name__ == "__main__":
    main()
