# Checkpoint: Quality Process

## Priority
LOW

## Objective
Validate code quality process aspects including dead code detection, documentation standards, and technical debt tracking.

## Scope
This checkpoint examines code for quality indicators that don't directly impact functionality but affect maintainability and developer experience.

## Review Standards
From **RFC_SALESFORCE_PRACTICES.md**:

**Documentation Requirements:**
- All public classes should have class-level comments
- All public methods should have method-level comments
- Complex logic should include inline comments

**Code Cleanliness:**
- No commented-out code blocks
- No unused variables or methods
- TODO comments tracked and linked to tickets
- No debug statements in production code

## Input Requirements
```json
{
  "files": ["array of .cls file paths to analyze"],
  "file_contents": ["array of file content strings matching the files array"]
}
```

## Task

Analyze code for quality process violations.

### Step 1: Dead Code Detection

**Unused Variables:**
```apex
// VIOLATION
public void processLeads() {
    Integer unusedCounter = 0; // Never used
    List<Lead> leads = [SELECT Id FROM Lead];
}
```

**Unused Methods:**
```apex
// VIOLATION - Private method never called
private void helperMethod() {
    // Method body
}
```

**Unused Classes:**
- Classes with no references in codebase
- Classes not instantiated anywhere
- Note: May be external API classes (lower confidence)

### Step 2: Documentation Detection

**Missing Class Comments:**
```apex
// VIOLATION - No class comment
public class LeadService {
    public void processLeads() { }
}

// GOOD
/**
 * Service class for Lead processing operations.
 * Handles lead qualification, assignment, and conversion.
 */
public class LeadService {
    public void processLeads() { }
}
```

**Missing Method Comments:**
```apex
// VIOLATION - Public method without comment
public List<Lead> getActiveLeads() {
    return [SELECT Id FROM Lead WHERE Status = 'Active'];
}

// GOOD
/**
 * Retrieves all leads with Active status.
 * @return List of active leads
 */
public List<Lead> getActiveLeads() {
    return [SELECT Id FROM Lead WHERE Status = 'Active'];
}
```

### Step 3: Commented-Out Code

**Detect Code Blocks:**
```apex
// VIOLATION - Commented-out code
public void processLeads() {
    // Old implementation
    // for (Lead l : leads) {
    //     update l;
    // }

    // New implementation
    update leads;
}
```

**Why This is Bad:**
- Creates confusion about intent
- Code should be removed and tracked in version control
- If needed later, retrieve from git history

### Step 4: TODO Comment Detection

**Untracked Technical Debt:**
```apex
// MEDIUM VIOLATION - TODO without ticket reference
public void processLeads() {
    // TODO: Add error handling
    update leads;
}

// GOOD - TODO with ticket reference
public void processLeads() {
    // TODO [TICKET-123]: Add retry logic for failed DML
    update leads;
}
```

### Step 5: Debug Statement Detection

**Production Debug Statements:**
```apex
// LOW VIOLATION - Debug statements in production code
public void processLeads() {
    System.debug('Processing leads: ' + leads.size());
    System.debug('Lead details: ' + leads);
    update leads;
}
```

**Why Flag This:**
- Debug logs consume storage
- Can expose sensitive data
- Performance impact in high-volume operations

**Exceptions:**
- Error logging is acceptable
- Trace-level logging for monitoring is acceptable

### Step 6: Code Complexity

**Long Methods:**
```apex
// MEDIUM VIOLATION - Method > 100 lines
public void processLeads() {
    // 150 lines of code
    // Should be broken into smaller methods
}
```

**Deeply Nested Logic:**
```apex
// MEDIUM VIOLATION - Nested depth > 4
if (condition1) {
    if (condition2) {
        if (condition3) {
            if (condition4) {
                if (condition5) {
                    // Too deeply nested!
                }
            }
        }
    }
}
```

## Violation Rules

**MEDIUM Violations:**
- Public class without class-level comment
- Public method without method comment
- Commented-out code blocks (> 5 lines)
- TODO comments without ticket references
- Methods > 100 lines
- Nesting depth > 4 levels

**LOW Violations:**
- Unused private variables
- Unused private methods (may be future use)
- System.debug() statements in production
- TODO comments with ticket references (tracked debt)
- Missing inline comments for complex logic

**NO VIOLATIONS:**
- Test classes (different documentation standards)
- Generated code
- Temporary feature flags (if documented)

