"""
app.py — Solum AI Platform
--------------------------
Multi-agent dashboard with:
  - Home screen with feature cards
  - Security RAG chatbot with model selector
  - Extensible: add ESL tags, wiki, image gen easily

Run: python app.py
Open: http://localhost:7860
"""

import os
import sys
import threading
import queue as _queue
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.stdout.reconfigure(encoding="utf-8")

import gradio as gr
from datetime import datetime

# ── RAG chain (lazy loaded so UI starts fast) ─────────────────
_rag         = None
_corrections = None
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "solum-admin")


def get_corrections():
    """Return the CorrectionsStore, reusing the RAG chain's embeddings if ready."""
    global _corrections
    if _corrections is None:
        try:
            from src.security.corrections import CorrectionsStore
            db_path = os.getenv("SECURITY_STORE_PATH", "./vectorstore/security")
            embeddings = getattr(_rag, "embeddings", None) if _rag else None
            _corrections = CorrectionsStore(persist_dir=db_path, embeddings=embeddings)
        except Exception as e:
            print(f"Corrections store init error: {e}")
            return None
    return _corrections


def get_rag(provider: str):
    global _rag
    try:
        from src.security.rag_chain import SecurityRAGChain
        db_path = os.getenv("SECURITY_STORE_PATH", "./vectorstore/security")
        if _rag is None:
            _rag = SecurityRAGChain(llm_provider=provider, persist_dir=db_path)
        else:
            current = type(_rag.llm).__name__.lower()
            if provider.lower() not in current:
                _rag.switch_provider(provider)
        return _rag, None
    except Exception as e:
        return None, str(e)


# ── Security chat handler ─────────────────────────────────────
def chat(question: str, history: list, model: str):
    question = question.strip()
    if not question:
        return history, "", "", ""

    # Show placeholder immediately so the UI never looks frozen
    history = history + [
        {"role": "user",      "content": question},
        {"role": "assistant", "content": "⏳ Loading model..."},
    ]
    yield history, "", question, ""

    rag, err = get_rag(model)
    if err:
        history[-1] = {"role": "assistant", "content": f"⚠️ Could not connect: {err}"}
        yield history, "", question, ""
        return

    # Model ready — now searching docs
    history[-1] = {"role": "assistant", "content": "🔍 Searching documents..."}
    yield history, "", question, ""

    try:
        full_answer = ""
        for token in rag.ask_stream(question):
            if not full_answer:
                history[-1] = {"role": "assistant", "content": token + "▌"}
            else:
                history[-1] = {"role": "assistant", "content": full_answer + token + "▌"}
            full_answer += token
            yield history, "", question, ""

        history[-1] = {"role": "assistant", "content": full_answer}
        yield history, "", question, full_answer

        from src.security.rag_chain import NOT_FOUND_PREFIX
        answered = NOT_FOUND_PREFIX.lower() not in full_answer.lower()

        if answered:
            source_docs = getattr(rag, "_last_docs", [])
            if source_docs:
                seen = set()
                refs = []
                for doc in source_docs:
                    src  = os.path.basename(doc.metadata.get("source", ""))
                    page = doc.metadata.get("page", "?")
                    key  = f"{src}_{page}"
                    if key not in seen and src:
                        seen.add(key)
                        refs.append(f"📄 **{src}** — page {page}")

                if refs:
                    final = full_answer + "\n\n---\n**References:**\n" + "\n".join(refs)
                    history[-1] = {"role": "assistant", "content": final}
                    yield history, "", question, full_answer

    except Exception as e:
        history[-1] = {"role": "assistant", "content": f"❌ Error: {e}"}
        yield history, "", question, ""


def clear_chat():
    return [], "", "", ""


