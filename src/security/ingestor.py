"""
src/security/ingestor.py
------------------------
Handles loading PDFs, splitting into chunks, and saving to ChromaDB
for the Security Q&A feature.

Three extraction layers (each is optional, gracefully skipped if unavailable):

  1. Text (PyPDFLoader)
       Extracts all selectable/digital text. Fast, always runs.

  2. OCR (pymupdf + pytesseract)
       Renders pages as images and reads text with OCR.
       Catches text embedded inside image layers (scanned inserts, stamps).
       Only adds chunks for pages where OCR finds substantially more than PyPDF.
       Requires: pip install pymupdf pytesseract
                 + Tesseract engine: https://github.com/UB-Mannheim/tesseract/wiki

  3. Vision LLM (pymupdf + Ollama llava)
       Sends page images to a local vision model which UNDERSTANDS structure:
       tables → row/column data, flowcharts → steps & decisions, org charts → hierarchy.
       Only runs on pages that contain embedded images or vector diagrams.
       Requires: ollama pull llava   (or set OLLAMA_VISION_MODEL in .env)
"""

import io
import os
import sys
from pathlib import Path
from typing import List, Tuple
from dotenv import load_dotenv

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from langchain_community.document_loaders import PyPDFLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_chroma import Chroma
from langchain_core.documents import Document

from src.llm_config import get_embeddings

load_dotenv()

CHUNK_SIZE                = int(os.getenv("CHUNK_SIZE", 800))
CHUNK_OVERLAP             = int(os.getenv("CHUNK_OVERLAP", 150))
DB_PATH                   = os.getenv("VECTORSTORE_PATH", "./vectorstore")
OCR_EXTRA_CHARS_THRESHOLD = int(os.getenv("OCR_EXTRA_CHARS_THRESHOLD", 150))
OCR_DPI                   = int(os.getenv("OCR_DPI", 200))
OLLAMA_VISION_MODEL       = os.getenv("OLLAMA_VISION_MODEL", "llava")
OLLAMA_BASE_URL           = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
TESSERACT_CMD             = os.getenv("TESSERACT_CMD", "")  # e.g. C:\Program Files\Tesseract-OCR\tesseract.exe

# Prompt sent to the vision LLM for each image-heavy page.
VISION_PROMPT = """\
You are analyzing a page from a security policy or procedure document.
Extract ALL structured information visible on this page.

Rules:
- Tables: describe every row with its column values (e.g. "Name: HJ Lee | Role: CISO | Email: ...").
- Flowcharts / process diagrams: list each step in order and describe the connections or decisions between them.
- Org charts: describe the hierarchy and who reports to whom.
- Text inside boxes, callouts, or shapes: include it verbatim.
- If the page contains only regular paragraphs of text with no tables or diagrams, reply with exactly: TEXT_ONLY

Output plain text only — no markdown, no bullet points."""


# ── Availability checks ───────────────────────────────────────────────────────

def _ocr_available() -> Tuple[bool, str]:
    """Return (True, '') if OCR deps are ready, else (False, reason)."""
    try:
        import fitz  # noqa: F401
    except ImportError:
        return False, "pymupdf not installed — run: pip install pymupdf"
    try:
        import pytesseract
        # Point pytesseract at the executable if a path is given in .env
        if TESSERACT_CMD:
            pytesseract.pytesseract.tesseract_cmd = TESSERACT_CMD
        pytesseract.get_tesseract_version()
    except ImportError:
        return False, "pytesseract not installed — run: pip install pytesseract"
    except Exception:
        return False, (
            "Tesseract engine not found.\n"
            f"     TESSERACT_CMD in .env: '{TESSERACT_CMD or 'not set'}'\n"
            "     Windows: set TESSERACT_CMD=C:\\Program Files\\Tesseract-OCR\\tesseract.exe in .env"
        )
    return True, ""


