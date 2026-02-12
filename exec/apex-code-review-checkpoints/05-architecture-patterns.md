# Checkpoint: Architecture Patterns

## Priority
HIGH

## Objective
Validate that Apex classes follow Salesforce enterprise architecture patterns including dependency injection, service layers, and separation of concerns.

## Scope
This checkpoint examines class structure and design patterns to ensure maintainable, testable, and scalable code architecture.

## Review Standards
From **RFC_SALESFORCE_PRACTICES.md** and **docs/SALESFORCE_APEX_STATIC_TYPES_GUIDE.md**:

**Enterprise Patterns (REQUIRED):**
- Dependency Injection (DI) via constructor injection
- Interface-based design for services
- Separation of concerns (Controller → Service → Repository)
- Bulkification patterns (Collection-based processing)

**Anti-Patterns (AVOID):**
- Tight coupling (direct instantiation of dependencies)
- God classes (single class doing too much)
- Anemic domain models (classes with only getters/setters)
- Direct SOQL/DML in controllers

## Input Requirements
```json
{
  "files": ["array of .cls file paths to analyze"],
  "file_contents": ["array of file content strings matching the files array"]
}
```

## Task

Analyze class architecture and identify pattern violations or anti-patterns.

### Step 1: Dependency Injection Detection

**Look for Constructor Injection:**
```apex
// GOOD - Constructor injection
public class LeadService {
    private ILeadRepository repository;

    public LeadService(ILeadRepository repo) {
        this.repository = repo;
    }
}
```

**Identify Tight Coupling:**
```apex
// BAD - Direct instantiation (tight coupling)
public class LeadService {
    public void processLeads() {
        LeadRepository repo = new LeadRepository(); // Tight coupling!
        repo.getLeads();
    }
}
```

### Step 2: Interface Usage Detection

**Check for Interface Definitions:**
```apex
// GOOD - Interface-based design
public interface ILeadService {
    List<Lead> getActiveLeads();
    void processLeads(List<Lead> leads);
}

public class LeadService implements ILeadService {
    // Implementation
}
```

**Identify Missing Interfaces:**
- Service classes without interfaces
- Repository classes without interfaces
- Handler classes without interfaces

### Step 3: Separation of Concerns

**Detect Layer Violations:**

**Controllers should:**
- Handle UI interaction only
- Delegate to service layer
- NOT contain business logic
- NOT contain SOQL/DML

**Services should:**
- Contain business logic
- Orchestrate operations
- Use repository for data access
- NOT contain SOQL/DML directly (use repositories)

**Repositories should:**
- Handle SOQL/DML only
- Abstract data access
- Implement interfaces

**Violations:**
```apex
// VIOLATION - Controller with business logic and SOQL
@AuraEnabled(cacheable=true)
public static List<Lead> getLeads() {
    // Business logic in controller!
    List<Lead> leads = [SELECT Id FROM Lead WHERE Status = 'Open'];

    // Data transformation in controller!
    for (Lead l : leads) {
        l.Name = l.Name.toUpperCase();
    }

    return leads;
}
```

### Step 4: Bulkification Patterns

**Check for Collection-Based Processing:**
```apex
// GOOD - Bulkified
public void processLeads(List<Lead> leads) {
    // Process collection
}

// BAD - Single record processing
public void processLead(Lead lead) {
    // Forces caller to loop
}
```

**Detect SOQL/DML in Loops:**
```apex
// VIOLATION
for (Lead l : leads) {
    update l; // DML in loop!
}

// GOOD
update leads; // Bulkified DML
```

### Step 5: God Class Detection

**Identify God Classes:**
- Class with > 500 lines of code
- Class with > 10 public methods
- Class with multiple responsibilities (mixed concerns)

## Violation Rules

**HIGH Violations:**
- Service class with tight coupling (direct instantiation)
- Controller with SOQL/DML operations
- Service class without interface
- God class (> 500 lines or > 10 methods)

**MEDIUM Violations:**
- Missing constructor injection
- Business logic in controller
- Single-record processing methods (not bulkified)

**LOW Violations:**
- Repository without interface
- Inconsistent naming patterns

## Output Format
```json
{
  "checkpoint_name": "architecture-patterns",
  "checkpoint_priority": "HIGH",
  "status": "pass|fail|warning",
  "files_analyzed": ["array of file paths"],
  "violations": [
    {
      "severity": "high",
      "category": "Architecture: Dependency Injection",
      "file": "[path]",
      "line": "[line number]",
      "issue": "Service class with tight coupling - direct instantiation of dependencies",
      "evidence": "LeadRepository repo = new LeadRepository();",
      "fix_guidance": "Use constructor injection:\nprivate ILeadRepository repo;\npublic LeadService(ILeadRepository repository) {\n    this.repo = repository;\n}",
      "confidence": 0.7
    },
    {
      "severity": "high",
      "category": "Architecture: Separation of Concerns",
      "file": "[path]",
      "line": "[line number]",
      "issue": "Controller contains SOQL query - violates separation of concerns",
      "evidence": "[SELECT Id FROM Lead ...]",
      "fix_guidance": "Move SOQL to repository layer and access via service",
      "confidence": 0.7
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "high_count": "[tight coupling + layer violations]",
    "medium_count": "[missing DI]",
    "low_count": "[naming inconsistencies]",
    "classes_with_di": "[number]",
    "classes_with_interfaces": "[number]",
    "god_classes": "[number]",
    "production_blocker": false
  }
}
```

**Status Logic:**
- `status: "pass"` if no violations
- `status: "fail"` if high_count > 0
- `status: "warning"` if only medium/low violations

## Success Criteria
- Service classes use dependency injection
- Interfaces defined for services and repositories
- Controllers delegate to services (no business logic)
- No SOQL/DML in loops
- Confidence = 0.7 (pattern detection requires interpretation)

## Failure Handling
**CONTINUE** - Architecture violations should not block other checks.
Report violations for refactoring planning.

## Cross-References
- **docs/SALESFORCE_APEX_STATIC_TYPES_GUIDE.md** - DI patterns
- **RFC_SALESFORCE_PRACTICES.md** - Architecture requirements
- **Salesforce DI Guide:** [Effective Dependency Injection](https://developer.salesforce.com/blogs/2021/08/effective-dependency-injection-in-apex)

## Confidence Scoring
**All architecture violations: 0.7 confidence**

Rationale:
- Pattern detection requires code analysis and interpretation
- Some patterns may be valid exceptions
- Context matters (e.g., simple utilities don't need DI)
- Manual review recommended for borderline cases

## Examples

**Example 1: Good Architecture**
```apex
// Interface
public interface ILeadService {
    List<Lead> getActiveLeads();
}

// Service with DI
public class LeadService implements ILeadService {
    private ILeadRepository repository;

    public LeadService(ILeadRepository repo) {
        this.repository = repo;
    }

    public List<Lead> getActiveLeads() {
        return repository.getLeadsByStatus('Active');
    }
}

// Controller (thin)
public with sharing class LeadController {
    @AuraEnabled(cacheable=true)
    public static List<Lead> getActiveLeads() {
        return new LeadService(new LeadRepository()).getActiveLeads();
    }
}
```

**Example 2: Architecture Violations**
```apex
// VIOLATION - No interface, tight coupling, SOQL in service
public class LeadService {
    public List<Lead> getActiveLeads() {
        // Tight coupling - direct instantiation
        LeadValidator validator = new LeadValidator();

        // Layer violation - SOQL in service (should be in repository)
        return [SELECT Id FROM Lead WHERE Status = 'Active'];
    }
}
```
