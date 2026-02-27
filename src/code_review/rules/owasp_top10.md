# OWASP Top 10 — Python Code Patterns

---

## RULE: SQL Injection (A03)
**ID**: OW001
**Severity**: Critical
**Category**: Security

### What it detects
User-controlled input concatenated directly into SQL query strings using `+`, `%`, or f-strings.

### Bad example
```python
username = request.args.get("user")
query = "SELECT * FROM users WHERE username = '" + username + "'"
cursor.execute(query)

# Also bad:
cursor.execute(f"SELECT * FROM accounts WHERE id = {user_id}")
cursor.execute("DELETE FROM items WHERE name = '%s'" % name)
```

### Good example
```python
cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
cursor.execute("SELECT * FROM accounts WHERE id = %s", (user_id,))
# SQLAlchemy ORM:
session.query(User).filter(User.id == user_id).first()
```

### Why it matters
SQL injection is OWASP #3. Parameterised queries prevent it completely at zero extra cost.

---

## RULE: Hardcoded Secret / Broken Authentication (A07)
**ID**: OW002
**Severity**: Critical
**Category**: Security

### What it detects
Secret keys, passwords, tokens, or API keys assigned directly as string literals.
Patterns: variable names containing `password`, `secret`, `token`, `key`, `api_key`, `credentials` assigned to string literals.

### Bad example
```python
SECRET_KEY = "mysupersecretkey123"
JWT_SECRET = "hardcoded-jwt-secret"
AWS_ACCESS_KEY = "AKIA1234EXAMPLE"
password = "admin"
```

### Good example
```python
import os
SECRET_KEY = os.getenv("SECRET_KEY")
JWT_SECRET = os.getenv("JWT_SECRET")
AWS_ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
```

### Why it matters
OWASP A07 (Identification and Authentication Failures). Secrets in source code end up in git history permanently and are exposed to all contributors.

---

## RULE: Command Injection (A03)
**ID**: OW003
**Severity**: Critical
**Category**: Security

### What it detects
User-supplied input passed to `os.system()`, `subprocess.call()` with `shell=True`, or `eval()`/`exec()`.

### Bad example
```python
os.system("ping " + user_input)
subprocess.call("ls " + directory, shell=True)
eval(user_provided_expression)
exec(user_code)
```

### Good example
```python
import subprocess
subprocess.run(["ping", user_input], check=True)  # list form — no shell injection
subprocess.run(["ls", directory], check=True)
# Never use eval/exec on user input
```

### Why it matters
Shell injection allows attackers to run arbitrary system commands. Using list form for subprocess prevents shell expansion entirely.

---

## RULE: Path Traversal (A01)
**ID**: OW004
**Severity**: Critical
**Category**: Security

### What it detects
File paths constructed from user input without validation, allowing `../` sequences to escape the intended directory.

### Bad example
```python
filename = request.args.get("file")
with open("/var/uploads/" + filename) as f:
    return f.read()
```

### Good example
```python
import os
from pathlib import Path

BASE_DIR = Path("/var/uploads").resolve()
filename = request.args.get("file")
safe_path = (BASE_DIR / filename).resolve()

if not str(safe_path).startswith(str(BASE_DIR)):
    raise ValueError("Path traversal detected")

with open(safe_path) as f:
    return f.read()
```

### Why it matters
OWASP A01 (Broken Access Control). Path traversal lets attackers read `/etc/passwd`, private keys, and other sensitive files.

---

## RULE: Insecure Deserialization (A08)
**ID**: OW005
**Severity**: Critical
**Category**: Security

### What it detects
Using `pickle.loads()`, `yaml.load()` (without `Loader=yaml.SafeLoader`), or `marshal.loads()` on untrusted data.

### Bad example
```python
import pickle
data = pickle.loads(user_supplied_bytes)

import yaml
config = yaml.load(user_input)  # unsafe
```

### Good example
```python
import json
data = json.loads(user_supplied_string)  # safe — no code execution

import yaml
config = yaml.safe_load(user_input)  # safe loader
```

### Why it matters
OWASP A08. Deserializing attacker-controlled data with pickle/yaml can execute arbitrary Python code.

---