# ── CSS ───────────────────────────────────────────────────────
CSS = """
@import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500&display=swap');

:root {
    --bg:        #0a0c10;
    --surface:   #111318;
    --border:    #1e2130;
    --accent:    #3b82f6;
    --accent2:   #06b6d4;
    --success:   #10b981;
    --text:      #e2e8f0;
    --muted:     #64748b;
    --card-bg:   #13161d;
}

* { box-sizing: border-box; }

body, .gradio-container {
    background: var(--bg) !important;
    font-family: 'DM Sans', sans-serif !important;
    color: var(--text) !important;
}

/* Hide gradio footer */
footer { display: none !important; }
.svelte-1ipelgc { display: none !important; }

/* ── Dashboard header ── */
.platform-header {
    text-align: center;
    padding: 40px 20px 20px;
    border-bottom: 1px solid var(--border);
    margin-bottom: 32px;
}
.platform-header h1 {
    font-family: 'Syne', sans-serif;
    font-size: 2.4rem;
    font-weight: 800;
    letter-spacing: -0.02em;
    background: linear-gradient(135deg, #e2e8f0 0%, var(--accent) 60%, var(--accent2) 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    margin: 0 0 8px;
}
.platform-header p {
    color: var(--muted);
    font-size: 0.95rem;
    margin: 0;
}

/* ── Feature cards on home ── */
.feature-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 16px;
    padding: 0 20px 40px;
    max-width: 1000px;
    margin: 0 auto;
}
.feature-card {
    background: var(--card-bg);
    border: 1px solid var(--border);
    border-radius: 16px;
    padding: 28px 24px;
    cursor: pointer;
    transition: all 0.2s ease;
    position: relative;
    overflow: hidden;
}
.feature-card::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 2px;
    background: var(--accent-gradient, linear-gradient(90deg, var(--accent), var(--accent2)));
    opacity: 0;
    transition: opacity 0.2s;
}
.feature-card:hover { 
    border-color: var(--accent);
    transform: translateY(-2px);
    box-shadow: 0 8px 32px rgba(59,130,246,0.15);
}
.feature-card:hover::before { opacity: 1; }
.feature-card .icon { font-size: 2rem; margin-bottom: 12px; }
.feature-card h3 {
    font-family: 'Syne', sans-serif;
    font-size: 1.05rem;
    font-weight: 700;
    margin: 0 0 8px;
    color: var(--text);
}
.feature-card p {
    font-size: 0.82rem;
    color: var(--muted);
    margin: 0 0 16px;
    line-height: 1.5;
}
.feature-card .badge {
    display: inline-block;
    font-size: 0.7rem;
    padding: 3px 10px;
    border-radius: 20px;
    font-weight: 500;
}
.badge-live { background: rgba(16,185,129,0.15); color: var(--success); border: 1px solid rgba(16,185,129,0.3); }
.badge-soon { background: rgba(100,116,139,0.15); color: var(--muted); border: 1px solid var(--border); }

/* ── Chat page ── */
.chat-page {
    max-width: 900px;
    margin: 0 auto;
    padding: 0 20px 40px;
}
.chat-header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 24px;
    padding-bottom: 16px;
    border-bottom: 1px solid var(--border);
}
.chat-header .back-hint {
    font-size: 0.8rem;
    color: var(--muted);
    margin-top: 4px;
}

/* ── Chatbot messages ── */
.chatbot-wrap .message-wrap {
    background: var(--surface) !important;
    border: 1px solid var(--border) !important;
    border-radius: 16px !important;
}
.chatbot-wrap [data-testid="bot"] {
    background: var(--card-bg) !important;
    border: 1px solid var(--border) !important;
    border-radius: 12px !important;
    color: var(--text) !important;
    font-size: 0.9rem !important;
    line-height: 1.7 !important;
}
.chatbot-wrap [data-testid="user"] {
    background: rgba(59,130,246,0.12) !important;
    border: 1px solid rgba(59,130,246,0.25) !important;
    border-radius: 12px !important;
    color: var(--text) !important;
}

/* ── Input row ── */
.input-row {
    display: flex;
    gap: 10px;
    align-items: flex-end;
    margin-top: 12px;
}
.input-row textarea {
    background: var(--surface) !important;
    border: 1px solid var(--border) !important;
    border-radius: 12px !important;
    color: var(--text) !important;
    font-family: 'DM Sans', sans-serif !important;
    resize: none !important;
}
.input-row textarea:focus {
    border-color: var(--accent) !important;
    outline: none !important;
    box-shadow: 0 0 0 3px rgba(59,130,246,0.1) !important;
}

/* ── Model selector bar ── */
.model-bar {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 12px 16px;
    margin-top: 12px;
    display: flex;
    align-items: center;
    gap: 12px;
}
.model-bar label {
    font-size: 0.78rem !important;
    color: var(--muted) !important;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    font-weight: 500;
}

/* Override gradio radio buttons */
.model-radio label { color: var(--text) !important; font-size: 0.85rem !important; }
.model-radio input[type=radio]:checked + span { color: var(--accent) !important; }

/* ── Buttons ── */
button.send-btn {
    background: var(--accent) !important;
    color: white !important;
    border: none !important;
    border-radius: 10px !important;
    font-family: 'Syne', sans-serif !important;
    font-weight: 600 !important;
    font-size: 0.85rem !important;
    padding: 10px 20px !important;
    cursor: pointer !important;
    transition: all 0.15s !important;
    white-space: nowrap;
}
button.send-btn:hover { 
    background: #2563eb !important;
    transform: translateY(-1px) !important;
}
button.clear-btn {
    background: transparent !important;
    color: var(--muted) !important;
    border: 1px solid var(--border) !important;
    border-radius: 10px !important;
    font-size: 0.82rem !important;
    padding: 8px 14px !important;
    cursor: pointer !important;
    transition: all 0.15s !important;
}
button.clear-btn:hover {
    border-color: var(--muted) !important;
    color: var(--text) !important;
}

/* Status pill */
.status-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 0.75rem;
    color: var(--success);
    background: rgba(16,185,129,0.1);
    border: 1px solid rgba(16,185,129,0.25);
    border-radius: 20px;
    padding: 3px 10px;
}
.status-dot {
    width: 6px; height: 6px;
    background: var(--success);
    border-radius: 50%;
    animation: pulse 2s infinite;
}
@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.4; }
}

/* ── Admin UI ── */
.admin-toggle-btn {
    background: transparent !important;
    border: 1px solid var(--border) !important;
    border-radius: 8px !important;
    color: var(--muted) !important;
    font-size: 1rem !important;
    padding: 6px 10px !important;
    cursor: pointer !important;
    transition: all 0.15s !important;
    min-width: 40px !important;
}
.admin-toggle-btn:hover {
    border-color: #f59e0b !important;
    color: #f59e0b !important;
}
.admin-badge {
    background: rgba(245,158,11,0.12);
    border: 1px solid rgba(245,158,11,0.35);
    border-radius: 8px;
    padding: 6px 14px;
    color: #f59e0b;
    font-size: 0.82rem;
    font-weight: 600;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}
.admin-panel {
    border: 1px solid rgba(245,158,11,0.3) !important;
    border-radius: 12px !important;
    padding: 16px !important;
    margin-top: 12px !important;
    background: var(--surface) !important;
}
.pwd-row input {
    background: var(--surface) !important;
    border: 1px solid var(--border) !important;
    border-radius: 10px !important;
    color: var(--text) !important;
}

/* Tab styling */
.tabs > .tab-nav { border-bottom: 1px solid var(--border) !important; }
.tabs > .tab-nav button {
    color: var(--muted) !important;
    font-family: 'Syne', sans-serif !important;
    font-weight: 600 !important;
    font-size: 0.9rem !important;
    border-bottom: 2px solid transparent !important;
    transition: all 0.15s !important;
}
.tabs > .tab-nav button.selected {
    color: var(--text) !important;
    border-bottom-color: var(--accent) !important;
}
"""

# ── HOME PAGE HTML ────────────────────────────────────────────
HOME_HTML = """
<div class="platform-header">
    <h1>SOLUM AI Platform</h1>
    <p>Your intelligent workspace — select a feature to get started</p>
</div>
<div class="feature-grid">
    <div class="feature-card" onclick="document.querySelectorAll('[role=tab]')[1].click()">
        <div class="icon">🔐</div>
        <h3>Security Assistant</h3>
        <p>Ask questions about incident response, policies, and security procedures</p>
        <span class="badge badge-live">● Live</span>
    </div>
    <div class="feature-card" onclick="document.querySelectorAll('[role=tab]')[2].click()">
        <div class="icon">🏷️</div>
        <h3>ESL Tag Generator</h3>
        <p>AI-powered XSL template designer — describe your label, get production-ready files</p>
        <span class="badge badge-live">● Live</span>
    </div>
    <div class="feature-card">
        <div class="icon">📖</div>
        <h3>SOLUM Wiki</h3>
        <p>Internal knowledge base search and Q&A across all company documentation</p>
        <span class="badge badge-soon">Coming Soon</span>
    </div>
    <div class="feature-card">
        <div class="icon">🖼️</div>
        <h3>Image Generator</h3>
        <p>Create product images and visual assets from descriptions and templates</p>
        <span class="badge badge-soon">Coming Soon</span>
    </div>
</div>
"""


# ── Admin helpers ─────────────────────────────────────────────
def _try_unlock(pwd):
    if pwd == ADMIN_PASSWORD:
        return (
            gr.update(visible=False),   # pwd_row
            gr.update(visible=True),    # admin_badge_row
            gr.update(visible=True),    # admin_panel
            True,                        # is_admin_state
            gr.update(value="🔓"),      # admin_toggle_btn label
            "",                          # clear pwd_input
            "",                          # clear pwd_error
        )
    return (
        gr.update(visible=True),
        gr.update(visible=False),
        gr.update(visible=False),
        False,
        gr.update(value="🔒"),
        "",
        "<span style='color:#ef4444'>❌ Incorrect password</span>",
    )


def _do_lock():
    return (
        gr.update(visible=False),   # pwd_row
        gr.update(visible=False),   # admin_badge_row
        gr.update(visible=False),   # admin_panel
        False,                       # is_admin_state
        gr.update(value="🔒"),      # admin_toggle_btn
    )


def _save_correction(question, answer, source_ref):
    if not question:
        return "<span style='color:#f59e0b'>⚠️ Ask a question first, then click Load Last Answer.</span>"
    if not answer.strip():
        return "<span style='color:#f59e0b'>⚠️ Please enter the correct answer.</span>"
    try:
        store = get_corrections()
        cid = store.add(question, answer.strip(), corrected_by="admin", source_ref=source_ref)
        return f"<span style='color:#10b981'>✅ Correction saved! (ID: {cid[:8]}...)</span>"
    except Exception as e:
        return f"<span style='color:#ef4444'>❌ Error saving: {e}</span>"


def _list_corrections():
    try:
        store = get_corrections()
        items = store.list_all()
        if not items:
            return []
        return [
            [
                c["id"][:8],
                (c["question"][:70] + "...") if len(c["question"]) > 70 else c["question"],
                (c["answer"][:90] + "...")   if len(c["answer"])   > 90 else c["answer"],
                c["by"],
                c["timestamp"][:19].replace("T", " "),
            ]
            for c in items
        ]
    except Exception:
        return []


