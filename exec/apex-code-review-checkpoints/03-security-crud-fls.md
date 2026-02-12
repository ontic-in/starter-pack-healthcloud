# Checkpoint: Security CRUD/FLS Validation

## Priority
CRITICAL

## Objective
Validate that all SOQL queries and DML operations implement proper CRUD (Create, Read, Update, Delete) and FLS (Field-Level Security) checks to prevent unauthorized data access.

## Scope
This checkpoint examines Apex code for database operations and verifies that appropriate permission checks are performed before accessing or modifying data.

## Review Standards
From **RFC_SALESFORCE_PRACTICES.md** - Security Requirements:

**MANDATORY CRUD/FLS Checks:**
- Before SOQL queries → Check `isAccessible()`
- Before DML INSERT → Check `isCreateable()`
- Before DML UPDATE → Check `isUpdateable()`
- Before DML DELETE → Check `isDeletable()`
- Before DML operations → Use `Security.stripInaccessible()`

**Exceptions (No checks required):**
- `WITH USER_MODE` queries (Salesforce enforces automatically)
- `@IsTest` test classes using `System.runAs()`
- Platform events, custom metadata, custom settings

## Input Requirements
```json
{
  "files": ["array of .cls file paths to analyze"],
  "file_contents": ["array of file content strings matching the files array"]
}
```

## Task

Scan each Apex class for SOQL/DML operations and verify CRUD/FLS checks are present.

**Step 1: Detect Database Operations**

**SOQL Patterns:**
```apex
[SELECT ... FROM ...]
[FIND ... IN ...]
Database.query(...)
Database.countQuery(...)
```

**DML Patterns:**
```apex
insert records;
update records;
delete records;
upsert records;
undelete records;
Database.insert(...)
Database.update(...)
Database.delete(...)
Database.upsert(...)
Database.undelete(...)
```

**Step 2: Check for USER_MODE (Automatic Enforcement)**
If query/DML uses `WITH USER_MODE` or `WITH SECURITY_ENFORCED`, skip CRUD/FLS check requirement:
```apex
// NO CHECK NEEDED - Salesforce enforces automatically
List<Lead> leads = [SELECT Id FROM Lead WITH USER_MODE];
```

**Step 3: Look for CRUD Checks**

**Before SOQL - Check Read Permission:**
```apex
// GOOD
if (!Schema.sObjectType.Lead.isAccessible()) {
    throw new AuraHandledException('No read permission');
}
List<Lead> leads = [SELECT Id FROM Lead];
```

**Before DML - Check Create/Update/Delete Permission:**
```apex
// GOOD - Check before INSERT
if (!Schema.sObjectType.Lead.isCreateable()) {
    throw new AuraHandledException('No create permission');
}
insert newLeads;

// GOOD - Check before UPDATE
if (!Schema.sObjectType.Lead.isUpdateable()) {
    throw new AuraHandledException('No update permission');
}
update existingLeads;
```

**Step 4: Look for FLS Checks**

**Security.stripInaccessible() - BEST PRACTICE:**
```apex
// GOOD - Strips inaccessible fields automatically
SObject[] strippedRecords = Security.stripInaccessible(
    AccessType.CREATABLE,
    recordsToInsert
).getRecords();
insert strippedRecords;
```

**Field-Level Checks:**
```apex
// GOOD - Check field accessibility
if (!Schema.sObjectType.Lead.fields.Email.isAccessible()) {
    // Don't include Email in query
}
```

**Step 5: Violation Detection**

**CRITICAL Violations:**
- SOQL query without `isAccessible()` check or `WITH USER_MODE`
- DML INSERT without `isCreateable()` check or `Security.stripInaccessible()`
- DML UPDATE without `isUpdateable()` check or `Security.stripInaccessible()`
- DML DELETE without `isDeletable()` check

**HIGH Violations:**
- SOQL querying specific fields without field-level accessibility checks
- DML operations in loops (potential for partial failures without proper error handling)

**Exemptions:**
- Test classes (`@IsTest`)
- Code inside `System.runAs()` blocks
- Platform events, custom metadata, custom settings
- Queries/DML with `WITH USER_MODE` or `WITH SECURITY_ENFORCED`

**Step 6: Fix Guidance**

**SOQL Without Checks:**
```apex
// BEFORE (VIOLATION)
List<Lead> leads = [SELECT Id, Name, Email FROM Lead WHERE Status = 'Open'];

// AFTER (FIXED)
if (!Schema.sObjectType.Lead.isAccessible()) {
    throw new AuraHandledException('You do not have permission to view Leads');
}
List<Lead> leads = [SELECT Id, Name, Email FROM Lead WHERE Status = 'Open'];

// OR (Alternative - USER_MODE)
List<Lead> leads = [SELECT Id, Name, Email FROM Lead WHERE Status = 'Open' WITH USER_MODE];
```

**DML Without Checks:**
```apex
// BEFORE (VIOLATION)
insert newLeads;

// AFTER (FIXED - Method 1: stripInaccessible)
SObject[] accessibleLeads = Security.stripInaccessible(
    AccessType.CREATABLE,
    newLeads
).getRecords();
insert accessibleLeads;

// AFTER (FIXED - Method 2: CRUD check)
if (!Schema.sObjectType.Lead.isCreateable()) {
    throw new AuraHandledException('You do not have permission to create Leads');
}
insert newLeads;
```

