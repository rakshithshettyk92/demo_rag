"""
src/security/rag_chain.py
--------------------------
The Security Q&A RAG pipeline: retrieves relevant chunks from ChromaDB
and sends them with the question to the LLM.
"""

import os
import sys
from pathlib import Path
from typing import Dict, Any
from dotenv import load_dotenv

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough
from langchain_core.output_parsers import StrOutputParser
from langchain_chroma import Chroma

from src.llm_config import get_llm, get_embeddings

load_dotenv()

TOP_K   = int(os.getenv("TOP_K_RESULTS", 8))
DB_PATH = os.getenv("SECURITY_STORE_PATH", "./vectorstore/security")

# Common security abbreviations → full form.
# Used to expand the query before retrieval so the embedding search
# can match chunks that use the full term instead of the abbreviation.
SECURITY_ABBREVIATIONS = {
    "ciso":  "Chief Information Security Officer",
    "cto":   "Chief Technology Officer",
    "ceo":   "Chief Executive Officer",
    "coo":   "Chief Operating Officer",
    "ir":    "incident response",
    "iam":   "identity and access management",
    "dlp":   "data loss prevention",
    "siem":  "security information and event management",
    "soc":   "security operations center",
    "mfa":   "multi-factor authentication",
    "vpn":   "virtual private network",
    "pii":   "personally identifiable information",
    "gdpr":  "general data protection regulation",
    "dr":    "disaster recovery",
    "bcp":   "business continuity plan",
    "rto":   "recovery time objective",
    "rpo":   "recovery point objective",
}


def expand_query(question: str) -> str:
    """
    Expand abbreviations in the query before retrieval.
    Documents often use the full term; queries often use the short form.
    Appending the full form ensures the embedding search finds both.
    """
    expanded = question
    lower_q  = question.lower()
    for abbrev, full in SECURITY_ABBREVIATIONS.items():
        # Match whole word only (avoids expanding "ir" inside "first")
        import re
        if re.search(rf"\b{abbrev}\b", lower_q):
            expanded += f" ({full})"
    return expanded

# The exact phrase the LLM must use — and that app.py watches for.
NOT_FOUND_PREFIX = "NOT FOUND IN DOCUMENTATION"

SECURITY_PROMPT = """You are a cybersecurity assistant. \
Your ONLY knowledge source is the documentation excerpts provided below.

STRICT RULES — follow without exception:
0. Sections marked [ADMIN VERIFIED CORRECTION] are the highest-priority source. \
   They represent manually verified answers — always use them when present and treat them as definitive.
1. Use ONLY the context below. Never use outside knowledge, training data, or assumptions.
2. If the context contains a clear answer, provide it and cite the exact source document and page number for every claim.
3. IMPORTANT — if multiple source documents give DIFFERENT values for the same thing (e.g. different names, dates, or roles), report ALL of them. State which document says what, and note that the documents differ. Do not pick just one.
4. If the context partially answers the question, answer only the covered part, then explicitly state: "Note: The documentation does not cover [the missing part]."
5. If the context contains NO relevant information, respond with exactly this prefix and nothing else fabricated:
   "NOT FOUND IN DOCUMENTATION: The indexed security documents do not contain information about this topic."
6. Never use words like "typically", "generally", or "usually" unless that exact phrasing appears in the context.
7. Never infer, extrapolate, or fill gaps — if it is not written in the context, it does not exist.
8. Do not repeat or rephrase the question back. Go straight to the answer or the not-found statement.

Context from security documentation:
{context}

Question: {question}

Answer (cite source file and page for every factual claim):"""


MIN_CHUNK_CHARS = 80  # skip near-empty chunks like "THANK YOU" or TOC lines


def format_docs(docs) -> str:
    if not docs:
        return "[NO RELEVANT DOCUMENTATION FOUND]"
    formatted = []
    i = 1
    for doc in docs:
        content = doc.page_content.strip()
        if len(content) < MIN_CHUNK_CHARS:   # filter noise / near-empty chunks
            continue
        source = os.path.basename(doc.metadata.get("source", "unknown"))
        page   = doc.metadata.get("page", "?")
        formatted.append(f"[Source {i}: {source}, page {page}]\n{content}")
        i += 1
    if not formatted:
        return "[NO RELEVANT DOCUMENTATION FOUND]"
    return "\n\n---\n\n".join(formatted)


