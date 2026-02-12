# Checkpoint: Static Method Analysis

## Priority
CRITICAL

## Objective
**Detect classes with excessive static methods and dependencies that prevent testability and violate Salesforce enterprise architecture patterns.**

## Context
**⚠️ THIS CHECKPOINT FAILED IN TICKET 86d0ffn9j ⚠️**

The monolithic review missed a class (LeadQualificationResponseParser) with 100% static methods containing SOQL/DML operations. This created an untestable "God Class with Static Cling" that:
- Cannot be unit tested without hitting the database
- Every test becomes a slow, fragile integration test
- Cannot use Apex Stub API for mocking
- Violates Salesforce Enterprise Patterns

**This is the most critical architectural checkpoint and must be explicit and reliable.**

## Scope
All Apex classes - specifically analyze:
- Service classes (name contains "Service")
- Handler classes (name contains "Handler", "Processor")
- Manager classes (name contains "Manager")
- Controller classes (name contains "Controller")
- Any class with 3+ methods

## Review Standards
From **`docs/SALESFORCE_APEX_STATIC_TYPES_GUIDE.md`**:

**Instance-Based Architecture (REQUIRED):**
- Service/handler classes MUST use instance-based architecture
- Dependencies must be mockable via interfaces
- Enables Apex Stub API for true unit testing

**Static Methods (ALLOWED ONLY FOR):**
- Pure utility methods (no dependencies, stateless)
- Constants and factory methods
- Recursion guards
- Entry points (@AuraEnabled, @InvocableMethod)

**Production Blocker Criteria:**
- Static ratio ≥ 80% with dependencies = Untestable Class

## Input Requirements
```json
{
  "files": ["array of .cls file paths to analyze"],
  "file_contents": ["array of file content strings matching the files array"],
  "pmd_context": "optional PMD violations for cross-reference"
}
```

## Task

### MANDATORY FOR EVERY CLASS WITH 3+ METHODS:

#### Step 1: Method Counting

Count methods in the class:
```apex
// Example class structure
public class ExampleService {
    // STATIC METHODS (count these)
    public static List<Lead> getLeads() { }
    private static void helper() { }

    // INSTANCE METHODS (count these)
    public ExampleService() { }
    public void processData() { }
    private void internalMethod() { }

    // EXCLUDE FROM RATIO CALCULATION
    @InvocableMethod
    public static void invocableEntry() { }
}
```

**Count:**
- `total_methods` = all methods (public + private + protected) EXCLUDING constructors and @InvocableMethod
- `static_methods` = methods with `static` keyword EXCLUDING @InvocableMethod
- `instance_methods` = total_methods - static_methods
- `invocable_methods` = methods with @InvocableMethod annotation (excluded from ratio)

#### Step 2: Calculate Static Ratio

```
static_ratio = (static_methods / total_methods) × 100
```

**Example:**
- Total methods: 5 (excluding 1 @InvocableMethod and 1 constructor)
- Static methods: 4 (excluding the @InvocableMethod)
- Static ratio: (4/5) × 100 = 80%

#### Step 3: Dependency Detection in Static Methods

Scan ONLY the static methods for these dependency patterns:

**SOQL Queries:**
```apex
[SELECT ... FROM ...]
[FIND ... IN ...]
```

**DML Operations:**
```apex
insert records;
update records;
delete records;
upsert records;
Database.insert(...)
Database.update(...)
Database.delete(...)
```

**Database Methods:**
```apex
Database.query(...)
Database.countQuery(...)
Database.getQueryLocator(...)
```

**HTTP Callouts:**
```apex
HttpRequest req = new HttpRequest();
HttpResponse res = new Http().send(req);
```

**Static Calls to Other Classes:**
```apex
OtherClass.staticMethod(...)
ServiceClass.getData(...)
```

**Logging Calls:**
```apex
System.debug(...)
ErrorLogger.log(...)
Logger.error(...)
```

**Count each dependency type and set:**
- `has_dependencies = true` if ANY dependency found in static methods
- `has_dependencies = false` if NO dependencies (pure utility)

