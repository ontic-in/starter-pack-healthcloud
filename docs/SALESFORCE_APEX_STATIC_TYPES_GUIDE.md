# Salesforce Apex Static vs Instance Methods: The Evidence-Based Guide

## Executive Summary

**The Position**: Static methods in Salesforce Apex exist on a spectrum from basic Trailhead examples (static utility methods) to enterprise architecture patterns (instance-based with dependency injection). The **context determines appropriateness**: tutorials teach static for simplicity, but production enterprise applications require testability and maintainability.

**Key Finding**: While **basic Salesforce examples use static methods**, official Salesforce testing documentation, DI guidance, and enterprise architecture patterns (including the official Apex Enterprise Patterns Trailhead module) strongly favor **instance-based architecture with dependency injection** for complex, testable production code. The disconnect between tutorial simplicity and production requirements creates confusion.

---

## Official Salesforce Guidance (With Citations)

### 1. Static vs Instance Methods Definition

**Source**: [Salesforce Apex Developer Guide - Static and Instance Methods](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_static.htm)

**Official Statement**:
> "A static method is used as a utility method, and it never depends on the value of an instance member variable. Because a static method is only associated with a class, it can't access the instance member variable values of its class."

**When to Use Static** (per official docs):
- Utility or helper logic
- Method behavior independent of instance data
- Examples: parsing values, calculations not depending on object fields

**When to Use Instance** (per official docs):
- Logic depends on object's member variables
- Behavior tied to particular class instance

### 2. Trigger Handler Pattern: The Spectrum

**Basic Trailhead Examples** (Teaching Pattern):

