# How to Add Custom Rules

Rules are plain Markdown files in this folder (`src/code_review/rules/`).
After adding or editing rule files, re-run:

```bash
python code_review_cli.py ingest
```

This re-ingests all rule files into the `code_review_rules` vector store.

---

## Rule File Format

Create a new `.md` file in this folder. You can have one rule or many rules per file.
Each rule must follow this exact template:

```markdown
## RULE: <Short Rule Name>
**ID**: <YOUR_PREFIX><number>   e.g. MYCO001
**Severity**: Critical | Major | Minor | Info
**Category**: Bug | Security | Style | Performance

### What it detects
<One or two sentences describing the bad pattern to detect.>

### Bad example
```python
# code showing the violation
```

### Good example
```python
# code showing the correct way
```

### Why it matters
<One or two sentences explaining the impact.>
```

---

## Severity Levels

| Level    | When to use |
|----------|-------------|
| Critical | Security vulnerability, data loss risk, production crash |
| Major    | Bug that causes wrong behaviour, serious code smell |
| Minor    | Style issue that reduces readability |
| Info     | Suggestion, best practice, nitpick |

---

## Category Tags

| Category    | Examples |
|-------------|----------|
| Bug         | Logic errors, null dereference, wrong algorithm |
| Security    | Injection, auth issues, secrets exposure |
| Style       | Naming, formatting, readability |
| Performance | O(n²) loops, memory leaks, slow I/O |

---

## Example: Company-Specific Rule

```markdown
## RULE: Use Company Logger
**ID**: MYCO001
**Severity**: Minor
**Category**: Style

### What it detects
Using `print()` instead of the company's standard `from mycompany.logger import get_logger`.

### Bad example
```python
print("Processing order", order_id)
```

### Good example
```python
from mycompany.logger import get_logger
logger = get_logger(__name__)
logger.info("Processing order %s", order_id)
```

### Why it matters
The company logger includes request IDs and structured fields required by the observability platform.
```

---

## Tips

- **Be specific** in "What it detects" — the scanner uses this text to retrieve the rule when it sees similar patterns.
- **Include realistic bad examples** — the RAG retriever matches code patterns against your examples.
- **One concept per rule** — don't combine unrelated checks into one rule ID.
- **Use your own prefix** for IDs to avoid clashing with built-in rules (e.g. `MYCO`, `TEAM`, `PROJ`).
