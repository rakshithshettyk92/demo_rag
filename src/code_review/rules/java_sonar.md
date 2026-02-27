
# Sonar Java Rules

---

## RULE: Null Pointer Dereference
**ID**: JAVA001
**Severity**: Critical
**Category**: Bug
**Language**: java

### What it detects
A variable that could be null is used without a null check, causing NullPointerException at runtime.

### Bad example
```java
String value = map.get("key");
int length = value.length(); // NPE if key not present
```

### Good example
```java
String value = map.get("key");
if (value != null) {
    int length = value.length();
}
// Or with Optional:
Optional.ofNullable(map.get("key")).map(String::length).orElse(0);
```

### Why it matters
NullPointerException is the most common Java runtime exception. Always check or use Optional.

---

## RULE: Resource Not Closed
**ID**: JAVA002
**Severity**: Major
**Category**: Bug
**Language**: java

### What it detects
Streams, connections, readers, or writers opened but not closed in a finally block or try-with-resources.

### Bad example
```java
FileInputStream fis = new FileInputStream("file.txt");
int data = fis.read();
// fis never closed — resource leak
```

### Good example
```java
try (FileInputStream fis = new FileInputStream("file.txt")) {
    int data = fis.read();
} // auto-closed
```

### Why it matters
Unclosed resources cause memory leaks and can exhaust file descriptors or DB connections.

---

## RULE: Empty Catch Block
**ID**: JAVA003
**Severity**: Major
**Category**: Bug
**Language**: java

### What it detects
A catch block that is completely empty, silently swallowing exceptions.

### Bad example
```java
try {
    riskyOperation();
} catch (Exception e) {
    // nothing
}
```

### Good example
```java
try {
    riskyOperation();
} catch (IOException e) {
    logger.error("IO error during operation", e);
    throw new ServiceException("Failed to process", e);
}
```

### Why it matters
Empty catch blocks hide failures, making bugs nearly impossible to diagnose in production.

---

## RULE: Raw Type Usage
**ID**: JAVA004
**Severity**: Major
**Category**: Bug
**Language**: java

### What it detects
Using raw generic types like `List`, `Map`, `Set` instead of parameterised types.

### Bad example
```java
List items = new ArrayList();
items.add("hello");
String s = (String) items.get(0); // unsafe cast
```

### Good example
```java
List<String> items = new ArrayList<>();
items.add("hello");
String s = items.get(0); // type-safe, no cast
```

### Why it matters
Raw types bypass generics type checking, causing ClassCastException at runtime.

---

## RULE: Hardcoded Credentials
**ID**: JAVA005
**Severity**: Critical
**Category**: Security
**Language**: java

### What it detects
Passwords, API keys, or tokens assigned as string literals in source code.

### Bad example
```java
String password = "admin123";
String apiKey = "sk-abc123secret";
DriverManager.getConnection(url, "root", "password");
```

### Good example
```java
String password = System.getenv("DB_PASSWORD");
String apiKey = System.getenv("API_KEY");
DriverManager.getConnection(url, System.getenv("DB_USER"), System.getenv("DB_PASS"));
```

### Why it matters
Credentials in source code are visible to every developer and end up in git history permanently.

---

## RULE: SQL Injection
**ID**: JAVA006
**Severity**: Critical
**Category**: Security
**Language**: java

### What it detects
SQL queries built by concatenating or formatting user input into query strings.

### Bad example
```java
String query = "SELECT * FROM users WHERE name = '" + userName + "'";
Statement stmt = conn.createStatement();
stmt.executeQuery(query);
```

### Good example
```java
String query = "SELECT * FROM users WHERE name = ?";
PreparedStatement stmt = conn.prepareStatement(query);
stmt.setString(1, userName);
stmt.executeQuery();
```

### Why it matters
SQL injection is OWASP #1. PreparedStatement prevents it completely.

---

## RULE: String Comparison Using ==
**ID**: JAVA007
**Severity**: Major
**Category**: Bug
**Language**: java

### What it detects
Comparing String objects using `==` or `!=` instead of `.equals()`.

### Bad example
```java
String a = new String("hello");
String b = new String("hello");
if (a == b) {  // compares references, not values — always false for new strings
    System.out.println("equal");
}
```

### Good example
```java
if (a.equals(b)) {
    System.out.println("equal");
}
// Null-safe:
if (Objects.equals(a, b)) { ... }
```

### Why it matters
`==` checks reference equality, not value equality. Two strings with the same content are different objects.

---

## RULE: Magic Numbers
**ID**: JAVA008
**Severity**: Minor
**Category**: Style
**Language**: java

### What it detects
Numeric literals used inline without being assigned to a named constant.

### Bad example
```java
if (statusCode == 404) {
    retry(3);
}
Thread.sleep(5000);
```

### Good example
```java
private static final int NOT_FOUND = 404;
private static final int MAX_RETRIES = 3;
private static final long RETRY_DELAY_MS = 5000L;

if (statusCode == NOT_FOUND) {
    retry(MAX_RETRIES);
}
Thread.sleep(RETRY_DELAY_MS);
```

### Why it matters
Named constants document intent and make future changes a one-line edit.

---

## RULE: Catching Throwable or Error
**ID**: JAVA009
**Severity**: Major
**Category**: Bug
**Language**: java

### What it detects
`catch (Throwable t)` or `catch (Error e)` which catches JVM errors like OutOfMemoryError.

### Bad example
```java
try {
    processData();
} catch (Throwable t) {
    logger.error("Error", t);
}
```

### Good example
```java
try {
    processData();
} catch (IOException e) {
    logger.error("IO error", e);
} catch (RuntimeException e) {
    logger.error("Runtime error", e);
    throw e;
}
```

### Why it matters
Catching Throwable/Error masks JVM errors that should terminate the process.

---

## RULE: Unsynchronised Static Field Access
**ID**: JAVA010
**Severity**: Major
**Category**: Bug
**Language**: java

### What it detects
Static mutable fields read or written from instance methods without synchronisation in multi-threaded code.

### Bad example
```java
private static int counter = 0;

public void increment() {
    counter++; // not thread-safe
}
```

### Good example
```java
private static final AtomicInteger counter = new AtomicInteger(0);

public void increment() {
    counter.incrementAndGet();
}
```

### Why it matters
Unsynchronised access to shared mutable state causes race conditions and data corruption.