def _delete_correction(id_prefix):
    if not id_prefix.strip():
        return "<span style='color:#f59e0b'>⚠️ Enter the first 8 chars of the ID to delete.</span>", _list_corrections()
    try:
        store = get_corrections()
        matched = [c for c in store.list_all() if c["id"].startswith(id_prefix.strip())]
        if not matched:
            return "<span style='color:#f59e0b'>⚠️ No correction found with that ID prefix.</span>", _list_corrections()
        for c in matched:
            store.delete(c["id"])
        return f"<span style='color:#10b981'>✅ Deleted {len(matched)} correction(s).</span>", _list_corrections()
    except Exception as e:
        return f"<span style='color:#ef4444'>❌ Error: {e}</span>", _list_corrections()


# ── ESL label registry ────────────────────────────────────────
try:
    from src.esl.label_registry import all_label_keys, DEFAULT_LABEL_KEY
    _ESL_SIZE_CHOICES = all_label_keys()
    _ESL_SIZE_DEFAULT = DEFAULT_LABEL_KEY
except Exception:
    _ESL_SIZE_CHOICES = ['2.5_4C" : 296 X 152']
    _ESL_SIZE_DEFAULT = '2.5_4C" : 296 X 152'


# ── ESL quick-start prompts ───────────────────────────────────
ESL_PROMPTS = {
    "regular": (
        "White background. "
        "Product name bold centered at the very top, Arial font, auto-fit text to width. "
        "Item ID small text top-right corner. "
        "Display page number bold large top-left. "
        "A black bordered rectangle on the bottom-left half. "
        "Inside that box: static label 'UNIT PRICE' small at the top of the box, "
        "then UNIT_PRICE value large bold centered, then UNIT_PRICE_UNIT small at the bottom. "
        "LIST_PRICE large bold centered on the bottom-right half. "
        "Barcode top-right area, 160px wide 18px tall. "
        "End date and pack quantity small text near the top. "
        "Use Arial throughout."
    ),
    "sale": (
        "White background. "
        "Product name bold centered at the top, Arial, auto-fit. "
        "Large SALE price (LIST_PRICE) bold Arial 44pt centered-right, bottom half. "
        "Smaller original price (UNIT_PRICE) with strikethrough above the sale price. "
        "Static red bold text 'SALE' label top-left corner. "
        "A black bordered box bottom-left containing static 'UNIT PRICE' label and UNIT_PRICE_UNIT. "
        "Barcode top-right 160px wide 18px tall. "
        "Item ID small top-right below barcode. "
        "End date small bottom center. "
        "Use Arial throughout."
    ),
    "clearance": (
        "Yellow background banner across the top quarter. White background for the rest. "
        "Static bold text 'CLEARANCE' in large font on the yellow banner, centered. "
        "Product name bold centered below the banner, Arial, auto-fit. "
        "Large clearance price (LIST_PRICE) bold Arial 48pt centered right side. "
        "Unit price small in a bordered box bottom-left with static 'UNIT PRICE' label. "
        "Barcode bottom-right 140px wide 18px tall. "
        "Item ID small text top-right. "
        "Use Arial throughout."
    ),
}


# ── ESL profile helpers ───────────────────────────────────────
def _esl_profile_choices():
    try:
        from src.esl.profile_store import list_profile_choices
        return list_profile_choices()
    except Exception:
        return []


def _esl_save_profile(company_code: str, fields_json: str):
    if not company_code.strip():
        return (
            "<span style='color:#f59e0b'>⚠️ Enter a company code before saving.</span>",
            _esl_profile_choices(),
        )
    try:
        from src.esl.profile_store import save_profile
        msg = save_profile(company_code, fields_json)
        return (
            f"<span style='color:#10b981'>✅ {msg}</span>",
            _esl_profile_choices(),
        )
    except Exception as e:
        return (
            f"<span style='color:#ef4444'>❌ {e}</span>",
            _esl_profile_choices(),
        )


def _esl_load_profile(choice: str):
    """Parse company code from dropdown choice label and load fields JSON."""
    if not choice:
        return "", "<span style='color:#f59e0b'>⚠️ Select a profile first.</span>"
    try:
        from src.esl.profile_store import fields_json_from_profile
        # Choice format: "ACME  —  ACME Corp  (7 fields)"  or  "ACME  (7 fields)"
        company_code = choice.split("—")[0].split("(")[0].strip()
        fields_json = fields_json_from_profile(company_code)
        return (
            fields_json,
            f"<span style='color:#10b981'>✅ Loaded profile: {company_code}</span>",
        )
    except Exception as e:
        return (
            "",
            f"<span style='color:#ef4444'>❌ {e}</span>",
        )


def _esl_upload_fields(file):
    """Read uploaded JSON file and return its content as a string."""
    if file is None:
        return ""
    try:
        with open(file.name, "r", encoding="utf-8") as f:
            content = f.read()
        import json
        parsed = json.loads(content)
        return json.dumps(parsed, indent=2, ensure_ascii=False)
    except Exception as e:
        return f"// Error reading file: {e}"


# ── ESL: logo dithering handler ───────────────────────────────
def _dither_logo(logo_pil, size_key: str):
    """Dither an uploaded logo to the ESL label's color palette."""
    if logo_pil is None:
        return None, None
    try:
        from src.esl.image_ditherer import dither_to_palette, get_palette_for_color_type
        from src.esl.label_registry import LABEL_REGISTRY
        reg_info   = LABEL_REGISTRY.get(size_key, {})
        color_type = reg_info.get("best_color", "4_COLOR")
        palette    = get_palette_for_color_type(color_type)
        dithered   = dither_to_palette(logo_pil, palette)
        return dithered, dithered        # (display, state)
    except Exception as e:
        print(f"Dithering error: {e}")
        return logo_pil, logo_pil


