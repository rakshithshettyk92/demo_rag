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
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.stdout.reconfigure(encoding="utf-8")

import gradio as gr
from datetime import datetime

# ── RAG chain (lazy loaded so UI starts fast) ─────────────────
_rag = None

def get_rag(provider: str):
    global _rag
    try:
        from src.security.rag_chain import SecurityRAGChain
        db_path = os.getenv("VECTORSTORE_PATH", "./vectorstore")
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
        return history, ""

    rag, err = get_rag(model)
    if err:
        history.append({"role": "user", "content": question})
        history.append({"role": "assistant", "content": f"⚠️ Could not connect: {err}"})
        return history, ""

    # Add user message
    history.append({"role": "user", "content": question})
    # Add placeholder assistant message
    history.append({"role": "assistant", "content": "▌"})
    yield history, ""

    try:
        full_answer = ""
        for token in rag.ask_stream(question):
            full_answer += token
            history[-1] = {"role": "assistant", "content": full_answer + "▌"}
            yield history, ""

        history[-1] = {"role": "assistant", "content": full_answer}
        yield history, ""

        # Match the exact prefix the prompt instructs the LLM to use.
        # Only show references when the answer is grounded in retrieved docs.
        from src.security.rag_chain import NOT_FOUND_PREFIX
        answered = NOT_FOUND_PREFIX.lower() not in full_answer.lower()

        if answered:
            # Reuse the docs already retrieved during ask_stream — no second DB call.
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
                    yield history, ""

    except Exception as e:
        history[-1] = {"role": "assistant", "content": f"❌ Error: {e}"}
        yield history, ""


def clear_chat():
    return [], ""


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
    <div class="feature-card">
        <div class="icon">🏷️</div>
        <h3>ESL Tag Generator</h3>
        <p>Generate electronic shelf label content from product data automatically</p>
        <span class="badge badge-soon">Coming Soon</span>
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


# ── BUILD UI ──────────────────────────────────────────────────
def build():
    with gr.Blocks(title="SOLUM AI Platform") as demo:

        with gr.Tabs() as tabs:

            # ── Tab 1: Home ───────────────────────────────────
            with gr.TabItem("🏠  Home"):
                gr.HTML(HOME_HTML)

            # ── Tab 2: Security Assistant ─────────────────────
            with gr.TabItem("🔐  Security"):
                with gr.Column(elem_classes="chat-page"):

                    # Header
                    gr.HTML("""
                    <div class="chat-header">
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

            # ── Tab 3: ESL Tags (placeholder) ─────────────────
            with gr.TabItem("🏷️  ESL Tags"):
                gr.HTML("""
                <div style="text-align:center; padding:80px 20px; color:#475569;">
                    <div style="font-size:3rem; margin-bottom:16px;">🏷️</div>
                    <div style="font-family:Syne,sans-serif; font-size:1.4rem; font-weight:700; 
                                color:#e2e8f0; margin-bottom:8px;">ESL Tag Generator</div>
                    <div style="font-size:0.9rem; line-height:1.6; max-width:400px; margin:0 auto;">
                        Generate electronic shelf label content from product data.<br>
                        <strong style="color:#3b82f6;">Coming soon</strong>
                    </div>
                </div>
                """)

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
        send_btn.click(
            fn=chat,
            inputs=[question_box, chatbot, model_selector],
            outputs=[chatbot, question_box],
        )
        question_box.submit(
            fn=chat,
            inputs=[question_box, chatbot, model_selector],
            outputs=[chatbot, question_box],
        )
        clear_btn.click(fn=clear_chat, outputs=[chatbot, question_box])

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
