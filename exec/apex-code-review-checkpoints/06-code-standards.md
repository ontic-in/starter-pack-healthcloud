# Checkpoint: Code Standards

## Priority
HIGH

## Objective
Validate Apex code adheres to naming conventions, bulkification principles, and Salesforce governor limit awareness.

## Scope
This checkpoint examines code style, naming patterns, and implementation practices to ensure maintainable and scalable code.

## Review Standards
From **RFC_SALESFORCE_PRACTICES.md**:

**Naming Conventions:**
- Classes: PascalCase (e.g., `LeadService`, `AccountController`)
- Methods: camelCase (e.g., `getActiveLeads`, `processRecords`)
- Variables: camelCase (e.g., `leadList`, `accountId`)
- Constants: UPPER_SNAKE_CASE (e.g., `MAX_RECORDS`, `DEFAULT_STATUS`)

**Bulkification:**
- All triggers must be bulkified
- No SOQL/DML in loops
- Collection-based processing
- Use maps for lookups instead of nested loops

**Governor Limits Awareness:**
- SOQL queries: 100 per transaction
- DML statements: 150 per transaction
- Heap size: 6MB (synchronous), 12MB (async)
- CPU time: 10,000ms (synchronous), 60,000ms (async)

## Input Requirements
```json
{
  "files": ["array of .cls file paths to analyze"],
  "file_contents": ["array of file content strings matching the files array"]
}
```

## Task

Scan code for naming violations, bulkification issues, and governor limit risks.

### Step 1: Naming Convention Validation

**Check Class Names:**
```apex
// GOOD
public class LeadService { }
public class AccountController { }

// VIOLATION - lowercase or snake_case
public class leadservice { }
public class account_controller { }
```

**Check Method Names:**
```apex
// GOOD
public void processLeads() { }
public List<Lead> getActiveLeads() { }

// VIOLATION - PascalCase or snake_case
public void ProcessLeads() { }
public void get_active_leads() { }
```

**Check Variable Names:**
```apex
// GOOD
List<Lead> leadList;
Id accountId;
String firstName;

// VIOLATION - PascalCase or snake_case
List<Lead> LeadList;
Id account_id;
```

**Check Constants:**
```apex
// GOOD
private static final Integer MAX_RECORDS = 200;
private static final String DEFAULT_STATUS = 'Active';

// VIOLATION - camelCase or PascalCase
private static final Integer maxRecords = 200;
private static final String DefaultStatus = 'Active';
```

### Step 2: Bulkification Validation

**Detect SOQL in Loops:**
```apex
// VIOLATION
for (Lead l : leads) {
    Account a = [SELECT Id FROM Account WHERE Id = :l.AccountId]; // SOQL in loop!
}

// GOOD
Set<Id> accountIds = new Set<Id>();
for (Lead l : leads) {
    accountIds.add(l.AccountId);
}
Map<Id, Account> accountMap = new Map<Id, Account>(
    [SELECT Id FROM Account WHERE Id IN :accountIds]
);
```

**Detect DML in Loops:**
```apex
// VIOLATION
for (Lead l : leads) {
    update l; // DML in loop!
}

// GOOD
List<Lead> leadsToUpdate = new List<Lead>();
for (Lead l : leads) {
    leadsToUpdate.add(l);
}
update leadsToUpdate;
```

**Detect Nested Loops Without Maps:**
```apex
// VIOLATION - O(n²) complexity
for (Lead l : leads) {
    for (Account a : accounts) {
        if (l.AccountId == a.Id) {
            // Inefficient nested loop
        }
    }
}

// GOOD - O(n) complexity with Map
Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
for (Lead l : leads) {
    Account a = accountMap.get(l.AccountId);
}
```

### Step 3: Governor Limit Awareness

**Check SOQL Query Count:**
- Count SOQL queries in method
- Flag if > 5 queries in single method (risk of hitting 100 limit)

**Check DML Statement Count:**
- Count DML statements in method
- Flag if > 5 DML in single method (risk of hitting 150 limit)

**Check Collection Sizes:**
```apex
// RISK - No limit on collection size
List<Lead> leads = [SELECT Id FROM Lead]; // Could return 10,000+ records!

// GOOD - Limit query
List<Lead> leads = [SELECT Id FROM Lead LIMIT 200];

// BETTER - Use SOQL FOR loop for large datasets
for (List<Lead> leadBatch : [SELECT Id FROM Lead]) {
    // Process in batches of 200
}
```

**Check String Concatenation in Loops:**
```apex
// VIOLATION - Heap size risk
String result = '';
for (Integer i = 0; i < 10000; i++) {
    result += 'value'; // String concatenation in loop - heap risk!
}

// GOOD - Use List and String.join()
List<String> values = new List<String>();
for (Integer i = 0; i < 10000; i++) {
    values.add('value');
}
String result = String.join(values, '');
```

### Step 4: Code Smell Detection

