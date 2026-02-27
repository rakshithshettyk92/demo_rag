# Sonar JavaScript / TypeScript Rules

---

## RULE: var Instead of let/const
**ID**: JS001
**Severity**: Major
**Category**: Bug
**Language**: javascript

### What it detects
Using `var` for variable declarations instead of `let` or `const`. `var` has function scope and is hoisted, causing subtle bugs.

### Bad example
```javascript
var count = 0;
var name = "Alice";
for (var i = 0; i < 10; i++) {
    setTimeout(() => console.log(i), 100); // always prints 10
}
```

### Good example
```javascript
const name = "Alice";
let count = 0;
for (let i = 0; i < 10; i++) {
    setTimeout(() => console.log(i), 100); // prints 0-9
}
```

### Why it matters
`let` and `const` have block scope and are not hoisted, preventing many common bugs.

---

## RULE: == Instead of ===
**ID**: JS002
**Severity**: Major
**Category**: Bug
**Language**: javascript

### What it detects
Using `==` or `!=` (loose equality) instead of `===` or `!==` (strict equality).

### Bad example
```javascript
if (value == null) { }       // true for both null AND undefined
if (count == "0") { }        // true — string "0" coerced to number
if (result != false) { }
```

### Good example
```javascript
if (value === null || value === undefined) { }
if (count === 0) { }
if (result !== false) { }
```

### Why it matters
`==` performs type coercion with non-obvious results. `===` checks both value and type.

---

## RULE: Hardcoded Credentials in JavaScript
**ID**: JS003
**Severity**: Critical
**Category**: Security
**Language**: javascript

### What it detects
API keys, tokens, passwords, or secrets assigned as string literals in JS/TS code.

### Bad example
```javascript
const API_KEY = "sk-abc123secret";
const password = "admin123";
fetch(url, { headers: { Authorization: "Bearer hardcoded-token" } });
```

### Good example
```javascript
const API_KEY = process.env.REACT_APP_API_KEY;   // React
const API_KEY = import.meta.env.VITE_API_KEY;    // Vite
// Server-side:
const API_KEY = process.env.API_KEY;
```

### Why it matters
Frontend JS is sent to every user's browser. Hardcoded secrets are trivially extracted.

---

## RULE: console.log in Production Code
**ID**: JS004
**Severity**: Minor
**Category**: Style
**Language**: javascript

### What it detects
`console.log()`, `console.debug()`, `console.info()` left in production code.

### Bad example
```javascript
function processOrder(order) {
    console.log("Processing order:", order);
    return submit(order);
}
```

### Good example
```javascript
import logger from './logger';

function processOrder(order) {
    logger.debug("Processing order", { orderId: order.id });
    return submit(order);
}
```

### Why it matters
Console logs leak sensitive data to browser devtools and clutter production logs.

---

## RULE: Callback Hell / Nested Promises
**ID**: JS005
**Severity**: Major
**Category**: Style
**Language**: javascript

### What it detects
Deeply nested callbacks or `.then().then().then()` chains that should use `async/await`.

### Bad example
```javascript
getUser(id, function(err, user) {
    getOrders(user.id, function(err, orders) {
        getItems(orders[0].id, function(err, items) {
            render(items);
        });
    });
});
```

### Good example
```javascript
async function loadUserData(id) {
    const user   = await getUser(id);
    const orders = await getOrders(user.id);
    const items  = await getItems(orders[0].id);
    render(items);
}
```

### Why it matters
Nested callbacks are hard to read, test, and handle errors in. async/await is flatter and cleaner.

---

## RULE: Missing Error Handling in Async Functions
**ID**: JS006
**Severity**: Major
**Category**: Bug
**Language**: javascript

### What it detects
`async/await` calls without try/catch, or `.then()` chains without `.catch()`.

### Bad example
```javascript
async function fetchData() {
    const response = await fetch(url); // unhandled rejection
    return response.json();
}

getData().then(process); // no .catch()
```

### Good example
```javascript
async function fetchData() {
    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.json();
    } catch (error) {
        console.error("Fetch failed:", error);
        throw error;
    }
}
```

### Why it matters
Unhandled promise rejections crash Node.js processes and cause silent failures in browsers.

---

## RULE: Unused Variables in JavaScript
**ID**: JS007
**Severity**: Minor
**Category**: Style
**Language**: javascript

### What it detects
Variables, constants, or imports that are declared but never referenced.

### Bad example
```javascript
import { useState, useEffect, useRef } from 'react'; // useRef never used
const TIMEOUT = 5000; // never used

function Component() {
    const [data, setData] = useState(null);
    const unused = "never read";
    return <div>{data}</div>;
}
```

### Good example
```javascript
import { useState, useEffect } from 'react';

function Component() {
    const [data, setData] = useState(null);
    return <div>{data}</div>;
}
```

### Why it matters
Unused code confuses readers and increases bundle size.

---

## RULE: eval() Usage
**ID**: JS008
**Severity**: Critical
**Category**: Security
**Language**: javascript

### What it detects
`eval()`, `new Function()`, or `setTimeout(string, ...)` called with user-supplied strings.

### Bad example
```javascript
eval(userInput);
new Function(userCode)();
setTimeout("processData(" + id + ")", 100);
```

### Good example
```javascript
// Never eval user input. Use proper data structures or functions:
const handlers = { add, remove, update };
handlers[action]?.(data);
setTimeout(() => processData(id), 100);
```

### Why it matters
`eval()` with user input is a direct code injection vulnerability and disables browser optimisations.

---

## RULE: TypeScript any Type
**ID**: TS001
**Severity**: Major
**Category**: Bug
**Language**: javascript

### What it detects
Use of TypeScript `any` type which disables all type checking for that value.

### Bad example
```typescript
function process(data: any): any {
    return data.value;
}
let result: any = fetchData();
```

### Good example
```typescript
interface DataPayload {
    value: string;
    timestamp: number;
}

function process(data: DataPayload): string {
    return data.value;
}
```

### Why it matters
`any` defeats the purpose of TypeScript. Use specific types, `unknown`, or generics instead.
