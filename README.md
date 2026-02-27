# SOLUM AI Platform

AI-powered workspace for security Q&A and code review.
**Runs 100% locally — no API keys required.**

---

## What's Inside

| Feature | Description |
|---------|-------------|
| 🔐 **Security Assistant** | Ask questions about your security PDFs (incident response, policies, DR plans) |
| ✏️ **Admin Corrections** | Password-protected mode to correct wrong answers — corrections take priority in future queries |
| 🔍 **Code Review** | RAG-powered scanner that checks your code against Sonar, PEP8, OWASP, and custom rules |
| 🌐 **Browser UI** | Gradio dashboard at `http://localhost:7860` |
| 💻 **CLI** | Terminal tools for ingestion, chat, scanning, and more |

---

## 🚀 Setup — One Command

```bash
python setup.py
```

That's it. The script handles everything automatically:

1. Checks Python ≥ 3.9
2. Installs all Python dependencies
3. Creates `.env` from the template
4. Creates required directories
5. Checks Ollama is installed (prints install link if not)
6. Starts Ollama server if not running
7. Pulls required models (`llama3.2`, `nomic-embed-text`, `llava`, `gemma3`)
8. Indexes code review rules into the vector store
9. Indexes any PDFs found in `pdfs/`
10. Verifies the pipeline and prints a quick-reference summary

> **Safe to re-run** — every step is idempotent and skips work already done.

### Only prerequisite: Ollama

Ollama must be installed before running setup. If it's missing, `setup.py` will print the correct install link for your OS.

| OS | Install |
|----|---------|
| Windows / Linux | [https://ollama.com/download](https://ollama.com/download) |
| macOS | `brew install ollama` |

---

## 📁 Project Structure

```
demo_rag_bot/
│
├── setup.py                     ← Run this once to set everything up
├── app.py                       ← Browser UI (Gradio)
├── security_cli.py              ← Terminal tool for security Q&A
├── code_review_cli.py           ← Terminal tool for code review
│
├── pdfs/                        ← Drop your security PDFs here
├── vectorstore/
│   ├── security/                ← Indexed security docs + corrections
│   └── code_review/             ← Indexed code review rules
│
├── src/
│   ├── llm_config.py            ← AI provider selector (Ollama / Claude / OpenAI)
│   ├── security/
│   │   ├── ingestor.py          ← PDF → text + OCR + vision → ChromaDB
│   │   ├── rag_chain.py         ← Retrieval pipeline + corrections injection
│   │   └── corrections.py       ← Admin-verified answer store
│   └── code_review/
│       ├── ingestor.py          ← Rule file → ChromaDB
│       ├── scanner.py           ← Code → violations (RAG-based)
│       ├── fixer.py             ← Violations → LLM-fixed code
│       ├── pr_creator.py        ← Fixed code → GitHub PR
│       └── rules/               ← Built-in rule sets (Markdown)
│           ├── pep8.md
│           ├── sonar_python.md
│           ├── owasp_top10.md
│           ├── java_style.md
│           ├── java_sonar.md
│           ├── javascript_style.md
│           ├── javascript_sonar.md
│           └── react_rules.md
│
├── requirements.txt
├── .env.example                 ← Config template (copied to .env by setup.py)
└── .env                         ← Your local config (never commit this)
```

---

## 📖 Daily Usage

### Browser UI (recommended)

```bash
python app.py
# Open: http://localhost:7860
```

### Security Q&A — CLI

```bash
# Scan pdfs/ and index only new or changed files
python security_cli.py quickstart

# Ingest a specific PDF
python security_cli.py ingest ./pdfs/nist.pdf

# Ask a single question
python security_cli.py ask "What is the incident response procedure?"

# Interactive chat
python security_cli.py chat

# Check what's indexed
python security_cli.py status
```

### Code Review — CLI

```bash
# (Re-)index built-in rules
python code_review_cli.py ingest

# Index rules from a custom folder
python code_review_cli.py ingest --dir ./my_company_rules

# Scan source files and print a violation report
python code_review_cli.py scan ./src

# Scan + auto-fix files in place
python code_review_cli.py fix ./src

# Scan + fix + open a GitHub PR automatically
python code_review_cli.py pr ./src --base main
```

---

## ✏️ Admin Corrections Mode

When the bot gives a wrong answer, admins can correct it directly in the UI. Corrections are stored in ChromaDB and injected as highest-priority context on all future similar queries — no re-ingestion needed.

**How to use:**

1. Open the browser UI (`python app.py`)
2. Click **🔒** in the Security Assistant header
3. Enter the admin password (default: `solum-admin`, change via `ADMIN_PASSWORD` in `.env`)
4. Ask a question — if the answer is wrong, click **📥 Load Last Answer**
5. Edit the answer in the form, optionally add a source reference
6. Click **💾 Save Correction**

Future queries will automatically use the corrected answer.

To view or delete corrections: expand **📋 Manage Corrections** in the admin panel.

---

## 🔄 Adding More PDFs

```bash
# 1. Drop PDF files into the pdfs/ folder
# 2. Run:
python security_cli.py quickstart
# Only new or changed PDFs are re-indexed (existing ones are skipped)
```

PDF ingestion uses three extraction layers automatically:
- **Text** (PyPDF) — fast, always runs
- **OCR** (Tesseract) — catches text baked into image layers
- **Vision LLM** (llava) — reads tables, flowcharts, org charts

---

## 🛠️ Adding Custom Code Review Rules

Create a `.md` file in `src/code_review/rules/` using this template:

```markdown
## RULE: Use Parameterised Queries
**ID**: MYCO001
**Severity**: Critical
**Category**: Security

### What it detects
Raw string interpolation in SQL queries, enabling SQL injection.

### Bad example
```python
query = f"SELECT * FROM users WHERE id = {user_id}"
```

### Good example
```python
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))
```

### Why it matters
String-interpolated queries allow attackers to manipulate the SQL structure.
```