## RULE: Cross-Site Scripting XSS (A03)
**ID**: OW006
**Severity**: Major
**Category**: Security

### What it detects
User input rendered directly into HTML responses without escaping in Flask/Django/Jinja2 templates.

### Bad example
```python
# Flask
@app.route("/greet")
def greet():
    name = request.args.get("name")
    return f"<h1>Hello {name}</h1>"  # raw user input in HTML

# Jinja2 with autoescape off
return render_template_string("Hello {{ name }}", name=user_input, autoescape=False)
```

### Good example
```python
from markupsafe import escape

@app.route("/greet")
def greet():
    name = escape(request.args.get("name", ""))
    return f"<h1>Hello {name}</h1>"

# Jinja2 autoescape is ON by default — use {{ variable }} not {{ variable | safe }}
```

### Why it matters
XSS allows attackers to inject scripts into pages viewed by other users, stealing sessions or credentials.

---

## RULE: Sensitive Data Exposure in Logs (A02)
**ID**: OW007
**Severity**: Major
**Category**: Security

### What it detects
Passwords, tokens, credit card numbers, or PII logged via `print()`, `logging`, or written to files.

### Bad example
```python
logging.info(f"User login: username={username}, password={password}")
print(f"API response: {response}")  # response may contain tokens
logger.debug("Payment data: %s", card_details)
```

### Good example
```python
logging.info("User login: username=%s", username)
# Never log passwords, tokens, or card details
logger.debug("Payment processed for user_id=%s", user_id)
```

### Why it matters
OWASP A02 (Cryptographic Failures). Log files are often stored insecurely and may be accessible to many people.

---

## RULE: Using MD5 or SHA1 for Password Hashing (A02)
**ID**: OW008
**Severity**: Critical
**Category**: Security

### What it detects
Using `hashlib.md5()` or `hashlib.sha1()` to hash passwords. These are fast hashes — not suitable for passwords.

### Bad example
```python
import hashlib
hashed = hashlib.md5(password.encode()).hexdigest()
hashed = hashlib.sha1(password.encode()).hexdigest()
```

### Good example
```python
import bcrypt
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt())

# Or using passlib
from passlib.hash import argon2
hashed = argon2.hash(password)
```

### Why it matters
MD5/SHA1 hashes can be cracked in seconds with GPU rainbow tables. bcrypt/argon2 are deliberately slow and salted.

---

## RULE: Debug Mode in Production (A05)
**ID**: OW009
**Severity**: Major
**Category**: Security

### What it detects
`debug=True` passed to Flask `app.run()` or Django `DEBUG = True` in settings without environment gating.

### Bad example
```python
app.run(debug=True, host="0.0.0.0")

# settings.py
DEBUG = True
```

### Good example
```python
import os
debug = os.getenv("FLASK_DEBUG", "false").lower() == "true"
app.run(debug=debug)

# settings.py
DEBUG = os.getenv("DJANGO_DEBUG", "False") == "True"
```

### Why it matters
OWASP A05 (Security Misconfiguration). Debug mode exposes stack traces, environment variables, and an interactive debugger to attackers.

---

## RULE: Missing Input Validation (A03)
**ID**: OW010
**Severity**: Major
**Category**: Security

### What it detects
Request parameters used directly without length/type/format validation before being processed or stored.

### Bad example
```python
@app.route("/user/<int:user_id>/update", methods=["POST"])
def update_user(user_id):
    name = request.form["name"]        # no length check
    email = request.form["email"]      # no format validation
    db.execute("UPDATE users SET name=?, email=? WHERE id=?", (name, email, user_id))
```

### Good example
```python
from pydantic import BaseModel, EmailStr, constr

class UpdateUserRequest(BaseModel):
    name: constr(min_length=1, max_length=100)
    email: EmailStr

@app.route("/user/<int:user_id>/update", methods=["POST"])
def update_user(user_id):
    try:
        data = UpdateUserRequest(**request.form)
    except ValidationError as e:
        return {"error": str(e)}, 400
    db.execute("UPDATE users SET name=?, email=? WHERE id=?",
               (data.name, data.email, user_id))
```

### Why it matters
Unvalidated input is the root cause of injection, buffer overflows, and data corruption. Validate at every trust boundary.