#### Step 4: Automatic Violation Triggers

**Apply these rules AUTOMATICALLY based on calculated metrics:**

**🔴 CRITICAL Violation:**
```
IF static_ratio >= 80% AND has_dependencies == true
THEN:
  severity: "critical"
  violation: "God Class with Static Cling - Untestable Class"
  production_blocker: true
  refactoring_priority: "immediate"
```

**🟡 HIGH Violation (Service Pattern):**
```
IF static_ratio >= 60% AND class_name contains ("Service" OR "Handler" OR "Manager")
THEN:
  severity: "high"
  violation: "Service class violating instance-based requirement"
  production_blocker: false
  refactoring_priority: "high"
```

**🟡 HIGH Violation (Excessive Static):**
```
IF static_ratio >= 50% AND total_methods >= 5
THEN:
  severity: "high"
  violation: "Excessive static methods prevent testability"
  production_blocker: false
  refactoring_priority: "high"
```

**🟠 MEDIUM Violation:**
```
IF static_ratio >= 40%
THEN:
  severity: "medium"
  violation: "Approaching static overuse threshold"
  production_blocker: false
  refactoring_priority: "medium"
```

**✅ NO VIOLATION:**
```
IF static_ratio < 40% OR (static_ratio >= 40% AND has_dependencies == false)
THEN:
  No violation - class is either instance-based or pure utility
```

#### Step 5: Testability Assessment

Determine testability status based on static ratio and dependencies:

**Untestable:**
```
IF has_dependencies == true AND static_ratio >= 60%
THEN testability = "untestable"
REASON: "Static methods with dependencies cannot be mocked - all tests hit database/callouts"
```

**Partially Mockable:**
```
IF has_dependencies == true AND static_ratio < 60% AND static_ratio >= 30%
THEN testability = "partially-mockable"
REASON: "Some methods can be tested with stubs, but static methods require database"
```

**Fully Mockable:**
```
IF has_dependencies == false OR static_ratio < 30%
THEN testability = "fully-mockable"
REASON: "Instance-based architecture enables Apex Stub API for complete mocking"
```

**Check for interfaces:**
- Scan class for `implements` keyword
- If interfaces found AND instance-based → testability improves
- If no interfaces AND high static ratio → testability decreases

#### Step 6: Fix Guidance

Provide specific refactoring guidance for violations:

**For CRITICAL Violations (80%+ static with dependencies):**

```apex
// BEFORE (VIOLATION - 86d0ffn9j example)
public class LeadQualificationResponseParser {
    public static void parseResponse(String jsonResponse) {
        // SOQL query in static method
        List<Lead> existingLeads = [SELECT Id FROM Lead WHERE Email = :email];

        // DML in static method
        insert newLeads;
    }
}

// AFTER (FIXED - Instance-Based with DI)

// Step 1: Create service interface
public interface ILeadService {
    List<Lead> getLeadsByEmail(String email);
    void createLeads(List<Lead> leads);
}

// Step 2: Implement service
public with sharing class LeadService implements ILeadService {
    public List<Lead> getLeadsByEmail(String email) {
        return [SELECT Id FROM Lead WHERE Email = :email WITH USER_MODE];
    }

    public void createLeads(List<Lead> leads) {
        insert leads;
    }
}

// Step 3: Refactor to instance-based
public class LeadQualificationResponseParser {
    private ILeadService leadService;

    // Constructor injection for testing
    public LeadQualificationResponseParser(ILeadService service) {
        this.leadService = service;
    }

    // Default constructor for production
    public LeadQualificationResponseParser() {
        this(new LeadService());
    }

    // NOW instance method (not static)
    public void parseResponse(String jsonResponse) {
        List<Lead> existingLeads = leadService.getLeadsByEmail(email);
        leadService.createLeads(newLeads);
    }
}

// Now fully testable with mocks!
@IsTest
class LeadQualificationResponseParserTest {
    @IsTest
    static void testParseResponse() {
        // Create mock - NO DATABASE ACCESS
        ILeadService mockService = (ILeadService) Test.createStub(
            ILeadService.class,
            new LeadServiceMock()
        );

        // Test with mock
        LeadQualificationResponseParser parser =
            new LeadQualificationResponseParser(mockService);
        parser.parseResponse('{"leads":[...]}');

        // Fast, reliable unit tests!
    }
}
```

