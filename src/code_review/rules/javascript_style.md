# ESLint Recommended + JavaScript Style Rules

---

## RULE: Prefer const Over let
**ID**: JSSTYLE001
**Severity**: Minor
**Category**: Style
**Language**: javascript

### What it detects
Variables declared with `let` that are never reassigned and should be `const`.

### Bad example
```javascript
let name = "Alice";         // never reassigned
let config = { timeout: 30 }; // object reference never reassigned
```

### Good example
```javascript
const name = "Alice";
const config = { timeout: 30 }; // const for object reference, properties can still change
let count = 0;                  // let only when reassignment needed
```

### Why it matters
`const` signals the reader that this binding will not change, making code easier to reason about.

---

## RULE: Arrow Function Consistency
**ID**: JSSTYLE002
**Severity**: Info
**Category**: Style
**Language**: javascript

### What it detects
Mixing arrow functions and regular functions for callbacks where arrow functions are more appropriate.

### Bad example
```javascript
const doubled = numbers.map(function(n) { return n * 2; });
setTimeout(function() { refresh(); }, 1000);
```

### Good example
```javascript
const doubled = numbers.map(n => n * 2);
setTimeout(() => refresh(), 1000);
```

### Why it matters
Arrow functions are shorter and don't rebind `this`, avoiding a common source of bugs.

---

## RULE: Object Destructuring
**ID**: JSSTYLE003
**Severity**: Info
**Category**: Style
**Language**: javascript

### What it detects
Accessing multiple properties of an object without using destructuring.

### Bad example
```javascript
const firstName = user.firstName;
const lastName  = user.lastName;
const email     = user.email;
```

### Good example
```javascript
const { firstName, lastName, email } = user;
```

### Why it matters
Destructuring is more concise and makes the properties being used explicit.

---

## RULE: Template Literals Instead of String Concatenation
**ID**: JSSTYLE004
**Severity**: Minor
**Category**: Style
**Language**: javascript

### What it detects
String concatenation using `+` that would be clearer as a template literal.

### Bad example
```javascript
const message = "Hello, " + firstName + " " + lastName + "!";
const url = baseUrl + "/api/v" + version + "/users/" + userId;
```

### Good example
```javascript
const message = `Hello, ${firstName} ${lastName}!`;
const url = `${baseUrl}/api/v${version}/users/${userId}`;
```

### Why it matters
Template literals are more readable and avoid missing spaces or quote errors.

---

## RULE: Semicolons
**ID**: JSSTYLE005
**Severity**: Info
**Category**: Style
**Language**: javascript

### What it detects
Missing semicolons at end of statements (when the project style requires them).

### Bad example
```javascript
const x = 1
const y = 2
function foo() { return x + y }
```

### Good example
```javascript
const x = 1;
const y = 2;
function foo() { return x + y; }
```

### Why it matters
Automatic Semicolon Insertion (ASI) has edge cases that cause subtle bugs. Explicit semicolons are unambiguous.

---

## RULE: No Trailing Commas in Wrong Places
**ID**: JSSTYLE006
**Severity**: Info
**Category**: Style
**Language**: javascript

### What it detects
Missing trailing commas in multi-line arrays, objects, and parameter lists (makes diffs cleaner).

### Bad example
```javascript
const config = {
    host: "localhost",
    port: 3000,
    debug: true   // no trailing comma — adding a line creates a 2-line diff
};
```

### Good example
```javascript
const config = {
    host: "localhost",
    port: 3000,
    debug: true,  // trailing comma — adding a line is a 1-line diff
};
```

### Why it matters
Trailing commas reduce noise in git diffs when adding new entries.

---

## RULE: Consistent Return
**ID**: JSSTYLE007
**Severity**: Major
**Category**: Bug
**Language**: javascript

### What it detects
Functions that sometimes return a value and sometimes return nothing (implicit `undefined`).

### Bad example
```javascript
function getUser(id) {
    if (id > 0) {
        return fetchUser(id);
    }
    // implicit return undefined for invalid ids
}
```

### Good example
```javascript
function getUser(id) {
    if (id > 0) {
        return fetchUser(id);
    }
    return null; // explicit
}
```

### Why it matters
Inconsistent returns make callers unsure whether to check for `undefined` or `null`.

---

## RULE: No var in TypeScript
**ID**: TSSTYLE001
**Severity**: Major
**Category**: Style
**Language**: javascript

### What it detects
`var` declarations in TypeScript files (`.ts`, `.tsx`).

### Bad example
```typescript
var userId: number = 42;
var items: string[] = [];
```

### Good example
```typescript
const userId: number = 42;
const items: string[] = [];
```

### Why it matters
TypeScript projects should always use `const`/`let`. `var` has been superseded since ES6.