Then re-ingest:

```bash
python code_review_cli.py ingest
```

---

## 🔮 Upgrading to a Cloud LLM

Everything works free with Ollama. When you're ready to use Claude or GPT-4o for faster, higher-quality answers:

**Claude (Anthropic):**
1. Get an API key at [console.anthropic.com](https://console.anthropic.com)
2. Add to `.env`: `ANTHROPIC_API_KEY=sk-ant-...`
3. Select **✦ Claude** in the model selector (UI) or `--provider anthropic` (CLI)

**GPT-4o (OpenAI):**
1. Get an API key at [platform.openai.com](https://platform.openai.com)
2. Add to `.env`: `OPENAI_API_KEY=sk-...`
3. Select **⬡ GPT-4o** in the model selector (UI) or `--provider openai` (CLI)

> Your documents do **not** need to be re-indexed when switching models. Only the answer generation changes.

---

## 🧠 How It Works

```
Your Question
      │
      ▼
1. Embed question (nomic-embed-text via Ollama)
      │
      ▼
2. Search ChromaDB
   ├─ Check corrections collection first  ← admin-verified answers
   └─ Search main document chunks         ← ingested PDFs / rules
      │
      ▼
3. Build prompt with retrieved context
   [ADMIN VERIFIED CORRECTION] shown first if relevant
      │
      ▼
4. Send to LLM (Ollama / Claude / GPT-4o)
      │
      ▼
5. Stream answer + source references
```

---

## 🐞 Troubleshooting

**Ollama not running:**
```bash
ollama serve
# Keep this terminal open, then retry
```

**Model not found:**
```bash
ollama pull llama3.2
ollama pull nomic-embed-text
ollama pull llava
```

**No documents indexed:**
```bash
python security_cli.py status
python security_cli.py quickstart
```

**Slow answers:**
- Normal for first run — Ollama loads the model into memory
- Try a faster model: `ollama pull llama3.2:1b` then set `OLLAMA_LLM_MODEL=llama3.2:1b` in `.env`
- Or use a cloud model (Claude / GPT-4o) for instant responses

**Re-run setup after a fresh clone:**
```bash
python setup.py
```
