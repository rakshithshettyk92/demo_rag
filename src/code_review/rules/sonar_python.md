# Sonar Python Rules

---

## RULE: Bare Except Clause
**ID**: PY001
**Severity**: Major
**Category**: Bug

### What it detects
A `except:` clause with no exception type catches everything including `SystemExit`, `KeyboardInterrupt`, and `GeneratorExit`. This hides real errors and makes debugging impossible.

### Bad example
```python
try:
    do_something()
except:
    pass
```

### Good example
```python
try:
    do_something()
except Exception as e:
    logging.error("Unexpected error: %s", e)
```

### Why it matters
Swallowing all exceptions masks bugs and makes the system appear to work when it is silently failing.

---

## RULE: Unused Import
**ID**: PY002
**Severity**: Minor
**Category**: Style

### What it detects
An import statement that is never referenced in the module.

### Bad example
```python
import os
import datetime  # never used

print(os.getcwd())
```

### Good example
```python
import os

print(os.getcwd())
```

### Why it matters
Unused imports pollute the namespace, slow startup, and confuse readers about what the module depends on.

---

## RULE: Unused Variable
**ID**: PY003
**Severity**: Minor
**Category**: Bug

### What it detects
A variable is assigned a value but never read afterwards.

### Bad example
```python
def calculate():
    result = 42
    unused = "never read"
    return result
```

### Good example
```python
def calculate():
    result = 42
    return result
```

### Why it matters
Unused variables waste memory and suggest incomplete refactoring or a logic bug.

---

## RULE: Mutable Default Argument
**ID**: PY004
**Severity**: Major
**Category**: Bug

### What it detects
Using a mutable object (list, dict, set) as a function default argument. The same object is shared across all calls.

### Bad example
```python
def append_item(item, items=[]):
    items.append(item)
    return items
```

### Good example
```python
def append_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### Why it matters
The mutable default is created once and reused, causing state to leak between calls — a classic Python gotcha.

---

## RULE: Hardcoded Credentials
**ID**: PY005
**Severity**: Critical
**Category**: Security

### What it detects
Passwords, API keys, tokens, or secrets assigned directly as string literals in source code.

### Bad example
```python
API_KEY = "sk-abc123secretkey"
password = "admin123"
DB_URL = "postgresql://user:pass@host/db"
```

### Good example
```python
import os
API_KEY = os.getenv("API_KEY")
password = os.getenv("DB_PASSWORD")
DB_URL = os.getenv("DATABASE_URL")
```

### Why it matters
Hardcoded credentials get committed to version control and are visible to anyone with repo access, including future attackers.

---

## RULE: String Concatenation in Loop
**ID**: PY006
**Severity**: Minor
**Category**: Performance

### What it detects
Building a string by using `+=` inside a loop. Each concatenation creates a new string object.

### Bad example
```python
result = ""
for item in items:
    result += item + ", "
```

### Good example
```python
result = ", ".join(items)
# or
parts = []
for item in items:
    parts.append(item)
result = ", ".join(parts)
```

### Why it matters
String concatenation in a loop is O(n²) in memory and time. `join()` is O(n).

---

## RULE: Import Inside Function
**ID**: PY007
**Severity**: Minor
**Category**: Style

### What it detects
An import statement placed inside a function body rather than at the top of the module. Exception: optional/conditional dependency imports are acceptable.

### Bad example
```python
def process():
    import re
    return re.sub(r"\s+", " ", text)
```

### Good example
```python
import re

def process():
    return re.sub(r"\s+", " ", text)
```

### Why it matters
Top-level imports make dependencies explicit and avoid repeated import overhead on every function call.

---

## RULE: Too Broad Exception Handling
**ID**: PY008
**Severity**: Major
**Category**: Bug

### What it detects
Catching `Exception` or all exceptions without logging or re-raising, silently swallowing the error.

### Bad example
```python
try:
    risky_operation()
except Exception:
    return None
```

### Good example
```python
try:
    risky_operation()
except ValueError as e:
    logging.warning("Invalid value: %s", e)
    return None
except Exception:
    logging.exception("Unexpected error in risky_operation")
    raise