**For HIGH Violations (Service classes):**
- Extract static methods to instance methods
- Add dependency injection via constructor
- Create interfaces for all external dependencies

**For MEDIUM Violations:**
- Review necessity of static methods
- Consider instance-based architecture for future scalability

## Output Format
```json
{
  "checkpoint_name": "static-method-analysis",
  "checkpoint_priority": "CRITICAL",
  "status": "pass|fail|warning",
  "files_analyzed": ["list of file paths"],
  "per_class_analysis": [
    {
      "file": "[path to .cls file]",
      "class_name": "[ClassName]",
      "total_methods": "[number - excludes constructors and @InvocableMethod]",
      "static_methods": "[number - excludes @InvocableMethod]",
      "instance_methods": "[number]",
      "invocable_methods": "[number - excluded from ratio calculation]",
      "static_ratio_percent": "[0-100]",
      "dependencies_detected": {
        "has_dependencies": "[true|false]",
        "soql_queries": "[count in static methods]",
        "dml_operations": "[count in static methods]",
        "database_methods": "[count in static methods]",
        "http_callouts": "[count in static methods]",
        "static_class_calls": ["ClassName.method", "OtherClass.staticCall"],
        "logging_calls": "[count in static methods]"
      },
      "automatic_violation": {
        "triggered": "[true|false]",
        "severity": "[CRITICAL|HIGH|MEDIUM|NONE]",
        "rule_matched": "[which automatic trigger rule matched]",
        "violation_description": "[specific violation message]"
      },
      "testability": {
        "status": "fully-mockable|partially-mockable|untestable",
        "rationale": "[explanation of why this status]",
        "interfaces_defined": "[true|false]",
        "can_use_stub_api": "[true|false]"
      },
      "production_blocker": "[true if CRITICAL violation, else false]",
      "refactoring_priority": "immediate|high|medium|low|none"
    }
  ],
  "violations": [
    {
      "severity": "critical",
      "category": "Architecture Standards",
      "file": "[path]",
      "line": null,
      "issue": "God Class with Static Cling - 80% static methods with SOQL/DML dependencies",
      "evidence": "Static ratio: 100%, Dependencies: 5 SOQL queries, 3 DML operations, Class type: Service",
      "fix_guidance": "[Refactoring steps with code examples - see Step 6 above]",
      "confidence": 0.9
    }
  ],
  "summary": {
    "classes_analyzed": "[number]",
    "classes_with_violations": "[number]",
    "critical_violations": "[number of classes with static ratio >= 80% and dependencies]",
    "high_violations": "[number of service classes with static ratio >= 60%]",
    "medium_violations": "[number of classes with static ratio >= 40%]",
    "classes_blocked_for_production": "[number with production_blocker=true]",
    "average_static_ratio": "[percentage across all classes]",
    "worst_offenders": [
      {
        "class": "[ClassName]",
        "static_ratio": "[percentage]",
        "dependencies": "[count]",
        "production_blocker": "[true|false]"
      }
    ],
    "production_blocker": "[true if ANY class has production_blocker=true]"
  }
}
```

**Status Logic:**
- `status: "pass"` if no violations (all classes < 40% static OR pure utilities)
- `status: "fail"` if critical_violations > 0 (80%+ static with dependencies)
- `status: "warning"` if only high or medium violations

## Success Criteria
- ✅ ALL classes with 3+ methods are analyzed
- ✅ Static ratio is calculated for EVERY class
- ✅ Automatic violation triggers are applied consistently
- ✅ Classes with 80%+ static ratio AND dependencies are flagged as production blockers
- ✅ Validation: Running against 86d0ffn9j code MUST catch the issue

