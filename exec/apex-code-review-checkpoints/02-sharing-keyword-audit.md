# Checkpoint: Sharing Keyword Audit

## Priority
CRITICAL

## Objective
Validate that all Apex classes explicitly declare their sharing mode to prevent security vulnerabilities and ensure predictable record access behavior.

## Scope
This checkpoint examines class declarations for the presence and correctness of sharing keywords (`with sharing`, `without sharing`, `inherited sharing`).

## Review Standards
From **RFC_SALESFORCE_PRACTICES.md** - Sharing Keyword Requirements:

**MANDATORY for:**
- All controllers (classes used by LWC, Visualforce, Aura)
- All service classes
- All classes that perform SOQL queries or DML operations
- All classes that access or modify record data

**Sharing Keyword Options:**
1. **`with sharing`** - Enforce user's record-level permissions (DEFAULT for controllers)
2. **`without sharing`** - Ignore sharing rules (use with extreme caution)
3. **`inherited sharing`** - Inherit from calling context (use for shared utilities)

**Security Rule:**
Controllers MUST use `with sharing` to prevent IDOR vulnerabilities and unauthorized data access.

## Input Requirements
```json
{
  "files": ["array of .cls file paths to analyze"],
  "file_contents": ["array of file content strings matching the files array"]
}
```

## Task

Scan each Apex class file for sharing keyword declarations and flag violations.

**Step 1: Extract Class Declarations**
For each file, locate the class declaration line:
```apex
public class ClassName {
public with sharing class ClassName {
public without sharing class ClassName {
public inherited sharing class ClassName {
@IsTest
public class TestClassName {
```

**Step 2: Sharing Keyword Detection**
Check for these patterns:
- `with sharing` - ✅ GOOD (for controllers/services)
- `without sharing` - ⚠️  FLAG (requires justification)
- `inherited sharing` - ⚠️  REVIEW (ensure appropriate usage)
- **MISSING** (no keyword) - 🔴 VIOLATION

**Step 3: Class Type Detection**
Identify class purpose from:
- **Name patterns:** `*Controller`, `*Service`, `*Handler`, `*Manager`, `*Selector`
- **Annotations:** `@IsTest` (test classes exempt from sharing requirement)
- **Methods:** Contains `@AuraEnabled`, `@RemoteAction`, `@HttpGet/Post` = controller

**Step 4: Violation Rules**

**CRITICAL Violations:**
- Controller class missing sharing keyword → CRITICAL
- Controller class with `without sharing` → CRITICAL (unless justified)
- Service class missing sharing keyword → CRITICAL

**HIGH Violations:**
- Non-test class with SOQL/DML but missing sharing keyword → HIGH
- Class using `without sharing` without code comment justification → HIGH

**MEDIUM Violations:**
- `inherited sharing` without clear parent context → MEDIUM

**Step 5: Fix Guidance**
Provide specific fix for each violation type:

**Missing Sharing (Controllers):**
```apex
// BEFORE
public class LeadController {

// AFTER
public with sharing class LeadController {
```

**Without Sharing (Unjustified):**
```apex
// BEFORE
public without sharing class DataService {

// AFTER (if user permissions should apply)
public with sharing class DataService {

// OR (if justified by business logic)
/**
 * Uses 'without sharing' to allow integration user to bypass
 * sharing rules for cross-organization data synchronization.
 * Approved by: Security Team, Date: 2025-10-30
 */
public without sharing class DataService {
```

## Output Format
```json
{
  "checkpoint_name": "sharing-keyword-audit",
  "checkpoint_priority": "CRITICAL",
  "status": "pass|fail|warning",
  "files_analyzed": ["array of file paths"],
  "violations": [
    {
      "severity": "critical|high|medium",
      "category": "Security: Sharing Keywords",
      "file": "[path]",
      "line": "[class declaration line number]",
      "issue": "Class omits sharing keyword declaration (defaults to 'without sharing' in some contexts)",
      "evidence": "public class ClassName { // No sharing keyword",
      "fix_guidance": "Add explicit sharing declaration: public with sharing class ClassName {",
      "confidence": 0.9
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "critical_count": "[missing sharing in controllers]",
    "high_count": "[missing sharing in service classes]",
    "medium_count": "[inherited sharing without context]",
    "classes_analyzed": "[number]",
    "classes_with_sharing": "[number]",
    "classes_without_sharing": "[number]",
    "classes_inherited_sharing": "[number]",
    "classes_missing_sharing": "[number]",
    "test_classes_exempt": "[number]",
    "production_blocker": "[true if critical_count > 0]"
  }
}
```

**Status Logic:**
- `status: "pass"` if all non-test classes have explicit sharing keywords
- `status: "fail"` if any controller/service missing sharing keyword
- `status: "warning"` if non-critical classes missing sharing

## Success Criteria
- All controller classes have explicit sharing declaration
- All service classes have explicit sharing declaration
- No `without sharing` usage without justification comments
- Confidence = 0.9 for keyword detection (regex-based)

## Failure Handling
**CONTINUE** - This checkpoint failing should not stop other checks.
However, violations must be reported clearly for security review.

## Cross-References
- **RFC_SALESFORCE_PRACTICES.md** - Sharing keyword requirements
- **Salesforce Documentation:** [Using the with sharing, without sharing, and inherited sharing Keywords](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_keywords_sharing.htm)

## Confidence Scoring
**All sharing keyword violations: 0.9 confidence**

Rationale:
- Keyword detection via regex is highly accurate
- Class declaration is unambiguous
- Controller/service pattern matching is reliable
- Edge cases: inner classes, dynamic class loading (rare)

## Examples

**Example 1: Missing Sharing in Controller**
```apex
// VIOLATION
public class LeadController {
    @AuraEnabled(cacheable=true)
    public static List<Lead> getLeads() {
        return [SELECT Id, Name FROM Lead];
    }
}

// Issue: Controller missing sharing keyword
// Severity: CRITICAL
// Fix: Add 'with sharing'
```

**Example 2: Justified Without Sharing**
```apex
// COMPLIANT
/**
 * Platform event publisher requires 'without sharing' to ensure
 * events are published regardless of user permissions.
 * Approved by: Security Review #SR-2025-042
 */
public without sharing class EventPublisher {
    public static void publishEvent(CustomEvent__e evt) {
        EventBus.publish(evt);
    }
}

// No violation - 'without sharing' is justified with comment
```

**Example 3: Test Class (Exempt)**
```apex
// EXEMPT - Test classes don't require sharing keywords
@IsTest
public class LeadControllerTest {
    @IsTest
    static void testGetLeads() {
        // test code
    }
}
```