## Output Format
```json
{
  "checkpoint_name": "quality-process",
  "checkpoint_priority": "LOW",
  "status": "pass|warning",
  "files_analyzed": ["array of file paths"],
  "violations": [
    {
      "severity": "medium",
      "category": "Quality: Documentation",
      "file": "[path]",
      "line": "[line number]",
      "issue": "Public class missing class-level documentation comment",
      "evidence": "public class LeadService {",
      "fix_guidance": "Add class comment:\n/**\n * Brief description of class purpose.\n * Key responsibilities and usage.\n */\npublic class LeadService {",
      "confidence": 0.5
    },
    {
      "severity": "medium",
      "category": "Quality: Code Cleanliness",
      "file": "[path]",
      "line": "[line number]",
      "issue": "Commented-out code block detected - should be removed and tracked in version control",
      "evidence": "// for (Lead l : leads) {\n//     update l;\n// }",
      "fix_guidance": "Remove commented code. If needed later, retrieve from git history.",
      "confidence": 0.5
    },
    {
      "severity": "low",
      "category": "Quality: Technical Debt",
      "file": "[path]",
      "line": "[line number]",
      "issue": "TODO comment without ticket reference",
      "evidence": "// TODO: Add error handling",
      "fix_guidance": "Add ticket reference: // TODO [TICKET-XXX]: Add error handling",
      "confidence": 0.5
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "medium_count": "[undocumented classes/methods + commented code]",
    "low_count": "[unused variables + debug statements]",
    "classes_without_comments": "[number]",
    "methods_without_comments": "[number]",
    "commented_code_blocks": "[number]",
    "todo_comments": "[number]",
    "todo_with_tickets": "[number]",
    "todo_without_tickets": "[number]",
    "debug_statements": "[number]",
    "long_methods": "[number]",
    "deeply_nested_blocks": "[number]",
    "production_blocker": false
  }
}
```

**Status Logic:**
- `status: "pass"` if no violations
- `status: "warning"` if any violations (quality issues are never "fail")
- **NOTE**: This checkpoint NEVER fails - quality process violations don't block deployment

## Success Criteria
- All quality indicators detected
- Violations categorized appropriately
- No false positives for test classes or generated code
- Confidence = 0.5 (quality assessment is subjective)

## Failure Handling
**CONTINUE** - Quality process violations should NEVER block other checks or deployment.

These are improvement suggestions, not blockers.

## Cross-References
- **RFC_SALESFORCE_PRACTICES.md** - Documentation standards
- **Clean Code:** Robert C. Martin's principles
- **Code Review Best Practices:** [Google Code Review Guidelines](https://google.github.io/eng-practices/review/)

## Confidence Scoring
**All quality violations: 0.5 confidence**

Rationale:
- Documentation requirements are subjective
- Dead code detection can have false positives (future use, external APIs)
- Commented code may be intentional (rare cases)
- TODO tracking depends on team process
- Manual review recommended for all quality violations

## Examples

**Example 1: Missing Documentation (MEDIUM)**
```apex
// VIOLATION
public class LeadService {
    public List<Lead> getActiveLeads() {
        return [SELECT Id FROM Lead WHERE Status = 'Active'];
    }
}

// FIXED
/**
 * Service class for Lead operations.
 * Handles lead retrieval, processing, and conversion logic.
 */
public class LeadService {
    /**
     * Retrieves all leads with Active status.
     * @return List of active leads with user-mode security enforced
     */
    public List<Lead> getActiveLeads() {
        return [SELECT Id FROM Lead WHERE Status = 'Active' WITH USER_MODE];
    }
}
```

**Example 2: Commented-Out Code (MEDIUM)**
```apex
// VIOLATION
public void processLeads(List<Lead> leads) {
    // Old implementation - keeping for reference
    // for (Lead l : leads) {
    //     l.Status = 'Processed';
    //     update l;
    // }

    // New bulkified implementation
    for (Lead l : leads) {
        l.Status = 'Processed';
    }
    update leads;
}

// FIXED - Remove commented code
public void processLeads(List<Lead> leads) {
    for (Lead l : leads) {
        l.Status = 'Processed';
    }
    update leads;
}
```

**Example 3: TODO Without Ticket (LOW)**
```apex
// VIOLATION
public void processLeads(List<Lead> leads) {
    // TODO: Add retry logic for failed updates
    update leads;
}

// FIXED
public void processLeads(List<Lead> leads) {
    // TODO [TICKET-456]: Add retry logic with exponential backoff for failed DML
    update leads;
}
```

**Example 4: Debug Statements (LOW)**
```apex
// VIOLATION
public void processLeads(List<Lead> leads) {
    System.debug('Processing ' + leads.size() + ' leads');
    System.debug('Lead data: ' + leads);
    update leads;
    System.debug('Leads processed successfully');
}

// FIXED - Remove debug statements or use proper logging
public void processLeads(List<Lead> leads) {
    // Use error logging only when needed
    try {
        update leads;
    } catch (DmlException e) {
        Logger.error('Failed to process leads', e);
        throw e;
    }
}
```

**Example 5: Unused Variables (LOW)**
```apex
// VIOLATION
public void processLeads(List<Lead> leads) {
    Integer totalCount = leads.size(); // Never used
    String processingStatus = 'Started'; // Never used

    update leads;
}

// FIXED
public void processLeads(List<Lead> leads) {
    update leads;
}
```

**Example 6: Long Method (MEDIUM)**
```apex
// VIOLATION - 150-line method
public void processLeads(List<Lead> leads) {
    // 150 lines of complex logic
    // Should be broken into smaller methods
}

// FIXED - Extract smaller methods
public void processLeads(List<Lead> leads) {
    validateLeads(leads);
    enrichLeadData(leads);
    applyBusinessRules(leads);
    persistLeads(leads);
}

private void validateLeads(List<Lead> leads) {
    // Validation logic
}

private void enrichLeadData(List<Lead> leads) {
    // Enrichment logic
}

private void applyBusinessRules(List<Lead> leads) {
    // Business rules
}

private void persistLeads(List<Lead> leads) {
    // DML logic
}
```
