# React Best Practices Rules

---

## RULE: Missing key Prop in Lists
**ID**: REACT001
**Severity**: Major
**Category**: Bug
**Language**: react

### What it detects
Rendering a list with `.map()` without providing a unique `key` prop on each element.

### Bad example
```jsx
function ItemList({ items }) {
    return (
        <ul>
            {items.map(item => (
                <li>{item.name}</li>  // missing key
            ))}
        </ul>
    );
}
```

### Good example
```jsx
function ItemList({ items }) {
    return (
        <ul>
            {items.map(item => (
                <li key={item.id}>{item.name}</li>
            ))}
        </ul>
    );
}
```

### Why it matters
React uses `key` to identify which items changed. Missing keys cause incorrect re-renders and UI bugs.

---

## RULE: Array Index as key
**ID**: REACT002
**Severity**: Minor
**Category**: Bug
**Language**: react

### What it detects
Using the array index as the `key` prop when items can be reordered, added, or deleted.

### Bad example
```jsx
{items.map((item, index) => (
    <ListItem key={index} data={item} />
))}
```

### Good example
```jsx
{items.map(item => (
    <ListItem key={item.id} data={item} />
))}
```

### Why it matters
Index keys cause incorrect component reuse when the list order changes, leading to state bugs.

---

## RULE: Hooks Rules Violation
**ID**: REACT003
**Severity**: Critical
**Category**: Bug
**Language**: react

### What it detects
Calling React hooks inside conditionals, loops, or nested functions — violating the Rules of Hooks.

### Bad example
```jsx
function Component({ isLoggedIn }) {
    if (isLoggedIn) {
        const [data, setData] = useState(null); // hook in conditional
    }
    for (let i = 0; i < 3; i++) {
        useEffect(() => {}, []); // hook in loop
    }
}
```

### Good example
```jsx
function Component({ isLoggedIn }) {
    const [data, setData] = useState(null); // always at top level
    useEffect(() => {
        if (isLoggedIn) {
            fetchData().then(setData);
        }
    }, [isLoggedIn]);
}
```

### Why it matters
React relies on hook call order being identical on every render. Breaking this causes unpredictable bugs.

---

## RULE: useEffect Missing Dependency
**ID**: REACT004
**Severity**: Major
**Category**: Bug
**Language**: react

### What it detects
`useEffect` callbacks that reference props or state variables not listed in the dependency array.

### Bad example
```jsx
function Component({ userId }) {
    const [data, setData] = useState(null);

    useEffect(() => {
        fetchUser(userId).then(setData); // userId not in deps
    }, []); // stale closure — won't re-fetch when userId changes
}
```

### Good example
```jsx
useEffect(() => {
    fetchUser(userId).then(setData);
}, [userId]); // re-runs whenever userId changes
```

### Why it matters
Missing dependencies cause stale closures — the effect uses an old value and the UI shows stale data.

---

## RULE: Direct State Mutation
**ID**: REACT005
**Severity**: Critical
**Category**: Bug
**Language**: react

### What it detects
Mutating state directly instead of calling the state setter with a new value.

### Bad example
```jsx
const [items, setItems] = useState([]);

function addItem(item) {
    items.push(item);   // direct mutation — React won't re-render
    setItems(items);
}

const [user, setUser] = useState({ name: "Alice" });
user.name = "Bob";      // mutation — stale reference
```

### Good example
```jsx
function addItem(item) {
    setItems(prev => [...prev, item]); // new array
}

setUser(prev => ({ ...prev, name: "Bob" })); // new object
```

### Why it matters
React compares state by reference. Mutating the existing object/array means the reference doesn't change and the component doesn't re-render.

---

## RULE: PropTypes or TypeScript Missing
**ID**: REACT006
**Severity**: Minor
**Category**: Style
**Language**: react

### What it detects
React components in `.jsx` files with no PropTypes definition and no TypeScript props interface.

### Bad example
```jsx
function Button({ label, onClick, disabled }) {
    return <button onClick={onClick} disabled={disabled}>{label}</button>;
}
// No PropTypes — callers don't know what props are expected
```

### Good example
```jsx
import PropTypes from 'prop-types';

function Button({ label, onClick, disabled }) {
    return <button onClick={onClick} disabled={disabled}>{label}</button>;
}

Button.propTypes = {
    label:    PropTypes.string.isRequired,
    onClick:  PropTypes.func.isRequired,
    disabled: PropTypes.bool,
};
```

### Why it matters
Without PropTypes or TypeScript, wrong prop types cause runtime errors that could be caught at development time.

---

## RULE: Inline Event Handler Functions
**ID**: REACT007
**Severity**: Minor
**Category**: Performance
**Language**: react

### What it detects
Event handlers defined as inline arrow functions inside JSX, causing a new function reference on every render.

### Bad example
```jsx
function List({ items, onDelete }) {
    return items.map(item => (
        <button onClick={() => onDelete(item.id)}>Delete</button>
    ));
}
```

### Good example
```jsx
function ListItem({ item, onDelete }) {
    const handleDelete = useCallback(() => onDelete(item.id), [item.id, onDelete]);
    return <button onClick={handleDelete}>Delete</button>;
}
```

### Why it matters
New function references on every render prevent `React.memo` optimisations and can cause unnecessary child re-renders.

---

## RULE: Component Too Large
**ID**: REACT008
**Severity**: Minor
**Category**: Style
**Language**: react

### What it detects
A single React component function that exceeds ~100 lines of JSX/logic — a sign it should be split.

### Bad example
```jsx
function Dashboard() {
    // 200+ lines of mixed data fetching, business logic, and rendering
}
```

### Good example
```jsx
function Dashboard() {
    return (
        <div>
            <Header />
            <MetricsPanel />
            <ActivityFeed />
        </div>
    );
}
// Each sub-component handles its own data and rendering
```

### Why it matters
Large components are hard to test, reuse, and reason about. Single responsibility makes each component easier to maintain.

---

## RULE: Avoid dangerouslySetInnerHTML Without Sanitization
**ID**: REACT009
**Severity**: Critical
**Category**: Security
**Language**: react

### What it detects
Using `dangerouslySetInnerHTML` with unsanitised user-supplied content.

### Bad example
```jsx
function Comment({ userContent }) {
    return <div dangerouslySetInnerHTML={{ __html: userContent }} />;
}
```

### Good example
```jsx
import DOMPurify from 'dompurify';

function Comment({ userContent }) {
    const clean = DOMPurify.sanitize(userContent);
    return <div dangerouslySetInnerHTML={{ __html: clean }} />;
}
```

### Why it matters
`dangerouslySetInnerHTML` with raw user content is a direct XSS vulnerability.
