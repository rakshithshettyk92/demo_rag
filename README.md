# 🔐 Security RAG — LangChain + Ollama (100% Free)

Answer questions about your security documentation using AI.
**No API keys needed. Runs entirely on your computer.**

---

## 🗂️ File Structure & What Each File Does

```
langchain-security-rag/
│
├── src/                         ← The core library (reusable across all your apps)
│   ├── llm_config.py            ← AI brain selector (Ollama/Claude/OpenAI)
│   ├── ingestor.py              ← PDF loader + chunker + ChromaDB writer
│   └── rag_chain.py             ← The RAG pipeline (retrieval + AI answer)
│
├── pdfs/                        ← DROP YOUR SECURITY PDFs HERE
├── vectorstore/                 ← Auto-created: your indexed documents (don't touch)
│
├── cli.py                       ← Terminal interface
├── app.py                       ← Browser UI (Gradio)
├── quickstart.py                ← Test everything works
│
├── requirements.txt             ← Python packages to install
└── .env.example                 ← Config template (copy to .env)
```

---

## 🚀 Setup (Do This Once)

### Step 1: Install Ollama (your free local AI)

| OS | Command |
|----|---------|
| Mac | `brew install ollama` |
| Windows/Linux | Download from https://ollama.com/download |

```bash
# After installing, pull the models you need:
ollama pull llama3.2          # The AI that answers questions (~2GB)
ollama pull nomic-embed-text  # The model that searches your docs (~270MB)

# Start Ollama (keep this running in a separate terminal):
ollama serve
```

### Step 2: Install Python dependencies

```bash
pip install -r requirements.txt
```

### Step 3: Configure

```bash
cp .env.example .env
# For Ollama (free), no changes needed!
# The defaults in .env.example work out of the box.
```

### Step 4: Test everything

```bash
python quickstart.py
```

If you see answers printed — everything works! ✅

---

## 📖 Daily Usage

### Add your security PDFs

```bash
# Put PDFs in the pdfs/ folder, then:
python cli.py ingest ./pdfs/

# Or ingest a single file:
python cli.py ingest ./pdfs/nist_framework.pdf
```

### Ask questions

```bash
# Single question:
python cli.py ask "What is SQL injection?"

# Interactive chat (ask multiple questions):
python cli.py chat

# Check what's indexed:
python cli.py status
```

### Browser UI (easier)

```bash
python app.py
# Open: http://localhost:7860
```

---

## 🔄 Upgrading to Paid AI (When Ready)

When you're ready to use Claude or OpenAI instead of Ollama:

**Getting a Claude API key:**
1. Go to https://console.anthropic.com
2. Sign up / log in
3. Click "API Keys" in the left menu
4. Click "Create Key" and copy it
5. Add to your `.env`: `ANTHROPIC_API_KEY=sk-ant-...`

**Getting an OpenAI API key:**
1. Go to https://platform.openai.com
2. Sign up / log in
3. Click your profile icon → "API Keys"
4. Click "Create new secret key" and copy it
5. Add to your `.env`: `OPENAI_API_KEY=sk-...`

**Then switch in your code — ONE line change:**
```python
# Before (free):
rag = SecurityRAGChain(llm_provider="ollama")

# After (Claude):
rag = SecurityRAGChain(llm_provider="anthropic")

# After (OpenAI):
rag = SecurityRAGChain(llm_provider="openai")
```

Or in the CLI:
```bash
python cli.py ask "What is XSS?" --provider anthropic
```

**Your documents do NOT need to be re-indexed.** Only the AI model changes.

---

## 🧠 How RAG Works (Plain English)

```
Your Question: "What is SQL injection?"
        ↓
1. EMBED QUESTION
   Convert question to numbers (vector): [0.23, -0.71, 0.44, ...]
        ↓
2. SEARCH ChromaDB
   Find the 4 document chunks most similar to those numbers
   Result: ["SQL injection occurs when...", "Prevention includes...", ...]
        ↓
3. BUILD PROMPT
   "You are a security expert. Use this context:
    [chunk 1]... [chunk 2]... [chunk 3]... [chunk 4]...
    Answer: What is SQL injection?"
        ↓
4. SEND TO AI (Ollama/Claude/OpenAI)
   AI reads the context and writes an answer
        ↓
5. RETURN ANSWER + SOURCES
   "SQL injection is a vulnerability that... [Source: owasp.pdf, page 3]"
```

---

## 🔮 What's Next (Your ESL Platform)

This same LangChain foundation will power all your future apps:

```
Your Platform (LangChain)
│
├── ✅ Security RAG          ← What we just built
├── 🔜 ESL Tag Generator    ← Product data → AI → image prompt → DALL-E
├── 🔜 Template Creator     ← Product info → fill HTML/PDF template
└── 🔜 Product Image AI     ← SKU → description → generate image
```

All of these share the same `src/llm_config.py` — one place to manage your AI providers.

---

## 🐞 Troubleshooting

**"Connection refused" or Ollama errors:**
```bash
# Make sure Ollama is running:
ollama serve

# In another terminal, verify it works:
ollama list   # should show your models
```

**"Model not found":**
```bash
ollama pull llama3.2
ollama pull nomic-embed-text
```

**"No documents indexed":**
```bash
python cli.py ingest ./pdfs/
python cli.py status
```

**Slow answers:**
- Normal! Ollama runs on your CPU/GPU. First run is slower.
- Try a smaller model: `ollama pull phi3` (much faster, slightly less accurate)
- Update `.env`: `OLLAMA_LLM_MODEL=phi3`