# ── ESL template generator handler ───────────────────────────
def _generate_esl(
    fields_json: str,
    description: str,
    size_key: str,
    provider: str,
    ref_data_json: str,
    dithered_logo,
):
    """Generate XSL + Fabric JSON + live preview from product fields and description."""
    # 7 "empty" values: xsl, json, dl_xsl, dl_json, layout_spec_state, preview, stream_box
    _empty = ("", "", None, None, "", None, "")

    if not description.strip():
        yield ("<span style='color:#f59e0b'>⚠️ Please enter a layout description.</span>", *_empty)
        return
    if not fields_json.strip():
        yield ("<span style='color:#f59e0b'>⚠️ Please enter product fields JSON.</span>", *_empty)
        return

    yield ("<span style='color:#64748b'>⏳ Sending prompt to AI...</span>", *_empty)

    try:
        from src.esl.template_service import get_service
        service = get_service()

        # ── Stream LLM tokens in background thread ────────────────────────
        token_q: _queue.Queue = _queue.Queue()
        result_holder: list   = [None]   # will hold (xsl, json, spec_str) or Exception

        def _run():
            try:
                result_holder[0] = service.generate(
                    fields_json=fields_json,
                    description=description,
                    size_key=size_key,
                    provider=provider,
                    stream_fn=lambda t: token_q.put(t),
                )
            except Exception as exc:
                result_holder[0] = exc
            finally:
                token_q.put(None)   # sentinel — signals end of stream

        threading.Thread(target=_run, daemon=True).start()

        # Yield each token to the stream box so the user sees output immediately
        tokens: list[str] = []
        while True:
            token = token_q.get()
            if token is None:
                break
            tokens.append(token)
            partial = "".join(tokens)
            yield (
                f"<span style='color:#64748b'>⏳ Generating… {len(tokens)} tokens</span>",
                "", "", None, None, "", None, partial,
            )

        if isinstance(result_holder[0], Exception):
            raise result_holder[0]

        xsl_content, fabric_json, layout_spec_str = result_holder[0]

        # ── Inject dithered logo into image elements if provided ──────────
        import json as _json, base64 as _b64, io as _io
        layout_spec = _json.loads(layout_spec_str)

        if dithered_logo is not None:
            buf = _io.BytesIO()
            dithered_logo.save(buf, format="PNG")
            logo_b64 = _b64.b64encode(buf.getvalue()).decode()

            for el in layout_spec.get("elements", []):
                if el.get("type") == "image":
                    el["image_data"] = logo_b64

            # Rebuild XSL and JSON now that image data is embedded
            from src.esl.xsl_builder import build_xsl
            from src.esl.fabric_json_builder import build_fabric_json
            from src.esl.label_registry import LABEL_REGISTRY as _LR
            _reg = _LR.get(size_key, {})
            _color_type   = _reg.get("best_color", "4_COLOR")
            _size_label   = _reg.get("label", size_key.split('"')[0].strip()).replace(" ", "_")
            _tpl_name     = f"AI_{_size_label}"
            xsl_content   = build_xsl(layout_spec)
            fabric_json   = build_fabric_json(layout_spec, template_name=_tpl_name, color_type=_color_type)

        # ── Render live preview ───────────────────────────────────────────
        preview_img = None
        yield ("<span style='color:#64748b'>🖼️  Rendering preview...</span>", *_empty)

        try:
            from src.esl.preview_renderer import render_preview
            ref_data = {}
            if ref_data_json and ref_data_json.strip():
                try:
                    ref_data = _json.loads(ref_data_json)
                except Exception:
                    pass
            preview_img = render_preview(layout_spec, ref_data, dithered_logo)
        except Exception as pe:
            print(f"Preview render error: {pe}")

        # ── Write temp download files ─────────────────────────────────────
        import tempfile
        xsl_tmp  = tempfile.NamedTemporaryFile(delete=False, suffix=".xsl",  mode="w", encoding="utf-8")
        json_tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".json", mode="w", encoding="utf-8")
        xsl_tmp.write(xsl_content);  xsl_tmp.close()
        json_tmp.write(fabric_json); json_tmp.close()

        yield (
            "<span style='color:#10b981'>✅ Template generated — refine below if needed.</span>",
            xsl_content,
            fabric_json,
            xsl_tmp.name,
            json_tmp.name,
            layout_spec_str,   # stored in state so refine can pick it up
            preview_img,
            "",                # clear stream box
        )

    except Exception as e:
        yield (f"<span style='color:#ef4444'>❌ Error: {e}</span>", *_empty)


# ── ESL refinement handler ────────────────────────────────────
def _refine_esl(
    instruction: str,
    current_layout_json: str,
    size_key: str,
    provider: str,
    ref_data_json: str,
    dithered_logo,
):
    """Apply a natural language refinement to the current layout spec."""
    # 7 keep-as-is updates: xsl, json, dl_xsl, dl_json, layout_spec_state, preview, stream_box
    _keep = (gr.update(), gr.update(), gr.update(), gr.update(), gr.update(), gr.update(), gr.update())

    if not instruction.strip():
        yield "<span style='color:#f59e0b'>⚠️ Enter a refinement instruction.</span>", *_keep
        return
    if not current_layout_json:
        yield "<span style='color:#f59e0b'>⚠️ Generate a template first before refining.</span>", *_keep
        return

    yield "<span style='color:#64748b'>✏️ Sending refinement to AI...</span>", *_keep

    try:
        from src.esl.template_service import get_service
        service = get_service()

        # ── Stream LLM tokens in background thread ────────────────────────
        token_q: _queue.Queue = _queue.Queue()
        result_holder: list   = [None]

        def _run_refine():
            try:
                result_holder[0] = service.refine(
                    current_layout_json=current_layout_json,
                    instruction=instruction,
                    size_key=size_key,
                    provider=provider,
                    stream_fn=lambda t: token_q.put(t),
                )
            except Exception as exc:
                result_holder[0] = exc
            finally:
                token_q.put(None)

        threading.Thread(target=_run_refine, daemon=True).start()

        tokens: list[str] = []
        while True:
            token = token_q.get()
            if token is None:
                break
            tokens.append(token)
            partial = "".join(tokens)
            yield (
                f"<span style='color:#64748b'>✏️ Refining… {len(tokens)} tokens</span>",
                gr.update(), gr.update(), gr.update(), gr.update(), gr.update(), gr.update(), partial,
            )

        if isinstance(result_holder[0], Exception):
            raise result_holder[0]

        xsl_content, fabric_json, layout_spec_str = result_holder[0]

        # Inject logo + render preview (same pipeline as generate)
        import json as _json, base64 as _b64, io as _io
        layout_spec = _json.loads(layout_spec_str)

        if dithered_logo is not None:
            buf = _io.BytesIO()
            dithered_logo.save(buf, format="PNG")
            logo_b64 = _b64.b64encode(buf.getvalue()).decode()
            for el in layout_spec.get("elements", []):
                if el.get("type") == "image":
                    el["image_data"] = logo_b64
            from src.esl.xsl_builder import build_xsl
            from src.esl.fabric_json_builder import build_fabric_json
            from src.esl.label_registry import LABEL_REGISTRY as _LR
            _reg    = _LR.get(size_key, {})
            _ct     = _reg.get("best_color", "4_COLOR")
            _sl     = _reg.get("label", size_key.split('"')[0].strip()).replace(" ", "_")
            xsl_content = build_xsl(layout_spec)
            fabric_json = build_fabric_json(layout_spec, template_name=f"AI_{_sl}", color_type=_ct)

        preview_img = None
        try:
            from src.esl.preview_renderer import render_preview
            ref_data = {}
            if ref_data_json and ref_data_json.strip():
                try:
                    ref_data = _json.loads(ref_data_json)
                except Exception:
                    pass
            preview_img = render_preview(layout_spec, ref_data, dithered_logo)
        except Exception as pe:
            print(f"Preview render error: {pe}")

        import tempfile
        xsl_tmp  = tempfile.NamedTemporaryFile(delete=False, suffix=".xsl",  mode="w", encoding="utf-8")
        json_tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".json", mode="w", encoding="utf-8")
        xsl_tmp.write(xsl_content);  xsl_tmp.close()
        json_tmp.write(fabric_json); json_tmp.close()

        yield (
            "<span style='color:#10b981'>✅ Refinement applied — refine again or download.</span>",
            xsl_content,
            fabric_json,
            xsl_tmp.name,
            json_tmp.name,
            layout_spec_str,   # updated state for next refinement
            preview_img,
            "",                # clear stream box
        )

    except Exception as e:
        yield f"<span style='color:#ef4444'>❌ Error: {e}</span>", *_keep