```

### Why it matters
Silent failure is worse than a crash — it hides real bugs and makes systems appear to work when they are broken.

---

## RULE: Missing Return Type Hint
**ID**: PY009
**Severity**: Info
**Category**: Style

### What it detects
A public function (not starting with `_`) that lacks a return type annotation.

### Bad example
```python
def get_user(user_id):
    return db.find(user_id)
```

### Good example
```python
from typing import Optional
from models import User

def get_user(user_id: int) -> Optional[User]:
    return db.find(user_id)
```

### Why it matters
Type hints enable static analysis tools to catch type errors and make APIs self-documenting.

---

## RULE: Global Mutable State
**ID**: PY010
**Severity**: Major
**Category**: Bug

### What it detects
Module-level mutable variables modified via the `global` keyword inside functions.

### Bad example
```python
_cache = None

def get_client():
    global _cache
    if _cache is None:
        _cache = create_client()
    return _cache
```

### Good example
```python
class ClientManager:
    def __init__(self):
        self._client = None

    def get_client(self):
        if self._client is None:
            self._client = create_client()
        return self._client
```

### Why it matters
Global state makes code hard to test, thread-unsafe, and creates hidden coupling between functions.

---

## RULE: SQL Injection Risk
**ID**: PY011
**Severity**: Critical
**Category**: Security

### What it detects
SQL queries built by concatenating or formatting user-supplied strings directly into the query.

### Bad example
```python
query = "SELECT * FROM users WHERE name = '" + user_input + "'"
cursor.execute(query)

query = f"DELETE FROM orders WHERE id = {order_id}"
cursor.execute(query)
```

### Good example
```python
cursor.execute("SELECT * FROM users WHERE name = %s", (user_input,))
cursor.execute("DELETE FROM orders WHERE id = %s", (order_id,))
```

### Why it matters
SQL injection is the #1 web vulnerability. Parameterised queries prevent it completely.

---

## RULE: f-string Without Variable
**ID**: PY012
**Severity**: Info
**Category**: Style

### What it detects
An f-string that contains no `{}` placeholders — it is a plain string with unnecessary `f` prefix.

### Bad example
```python
message = f"Hello world"
path = f"/api/v1/users"
```

### Good example
```python
message = "Hello world"
path = "/api/v1/users"
```

### Why it matters
Unnecessary f-prefix is misleading noise and adds minor overhead.

---

## RULE: Magic Number
**ID**: PY013
**Severity**: Info
**Category**: Style

### What it detects
Numeric literals used directly in code without being assigned to a named constant, making the code hard to understand and maintain.

### Bad example
```python
if retries > 3:
    sleep(60)

chunk = data[:800]
```

### Good example
```python
MAX_RETRIES = 3
RETRY_WAIT_SECONDS = 60
CHUNK_SIZE = 800

if retries > MAX_RETRIES:
    sleep(RETRY_WAIT_SECONDS)

chunk = data[:CHUNK_SIZE]
```

### Why it matters
Named constants document intent and make changes (e.g. bumping the retry limit) a one-line edit.

---

## RULE: Comparison to None Using ==
**ID**: PY014
**Severity**: Minor
**Category**: Style

### What it detects
Using `== None` or `!= None` instead of `is None` / `is not None`.

### Bad example
```python
if value == None:
    return default

if result != None:
    process(result)
```

### Good example
```python
if value is None:
    return default

if result is not None:
    process(result)
```

### Why it matters
`None` is a singleton. `is None` tests identity (correct). `== None` calls `__eq__` which can be overridden.

---

## RULE: Print Statement for Debugging
**ID**: PY015
**Severity**: Info
**Category**: Style

### What it detects
`print()` calls used for debugging or logging in production code rather than the `logging` module.

### Bad example
```python
def process(data):
    print(f"Processing: {data}")
    result = transform(data)
    print(f"Result: {result}")
    return result
```

### Good example
```python
import logging
logger = logging.getLogger(__name__)

def process(data):
    logger.debug("Processing: %s", data)
    result = transform(data)
    logger.debug("Result: %s", result)
    return result
```

### Why it matters
`print()` cannot be configured, filtered, or redirected per environment. The `logging` module supports levels, handlers, and formatters.