## Output Format
```json
{
  "checkpoint_name": "security-crud-fls",
  "checkpoint_priority": "CRITICAL",
  "status": "pass|fail|warning",
  "files_analyzed": ["array of file paths"],
  "violations": [
    {
      "severity": "critical",
      "category": "Security: CRUD/FLS",
      "file": "[path]",
      "line": "[line number of SOQL/DML]",
      "issue": "SOQL query without CRUD permission check (isAccessible) or USER_MODE",
      "evidence": "[SELECT Id FROM Lead WHERE ...]",
      "fix_guidance": "Add permission check before query:\nif (!Schema.sObjectType.Lead.isAccessible()) {\n    throw new AuraHandledException('No read permission');\n}\nOR use WITH USER_MODE in query",
      "confidence": 0.8
    },
    {
      "severity": "critical",
      "category": "Security: CRUD/FLS",
      "file": "[path]",
      "line": "[line number of DML]",
      "issue": "DML INSERT without createable check or Security.stripInaccessible()",
      "evidence": "insert newRecords;",
      "fix_guidance": "Use Security.stripInaccessible():\nSObject[] stripped = Security.stripInaccessible(\n    AccessType.CREATABLE,\n    newRecords\n).getRecords();\ninsert stripped;",
      "confidence": 0.8
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "critical_count": "[unprotected SOQL/DML count]",
    "high_count": "[field-level security concerns]",
    "soql_operations_found": "[number]",
    "soql_without_checks": "[number]",
    "soql_with_user_mode": "[number]",
    "dml_operations_found": "[number]",
    "dml_without_checks": "[number]",
    "dml_with_strip_inaccessible": "[number]",
    "production_blocker": "[true if critical_count > 0]"
  }
}
```

**Status Logic:**
- `status: "pass"` if all SOQL/DML have proper checks or use USER_MODE
- `status: "fail"` if any unprotected SOQL/DML found
- `status: "warning"` if only field-level security concerns

## Success Criteria
- All SOQL queries have `isAccessible()` checks OR use `WITH USER_MODE`
- All DML operations have CRUD checks OR use `Security.stripInaccessible()`
- Test classes correctly identified and exempted
- Confidence = 0.8 (pattern matching requires context analysis)

## Failure Handling
**CONTINUE** - This checkpoint failing should not stop other checks.
Security violations must be reported for mandatory remediation.

## Cross-References
- **RFC_SALESFORCE_PRACTICES.md** - Security requirements
- **Salesforce Documentation:** [Enforcing CRUD and FLS](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_perms_enforcing.htm)
- **Security.stripInaccessible():** [Reference](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Security.htm#apex_System_Security_stripInaccessible)

## Confidence Scoring
**All CRUD/FLS violations: 0.8 confidence**

Rationale:
- Pattern matching can detect SOQL/DML reliably
- Context analysis needed to confirm check presence (proximity, scope)
- False positives possible if checks are in helper methods
- Manual review recommended for complex scenarios

Lower to 0.7 if:
- Checks are in separate utility classes (harder to trace)
- Dynamic SOQL (`Database.query()` with string building)
- Complex control flow makes proximity analysis uncertain

## Examples

**Example 1: Unprotected SOQL (VIOLATION)**
```apex
// CRITICAL VIOLATION
public class LeadSelector {
    public List<Lead> getOpenLeads() {
        return [SELECT Id, Name, Email FROM Lead WHERE Status = 'Open'];
    }
}
// Issue: No isAccessible() check, no USER_MODE
```

**Example 2: Protected SOQL (COMPLIANT)**
```apex
// COMPLIANT - Option 1: Manual check
public class LeadSelector {
    public List<Lead> getOpenLeads() {
        if (!Schema.sObjectType.Lead.isAccessible()) {
            throw new AuraHandledException('No read permission');
        }
        return [SELECT Id, Name, Email FROM Lead WHERE Status = 'Open'];
    }
}

// COMPLIANT - Option 2: USER_MODE
public class LeadSelector {
    public List<Lead> getOpenLeads() {
        return [SELECT Id, Name, Email FROM Lead WHERE Status = 'Open' WITH USER_MODE];
    }
}
```

**Example 3: Protected DML with stripInaccessible (COMPLIANT)**
```apex
// COMPLIANT
public class LeadService {
    public void createLeads(List<Lead> newLeads) {
        SObject[] accessibleLeads = Security.stripInaccessible(
            AccessType.CREATABLE,
            newLeads
        ).getRecords();
        insert accessibleLeads;
    }
}
```

**Example 4: Test Class (EXEMPT)**
```apex
// EXEMPT - Test classes don't require CRUD/FLS checks
@IsTest
public class LeadServiceTest {
    @IsTest
    static void testCreateLeads() {
        List<Lead> leads = [SELECT Id FROM Lead]; // No check needed in tests
        // assertions
    }
}
```