# ── BUILD UI ──────────────────────────────────────────────────
def build():
    with gr.Blocks(title="SOLUM AI Platform") as demo:

        # ── Shared state ──────────────────────────────────────
        is_admin_state = gr.State(False)
        last_q_state   = gr.State("")
        last_a_state   = gr.State("")

        with gr.Tabs() as tabs:

            # ── Tab 1: Home ───────────────────────────────────
            with gr.TabItem("🏠  Home"):
                gr.HTML(HOME_HTML)

            # ── Tab 2: Security Assistant ─────────────────────
            with gr.TabItem("🔐  Security"):
                with gr.Column(elem_classes="chat-page"):

                    # Header row with admin lock button
                    with gr.Row(equal_height=True):
                        gr.HTML("""
                        <div class="chat-header" style="flex:1; margin:0;">
                            <div>
                                <div style="display:flex; align-items:center; gap:10px;">
                                    <span style="font-family:'Syne',sans-serif; font-size:1.3rem; font-weight:700;">
                                        Security Assistant
                                    </span>
                                    <span class="status-pill">
                                        <span class="status-dot"></span> Active
                                    </span>
                                </div>
                                <div class="back-hint">Ask about incident response, security policies, disaster recovery, and more</div>
                            </div>
                        </div>
                        """)
                        admin_toggle_btn = gr.Button(
                            "🔒",
                            elem_classes="admin-toggle-btn",
                            scale=0,
                            min_width=44,
                        )

                    # Password row (hidden by default)
                    with gr.Row(visible=False, elem_classes="pwd-row") as pwd_row:
                        pwd_input  = gr.Textbox(
                            placeholder="Enter admin password...",
                            type="password",
                            show_label=False,
                            scale=4,
                            container=False,
                        )
                        unlock_btn = gr.Button("Unlock", scale=1, min_width=80, variant="primary")
                    pwd_error = gr.HTML("")

                    # Admin badge (hidden until logged in)
                    with gr.Row(visible=False) as admin_badge_row:
                        gr.HTML('<div class="admin-badge">🔓 Admin Mode Active</div>')
                        lock_btn = gr.Button("🔒 Lock", scale=0, min_width=90, size="sm")

                    # Chatbot
                    chatbot = gr.Chatbot(
                        value=[],
                        height=480,
                        show_label=False,
                        elem_classes="chatbot-wrap",
                        label="Security Assistant",
                    )

                    # Input row
                    with gr.Row(elem_classes="input-row"):
                        question_box = gr.Textbox(
                            placeholder="Ask a security question...",
                            show_label=False,
                            lines=2,
                            max_lines=4,
                            scale=5,
                            container=False,
                        )
                        with gr.Column(scale=1, min_width=120):
                            send_btn  = gr.Button("Send ↑", elem_classes="send-btn", variant="primary")
                            clear_btn = gr.Button("Clear", elem_classes="clear-btn")

                    # Model selector
                    gr.HTML("<div style='font-size:0.75rem; color:#64748b; margin:8px 0 4px; text-transform:uppercase; letter-spacing:0.08em; font-weight:500;'>Model</div>")
                    model_selector = gr.Radio(
                        choices=[
                            ("🦙  Llama 3.2  (default)", "ollama"),
                            ("💎  Gemma 3  (Google)", "gemma"),
                            ("✦  Claude  (API key needed)", "anthropic"),
                            ("⬡  GPT-4o  (API key needed)", "openai"),
                        ],
                        value="ollama",
                        show_label=False,
                        elem_classes="model-radio",
                    )

                    # ── Admin panel (hidden until logged in) ───
                    with gr.Column(visible=False, elem_classes="admin-panel") as admin_panel:
                        gr.HTML("<div style='color:#f59e0b; font-family:Syne,sans-serif; font-weight:700; font-size:0.95rem; margin-bottom:12px;'>⚙️ Admin Controls</div>")

                        with gr.Accordion("✏️ Correct Last Answer", open=True):
                            load_last_btn = gr.Button("📥 Load Last Answer", size="sm")
                            corr_q_box    = gr.Textbox(label="Question", interactive=False)
                            corr_a_box    = gr.Textbox(
                                label="Correct Answer",
                                lines=6,
                                placeholder="Enter the correct answer here...",
                            )
                            corr_src_box  = gr.Textbox(
                                label="Source Reference (optional)",
                                placeholder="e.g. Security Policy v1.6, page 23",
                            )
                            with gr.Row():
                                save_corr_btn = gr.Button("💾 Save Correction", variant="primary", scale=2)
                                corr_status   = gr.HTML("", scale=3)

                        with gr.Accordion("📋 Manage Corrections", open=False):
                            corr_df = gr.Dataframe(
                                headers=["ID (8 chars)", "Question", "Answer", "By", "Saved At"],
                                datatype=["str", "str", "str", "str", "str"],
                                wrap=True,
                                label=None,
                            )
                            with gr.Row():
                                refresh_corr_btn = gr.Button("🔄 Refresh", scale=1)
                                del_id_box       = gr.Textbox(
                                    label="ID prefix to delete",
                                    placeholder="First 8 chars of ID",
                                    scale=3,
                                    container=False,
                                )
                                del_corr_btn = gr.Button("🗑️ Delete", variant="stop", scale=1)
                            del_status = gr.HTML("")

            # ── Tab 3: ESL Template Generator ─────────────────
            with gr.TabItem("🏷️  ESL Tags"):
                with gr.Column(elem_classes="chat-page"):
                    gr.HTML("""
                    <div class="chat-header" style="margin-bottom:8px;">
                        <div>
                            <div style="display:flex; align-items:center; gap:10px;">
                                <span style="font-family:'Syne',sans-serif; font-size:1.3rem; font-weight:700;">
                                    ESL Template Generator
                                </span>
                                <span class="status-pill">
                                    <span class="status-dot"></span> AI-Powered
                                </span>
                            </div>
                            <div class="back-hint">
                                Describe your label layout — AI generates the XSL template + designer JSON
                            </div>
                        </div>
                    </div>
                    """)

                    # ── Row 1: ESL size + AI model ────────────────
                    with gr.Row():
                        esl_size_dd = gr.Dropdown(
                            choices=_ESL_SIZE_CHOICES,
                            value=_ESL_SIZE_DEFAULT,
                            label="ESL Size  (54 models)",
                            scale=1,
                            allow_custom_value=False,
                        )
                        esl_model_dd = gr.Radio(
                            choices=[
                                ("🦙  Llama 3.2", "ollama"),
                                ("💎  Gemma 3", "gemma"),
                                ("✦  Claude", "anthropic"),
                                ("⬡  GPT-4o", "openai"),
                            ],
                            value="ollama",
                            label="AI Model",
                            scale=3,
                            elem_classes="model-radio",
                        )

                    # ── Row 2: Company profile bar ────────────────
                    gr.HTML("<div style='font-size:0.75rem; color:#64748b; margin:12px 0 4px; text-transform:uppercase; letter-spacing:0.08em; font-weight:500;'>Company Field Profile</div>")
                    with gr.Row():
                        esl_profile_dd = gr.Dropdown(
                            choices=_esl_profile_choices(),
                            value=None,
                            label="Load saved profile",
                            scale=3,
                            allow_custom_value=False,
                        )
                        esl_load_profile_btn = gr.Button("Load", scale=1, min_width=80)
                        esl_company_code_box = gr.Textbox(
                            label="Company Code",
                            placeholder="e.g. ACME or RETAILCO_SAP",
                            scale=2,
                            max_lines=1,
                        )
                        esl_save_profile_btn = gr.Button("Save Profile", scale=1, min_width=110)
                    esl_profile_status = gr.HTML("")

                    # ── Row 3: Fields — upload or paste ──────────
                    gr.HTML("<div style='font-size:0.75rem; color:#64748b; margin:12px 0 4px; text-transform:uppercase; letter-spacing:0.08em; font-weight:500;'>Product Fields</div>")
                    with gr.Row():
                        esl_upload = gr.File(
                            label="Upload fields JSON file",
                            file_types=[".json"],
                            scale=1,
                        )
                        esl_fields_box = gr.Textbox(
                            label="Or paste / edit fields JSON directly",
                            value='{\n  "ITEM_NAME": "string",\n  "LIST_PRICE": "decimal",\n  "UNIT_PRICE": "decimal",\n  "UNIT_PRICE_UNIT": "string",\n  "ITEM_ID": "string",\n  "PACK_QUANTITY": "string",\n  "END_DATE": "string"\n}',
                            lines=10,
                            scale=3,
                            elem_id="esl_fields_box",
                        )

                    # ── Logo / Image upload + dithering ──────────
                    gr.HTML("<div style='font-size:0.75rem; color:#64748b; margin:16px 0 4px; text-transform:uppercase; letter-spacing:0.08em; font-weight:500;'>Logo / Image  <span style='text-transform:none; letter-spacing:0; font-weight:400; color:#475569;'>(optional — auto-dithered to label palette)</span></div>")
                    with gr.Row(equal_height=False):
                        with gr.Column(scale=1):
                            esl_logo_upload = gr.Image(
                                label="Upload logo or product image",
                                type="pil",
                                image_mode="RGB",
                                sources=["upload"],
                                height=160,
                            )
                        with gr.Column(scale=1):
                            esl_dithered_preview = gr.Image(
                                label="Dithered preview  (colors auto-matched to label palette)",
                                interactive=False,
                                height=160,
                            )
                    esl_dithered_logo_state  = gr.State(None)
                    esl_layout_spec_state    = gr.State("")   # holds current layout JSON for refinements

                    # ── Row 4: Prompt guide ───────────────────────
                    with gr.Accordion("💡 How to describe your label  (click to expand)", open=False):
                        gr.HTML("""
                        <div style="font-size:0.85rem; line-height:1.8; color:#cbd5e1; padding:8px 4px;">

                        <div style="color:#3b82f6; font-weight:700; font-size:0.9rem; margin-bottom:8px;">
                            Write your description as plain sentences. Cover these points:
                        </div>

                        <table style="width:100%; border-collapse:collapse; font-size:0.82rem;">
                          <tr style="border-bottom:1px solid #1e2130;">
                            <td style="padding:6px 12px 6px 0; color:#94a3b8; white-space:nowrap; vertical-align:top;">📐 Background</td>
                            <td style="padding:6px 0;">"White background" · "Yellow background" · "Red top banner, white body"</td>
                          </tr>
                          <tr style="border-bottom:1px solid #1e2130;">
                            <td style="padding:6px 12px 6px 0; color:#94a3b8; white-space:nowrap; vertical-align:top;">🔤 Product name</td>
                            <td style="padding:6px 0;">"Product name bold centered at top, Arial 20pt, fits in one line"</td>
                          </tr>
                          <tr style="border-bottom:1px solid #1e2130;">
                            <td style="padding:6px 12px 6px 0; color:#94a3b8; white-space:nowrap; vertical-align:top;">💲 Price</td>
                            <td style="padding:6px 0;">"Large sale price center-right, bold Arial 44pt" · "Crossed-out original price above in small grey"</td>
                          </tr>
                          <tr style="border-bottom:1px solid #1e2130;">
                            <td style="padding:6px 12px 6px 0; color:#94a3b8; white-space:nowrap; vertical-align:top;">📦 Unit price</td>
                            <td style="padding:6px 0;">"Unit price in a bordered box on the left, label 'UNIT PRICE' above it"</td>
                          </tr>
                          <tr style="border-bottom:1px solid #1e2130;">
                            <td style="padding:6px 12px 6px 0; color:#94a3b8; white-space:nowrap; vertical-align:top;">📊 Barcode</td>
                            <td style="padding:6px 0;">"Barcode bottom-left" · "Barcode top-right, 160px wide, 18px tall"</td>
                          </tr>
                          <tr style="border-bottom:1px solid #1e2130;">
                            <td style="padding:6px 12px 6px 0; color:#94a3b8; white-space:nowrap; vertical-align:top;">🪧 Other fields</td>
                            <td style="padding:6px 0;">"Item ID small top-right" · "Pack quantity small near product name" · "End date small bottom"</td>
                          </tr>
                          <tr>
                            <td style="padding:6px 12px 6px 0; color:#94a3b8; white-space:nowrap; vertical-align:top;">✏️ Font / style</td>
                            <td style="padding:6px 0;">"Use Arial throughout" · "Price bold and red" · "Product name italic"</td>
                          </tr>
                        </table>

                        <div style="margin-top:14px; padding:10px 14px; background:#0a0c10; border-radius:8px; border-left:3px solid #3b82f6;">
                            <div style="color:#64748b; font-size:0.75rem; margin-bottom:4px;">GOOD EXAMPLE</div>
                            <div style="color:#e2e8f0; font-style:italic;">
                            "White background. Product name bold centered at the top, Arial, auto-fit text.
                            Large list price center-right, bold Arial 44pt. Unit price in a black bordered box
                            bottom-left with a small static label 'UNIT PRICE' above it. Barcode bottom-right
                            160px wide. Item ID small text top-right. Pack quantity tiny near product name."
                            </div>
                        </div>

                        <div style="margin-top:10px; color:#64748b; font-size:0.78rem;">
                            💡 Tip: Reference field names from your JSON above (e.g. LIST_PRICE, UNIT_PRICE_UNIT)
                            so AI maps them exactly. Mention position as: top / bottom / left / right / center /
                            top-left / top-right / bottom-left / bottom-right.
                        </div>
                        </div>
                        """)

                    # ── Row 5: Quick-start label types ────────────
                    gr.HTML("<div style='font-size:0.75rem; color:#64748b; margin:12px 0 6px; text-transform:uppercase; letter-spacing:0.08em; font-weight:500;'>Quick Start — pick a label type to pre-fill description</div>")
                    with gr.Row():
                        esl_btn_regular  = gr.Button("Regular",        scale=1, size="sm")
                        esl_btn_sale     = gr.Button("Sale",            scale=1, size="sm")
                        esl_btn_clr      = gr.Button("Clearance",       scale=1, size="sm")

                    # ── Row 6: Layout description ─────────────────
                    esl_desc_box = gr.Textbox(
                        label="Layout Description  (edit after selecting a quick-start or write your own)",
                        lines=6,
                        placeholder=(
                            "e.g. White background. Product name bold centered at top. "
                            "Large sale price bottom-right in bold Arial. Small unit price "
                            "bottom-left with a border box. Barcode top-right. Item ID small top-right."
                        ),
                        elem_id="esl_desc_box",
                    )

                    # ── Field-name autocomplete (Tab / → to accept) ───
                    gr.HTML("""
<script>
(function () {
  'use strict';

  var fieldNames = [];
  var currentSuggestion = null;
  var descTA = null;
  var fieldsTA = null;
  var popup = null;

  /* ── popup element ── */
  function createPopup() {
    popup = document.createElement('div');
    popup.id = 'esl-ac-popup';
    popup.style.cssText =
      'position:fixed;z-index:99999;background:#111318;border:1px solid #3b82f6;' +
      'border-radius:8px;padding:5px 12px;font-size:0.8rem;color:#e2e8f0;' +
      'pointer-events:none;display:none;box-shadow:0 4px 20px rgba(0,0,0,.6);' +
      'white-space:nowrap;font-family:"DM Sans",monospace;';
    document.body.appendChild(popup);
  }

  function showPopup(prefix, suggestion) {
    if (!popup) createPopup();
    var rest = suggestion.slice(prefix.length);
    popup.innerHTML =
      '<span style="color:#64748b;font-size:.72rem;margin-right:6px;">Tab&nbsp;/&nbsp;&#8594;</span>' +
      '<span style="color:#e2e8f0;font-weight:600;">' + prefix + '</span>' +
      '<span style="color:#3b82f6;">' + rest + '</span>';
    var rect = descTA.getBoundingClientRect();
    popup.style.left = (rect.left + 8) + 'px';
    popup.style.top  = (rect.bottom + 5) + 'px';
    popup.style.display = 'block';
  }

  function hidePopup() {
    if (popup) popup.style.display = 'none';
    currentSuggestion = null;
  }

  /* ── field-name helpers ── */
  function parseFields(json) {
    try { return Object.keys(JSON.parse(json)); }
    catch (_) {
      return (json.match(/"([A-Z][A-Z0-9_]*)"\s*:/g) || [])
        .map(function (m) { return m.replace(/["\s:]/g, ''); });
    }
  }

  function getPrefix(text, pos) {
    var m = text.slice(0, pos).match(/([A-Z][A-Z0-9_]*)$/);
    return m ? m[1] : '';
  }

  function getSuggestion(prefix) {
    if (prefix.length < 2) return null;
    for (var i = 0; i < fieldNames.length; i++) {
      if (fieldNames[i] !== prefix && fieldNames[i].indexOf(prefix) === 0)
        return fieldNames[i];
    }
    return null;
  }

  /* ── accept suggestion ── */
  function accept() {
    if (!currentSuggestion || !descTA) return;
    var pos    = descTA.selectionStart;
    var prefix = getPrefix(descTA.value, pos);
    if (!prefix) return;
    var before = descTA.value.slice(0, pos - prefix.length);
    var after  = descTA.value.slice(pos);
    var newVal = before + currentSuggestion + after;
    var newPos = before.length + currentSuggestion.length;

    /* update textarea and fire Gradio's input event */
    var setter = Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set;
    setter.call(descTA, newVal);
    descTA.dispatchEvent(new Event('input', { bubbles: true }));
    descTA.setSelectionRange(newPos, newPos);
    hidePopup();
  }

  /* ── event handlers ── */
  function onInput() {
    var prefix = getPrefix(this.value, this.selectionStart);
    var s = getSuggestion(prefix);
    if (s) { currentSuggestion = s; showPopup(prefix, s); }
    else hidePopup();
  }

  function onKeydown(e) {
    if (!currentSuggestion) return;
    if (e.key === 'Tab' || e.key === 'ArrowRight') {
      e.preventDefault();
      accept();
    } else if (e.key === 'Escape') {
      hidePopup();
    }
  }

  /* ── initialise ── */
  function setup() {
    fieldsTA.addEventListener('input', function () {
      fieldNames = parseFields(this.value);
    });
    fieldNames = parseFields(fieldsTA.value);

    descTA.addEventListener('input',   onInput);
    descTA.addEventListener('keydown', onKeydown);
    descTA.addEventListener('blur',    function () { setTimeout(hidePopup, 160); });
    descTA.addEventListener('click',   hidePopup);
    console.log('[ESL Autocomplete] ready — fields:', fieldNames);
  }

  function findTextareas() {
    var dc = document.getElementById('esl_desc_box');
    var fc = document.getElementById('esl_fields_box');
    if (dc && fc) {
      descTA   = dc.querySelector('textarea');
      fieldsTA = fc.querySelector('textarea');
      if (descTA && fieldsTA) return true;
    }
    /* fallback: search by label text */
    document.querySelectorAll('textarea').forEach(function (ta) {
      var lbl = (ta.closest('.form') || ta.closest('[class*="block"]') || ta.parentElement);
      lbl = lbl && lbl.querySelector('label span, .label span');
      if (!lbl) return;
      if (lbl.textContent.indexOf('Layout Description') !== -1) descTA   = ta;
      if (lbl.textContent.indexOf('fields JSON')        !== -1) fieldsTA = ta;
    });
    return !!(descTA && fieldsTA);
  }

  var tries = 0;
  var ticker = setInterval(function () {
    if (++tries > 40) { clearInterval(ticker); return; }
    if (findTextareas()) { clearInterval(ticker); setup(); }
  }, 500);
})();
</script>
""")

                    # ── Reference data for live preview ──────────
                    gr.HTML("<div style='font-size:0.75rem; color:#64748b; margin:12px 0 4px; text-transform:uppercase; letter-spacing:0.08em; font-weight:500;'>Sample Data  <span style='text-transform:none; letter-spacing:0; font-weight:400; color:#475569;'>(for live preview — fill with real product values)</span></div>")
                    esl_ref_data_box = gr.Textbox(
                        label="Reference data JSON  (field_name: display_value)",
                        placeholder='{\n  "ITEM_NAME": "Organic Whole Milk 1L",\n  "LIST_PRICE": "2.99",\n  "ITEM_ID": "SKU-001234"\n}',
                        lines=4,
                        value="",
                    )

                    esl_gen_btn = gr.Button("Generate Template  +  Live Preview", variant="primary", elem_classes="send-btn")
                    esl_status  = gr.HTML("")
                    esl_stream_box = gr.Textbox(
                        label="AI stream  (live token output — visible while model is generating)",
                        lines=3,
                        interactive=False,
                        visible=True,
                        value="",
                        elem_id="esl_stream_box",
                    )

                    # ── Row 5: Output ─────────────────────────────
                    with gr.Row():
                        esl_xsl_out = gr.Textbox(
                            label="Generated XSL  (copy or download)",
                            lines=18,
                            interactive=True,
                        )
                        esl_json_out = gr.Textbox(
                            label="Designer JSON  (load back in template designer for future edits)",
                            lines=18,
                            interactive=True,
                        )

                    with gr.Row():
                        esl_dl_xsl  = gr.DownloadButton(label="Download .xsl",  scale=1)
                        esl_dl_json = gr.DownloadButton(label="Download designer .json", scale=1)
                        gr.HTML("<div style='flex:3'></div>")

                    # ── Live label preview ────────────────────────
                    gr.HTML("<div style='font-size:0.75rem; color:#64748b; margin:16px 0 6px; text-transform:uppercase; letter-spacing:0.08em; font-weight:500;'>Live Preview  <span style='text-transform:none; letter-spacing:0; font-weight:400; color:#475569;'>(rendered with your sample data — shows final label appearance)</span></div>")
                    esl_preview_img = gr.Image(
                        label="Label Preview",
                        interactive=False,
                    )

                    # ── AI Refinement ─────────────────────────────
                    gr.HTML("""
                    <div style='margin:20px 0 6px; padding:10px 14px; background:#0f172a;
                                border:1px solid #1e293b; border-radius:8px;'>
                      <div style='font-size:0.75rem; color:#64748b; text-transform:uppercase;
                                  letter-spacing:0.08em; font-weight:500; margin-bottom:4px;'>
                        Refine Layout
                      </div>
                      <div style='font-size:0.82rem; color:#94a3b8; line-height:1.5;'>
                        Not happy with the result? Describe any change in plain English and hit
                        <strong style='color:#e2e8f0;'>Apply Refinement</strong>.
                        You can refine as many times as needed — each pass builds on the last.
                        <br><br>
                        <span style='color:#64748b;'>Examples: &nbsp;</span>
                        <em>"Move the price to the right side"</em> &nbsp;·&nbsp;
                        <em>"Add BRAND_NAME below the product name in grey"</em> &nbsp;·&nbsp;
                        <em>"Make the barcode 30px taller"</em> &nbsp;·&nbsp;
                        <em>"Add a horizontal red divider line between name and price"</em>
                      </div>
                    </div>
                    """)
                    with gr.Row():
                        esl_refine_box = gr.Textbox(
                            label="Refinement instruction",
                            placeholder="e.g. Move price to center-right and make it larger",
                            lines=2,
                            scale=4,
                        )
                        esl_refine_btn = gr.Button(
                            "Apply Refinement",
                            variant="secondary",
                            scale=1,
                            min_width=140,
                        )

            # ── Tab 4: Wiki (placeholder) ──────────────────────
            with gr.TabItem("📖  Wiki"):
                gr.HTML("""
                <div style="text-align:center; padding:80px 20px; color:#475569;">
                    <div style="font-size:3rem; margin-bottom:16px;">📖</div>
                    <div style="font-family:Syne,sans-serif; font-size:1.4rem; font-weight:700; 
                                color:#e2e8f0; margin-bottom:8px;">SOLUM Wiki</div>
                    <div style="font-size:0.9rem; line-height:1.6; max-width:400px; margin:0 auto;">
                        Internal knowledge base — search and Q&A across all documentation.<br>
                        <strong style="color:#3b82f6;">Coming soon</strong>
                    </div>
                </div>
                """)

            # ── Tab 5: Image Gen (placeholder) ────────────────
            with gr.TabItem("🖼️  Images"):
                gr.HTML("""
                <div style="text-align:center; padding:80px 20px; color:#475569;">
                    <div style="font-size:3rem; margin-bottom:16px;">🖼️</div>
                    <div style="font-family:Syne,sans-serif; font-size:1.4rem; font-weight:700; 
                                color:#e2e8f0; margin-bottom:8px;">Image Generator</div>
                    <div style="font-size:0.9rem; line-height:1.6; max-width:400px; margin:0 auto;">
                        Create product images and visual assets from descriptions.<br>
                        <strong style="color:#3b82f6;">Coming soon</strong>
                    </div>
                </div>
                """)

        # ── Wire events ───────────────────────────────────────

        # Chat
        send_btn.click(
            fn=chat,
            inputs=[question_box, chatbot, model_selector],
            outputs=[chatbot, question_box, last_q_state, last_a_state],
        )
        question_box.submit(
            fn=chat,
            inputs=[question_box, chatbot, model_selector],
            outputs=[chatbot, question_box, last_q_state, last_a_state],
        )
        clear_btn.click(
            fn=clear_chat,
            outputs=[chatbot, question_box, last_q_state, last_a_state],
        )

        # Admin: show password row on lock button click
        admin_toggle_btn.click(
            fn=lambda: gr.update(visible=True),
            outputs=[pwd_row],
        )

        # Admin: validate password
        unlock_btn.click(
            fn=_try_unlock,
            inputs=[pwd_input],
            outputs=[pwd_row, admin_badge_row, admin_panel, is_admin_state, admin_toggle_btn, pwd_input, pwd_error],
        )
        pwd_input.submit(
            fn=_try_unlock,
            inputs=[pwd_input],
            outputs=[pwd_row, admin_badge_row, admin_panel, is_admin_state, admin_toggle_btn, pwd_input, pwd_error],
        )

        # Admin: lock
        lock_btn.click(
            fn=_do_lock,
            outputs=[pwd_row, admin_badge_row, admin_panel, is_admin_state, admin_toggle_btn],
        )

        # Admin: populate correction form from last Q&A
        load_last_btn.click(
            fn=lambda q, a: (q, a),
            inputs=[last_q_state, last_a_state],
            outputs=[corr_q_box, corr_a_box],
        )

        # Admin: save correction
        save_corr_btn.click(
            fn=_save_correction,
            inputs=[corr_q_box, corr_a_box, corr_src_box],
            outputs=[corr_status],
        )

        # Admin: list corrections
        refresh_corr_btn.click(
            fn=_list_corrections,
            outputs=[corr_df],
        )

        # Admin: delete correction
        del_corr_btn.click(
            fn=_delete_correction,
            inputs=[del_id_box],
            outputs=[del_status, corr_df],
        )

        # ── ESL: quick-start label type buttons ──────────────
        esl_btn_regular.click(fn=lambda: ESL_PROMPTS["regular"],   outputs=[esl_desc_box])
        esl_btn_sale.click(   fn=lambda: ESL_PROMPTS["sale"],      outputs=[esl_desc_box])
        esl_btn_clr.click(    fn=lambda: ESL_PROMPTS["clearance"], outputs=[esl_desc_box])

        # ── ESL: upload JSON file → fill text box ─────────────
        esl_upload.change(
            fn=_esl_upload_fields,
            inputs=[esl_upload],
            outputs=[esl_fields_box],
        )

        # ── ESL: save profile ─────────────────────────────────
        esl_save_profile_btn.click(
            fn=_esl_save_profile,
            inputs=[esl_company_code_box, esl_fields_box],
            outputs=[esl_profile_status, esl_profile_dd],
        )

        # ── ESL: load profile → fill text box ─────────────────
        esl_load_profile_btn.click(
            fn=_esl_load_profile,
            inputs=[esl_profile_dd],
            outputs=[esl_fields_box, esl_profile_status],
        )

        # ── ESL: dither logo on upload or size change ─────────
        esl_logo_upload.change(
            fn=_dither_logo,
            inputs=[esl_logo_upload, esl_size_dd],
            outputs=[esl_dithered_preview, esl_dithered_logo_state],
        )
        esl_size_dd.change(
            fn=_dither_logo,
            inputs=[esl_logo_upload, esl_size_dd],
            outputs=[esl_dithered_preview, esl_dithered_logo_state],
        )

        # ── ESL: generate template + live preview ─────────────
        _esl_outputs = [
            esl_status, esl_xsl_out, esl_json_out,
            esl_dl_xsl, esl_dl_json,
            esl_layout_spec_state,   # keeps track of current spec for refinements
            esl_preview_img,
            esl_stream_box,          # live token stream during generation
        ]
        esl_gen_btn.click(
            fn=_generate_esl,
            inputs=[esl_fields_box, esl_desc_box, esl_size_dd, esl_model_dd,
                    esl_ref_data_box, esl_dithered_logo_state],
            outputs=_esl_outputs,
        )

        # ── ESL: refine layout ────────────────────────────────
        esl_refine_btn.click(
            fn=_refine_esl,
            inputs=[esl_refine_box, esl_layout_spec_state, esl_size_dd, esl_model_dd,
                    esl_ref_data_box, esl_dithered_logo_state],
            outputs=_esl_outputs,
        )

    return demo


demo = build()

if __name__ == "__main__":
    print("\n🚀 Starting SOLUM AI Platform...")
    print("📌 Open: http://localhost:7860\n")
    demo.launch(
        css=CSS,
        theme=gr.themes.Base(),
        server_name="0.0.0.0",
        server_port=7860,
        show_error=True,
        share=False,
    )