class SecurityRAGChain:
    def __init__(
        self,
        llm_provider: str = None,
        persist_dir: str = DB_PATH,
        collection_name: str = "security_docs",
    ):
        print("🔧 Building Security RAG Chain...")

        self.llm        = get_llm(llm_provider)
        self.embeddings = get_embeddings(llm_provider)

        self.vectorstore = Chroma(
            persist_directory=persist_dir,
            embedding_function=self.embeddings,
            collection_name=collection_name,
        )

        doc_count = self.vectorstore._collection.count()
        print(f"📚 Vector store loaded: {doc_count} chunks available")

        if doc_count == 0:
            print("⚠️  WARNING: No documents indexed yet! Run quickstart.py first.")

        # Corrections store — admin-verified overrides, same persist_dir
        try:
            from src.security.corrections import CorrectionsStore
            self._corrections = CorrectionsStore(
                persist_dir=persist_dir,
                embeddings=self.embeddings,
            )
            n = self._corrections.count()
            if n:
                print(f"✏️  Corrections loaded: {n} admin-verified answer(s)")
        except Exception as e:
            print(f"⚠️  Corrections store unavailable: {e}")
            self._corrections = None

        # MMR (Maximum Marginal Relevance): fetches fetch_k candidates by similarity,
        # then selects k diverse ones. Prevents returning 10 chunks from the same
        # document section and ensures results span different parts of the corpus.
        self.retriever = self.vectorstore.as_retriever(
            search_type="mmr",
            search_kwargs={"k": TOP_K, "fetch_k": TOP_K * 4},
        )

        self.prompt = ChatPromptTemplate.from_template(SECURITY_PROMPT)
        self._build_chain()
        print("✅ RAG Chain ready!\n")

    def _build_chain(self):
        self.chain = (
            {
                "context":  self.retriever | format_docs,
                "question": RunnablePassthrough(),
            }
            | self.prompt
            | self.llm
            | StrOutputParser()
        )

    def _get_correction_context(self, question: str) -> str:
        """Return formatted admin corrections for this question, or empty string."""
        if not self._corrections:
            return ""
        try:
            corr_docs = self._corrections.search(question, k=2)
            if not corr_docs:
                return ""
            parts = [
                f"[ADMIN VERIFIED CORRECTION — treat as authoritative]\n{d.page_content}"
                for d in corr_docs
            ]
            return "\n\n---\n\n".join(parts) + "\n\n---\n\n"
        except Exception:
            return ""

    def _retrieve(self, question: str):
        """Retrieve docs once and cache them for the current turn.
        Query is expanded first to handle abbreviations like CISO, MFA, DR, etc."""
        expanded = expand_query(question)
        docs = self.retriever.invoke(expanded)
        self._last_docs = docs
        return docs

    def ask(self, question: str, return_sources: bool = True) -> Dict[str, Any]:
        correction_ctx = self._get_correction_context(question)
        docs    = self._retrieve(question)
        context = correction_ctx + format_docs(docs)
        answer  = (
            {"context": lambda _: context, "question": RunnablePassthrough()}
            | self.prompt
            | self.llm
            | StrOutputParser()
        ).invoke(question)

        result = {"answer": answer, "question": question}
        if return_sources:
            result["sources"] = [
                {
                    "source":  os.path.basename(doc.metadata.get("source", "unknown")),
                    "page":    doc.metadata.get("page", "?"),
                    "excerpt": doc.page_content[:300] + "...",
                }
                for doc in docs
            ]
        return result

    def ask_stream(self, question: str):
        """
        Retrieve docs once, store them in self._last_docs, then stream the answer.
        If no docs pass the similarity threshold, yield a not-found message immediately
        without calling the LLM at all.
        """
        correction_ctx = self._get_correction_context(question)
        docs = self._retrieve(question)

        if not docs and not correction_ctx:
            yield (
                f"**{NOT_FOUND_PREFIX}**\n\n"
                "No sections in the indexed security documents matched your question "
                "with sufficient relevance. Try rephrasing, or check that the relevant "
                "document has been ingested."
            )
            return

        context = correction_ctx + format_docs(docs)
        stream_chain = (
            {"context": lambda _: context, "question": RunnablePassthrough()}
            | self.prompt
            | self.llm
            | StrOutputParser()
        )
        yield from stream_chain.stream(question)

    def switch_provider(self, provider: str):
        print(f"🔄 Switching LLM to: {provider}")
        self.llm = get_llm(provider)
        self._build_chain()
        print(f"✅ Now using: {provider}")
