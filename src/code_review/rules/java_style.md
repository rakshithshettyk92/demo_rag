# Google Java Style Guide Rules

---

## RULE: Class Naming Convention
**ID**: JSTYLE001
**Severity**: Minor
**Category**: Style
**Language**: java

### What it detects
Class names not in UpperCamelCase (PascalCase). Interface names not in UpperCamelCase.

### Bad example
```java
class user_profile { }
class httpClient { }
interface data_processor { }
```

### Good example
```java
class UserProfile { }
class HttpClient { }
interface DataProcessor { }
```

### Why it matters
UpperCamelCase for classes is universal Java convention. Deviations confuse readers.

---

## RULE: Method and Variable Naming
**ID**: JSTYLE002
**Severity**: Minor
**Category**: Style
**Language**: java

### What it detects
Methods or local variables not in lowerCamelCase.

### Bad example
```java
public void Get_User() { }
int User_Count = 0;
String FirstName = "John";
```

### Good example
```java
public void getUser() { }
int userCount = 0;
String firstName = "John";
```

### Why it matters
lowerCamelCase for methods/variables is the Java standard. Consistent naming improves readability.

---

## RULE: Constant Naming Convention
**ID**: JSTYLE003
**Severity**: Minor
**Category**: Style
**Language**: java

### What it detects
`static final` constants not in UPPER_SNAKE_CASE.

### Bad example
```java
private static final int maxRetries = 3;
private static final String defaultUrl = "http://localhost";
```

### Good example
```java
private static final int MAX_RETRIES = 3;
private static final String DEFAULT_URL = "http://localhost";
```

### Why it matters
UPPER_SNAKE_CASE immediately signals to readers that a value is a constant.

---

## RULE: Braces for All Blocks
**ID**: JSTYLE004
**Severity**: Minor
**Category**: Style
**Language**: java

### What it detects
`if`, `else`, `for`, `while` blocks without braces — even single-line bodies.

### Bad example
```java
if (condition)
    doSomething();

for (int i = 0; i < 10; i++)
    process(i);
```

### Good example
```java
if (condition) {
    doSomething();
}

for (int i = 0; i < 10; i++) {
    process(i);
}
```

### Why it matters
Missing braces are a common source of bugs when lines are added to the block later.

---

## RULE: Avoid Wildcard Imports
**ID**: JSTYLE005
**Severity**: Minor
**Category**: Style
**Language**: java

### What it detects
`import com.example.*;` wildcard imports that pull in all classes from a package.

### Bad example
```java
import java.util.*;
import com.company.models.*;
```

### Good example
```java
import java.util.List;
import java.util.Map;
import com.company.models.User;
```

### Why it matters
Wildcard imports hide what is actually used, cause name conflicts, and slow IDE indexing.

---

## RULE: Line Length
**ID**: JSTYLE006
**Severity**: Info
**Category**: Style
**Language**: java

### What it detects
Lines exceeding 100 characters (Google style) or 120 characters (common team limit).

### Bad example
```java
public ResponseEntity<UserProfileResponse> getUserProfileWithAllDetails(Long userId, String locale, Boolean includeHistory) {
```

### Good example
```java
public ResponseEntity<UserProfileResponse> getUserProfileWithAllDetails(
        Long userId,
        String locale,
        Boolean includeHistory) {
```

### Why it matters
Long lines require horizontal scrolling and make code review harder on standard screens.

---

## RULE: Unnecessary Else After Return
**ID**: JSTYLE007
**Severity**: Info
**Category**: Style
**Language**: java

### What it detects
`else` block that follows an `if` block ending with `return`, `throw`, `break`, or `continue`.

### Bad example
```java
if (value == null) {
    return defaultValue;
} else {
    return processValue(value);
}
```

### Good example
```java
if (value == null) {
    return defaultValue;
}
return processValue(value);
```

### Why it matters
Unnecessary else adds indentation without benefit. Early returns flatten the code.

---

## RULE: Override Annotation
**ID**: JSTYLE008
**Severity**: Minor
**Category**: Bug
**Language**: java

### What it detects
Methods intended to override a parent class method that are missing the `@Override` annotation.

### Bad example
```java
public class Dog extends Animal {
    public String toString() { // missing @Override
        return "Dog";
    }
}
```

### Good example
```java
public class Dog extends Animal {
    @Override
    public String toString() {
        return "Dog";
    }
}
```

### Why it matters
`@Override` causes a compile error if the method signature doesn't match, catching typos early.