**Source**: [Trailhead: Apex Triggers - Introduction](https://trailhead.salesforce.com/content/learn/modules/apex_triggers/apex_triggers_intro)

The basic Trailhead module shows **static utility method** pattern for simplicity:

```apex
trigger ContactNotificationTrigger on Contact (after insert) {
    Integer recordCount = Trigger.new.size();
    Set<String> recipientIDs = new Set<String>{UserInfo.getUserId()};
    // Calls static utility method
    CustomContactNotification.notifyUsers(recipientIDs, recordCount);
}
```

This is appropriate for **learning fundamentals**, not production enterprise code.

**Enterprise Architecture Pattern**:

**Source**: [Trailhead: Apex Enterprise Patterns - Domain & Selector Layers](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl)

**Source**: [Salesforce Platform Enterprise Architecture](https://github.com/PacktPublishing/Salesforce-Platform-Enterprise-Architecture-4th-Edition) (Community standard, referenced in Salesforce architect materials)

Enterprise patterns use **instance-based handlers with dependency injection**:

```apex
trigger OpportunityTrigger on Opportunity (before insert, after update) {
    fflib_SObjectDomain.triggerHandler(Opportunities.class);
}

// Handler class (instance-based)
public class Opportunities extends fflib_SObjectDomain {
    public Opportunities(List<Opportunity> records) {
        super(records);
    }

    public override void onBeforeInsert() {
        // Business logic with injected services
    }
}
```

**Source**: [Apex Developer Guide - Trigger Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_bestpract.htm)

**Verdict**: Salesforce teaches static for simplicity, but enterprise patterns use instance-based for testability.

### 3. Dependency Injection

**Source**: [Salesforce Developer Blog - Breaking Runtime Dependencies with Dependency Injection (July 2019)](https://developer.salesforce.com/blogs/2019/07/breaking-runtime-dependencies-with-dependency-injection)

**Source**: [Salesforce Developers YouTube - Dependency Injection in Apex](https://www.youtube.com/watch?v=-zKz4bhg6KM) (Related to the blog post)

**Key Benefits Cited**:
- Decouples components for modular package development
- Enables runtime implementation swapping without code changes
- **Supports testability** - the YouTube companion states: "dependency injection...makes it easier to write tests using stub APIs in Apex"
- Reduces compile-time dependencies

**Source**: [Effective Dependency Injection in Apex (August 2021)](https://developer.salesforce.com/blogs/2021/08/effective-dependency-injection-in-apex)

**Caution**: Salesforce notes not to "overdo it" due to complexity overhead, but explicitly **endorses DI for strategic dependencies** where testability and modularity matter.

### 4. Testing Best Practices

**Source**: [Apex Developer Guide - Writing Tests](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_intro_writing_tests.htm)

**Official Test Isolation Guidance**:
> "Unit test methods take no arguments, commit no data to the database, and send no emails. Such methods are flagged with the @IsTest annotation in the method definition."

> "Test classes that test code with external dependencies, such as callouts to external services, should use mock objects to simulate these dependencies."

**On Mocking and the Stub API**:
> "When you want your test methods to call logic in your code rather than invoking external services, use the Stub API or the HttpCalloutMock interface."

> "Apex provides the Stub API, starting in version 39.0, to mock interfaces and virtual classes in tests."

**Source**: [Salesforce Developer Blog - Introducing apex-mockery (June 2023)](https://developer.salesforce.com/blogs/2023/06/introducing-apex-mockery-a-unit-test-mocking-library)

**Official Recommendation**:
> "You can replace the service dependency with a mock that implements the interface"

**Source**: [Apex Testing Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_best_practices.htm)

**Key Principles**:
- **Mocking**: Explicitly recommended for external dependencies
- **Test Isolation**: Each test must be independent, no shared state
- **Stub API**: Official mechanism for interface and virtual class mocking

**Implication**: Static methods that cannot be mocked directly conflict with official testing guidance on isolation and mocking.

---

## Understanding the Spectrum: Tutorial vs Production

### The Disconnect

Salesforce official content serves different audiences:

| Audience | Content Type | Pattern | Rationale | Source |
|----------|--------------|---------|-----------|--------|
| **Learners** | Basic Trailhead | Static utility methods | Simplicity, fewer concepts | [Apex Triggers Intro](https://trailhead.salesforce.com/content/learn/modules/apex_triggers/apex_triggers_intro) |
| **Enterprise Developers** | Advanced Trailhead | Instance-based, DI | Testability, maintainability | [Apex Enterprise Patterns](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl) |
| **Architects** | Salesforce Platform Enterprise Architecture | Service/Domain/Selector layers | Separation of concerns, scaling | [GitHub Repo](https://github.com/PacktPublishing/Salesforce-Platform-Enterprise-Architecture-4th-Edition) |

### Why the Confusion Exists

**Beginners learn static patterns** (ContactNotificationTrigger example) because:
- Fewer concepts to understand
- No interfaces or DI complexity
- Focused on Apex syntax fundamentals

**Production code requires instance patterns** because:
- Official testing guidance mandates mocking ([Writing Tests](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_intro_writing_tests.htm))
- DI is officially endorsed ([DI Blog](https://developer.salesforce.com/blogs/2019/07/breaking-runtime-dependencies-with-dependency-injection))
- Enterprise patterns teach layered architecture ([Enterprise Patterns](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl))

**Result**: Developers copy tutorial patterns into production code, creating untestable, tightly-coupled systems.

---

## The Nuanced Position: When Static Methods Are Appropriate

### ✅ Legitimate Use Cases

#### 1. **Pure Utility Functions**
```apex
public class StringUtils {
    public static String formatPhoneNumber(String phone) {
        // No state, no dependencies, pure transformation
        return phone.replaceAll('[^0-9]', '');
    }
}
```

**Justification**:
- No instance state required
- Stateless operation
- No dependencies to mock
- Aligns with official guidance: "utility method"

#### 2. **Recursion Guards**
```apex
public class AccountTriggerHandler {
    private static Boolean isProcessing = false;

    public void run() {
        if (isProcessing) return;
        isProcessing = true;
        try {
            // Handler logic
        } finally {
            isProcessing = false;
        }
    }
}
```

**Justification**:
- Transaction-scoped state management
- Prevents infinite loops in triggers
- Common accepted pattern
- Static variable, but handler itself is instance-based

#### 3. **Constants and Configuration**
```apex
public class Constants {
    public static final String DEFAULT_COUNTRY = 'US';
    public static final Integer MAX_QUERY_SIZE = 200;
}
```

**Justification**:
- Immutable values
- No behavior to test
- Standard practice across all languages

#### 4. **Factory Methods**
```apex
public class LeadProcessorFactory {
    public static ILeadProcessor getInstance(String type) {
        if (type == 'Standard') return new StandardLeadProcessor();
        if (type == 'Premium') return new PremiumLeadProcessor();
        return new DefaultLeadProcessor();
    }
}
```

**Justification**:
- Returns instance-based objects
- Encapsulates construction logic
- Enables polymorphism and DI

---

## ❌ Cargo-Cult Anti-Patterns

### Anti-Pattern #1: Static Service Classes

**Common Code**:
```apex
public class LeadService {
    public static void processLeads(List<Lead> leads) {
        // Direct database queries
        List<Account> accounts = [SELECT Id FROM Account WHERE ...];

        // Direct DML operations
        insert opportunities;

        // Hard-coded dependencies
        EmailService.sendNotifications(leads);
    }
}
```

**Why This Violates Official Salesforce Guidance**:
1. **Cannot mock dependencies** (EmailService call) - conflicts with [apex-mockery guidance](https://developer.salesforce.com/blogs/2023/06/introducing-apex-mockery-a-unit-test-mocking-library)
2. **Hard to test in isolation** - requires database operations
3. **Prevents dependency injection** - conflicts with [DI best practices](https://developer.salesforce.com/blogs/2019/07/breaking-runtime-dependencies-with-dependency-injection)
4. **Tight coupling** - changes to EmailService break LeadService tests

**Recommended Refactor**:
```apex
public class LeadService {
    private IEmailService emailService;
    private ILeadRepository leadRepository;

    public LeadService(IEmailService emailSvc, ILeadRepository leadRepo) {
        this.emailService = emailSvc;
        this.leadRepository = leadRepo;
    }

    public void processLeads(List<Lead> leads) {
        List<Account> accounts = leadRepository.getRelatedAccounts(leads);
        // ... logic ...
        emailService.sendNotifications(leads);
    }
}
```

### Anti-Pattern #2: Static Trigger Handlers

**Common Code**:
```apex
public class LeadTriggerHandler {
    public static void handleBeforeInsert(List<Lead> newLeads) {
        // Direct service calls
        LeadService.validateLeads(newLeads);
        LeadService.enrichData(newLeads);
    }
}
```

**Why This Conflicts with Enterprise Best Practices**:
- Basic [Trailhead examples](https://trailhead.salesforce.com/content/learn/modules/apex_triggers) show static for teaching, but [Enterprise Patterns](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl) use instance-based
- Cannot inject mock services for testing (violates [testing guidance](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_intro_writing_tests.htm))
- All dependencies must be static (cascading anti-pattern)
- Conflicts with [DI recommendations](https://developer.salesforce.com/blogs/2019/07/breaking-runtime-dependencies-with-dependency-injection)

**Enterprise Pattern**:
```apex
public class LeadTriggerHandler {
    private ILeadService leadService;

    public LeadTriggerHandler() {
        // Could use DI framework or factory
        this.leadService = ServiceFactory.getLeadService();
    }

    public void handleBeforeInsert(List<Lead> newLeads) {
        leadService.validateLeads(newLeads);
        leadService.enrichData(newLeads);
    }
}

// Trigger
trigger LeadTrigger on Lead (before insert) {
    new LeadTriggerHandler().handleBeforeInsert(Trigger.new);
}
```

### Anti-Pattern #3: "Avoiding Instance Creation Overhead"

**The Myth**: "Creating objects is expensive in Salesforce's multi-tenant environment"

**The Reality**:
- No official Salesforce documentation supports this claim
- Governor limits focus on: **SOQL queries, DML operations, CPU time, heap size**
- Object instantiation is negligible compared to database operations
- No credible benchmarks show meaningful impact

**Evidence**: [Governor Limits Documentation](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm) lists limits - object instantiation is not mentioned.

### Anti-Pattern #4: "Static Methods Encourage Bulkification"

**The Myth**: Static methods = bulk-safe code

**The Reality**: Orthogonal concerns
- You can write non-bulkified static methods
- You can write bulkified instance methods
- Bulkification is about **collection processing**, not method type

**Bad Static Method** (not bulkified):
```apex
public static void processLead(Lead lead) {
    Account acc = [SELECT Id FROM Account WHERE Id = :lead.AccountId];
    // Processing single record - will violate governor limits in bulk
}
```

**Good Instance Method** (bulkified):
```apex
public void processLeads(List<Lead> leads) {
    Set<Id> accountIds = new Set<Id>();
    for (Lead l : leads) accountIds.add(l.AccountId);

    Map<Id, Account> accountMap = new Map<Id, Account>(
        [SELECT Id FROM Account WHERE Id IN :accountIds]
    );
    // Properly bulkified instance method
}
```

---

## Decision Framework: Static vs Instance

### Decision Tree

```
START: Should this be static or instance-based?

1. Is this a pure utility function with NO dependencies?
   YES → Static is appropriate
   NO → Continue to #2

2. Does this method need to interact with other services or repositories?
   YES → Instance-based with DI
   NO → Continue to #3

3. Will this method need to be mocked in tests?
   YES → Instance-based with interface
   NO → Continue to #4

4. Does this method manage state within a transaction?
   YES → Instance-based (unless recursion guard)
   NO → Continue to #5

5. Is this a constant or configuration value?
   YES → Static is appropriate
   NO → Default to instance-based for flexibility
```

### Quick Reference Table

| Use Case | Static or Instance | Rationale | Official Source |
|----------|-------------------|-----------|-----------------|
| Pure utility (no deps) | Static | No state, no dependencies | [Apex Dev Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_static.htm) |
| Service classes | Instance | Needs DI and mocking | [DI Blog](https://developer.salesforce.com/blogs/2019/07/breaking-runtime-dependencies-with-dependency-injection) |
| Trigger handlers | Instance | Enterprise patterns use instance | [Enterprise Patterns](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl) |
| Recursion guards | Static variable | Transaction-scoped control | Common pattern |
| Constants | Static | Immutable values | Standard practice |
| Business logic | Instance | Testability and DI | [Testing Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_best_practices.htm) |

---

## Edge Cases and Nuances

### Edge Case #1: Performance-Critical Paths

**Scenario**: Extremely high-volume processing where every CPU millisecond matters.

**Nuance**: In rare cases, avoiding object instantiation overhead might be justified.

**Guidance**:
1. **Measure first**: Use [CPU time limits](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm) monitoring
2. **Profile the difference**: Prove instantiation is the bottleneck (it rarely is)
3. **Document the tradeoff**: Explicitly note you're sacrificing testability for performance
4. **Consider alternatives**: Can you instantiate once and reuse?

### Edge Case #2: Batch Apex and Queueable

**Scenario**: Large-scale async processing.

**Nuance**: Instances are created per chunk/execution, not per record.

**Guidance**:
```apex
public class LeadBatchProcessor implements Database.Batchable<SObject> {
    private ILeadService leadService;

    public LeadBatchProcessor(ILeadService service) {
        this.leadService = service;
    }

    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        // Service injected at batch start, reused per chunk
        leadService.processLeads(scope);
    }
}
```

**Verdict**: Instance-based architecture works perfectly; one instance per batch execution is negligible.

### Edge Case #3: Legacy Code with Static Everywhere

**Scenario**: Existing codebase with 100% static service classes.

**Nuance**: Refactoring everything at once is impractical.

**Guidance**:
1. **Apply to new code**: All new classes follow instance-based pattern
2. **Refactor incrementally**: When modifying existing classes for features, refactor then
3. **Adapter pattern**: Create instance-based wrappers around static legacy code
4. **Document technical debt**: Track in backlog with priority based on test coverage gaps

### Edge Case #4: Simple CRUD Operations

**Scenario**: Basic database operations with no business logic.

**Nuance**: Repository pattern might feel like over-engineering.

**Guidance**:
```apex
// Acceptable for truly simple cases
public class LeadRepository {
    public List<Lead> getLeadsByStatus(String status) {
        return [SELECT Id, Name FROM Lead WHERE Status = :status];
    }
}

// Call site can be static if no other dependencies
public class LeadService {
    public static List<Lead> getActiveLeads() {
        LeadRepository repo = new LeadRepository();
        return repo.getLeadsByStatus('Active');
    }
}
```

**But consider**: If you'll ever need to mock the query (for unit testing upper layers), make it instance-based from the start.

---

## Testing Implications

### The Static Method Testing Problem

**What You Cannot Do with Static Methods**:
```apex
// Cannot mock LeadService because it's static
@IsTest
public class AccountProcessorTest {
    @IsTest
    static void testProcessAccount() {
        Account acc = new Account(Name = 'Test');

        // This calls REAL LeadService.processLeads()
        // Cannot inject mock, cannot isolate test
        AccountProcessor.process(acc); // Internally calls static LeadService

        // Test now depends on LeadService implementation
        // Changes to LeadService can break AccountProcessor tests
    }
}
```

### Instance-Based Testing with Mocking

**Official Pattern Using Stub API**:
```apex
@IsTest
public class AccountProcessorTest {
    @IsTest
    static void testProcessAccount() {
        // Create mock using official Stub API
        ILeadService mockLeadService = (ILeadService)Test.createStub(
            ILeadService.class,
            new LeadServiceMock()
        );

        // Inject mock via constructor (DI)
        AccountProcessor processor = new AccountProcessor(mockLeadService);

        Account acc = new Account(Name = 'Test');
        processor.process(acc);

        // Test is isolated - only testing AccountProcessor logic
        // LeadService implementation doesn't matter
    }
}
```

**Source**: [Stub API Documentation](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_stub_api.htm)

---

## Recommended Architecture Pattern

### Layer-Based Architecture (Aligns with Official Guidance)

```
┌─────────────────────────────────────────┐
│ Trigger (Minimal Logic)                 │
│ - Instantiates handler                  │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Trigger Handler (Instance)              │
│ - Orchestrates services                 │
│ - Dependencies injected via constructor │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Service Layer (Instance)                │
│ - Business logic                        │
│ - Depends on repositories via interface │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│ Repository Layer (Instance)             │
│ - Data access                           │
│ - SOQL and DML operations               │
└─────────────────────────────────────────┘
```

### Example Implementation

```apex
// 1. Interfaces (enable DI and mocking)
public interface ILeadRepository {
    List<Lead> getLeadsByAccountId(Set<Id> accountIds);
    void updateLeads(List<Lead> leads);
}

public interface ILeadService {
    void processLeads(List<Lead> leads);
}

// 2. Repository (Instance-based)
public class LeadRepository implements ILeadRepository {
    public List<Lead> getLeadsByAccountId(Set<Id> accountIds) {
        return [SELECT Id, Status FROM Lead WHERE AccountId IN :accountIds];
    }

    public void updateLeads(List<Lead> leads) {
        update leads;
    }
}

// 3. Service (Instance-based with DI)
public class LeadService implements ILeadService {
    private ILeadRepository repository;

    public LeadService(ILeadRepository repo) {
        this.repository = repo;
    }

    public void processLeads(List<Lead> leads) {
        // Business logic
        repository.updateLeads(leads);
    }
}

// 4. Trigger Handler (Instance-based with DI)
public class LeadTriggerHandler {
    private ILeadService leadService;

    public LeadTriggerHandler(ILeadService service) {
        this.leadService = service;
    }

    public void handleBeforeUpdate(List<Lead> leads) {
        leadService.processLeads(leads);
    }
}

// 5. Factory (Static factory method returning instances)
public class ServiceFactory {
    public static ILeadService getLeadService() {
        ILeadRepository repo = new LeadRepository();
        return new LeadService(repo);
    }
}

// 6. Trigger (Minimal logic)
trigger LeadTrigger on Lead (before update) {
    ILeadService service = ServiceFactory.getLeadService();
    new LeadTriggerHandler(service).handleBeforeUpdate(Trigger.new);
}
```

**Fully Testable**:
```apex
@IsTest
public class LeadTriggerHandlerTest {
    @IsTest
    static void testHandleBeforeUpdate() {
        // Mock service
        ILeadService mockService = (ILeadService)Test.createStub(
            ILeadService.class,
            new LeadServiceMock()
        );

        // Inject mock
        LeadTriggerHandler handler = new LeadTriggerHandler(mockService);

        // Test in isolation
        List<Lead> leads = new List<Lead>{new Lead(Name='Test')};
        handler.handleBeforeUpdate(leads);

        // Verify behavior without hitting database
    }
}
```

---

## Common Objections Addressed

### Objection #1: "Everyone uses static methods in Salesforce"

**Response**: This reflects the gap between tutorial simplicity and production requirements.

**Evidence**:
- Basic Trailhead modules use static for teaching simplicity
- Enterprise patterns (official [Apex Enterprise Patterns module](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl)) use instance-based
- Official testing and DI guidance requires mockable dependencies

### Objection #2: "Dependency injection is too complex for Apex"

**Response**: Salesforce explicitly endorses it.

**Source**: [Breaking Runtime Dependencies with Dependency Injection](https://developer.salesforce.com/blogs/2019/07/breaking-runtime-dependencies-with-dependency-injection)

**Counter**: Constructor injection (shown above) is straightforward and adds minimal code.

### Objection #3: "Governor limits require static methods"

**Response**: False premise.

**Evidence**: [Governor Limits Documentation](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm) - limits are per transaction, not per instance.

**Static variables** help manage transaction state, but methods can be instance-based.

### Objection #4: "Static methods are faster"

**Response**: Requires proof.

**Challenge**:
1. Show profiling data proving instance creation is the bottleneck
2. Prove it's significant compared to SOQL/DML operations (it's not)
3. Justify sacrificing testability for unmeasured "performance"

**Reality**: Database operations are 1000x+ more expensive than object instantiation.

### Objection #5: "Our codebase is already all static"

**Response**: Technical debt doesn't justify more technical debt.

**Recommendation**:
1. Apply instance-based pattern to new code
2. Refactor incrementally
3. Document the gap between current state and official best practices

---

## Practical Migration Strategy

### Phase 1: New Code (Immediate)
- All new classes follow instance-based architecture
- Use DI and interfaces
- Measure improvement in test coverage and test execution speed

### Phase 2: High-Value Refactoring (Sprint-by-Sprint)
- Identify classes with low test coverage due to static coupling
- Refactor to instance-based when adding features
- Prioritize classes with frequent bugs or changes

### Phase 3: Systematic Refactoring (Technical Debt Backlog)
- Create tickets for each static service class
- Estimate effort vs. testing benefit
- Include in quarterly planning

### Phase 4: Document Architecture Standards
- Update team coding standards
- Require instance-based architecture for code reviews
- Create templates and examples

---

## Conclusion

### The Evidence-Based Position

1. **Salesforce guidance exists on a spectrum**: Basic tutorials use static for simplicity; enterprise patterns ([Apex Enterprise Patterns](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl), [fflib](https://github.com/apex-enterprise-patterns/fflib-apex-common)) use instance-based
2. **Official testing and DI documentation** strongly favors mockable, testable dependencies (requires instance-based)
3. **Static methods are appropriate** for pure utilities, constants, and stateless operations
4. **Production enterprise code benefits from instance-based architecture** with DI for maintainability and testability
5. **Governor limits do not mandate static methods** - transaction-scoped, not instance-scoped

### The Practical Recommendation

**Default to instance-based with dependency injection** unless you have a specific, justified reason for static:
- ✅ Pure utility function
- ✅ Constant value
- ✅ Factory method (returning instances)
- ✅ Recursion guard (static variable, instance methods)

**Avoid static for**:
- ❌ Service classes with dependencies
- ❌ Trigger handlers
- ❌ Business logic that needs testing
- ❌ Any code that interacts with external systems

### The Strategic Impact

Following official Salesforce guidance yields:
- **Higher test coverage** (can mock dependencies)
- **Faster test execution** (isolated unit tests)
- **More maintainable code** (loose coupling via DI)
- **Easier debugging** (can inject logging/monitoring services)
- **Better compliance** with Salesforce architect recommendations

---

## References

### Official Salesforce Documentation
1. [Static and Instance Methods](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_static.htm)
2. [Trigger Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_bestpract.htm)
3. [Testing Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_best_practices.htm)
4. [Governor Limits](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm)
5. [Stub API Documentation](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_stub_api.htm)

### Official Salesforce Developer Blog
6. [Breaking Runtime Dependencies with Dependency Injection](https://developer.salesforce.com/blogs/2019/07/breaking-runtime-dependencies-with-dependency-injection)
7. [Introducing apex-mockery: A Unit Test Mocking Library](https://developer.salesforce.com/blogs/2023/06/introducing-apex-mockery-a-unit-test-mocking-library)
8. [Effective Dependency Injection in Apex](https://developer.salesforce.com/blogs/2021/08/effective-dependency-injection-in-apex)

### Official Trailhead Modules
9. [Apex Triggers Module - Introduction](https://trailhead.salesforce.com/content/learn/modules/apex_triggers/apex_triggers_intro)
10. [Apex Enterprise Patterns - Domain & Selector Layers](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_dsl)
11. [Apex Enterprise Patterns - Service Layer](https://trailhead.salesforce.com/content/learn/modules/apex_patterns_sl)

### Community Standards (Referenced in Salesforce Materials)
12. [fflib Apex Common - Enterprise Patterns Library](https://github.com/apex-enterprise-patterns/fflib-apex-common)
13. [Salesforce Platform Enterprise Architecture (4th Edition)](https://github.com/PacktPublishing/Salesforce-Platform-Enterprise-Architecture-4th-Edition)
14. [Salesforce Architect - Architecture Fundamentals](https://architect.salesforce.com/fundamentals/architecture-basics)

---

**Document Version**: 2.0 (Revised with verified sources)
**Last Updated**: 2025-09-30
**Maintained By**: TASC Managed Services - Salesforce Tech Lead
**Review Cycle**: Quarterly (verify against latest Salesforce documentation)
**Verification Status**: All Salesforce documentation URLs verified via Perplexity research, quotes cross-referenced