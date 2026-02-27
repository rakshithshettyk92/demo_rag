"""
src/code_review/ingestor.py
----------------------------
Ingests rule documents (Markdown / PDF) into the 'code_review_rules' ChromaDB
collection. Completely isolated from the 'security_docs' collection.

Usage:
    from src.code_review.ingestor import CodeReviewIngestor
    ingestor = CodeReviewIngestor()
    ingestor.ingest_rules()          # ingest built-in rules
    ingestor.ingest_rules("./my_rules")  # ingest custom rules folder
"""

import os
import sys
from pathlib import Path
from typing import List

from dotenv import load_dotenv
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_chroma import Chroma
from langchain_core.documents import Document

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from src.llm_config import get_embeddings

load_dotenv()

CHUNK_SIZE    = int(os.getenv("CHUNK_SIZE", 800))
CHUNK_OVERLAP = int(os.getenv("CHUNK_OVERLAP", 150))
DB_PATH       = os.getenv("CODE_REVIEW_STORE_PATH", "./vectorstore/code_review")

COLLECTION_NAME = "code_review_rules"

# Language detection: rule filename prefix → language tag
RULE_LANGUAGE_MAP = {
    "sonar_python": "python",
    "pep8":         "python",
    "java_sonar":   "java",
    "java_style":   "java",
    "javascript":   "javascript",
    "react":        "react",
    "owasp":        "general",   # OWASP rules apply to all languages
}

# Default rules directory bundled with this feature
DEFAULT_RULES_DIR = Path(__file__).parent / "rules"


class CodeReviewIngestor:
    def __init__(self, persist_dir: str = DB_PATH, embed_provider: str = None):
        self.persist_dir = persist_dir
        self.embeddings  = get_embeddings(embed_provider)
        self.splitter    = RecursiveCharacterTextSplitter(
            chunk_size=CHUNK_SIZE,
            chunk_overlap=CHUNK_OVERLAP,
            separators=["\n## RULE:", "\n### ", "\n\n", "\n", ". ", " ", ""],
        )
        os.makedirs(persist_dir, exist_ok=True)
        print(f"📦 Code Review Vector store: {persist_dir}")
        print(f"   Collection: {COLLECTION_NAME}")

    # ── Load Markdown files ───────────────────────────────────────────────────

    def _detect_language(self, filename: str) -> str:
        """Detect language tag from rule filename prefix."""
        name = filename.lower()
        for prefix, lang in RULE_LANGUAGE_MAP.items():
            if name.startswith(prefix):
                return lang
        return "general"

    def _load_markdown(self, path: Path) -> List[Document]:
        """Load a Markdown file as a single Document with language metadata."""
        text = path.read_text(encoding="utf-8")
        lang = self._detect_language(path.stem)
        return [Document(
            page_content=text,
            metadata={"source": str(path), "filename": path.name, "language": lang},
        )]

    def _load_pdf(self, path: Path) -> List[Document]:
        """Load a PDF file using PyPDFLoader with language metadata."""
        try:
            from langchain_community.document_loaders import PyPDFLoader
            lang  = self._detect_language(path.stem)
            pages = PyPDFLoader(str(path)).load()
            for p in pages:
                p.metadata["filename"] = path.name
                p.metadata["language"] = lang
            return pages
        except Exception as e:
            print(f"  ⚠️  Could not load PDF {path.name}: {e}")
            return []

    # ── Chunk & save ─────────────────────────────────────────────────────────

    def _chunk_and_save(self, docs: List[Document]) -> int:
        if not docs:
            return 0
        chunks = self.splitter.split_documents(docs)
        print(f"     → {len(chunks)} chunks")
        Chroma.from_documents(
            documents=chunks,
            embedding=self.embeddings,
            persist_directory=self.persist_dir,
            collection_name=COLLECTION_NAME,
        )
        return len(chunks)

    # ── Single file ingestion (used by CLI tracker) ───────────────────────────

    def ingest_file(self, file_path: str) -> int:
        """
        Ingest a single rule file (.md or .pdf) into the collection.
        Used by the CLI when the tracker detects a new or changed file.

        Returns:
            Number of chunks indexed, or 0 on failure.
        """
        path = Path(file_path)
        if not path.exists():
            print(f"  ⚠️  File not found: {file_path}")
            return 0

        lang = self._detect_language(path.stem)
        print(f"  📄 {path.name}  [{lang}]")

        if path.suffix.lower() == ".md":
            docs = self._load_markdown(path)
        else:
            docs = self._load_pdf(path)

        return self._chunk_and_save(docs)

    # ── Main ingestion ────────────────────────────────────────────────────────

    def ingest_rules(self, rules_dir: str = None) -> int:
        """
        Ingest all .md and .pdf files from rules_dir into the
        'code_review_rules' collection.

        Args:
            rules_dir: Path to folder with rule files.
                       Defaults to src/code_review/rules/ (built-in rules).

        Returns:
            Total number of chunks indexed.
        """
        folder = Path(rules_dir) if rules_dir else DEFAULT_RULES_DIR
        if not folder.exists():
            print(f"⚠️  Rules folder not found: {folder}")
            return 0

        md_files  = list(folder.glob("*.md"))
        pdf_files = list(folder.glob("*.pdf"))
        all_files = md_files + pdf_files

        # Exclude the README from ingestion (it's a format guide, not rules)
        all_files = [f for f in all_files if f.name.lower() != "readme.md"]

        if not all_files:
            print(f"⚠️  No rule files found in: {folder}")
            return 0

        print(f"\n🔄 Ingesting {len(all_files)} rule file(s) into '{COLLECTION_NAME}'...")
        total = 0

        for f in all_files:
            lang = self._detect_language(f.stem)
            print(f"  📄 {f.name}  [{lang}]")
            if f.suffix.lower() == ".md":
                docs = self._load_markdown(f)
            else:
                docs = self._load_pdf(f)
            total += self._chunk_and_save(docs)

        print(f"\n✅ Done! {total} rule chunks indexed into '{COLLECTION_NAME}'")
        return total

    # ── Utility ───────────────────────────────────────────────────────────────

    def get_vectorstore(self) -> Chroma:
        return Chroma(
            persist_directory=self.persist_dir,
            embedding_function=self.embeddings,
            collection_name=COLLECTION_NAME,
        )

    def count_rules(self) -> int:
        try:
            return self.get_vectorstore()._collection.count()
        except Exception:
            return 0

    def clear_rules(self):
        """Delete all chunks from the code_review_rules collection."""
        try:
            vs = self.get_vectorstore()
            ids = vs._collection.get()["ids"]
            if ids:
                vs._collection.delete(ids=ids)
                print(f"🗑️  Cleared {len(ids)} chunks from '{COLLECTION_NAME}'")
        except Exception as e:
            print(f"⚠️  Could not clear collection: {e}")