## Failure Handling
**CONTINUE** - This checkpoint failing should not stop other checks.

However, if `production_blocker = true`, the final aggregated report MUST:
- Highlight deployment risk prominently
- Set `production_readiness: "critical-issues"`
- Require remediation before production deployment

## Validation Against 86d0ffn9j

**Test Case:**
- **Input:** LeadQualificationResponseParser.cls (100% static methods with SOQL/DML)
- **Expected Output:**
  - `static_ratio_percent: 100`
  - `has_dependencies: true`
  - `automatic_violation.triggered: true`
  - `automatic_violation.severity: "CRITICAL"`
  - `production_blocker: true`
  - `testability.status: "untestable"`
  - `confidence: 0.9`

**If this test fails, the checkpoint has NOT caught the 86d0ffn9j issue and Phase 2 is incomplete.**

## Cross-References
- **`docs/SALESFORCE_APEX_STATIC_TYPES_GUIDE.md`** - Architecture patterns and static method guidelines
- **RFC_SALESFORCE_PRACTICES.md** - Instance-based architecture requirements
- **Salesforce DI Guide:** [Effective Dependency Injection in Apex](https://developer.salesforce.com/blogs/2021/08/effective-dependency-injection-in-apex)
- **Apex Stub API:** [Test.createStub()](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_testing_stub_api.htm)

## Confidence Scoring
**All static method violations: 0.9 confidence**

Rationale:
- Method counting via regex/parsing is highly accurate
- Dependency detection patterns are explicit
- Automatic violation triggers are deterministic
- False positives rare (only if comments contain trigger patterns)

Edge cases (still 0.9 confidence):
- Inner classes (count separately)
- Dynamic Apex (rare, handle as best effort)
- Code generation (analyze generated code as-is)

## Examples

**Example 1: CRITICAL Violation (86d0ffn9j Pattern)**
```apex
// VIOLATION - Caught by this checkpoint
public class LeadQualificationResponseParser {
    // 5 static methods, 0 instance methods = 100% static
    public static void parseResponse(String json) {
        List<Lead> leads = [SELECT Id FROM Lead]; // SOQL dependency
        insert newLeads; // DML dependency
    }
    public static void helper1() { }
    public static void helper2() { }
    public static void helper3() { }
    public static void helper4() { }
}

// Checkpoint Output:
// static_ratio: 100%
// has_dependencies: true (SOQL + DML)
// automatic_violation: CRITICAL
// production_blocker: true
// testability: untestable
```

**Example 2: Compliant Instance-Based Service**
```apex
// NO VIOLATION - Good architecture
public with sharing class LeadService implements ILeadService {
    private ILeadRepository repo;

    public LeadService(ILeadRepository repository) {
        this.repo = repository;
    }

    // All instance methods (except entry point)
    public List<Lead> getActiveLeads() {
        return repo.getLeadsByStatus('Active');
    }

    @AuraEnabled(cacheable=true)
    public static List<Lead> getLeadsForUI() {
        // Entry point delegates to instance
        return new LeadService(new LeadRepository()).getActiveLeads();
    }
}

// Checkpoint Output:
// static_ratio: 17% (1 static entry point, 6 instance methods)
// has_dependencies: false (dependencies injected via interface)
// automatic_violation: NONE
// production_blocker: false
// testability: fully-mockable
```

**Example 3: Pure Utility Class (Compliant)**
```apex
// NO VIOLATION - Pure utility (no dependencies)
public class StringUtils {
    // 100% static but NO dependencies = OK
    public static Boolean isEmpty(String str) {
        return str == null || str.trim().length() == 0;
    }

    public static String capitalize(String str) {
        return str.substring(0, 1).toUpperCase() + str.substring(1);
    }
}

// Checkpoint Output:
// static_ratio: 100%
// has_dependencies: false (pure utility)
// automatic_violation: NONE (exception for pure utilities)
// production_blocker: false
// testability: fully-mockable (no mocking needed)
```