**Magic Numbers:**
```apex
// VIOLATION
if (leads.size() > 200) { } // Magic number

// GOOD
private static final Integer MAX_LEADS = 200;
if (leads.size() > MAX_LEADS) { }
```

**Hard-coded IDs:**
```apex
// VIOLATION
Id accountId = '001000000000000'; // Hard-coded ID

// GOOD
Id accountId = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1].Id;
```

**Empty Catch Blocks:**
```apex
// VIOLATION
try {
    // code
} catch (Exception e) {
    // Empty catch - swallows errors!
}

// GOOD
try {
    // code
} catch (Exception e) {
    System.debug('Error: ' + e.getMessage());
    throw e;
}
```

## Violation Rules

**HIGH Violations:**
- SOQL in loop
- DML in loop
- Hard-coded Salesforce IDs
- > 5 SOQL queries in single method

**MEDIUM Violations:**
- Naming convention violations
- Magic numbers (no constants)
- Nested loops without maps (O(n²))
- Empty catch blocks

**LOW Violations:**
- Inconsistent naming style
- Missing LIMIT clause in queries

## Output Format
```json
{
  "checkpoint_name": "code-standards",
  "checkpoint_priority": "HIGH",
  "status": "pass|fail|warning",
  "files_analyzed": ["array of file paths"],
  "violations": [
    {
      "severity": "high",
      "category": "Code Standards: Bulkification",
      "file": "[path]",
      "line": "[line number]",
      "issue": "SOQL query in loop - will hit governor limits with large datasets",
      "evidence": "for (Lead l : leads) { Account a = [SELECT ...]; }",
      "fix_guidance": "Collect IDs first, query once outside loop:\nSet<Id> ids = new Set<Id>();\nfor (Lead l : leads) { ids.add(l.AccountId); }\nMap<Id, Account> accountMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :ids]);",
      "confidence": 0.7
    },
    {
      "severity": "medium",
      "category": "Code Standards: Naming",
      "file": "[path]",
      "line": "[line number]",
      "issue": "Method name violates camelCase convention",
      "evidence": "public void ProcessLeads() { }",
      "fix_guidance": "Use camelCase: public void processLeads() { }",
      "confidence": 0.7
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "high_count": "[SOQL/DML in loops + hard-coded IDs]",
    "medium_count": "[naming + magic numbers]",
    "low_count": "[style inconsistencies]",
    "soql_in_loops": "[count]",
    "dml_in_loops": "[count]",
    "naming_violations": "[count]",
    "magic_numbers": "[count]",
    "production_blocker": false
  }
}
```

**Status Logic:**
- `status: "pass"` if no violations
- `status: "fail"` if high_count > 0 (SOQL/DML in loops)
- `status: "warning"` if only medium/low violations

## Success Criteria
- No SOQL/DML in loops
- Naming conventions followed
- No hard-coded IDs
- Governor limit awareness demonstrated
- Confidence = 0.7 (pattern detection + context)

## Failure Handling
**CONTINUE** - Code standard violations should not block deployment but should be fixed.

## Cross-References
- **RFC_SALESFORCE_PRACTICES.md** - Coding standards
- **Salesforce Limits:** [Governor Limits](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm)
- **Best Practices:** [Bulkification](https://developer.salesforce.com/wiki/apex_code_best_practices)

## Confidence Scoring
**All code standard violations: 0.7 confidence**

Rationale:
- Pattern detection is reliable for SOQL/DML in loops
- Naming violations are clear
- Context needed for some violations (e.g., valid exceptions)
- Some patterns may be acceptable in specific scenarios

## Examples

**Example 1: SOQL/DML in Loop (HIGH)**
```apex
// VIOLATION
public void processLeads(List<Lead> leads) {
    for (Lead l : leads) {
        Account a = [SELECT Id FROM Account WHERE Id = :l.AccountId]; // SOQL in loop
        l.Account = a;
        update l; // DML in loop
    }
}

// FIXED
public void processLeads(List<Lead> leads) {
    Set<Id> accountIds = new Set<Id>();
    for (Lead l : leads) {
        accountIds.add(l.AccountId);
    }

    Map<Id, Account> accountMap = new Map<Id, Account>(
        [SELECT Id FROM Account WHERE Id IN :accountIds]
    );

    List<Lead> leadsToUpdate = new List<Lead>();
    for (Lead l : leads) {
        l.Account = accountMap.get(l.AccountId);
        leadsToUpdate.add(l);
    }
    update leadsToUpdate;
}
```

**Example 2: Naming Violations (MEDIUM)**
```apex
// VIOLATIONS
public class lead_service { // Class: PascalCase required
    private static final String defaultStatus = 'Active'; // Constant: UPPER_SNAKE_CASE required

    public void ProcessLeads() { } // Method: camelCase required

    public void getLeads() {
        List<Lead> LeadList; // Variable: camelCase required
    }
}

// FIXED
public class LeadService {
    private static final String DEFAULT_STATUS = 'Active';

    public void processLeads() { }

    public void getLeads() {
        List<Lead> leadList;
    }
}
```
