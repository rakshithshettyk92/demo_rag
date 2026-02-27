# PEP 8 — Python Style Guide Rules

---

## RULE: Line Too Long
**ID**: E501
**Severity**: Minor
**Category**: Style

### What it detects
Any line exceeding 79 characters (PEP 8 standard) or 120 characters (common team relaxed limit).

### Bad example
```python
result = some_function(argument_one, argument_two, argument_three, argument_four, argument_five)
```

### Good example
```python
result = some_function(
    argument_one,
    argument_two,
    argument_three,
    argument_four,
    argument_five,
)
```

### Why it matters
Long lines require horizontal scrolling and make side-by-side diffs harder to read.

---

## RULE: Improper Indentation
**ID**: E1xx
**Severity**: Major
**Category**: Style

### What it detects
Indentation that is not a multiple of 4 spaces, or mixing tabs and spaces.

### Bad example
```python
def foo():
  x = 1     # 2 spaces — wrong
  if x:
        y = 2   # 8 spaces — inconsistent
```

### Good example
```python
def foo():
    x = 1
    if x:
        y = 2
```

### Why it matters
Inconsistent indentation causes `IndentationError` or subtle logic bugs from misaligned blocks.

---

## RULE: Whitespace Around Operators
**ID**: E225
**Severity**: Minor
**Category**: Style

### What it detects
Missing or extra whitespace around binary operators (`=`, `+`, `-`, `==`, etc.).

### Bad example
```python
x=1
y = x+2
if x ==1:
    pass
```

### Good example
```python
x = 1
y = x + 2
if x == 1:
    pass
```

### Why it matters
Consistent spacing around operators improves readability and makes expressions easier to parse visually.

---

## RULE: Blank Lines Around Functions and Classes
**ID**: E302 / E303
**Severity**: Minor
**Category**: Style

### What it detects
Top-level functions and classes should be separated by two blank lines. Methods inside a class should be separated by one blank line.

### Bad example
```python
def foo():
    pass
def bar():
    pass
class MyClass:
    def method_a(self):
        pass
    def method_b(self):
        pass
```

### Good example
```python
def foo():
    pass


def bar():
    pass


class MyClass:
    def method_a(self):
        pass

    def method_b(self):
        pass
```

### Why it matters
Standard blank line conventions make the structure of a module immediately visible.

---

## RULE: Import Ordering
**ID**: E401 / I001
**Severity**: Minor
**Category**: Style

### What it detects
Imports that are not grouped and ordered as: standard library → third-party → local, each group separated by a blank line. Multiple imports on one line.

### Bad example
```python
import os, sys
from myapp import utils
import requests
import json
```

### Good example
```python
import json
import os
import sys

import requests

from myapp import utils
```

### Why it matters
Consistent import ordering makes it immediately clear what a module depends on and avoids circular import issues.

---

## RULE: Naming Conventions
**ID**: N801 / N802 / N803
**Severity**: Minor
**Category**: Style

### What it detects
- Classes not in `CapWords` (PascalCase)
- Functions and variables not in `snake_case`
- Constants not in `UPPER_SNAKE_CASE`

### Bad example
```python
class myClass:          # should be MyClass
    def MyMethod(self): # should be my_method
        myVariable = 1  # should be my_variable
        CHUNK = 800     # OK — constant
```

### Good example
```python
class MyClass:
    def my_method(self):
        my_variable = 1
        CHUNK_SIZE = 800
```

### Why it matters
Consistent naming allows readers to immediately identify whether something is a class, function, variable, or constant.

---

## RULE: Trailing Whitespace
**ID**: W291 / W293
**Severity**: Info
**Category**: Style

### What it detects
Whitespace characters at the end of a line or on a blank line.

### Bad example
```python
def foo():
    x = 1

    return x
```

### Good example
```python
def foo():
    x = 1

    return x
```

### Why it matters
Trailing whitespace causes noisy diffs and can cause issues in some text processing tools.

---

## RULE: Missing Newline at End of File
**ID**: W292
**Severity**: Info
**Category**: Style

### What it detects
A file that does not end with a single newline character.

### Why it matters
POSIX standard requires text files to end with a newline. Many Unix tools and diffs behave incorrectly without it.

---

## RULE: Comparison to True/False Using ==
**ID**: E712
**Severity**: Minor
**Category**: Style

### What it detects
Using `== True`, `== False`, `!= True`, `!= False` instead of truthiness checks.

### Bad example
```python
if flag == True:
    pass

if result == False:
    retry()
```

### Good example
```python
if flag:
    pass

if not result:
    retry()
```

### Why it matters
Direct truthiness checks are more Pythonic, more readable, and work with any truthy/falsy value.

---

## RULE: Unnecessary Semicolons
**ID**: E703
**Severity**: Info
**Category**: Style

### What it detects
Semicolons at the end of a statement or used to separate statements on one line (Python is not C).

### Bad example
```python
x = 1;
y = 2; z = 3;
```

### Good example
```python
x = 1
y = 2
z = 3
```

### Why it matters
Semicolons are not idiomatic Python and add visual clutter without benefit.
