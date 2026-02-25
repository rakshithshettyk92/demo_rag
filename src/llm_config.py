"""
src/llm_config.py
-----------------
Central AI provider selector.
Supported providers:
    ollama      - any Ollama model (llama3.2, gemma2, mistral, phi3, etc.) FREE
    gemma       - shortcut for Ollama + Gemma2 model FREE
    anthropic   - Claude (needs API key)
    openai      - GPT (needs API key)
"""

import os
import sys
from pathlib import Path
from dotenv import load_dotenv

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

load_dotenv()

PROVIDER     = os.getenv("LLM_PROVIDER", "ollama").lower()
OLLAMA_URL   = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
OLLAMA_LLM   = os.getenv("OLLAMA_LLM_MODEL", "llama3.2")
OLLAMA_EMBED = os.getenv("OLLAMA_EMBED_MODEL", "nomic-embed-text")
GEMMA_MODEL  = os.getenv("GEMMA_MODEL", "gemma2:2b")  # gemma2:2b | gemma2 | gemma2:27b


def get_llm(provider: str = None, temperature: float = 0.0):
    """
    Returns a LangChain LLM object for the given provider.

    Usage:
        get_llm()               # uses LLM_PROVIDER from .env
        get_llm("ollama")       # Ollama with OLLAMA_LLM_MODEL from .env
        get_llm("gemma")        # Ollama with GEMMA_MODEL from .env
        get_llm("anthropic")    # Claude (needs ANTHROPIC_API_KEY)
        get_llm("openai")       # GPT (needs OPENAI_API_KEY)
    """
    provider = (provider or PROVIDER).lower()

    # ── FREE: Ollama (llama3.2, mistral, phi3, etc.) ─────────
    if provider == "ollama":
        try:
            from langchain_ollama import ChatOllama
            print(f"🤖 LLM: Ollama / {OLLAMA_LLM} (FREE, local)")
            return ChatOllama(
                base_url=OLLAMA_URL,
                model=OLLAMA_LLM,
                temperature=temperature,
            )
        except ImportError:
            raise ImportError("Run: pip install langchain-ollama")

    # ── FREE: Gemma (Google, via Ollama) ─────────────────────
    elif provider == "gemma":
        try:
            from langchain_ollama import ChatOllama
            print(f"🤖 LLM: Gemma / {GEMMA_MODEL} (FREE, local via Ollama)")
            print(f"   💡 To change model size set GEMMA_MODEL in .env")
            print(f"      Options: gemma2:2b (fastest) | gemma2 (balanced) | gemma2:27b (best)")
            return ChatOllama(
                base_url=OLLAMA_URL,
                model=GEMMA_MODEL,
                temperature=temperature,
            )
        except ImportError:
            raise ImportError("Run: pip install langchain-ollama")

    # ── PAID: Claude (Anthropic) ─────────────────────────────
    elif provider == "anthropic":
        api_key = os.getenv("ANTHROPIC_API_KEY")
        if not api_key:
            raise ValueError(
                "ANTHROPIC_API_KEY not set in .env\n"
                "Get your key at: https://console.anthropic.com\n"
                "For free use: switch to provider='ollama' or provider='gemma'"
            )
        try:
            from langchain_anthropic import ChatAnthropic
            model = os.getenv("ANTHROPIC_MODEL", "claude-haiku-4-5-20251001")
            print(f"🤖 LLM: Claude / {model}")
            return ChatAnthropic(api_key=api_key, model=model, temperature=temperature)
        except ImportError:
            raise ImportError("Run: pip install langchain-anthropic")

    # ── PAID: OpenAI ─────────────────────────────────────────
    elif provider == "openai":
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError(
                "OPENAI_API_KEY not set in .env\n"
                "Get your key at: https://platform.openai.com/api-keys\n"
                "For free use: switch to provider='ollama' or provider='gemma'"
            )
        try:
            from langchain_openai import ChatOpenAI
            model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
            print(f"🤖 LLM: OpenAI / {model}")
            return ChatOpenAI(api_key=api_key, model=model, temperature=temperature)
        except ImportError:
            raise ImportError("Run: pip install langchain-openai")

    else:
        raise ValueError(
            f"Unknown provider: '{provider}'.\n"
            f"Choose from: ollama, gemma, anthropic, openai"
        )


def get_embeddings(provider: str = None):
    """
    Returns a LangChain embeddings object.

    Ollama and Gemma both use nomic-embed-text locally (free).
    Paid providers fall back to HuggingFace embeddings (also free).
    """
    provider = (provider or PROVIDER).lower()

    # Both ollama and gemma use Ollama for embeddings (free, local)
    if provider in ("ollama", "gemma"):
        try:
            from langchain_ollama import OllamaEmbeddings
            print(f"📐 Embeddings: Ollama / {OLLAMA_EMBED} (FREE, local)")
            return OllamaEmbeddings(base_url=OLLAMA_URL, model=OLLAMA_EMBED)
        except ImportError:
            raise ImportError("Run: pip install langchain-ollama")

    # Paid LLM providers use HuggingFace embeddings (still free)
    elif provider in ("anthropic", "openai", "huggingface"):
        try:
            from langchain_huggingface import HuggingFaceEmbeddings
            print("📐 Embeddings: HuggingFace / all-MiniLM-L6-v2 (FREE, local)")
            return HuggingFaceEmbeddings(
                model_name="sentence-transformers/all-MiniLM-L6-v2"
            )
        except ImportError:
            raise ImportError("Run: pip install langchain-huggingface sentence-transformers")

    else:
        # Fallback — always free
        try:
            from langchain_huggingface import HuggingFaceEmbeddings
            return HuggingFaceEmbeddings(
                model_name="sentence-transformers/all-MiniLM-L6-v2"
            )
        except ImportError:
            raise ImportError("Run: pip install langchain-huggingface sentence-transformers")


def list_providers() -> dict:
    """
    Returns all available providers and their current config.
    Useful for debugging or displaying in UI.
    """
    return {
        "ollama": {
            "model":   OLLAMA_LLM,
            "free":    True,
            "ready":   True,
            "note":    "Requires: ollama serve",
        },
        "gemma": {
            "model":   GEMMA_MODEL,
            "free":    True,
            "ready":   True,
            "note":    f"Requires: ollama pull {GEMMA_MODEL} && ollama serve",
        },
        "anthropic": {
            "model":   os.getenv("ANTHROPIC_MODEL", "claude-haiku-4-5-20251001"),
            "free":    False,
            "ready":   bool(os.getenv("ANTHROPIC_API_KEY")),
            "note":    "Requires: ANTHROPIC_API_KEY in .env",
        },
        "openai": {
            "model":   os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
            "free":    False,
            "ready":   bool(os.getenv("OPENAI_API_KEY")),
            "note":    "Requires: OPENAI_API_KEY in .env",
        },
    }
