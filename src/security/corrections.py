"""
src/security/corrections.py
----------------------------
Stores admin-verified answer corrections in a dedicated ChromaDB collection.
Corrections are retrieved at query time and injected as highest-priority context,
overriding or augmenting answers from the regular document index.
"""

import os
import sys
import uuid
from datetime import datetime
from pathlib import Path
from typing import List, Dict

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent))

from dotenv import load_dotenv
from langchain_chroma import Chroma
from langchain_core.documents import Document

load_dotenv()

DB_PATH         = os.getenv("SECURITY_STORE_PATH", "./vectorstore/security")
COLLECTION_NAME = "security_corrections"


class CorrectionsStore:
    def __init__(
        self,
        persist_dir: str = DB_PATH,
        embeddings=None,
        embed_provider: str = None,
    ):
        if embeddings is None:
            from src.llm_config import get_embeddings
            embeddings = get_embeddings(embed_provider)

        self._store = Chroma(
            persist_directory=persist_dir,
            embedding_function=embeddings,
            collection_name=COLLECTION_NAME,
        )

    def add(
        self,
        question: str,
        correct_answer: str,
        corrected_by: str = "admin",
        source_ref: str = "",
    ) -> str:
        """Save a correction and return its ID."""
        cid = str(uuid.uuid4())
        self._store.add_documents(
            documents=[Document(
                page_content=f"Q: {question}\nA: {correct_answer}",
                metadata={
                    "correction_id":     cid,
                    "original_question": question,
                    "correct_answer":    correct_answer,
                    "corrected_by":      corrected_by,
                    "source_ref":        source_ref,
                    "timestamp":         datetime.now().isoformat(),
                },
            )],
            ids=[cid],
        )
        return cid

    def search(self, question: str, k: int = 2) -> List[Document]:
        """Find corrections relevant to a question."""
        try:
            if self._store._collection.count() == 0:
                return []
            return self._store.similarity_search(question, k=k)
        except Exception:
            return []

    def list_all(self) -> List[Dict]:
        """Return all corrections sorted newest first."""
        try:
            r = self._store._collection.get(include=["metadatas"])
            items = [
                {
                    "id":         m.get("correction_id", ""),
                    "question":   m.get("original_question", ""),
                    "answer":     m.get("correct_answer", ""),
                    "by":         m.get("corrected_by", ""),
                    "timestamp":  m.get("timestamp", ""),
                    "source_ref": m.get("source_ref", ""),
                }
                for m in r["metadatas"]
            ]
            return sorted(items, key=lambda x: x["timestamp"], reverse=True)
        except Exception:
            return []

    def delete(self, correction_id: str):
        """Delete a correction by its full ID."""
        try:
            self._store.delete([correction_id])
        except Exception:
            pass

    def count(self) -> int:
        try:
            return self._store._collection.count()
        except Exception:
            return 0