def _vision_available() -> Tuple[bool, str]:
    """Return (True, '') if Ollama vision is ready, else (False, reason)."""
    try:
        import fitz  # noqa: F401
    except ImportError:
        return False, "pymupdf not installed — run: pip install pymupdf"
    try:
        import ollama
        models = [m["model"] for m in ollama.list().get("models", [])]
        if not any(OLLAMA_VISION_MODEL.split(":")[0] in m for m in models):
            return False, (
                f"Vision model '{OLLAMA_VISION_MODEL}' not pulled.\n"
                f"     Run: ollama pull {OLLAMA_VISION_MODEL}"
            )
        return True, ""
    except ImportError:
        return False, "ollama package not installed — run: pip install ollama"
    except Exception as e:
        return False, f"Ollama not reachable: {e}"


# ── Ingestor ──────────────────────────────────────────────────────────────────

class SecurityIngestor:
    def __init__(self, persist_dir: str = DB_PATH, embed_provider: str = None):
        self.persist_dir = persist_dir
        self.embeddings  = get_embeddings(embed_provider)
        self.splitter    = RecursiveCharacterTextSplitter(
            chunk_size=CHUNK_SIZE,
            chunk_overlap=CHUNK_OVERLAP,
            separators=["\n\n", "\n", ". ", "! ", "? ", " ", ""],
        )
        os.makedirs(persist_dir, exist_ok=True)

        self._ocr_ready,    self._ocr_reason    = _ocr_available()
        self._vision_ready, self._vision_reason = _vision_available()

        ocr_status    = "enabled" if self._ocr_ready    else f"disabled ({self._ocr_reason})"
        vision_status = "enabled" if self._vision_ready else f"disabled ({self._vision_reason})"
        print(f"📦 Vector store: {persist_dir}")
        print(f"   OCR:    {ocr_status}")
        print(f"   Vision: {vision_status}")

    # ── Layer 1: Text ─────────────────────────────────────────────────────────

    def load_pdf(self, pdf_path: str) -> List[Document]:
        path = Path(pdf_path)
        if not path.exists():
            raise FileNotFoundError(f"PDF not found: {pdf_path}")
        print(f"  📄 Loading: {path.name}")
        loader = PyPDFLoader(str(path))
        pages  = loader.load()
        print(f"     → {len(pages)} pages (text)")
        return pages

    # ── Layer 2: OCR ──────────────────────────────────────────────────────────

    def extract_ocr_chunks(self, pdf_path: str, pypdf_pages: List[Document]) -> List[Document]:
        """
        Render each page as an image, OCR it, and return extra Document objects
        only for pages where OCR found substantially more text than PyPDF.
        These are pages with text baked into image layers (stamps, scanned inserts).
        """
        if not self._ocr_ready:
            return []

        import fitz
        import pytesseract
        from PIL import Image

        if TESSERACT_CMD:
            pytesseract.pytesseract.tesseract_cmd = TESSERACT_CMD

        pypdf_by_page = {
            doc.metadata.get("page", i): doc.page_content
            for i, doc in enumerate(pypdf_pages)
        }

        ocr_docs = []
        matrix   = fitz.Matrix(OCR_DPI / 72, OCR_DPI / 72)
        pdf_doc  = fitz.open(pdf_path)

        for page_num, page in enumerate(pdf_doc):
            pix      = page.get_pixmap(matrix=matrix)
            img      = Image.open(io.BytesIO(pix.tobytes("png")))
            ocr_text = pytesseract.image_to_string(img).strip()
            pypdf_text = pypdf_by_page.get(page_num, "").strip()
            extra      = len(ocr_text) - len(pypdf_text)

            if extra >= OCR_EXTRA_CHARS_THRESHOLD:
                ocr_docs.append(Document(
                    page_content=ocr_text,
                    metadata={
                        "source":            pdf_path,
                        "page":              page_num,
                        "extraction_method": "ocr",
                    },
                ))
                print(f"     → Page {page_num}: OCR +{extra} chars (image text)")

        pdf_doc.close()
        return ocr_docs

    # ── Layer 3: Vision LLM ───────────────────────────────────────────────────

    def extract_vision_chunks(self, pdf_path: str, pypdf_pages: List[Document]) -> List[Document]:
        """
        For pages that contain embedded images or have sparse PyPDF text,
        render the page and send it to the Ollama vision model.
        The model describes tables row-by-row, flowchart steps in order,
        and org-chart hierarchies — producing structured, searchable text.
        """
        if not self._vision_ready:
            return []

        import fitz
        import ollama

        pypdf_by_page = {
            doc.metadata.get("page", i): doc.page_content
            for i, doc in enumerate(pypdf_pages)
        }

        vision_docs = []
        matrix      = fitz.Matrix(OCR_DPI / 72, OCR_DPI / 72)
        pdf_doc     = fitz.open(pdf_path)

        for page_num, page in enumerate(pdf_doc):
            pypdf_text = pypdf_by_page.get(page_num, "").strip()
            has_images = bool(page.get_images())
            is_sparse  = len(pypdf_text) < 200

            # Only send to vision if the page has embedded images or is sparse
            if not has_images and not is_sparse:
                continue

            pix      = page.get_pixmap(matrix=matrix)
            img_bytes = pix.tobytes("png")

            try:
                response    = ollama.chat(
                    model=OLLAMA_VISION_MODEL,
                    messages=[{
                        "role":    "user",
                        "content": VISION_PROMPT,
                        "images":  [img_bytes],
                    }],
                )
                description = response["message"]["content"].strip()

                if not description or description == "TEXT_ONLY":
                    continue

                vision_docs.append(Document(
                    page_content=description,
                    metadata={
                        "source":            pdf_path,
                        "page":              page_num,
                        "extraction_method": "vision",
                    },
                ))
                print(f"     → Page {page_num}: Vision extracted structured content "
                      f"({'images' if has_images else 'sparse page'})")

            except Exception as e:
                print(f"     ⚠️  Vision failed on page {page_num}: {e}")

        pdf_doc.close()
        return vision_docs

    # ── Chunking & storage ────────────────────────────────────────────────────

    def chunk_documents(self, documents: List[Document]) -> List[Document]:
        chunks = self.splitter.split_documents(documents)
        print(f"     → {len(chunks)} chunks")
        return chunks

    def save_to_vectorstore(self, chunks: List[Document], collection_name: str = "security_docs"):
        vectorstore = Chroma.from_documents(
            documents=chunks,
            embedding=self.embeddings,
            persist_directory=self.persist_dir,
            collection_name=collection_name,
        )
        print(f"     ✅ Saved to ChromaDB: '{collection_name}'")
        return vectorstore

    # ── Merge OCR + Vision for the same page ─────────────────────────────────

    def _merge_ocr_and_vision(
        self,
        ocr_docs: List[Document],
        vision_docs: List[Document],
    ) -> List[Document]:
        """
        For pages that both OCR and Vision processed, merge their outputs into
        one Document per page instead of two separate ones.

        Vision provides structured understanding (tables, flowcharts, hierarchy).
        OCR provides raw character accuracy (exact names, emails, numbers).
        Together they give the retriever richer, more searchable content.

        Pages only covered by one layer are kept as-is.
        """
        ocr_by_page    = {d.metadata["page"]: d for d in ocr_docs}
        vision_by_page = {d.metadata["page"]: d for d in vision_docs}

        merged   = []
        all_pages = sorted(set(ocr_by_page) | set(vision_by_page))

        for page_num in all_pages:
            ocr_doc    = ocr_by_page.get(page_num)
            vision_doc = vision_by_page.get(page_num)

            if ocr_doc and vision_doc:
                # Both available — combine into one richer document
                combined_text = (
                    "[Structured content from Vision model]\n"
                    f"{vision_doc.page_content}\n\n"
                    "[Raw text from OCR]\n"
                    f"{ocr_doc.page_content}"
                )
                merged.append(Document(
                    page_content=combined_text,
                    metadata={
                        **vision_doc.metadata,
                        "extraction_method": "vision+ocr",
                    },
                ))
                print(f"     → Page {page_num}: merged Vision + OCR into one chunk")
            elif vision_doc:
                merged.append(vision_doc)
            else:
                merged.append(ocr_doc)

        return merged

    # ── Main pipeline ─────────────────────────────────────────────────────────

    def ingest_pdf(self, pdf_path: str, collection_name: str = "security_docs") -> int:
        """
        Full pipeline: PDF → text + merged(OCR + Vision) chunks → ChromaDB.

        Layer 1 — Text (PyPDF):  always runs, extracts selectable text.
        Layer 2 — OCR:           catches text baked into image layers.
        Layer 3 — Vision LLM:    describes tables, flowcharts, org charts.
        Layers 2+3 are merged per-page so each image-heavy page produces
        one rich chunk instead of two redundant ones.

        Returns total chunks indexed, or -1 if nothing could be extracted.
        """
        pdf_name = Path(pdf_path).name
        print(f"\n🔄 Ingesting: {pdf_name}")

        pages    = self.load_pdf(pdf_path)
        has_text = bool("".join(p.page_content for p in pages).strip())
        all_chunks: List[Document] = []

        # Layer 1: selectable text
        if has_text:
            all_chunks.extend(self.chunk_documents(pages))
        else:
            print("  ℹ️  No selectable text — relying on OCR / Vision.")

        # Layers 2 + 3: run both, then merge per-page
        ocr_docs    = self.extract_ocr_chunks(pdf_path, pages)    if self._ocr_ready    else []
        vision_docs = self.extract_vision_chunks(pdf_path, pages) if self._vision_ready else []

        if ocr_docs or vision_docs:
            if ocr_docs and vision_docs:
                # Merge: one chunk per image-heavy page with both outputs
                image_docs = self._merge_ocr_and_vision(ocr_docs, vision_docs)
                print(f"  🔀 Merged OCR + Vision: {len(image_docs)} page(s) combined.")
            elif vision_docs:
                image_docs = vision_docs
                print(f"  👁️  Vision only: {len(vision_docs)} page(s).")
            else:
                image_docs = ocr_docs
                print(f"  🔍 OCR only: {len(ocr_docs)} page(s).")

            all_chunks.extend(self.chunk_documents(image_docs))

        if not all_chunks:
            print(f"  ⚠️  No content extracted from {pdf_name} — skipping.")
            return -1

        self.save_to_vectorstore(all_chunks, collection_name)
        print(f"  ✅ Done! {len(all_chunks)} total chunks indexed.")
        return len(all_chunks)

    def ingest_folder(self, folder_path: str, collection_name: str = "security_docs") -> int:
        folder = Path(folder_path)
        pdfs   = list(folder.glob("*.pdf"))
        if not pdfs:
            print(f"⚠️  No PDFs found in: {folder_path}")
            return 0
        total = 0
        for pdf in pdfs:
            result = self.ingest_pdf(str(pdf), collection_name)
            if result > 0:
                total += result
        print(f"\n✅ Total: {total} chunks indexed")
        return total

    # ── Utility ───────────────────────────────────────────────────────────────

    def get_vectorstore(self, collection_name: str = "security_docs") -> Chroma:
        return Chroma(
            persist_directory=self.persist_dir,
            embedding_function=self.embeddings,
            collection_name=collection_name,
        )

    def count_documents(self, collection_name: str = "security_docs") -> int:
        try:
            vs = self.get_vectorstore(collection_name)
            return vs._collection.count()
        except Exception:
            return 0

    def list_sources(self, collection_name: str = "security_docs") -> List[str]:
        try:
            vs      = self.get_vectorstore(collection_name)
            results = vs._collection.get(include=["metadatas"])
            sources = sorted(set(m.get("source", "unknown") for m in results["metadatas"]))
            return [Path(s).name for s in sources]
        except Exception:
            return []
