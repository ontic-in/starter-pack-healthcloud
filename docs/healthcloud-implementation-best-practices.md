# Salesforce Health Cloud: Implementation Best Practices

> **Document Version:** 1.0 | **Last Updated:** February 2026
> **Purpose:** Comprehensive best practices guide for Salesforce Health Cloud implementations, covering architecture, development, security, integrations, testing, and operations.

---

## Table of Contents

1. [Data Model & Configuration](#1-data-model--configuration)
2. [Apex Development Standards](#2-apex-development-standards)
3. [Trigger Framework](#3-trigger-framework)
4. [Governor Limits & Bulk Patterns](#4-governor-limits--bulk-patterns)
5. [OmniStudio & FlexCards](#5-omnistudio--flexcards)
6. [Lightning Web Components (LWC)](#6-lightning-web-components-lwc)
7. [Error Logging Framework](#7-error-logging-framework)
8. [FHIR & EHR Integration](#8-fhir--ehr-integration)
9. [Security & Compliance](#9-security--compliance)
10. [Data Migration](#10-data-migration)
11. [Testing Strategy](#11-testing-strategy)
12. [Deployment & CI/CD](#12-deployment--cicd)
13. [Performance Optimisation](#13-performance-optimisation)
14. [Ongoing Operations](#14-ongoing-operations)

---

## 1. Data Model & Configuration

### 1.1 Use Health Cloud Standard Objects First

- **Always prefer standard Health Cloud objects** over custom objects: `Account` (Person Account for patients), `CarePlan`, `CareTeamMember`, `HealthCondition`, `MedicationStatement`, `AllergyIntolerance`
- Extend standard objects with custom fields only when the data doesn't fit the existing model
- Use the **Clinical Data Model** (CDM) which aligns with FHIR R4 resources

### 1.2 Person Account Configuration

- Enable Person Accounts for patient records (required for Health Cloud)
- Use Record Types to distinguish between patients, providers, and other account types
- Configure page layouts per record type for relevant field visibility

### 1.3 Care Plan Design

- Create **care plan templates** for common clinical pathways (e.g., Diabetes Management, Cardiac Rehab, Chronic Disease)
- Each template should define: goals with measurable targets, standard tasks, care team roles, and review schedules
- Version templates and ensure updates don't break active care plans
- Use `CarePlanTemplate`, `CarePlanTemplateGoal`, and `CarePlanTemplateTask` objects

### 1.4 Data Model Extension Rules

| Do | Don't |
|---|---|
| Add custom fields to standard objects | Create parallel custom objects that duplicate standard functionality |
| Use picklists for controlled vocabularies (ICD-10, SNOMED) | Hardcode clinical codes in Apex |
| Use lookup relationships for cross-object references | Use text fields for record references |
| Document all custom fields with descriptions | Leave custom fields undocumented |
| Use Record Types for variant behaviour | Create separate objects for minor variants |

### 1.5 Naming Conventions

- **Custom Objects:** `[Domain]_[Entity]__c` (e.g., `HC_ErrorLog__c`, `HC_ConsentRecord__c`)
- **Custom Fields:** `[Descriptive_Name]__c` (e.g., `NRIC_Number__c`, `Medisave_Balance__c`)
- **Apex Classes:** PascalCase with suffix indicating type (e.g., `PatientTriggerHandler`, `FHIRService`, `CarePlanBatch`)
- **LWC Components:** camelCase (e.g., `patientTimeline`, `carePlanGoalTracker`)
- **Flows:** `[Object]_[Action]_[Context]` (e.g., `Patient_Create_Registration`, `CarePlan_Escalate_OffTrack`)

---

## 2. Apex Development Standards

### 2.1 Code Structure

```
force-app/main/default/classes/
├── triggers/           # One trigger per object
├── handlers/           # Trigger handler classes
├── services/           # Business logic (reusable)
├── selectors/          # SOQL query classes
├── domains/            # Domain logic (SObject-specific)
├── controllers/        # LWC/Aura controllers
├── integrations/       # API callout classes
├── utilities/          # Shared helpers
├── wrappers/           # DTO/wrapper classes
├── batch/              # Batch Apex classes
├── queueable/          # Queueable Apex classes
├── scheduled/          # Scheduled Apex classes
└── test/               # Test classes
```

### 2.2 Separation of Concerns

- **Triggers:** Delegate immediately to handler classes. No business logic in triggers.
- **Handlers:** Orchestrate the trigger context. Call service methods.
- **Services:** Contain reusable business logic. Stateless where possible.
- **Selectors:** Centralise all SOQL queries. Makes testing and optimisation easier.
- **Controllers:** Thin layer between LWC and services. Validate inputs, call services, format outputs.

### 2.3 Apex Coding Standards

```apex
// DO: Bulkified, efficient, readable
public class CarePlanService {

    public static List<CarePlan> createFromTemplate(
        List<Id> patientIds,
        Id templateId
    ) {
        // Query once, outside loops
        CarePlanTemplate template = [
            SELECT Id, Name, (SELECT Id, Name, Target__c FROM Goals__r)
            FROM CarePlanTemplate
            WHERE Id = :templateId
            LIMIT 1
        ];

        List<CarePlan> plans = new List<CarePlan>();
        for (Id patientId : patientIds) {
            plans.add(new CarePlan(
                AccountId = patientId,
                Name = template.Name + ' - ' + Date.today().format(),
                Status = 'Draft'
            ));
        }
        insert plans;
        return plans;
    }
}
```

### 2.4 Must-Follow Rules

- **No SOQL/DML inside loops** - Query/update outside loops, use maps for lookups
- **No hardcoded IDs** - Use Custom Metadata, Custom Settings, or Custom Labels
- **No hardcoded strings** for picklist values - Use constants or Custom Labels
- **All methods must be testable** - Avoid tight coupling, use dependency injection where needed
- **All public methods must have Apex doc comments** with `@description`, `@param`, `@return`
- **Maximum 1 trigger per object** - Delegate to handler class

---

## 3. Trigger Framework

### 3.1 Recommended Pattern: One Trigger Per Object

```apex
// PatientAccountTrigger.trigger
trigger PatientAccountTrigger on Account (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
) {
    new PatientAccountTriggerHandler().run();
}
```

### 3.2 Base Trigger Handler

```apex
public virtual class TriggerHandler {

    public void run() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) beforeInsert(Trigger.new);
            else if (Trigger.isUpdate) beforeUpdate(Trigger.new, Trigger.oldMap);
            else if (Trigger.isDelete) beforeDelete(Trigger.old);
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) afterInsert(Trigger.new);
            else if (Trigger.isUpdate) afterUpdate(Trigger.new, Trigger.oldMap);
            else if (Trigger.isDelete) afterDelete(Trigger.old);
            else if (Trigger.isUndelete) afterUndelete(Trigger.new);
        }
    }

    // Override in child classes
    protected virtual void beforeInsert(List<SObject> newRecords) {}
    protected virtual void beforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {}
    protected virtual void beforeDelete(List<SObject> oldRecords) {}
    protected virtual void afterInsert(List<SObject> newRecords) {}
    protected virtual void afterUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {}
    protected virtual void afterDelete(List<SObject> oldRecords) {}
    protected virtual void afterUndelete(List<SObject> newRecords) {}
}
```

### 3.3 Handler Implementation

```apex
public class PatientAccountTriggerHandler extends TriggerHandler {

    protected override void afterInsert(List<SObject> newRecords) {
        List<Account> patients = filterPatients((List<Account>) newRecords);
        if (!patients.isEmpty()) {
            CarePlanService.createDefaultPlans(patients);
            ConsentService.createDefaultConsent(patients);
        }
    }

    protected override void afterUpdate(
        List<SObject> newRecords,
        Map<Id, SObject> oldMap
    ) {
        List<Account> patients = filterPatients((List<Account>) newRecords);
        PatientChangeDetector.processChanges(patients, (Map<Id, Account>) oldMap);
    }

    private List<Account> filterPatients(List<Account> accounts) {
        List<Account> patients = new List<Account>();
        for (Account acc : accounts) {
            if (acc.RecordTypeId == PatientConstants.PATIENT_RECORD_TYPE_ID) {
                patients.add(acc);
            }
        }
        return patients;
    }
}
```

### 3.4 Trigger Bypass Mechanism

```apex
// Enable trigger bypass for data migrations or batch processing
public class TriggerControl {
    private static Set<String> disabledTriggers = new Set<String>();

    public static void disable(String triggerName) {
        disabledTriggers.add(triggerName);
    }

    public static void enable(String triggerName) {
        disabledTriggers.remove(triggerName);
    }

    public static Boolean isDisabled(String triggerName) {
        return disabledTriggers.contains(triggerName);
    }
}
```

---

## 4. Governor Limits & Bulk Patterns

### 4.1 Critical Governor Limits

| Limit | Synchronous | Asynchronous |
|---|---|---|
| SOQL Queries | 100 | 200 |
| SOQL Rows Retrieved | 50,000 | 50,000 |
| DML Statements | 150 | 150 |
| DML Rows | 10,000 | 10,000 |
| Callouts | 100 | 100 |
| CPU Time | 10,000 ms | 60,000 ms |
| Heap Size | 6 MB | 12 MB |
| Platform Events Published | 150 | 150 |

### 4.2 Bulkification Patterns

```apex
// BAD: SOQL in loop
for (CarePlan plan : plans) {
    List<CareTeamMember> members = [
        SELECT Id FROM CareTeamMember WHERE CarePlanId = :plan.Id
    ];
}

// GOOD: Query once, map by key
Map<Id, List<CareTeamMember>> membersByPlan = new Map<Id, List<CareTeamMember>>();
for (CareTeamMember member : [
    SELECT Id, CarePlanId FROM CareTeamMember
    WHERE CarePlanId IN :planIds
]) {
    if (!membersByPlan.containsKey(member.CarePlanId)) {
        membersByPlan.put(member.CarePlanId, new List<CareTeamMember>());
    }
    membersByPlan.get(member.CarePlanId).add(member);
}
```

### 4.3 Asynchronous Processing Guidelines

| Pattern | Use Case | Limits |
|---|---|---|
| **Future Methods** | Simple callouts from triggers | 50 per transaction, no chaining |
| **Queueable Apex** | Complex async with state, callouts | Chainable (depth 5 in prod), monitoring |
| **Batch Apex** | Processing >50K records | 5 concurrent batches, 200 records/execute |
| **Scheduled Apex** | Recurring jobs | 100 scheduled jobs, cron expression |
| **Platform Events** | Decoupled async, cross-transaction | 150 events/transaction, separate limits |

### 4.4 Health Cloud Specific Considerations

- Care plan creation with many goals/tasks can hit DML limits - batch process if creating plans for >50 patients at once
- FHIR API sync should use Queueable Apex for callout support
- Patient 360 FlexCards should avoid excessive DataRaptor calls - use caching

---

## 5. OmniStudio & FlexCards

### 5.1 FlexCard Best Practices

- **Keep FlexCards small** - Each compiled LWC cannot exceed 131,072 characters. Use child FlexCards for complex layouts.
- **Limit data sources per card** - Aim for 1-2 DataRaptors per FlexCard
- **Enable caching** for data that doesn't change frequently (provider directory, templates)
- **Use responsive design** - Enable the Responsive feature for mobile/tablet support
- **Test on target devices** - FlexCards render differently on desktop vs. mobile

### 5.2 DataRaptor Best Practices

- **Targeted extraction** - Only query the fields you need, not entire objects
- **Limit SObjects to 3 or fewer** per DataRaptor
- **Use indexed fields** for filtering and sorting
- **Use DataRaptor Turbo Extract** for large datasets to avoid governor limits
- **Implement caching** for frequently accessed, rarely changing data

### 5.3 OmniScript Best Practices

- **Modular design** - Break complex flows into reusable sub-OmniScripts
- **Conditional steps** - Show/hide steps based on user input to reduce complexity
- **Validation at each step** - Don't wait until the end to validate data
- **Prefill where possible** - Use DataRaptors to prepopulate patient context
- **Error handling** - Add try-catch in Integration Procedures called by OmniScripts

### 5.4 Integration Procedures

- Use Integration Procedures for server-side logic (not client-side DataRaptors)
- Chain multiple DataRaptors within a single Integration Procedure
- Handle errors gracefully with try-catch blocks
- Log failures via Platform Events for visibility

---

## 6. Lightning Web Components (LWC)

### 6.1 Component Architecture

- **Smart/Container components** - Handle data fetching, state management
- **Presentational/Child components** - Receive data via `@api` properties, emit events up
- **Shared utilities** - Create `c/utils` module for shared functions (error handling, formatting)

### 6.2 Error Handling

```javascript
// Shared error utility - import in all components
export function reduceErrors(errors) {
    if (!Array.isArray(errors)) errors = [errors];
    return errors
        .filter(e => !!e)
        .map(e => {
            if (Array.isArray(e.body)) return e.body.map(b => b.message);
            if (e.body && e.body.message) return e.body.message;
            if (typeof e.message === 'string') return e.message;
            return e.statusText || 'Unknown error';
        })
        .flat();
}
```

### 6.3 Wire vs. Imperative Apex

| Use Wire When | Use Imperative When |
|---|---|
| Data loads on component mount | User action triggers the call |
| Reactive to parameter changes | Need to control timing |
| Read-only data display | Write operations (create/update) |
| Caching is beneficial | Need fresh data every time |

### 6.4 Performance Best Practices

- **Lazy load** components not visible on initial render
- **Debounce** search inputs (300ms minimum)
- **Avoid deep component nesting** - Flatter hierarchies perform better
- **Use `@wire` with Lightning Data Service** for standard CRUD (automatic caching)
- **Limit DOM nodes** - Large patient lists should use pagination or virtual scrolling

### 6.5 Error Boundary Pattern

```javascript
// errorBoundary.js - wrap sections of UI to catch child errors
export default class ErrorBoundary extends LightningElement {
    error;
    stack;

    errorCallback(error, stack) {
        this.error = error;
        this.stack = stack;
    }
}
```

---

## 7. Error Logging Framework

### 7.1 Architecture Decision

**Recommended:** Use [Nebula Logger](https://github.com/jongpie/NebulaLogger) - an open-source, production-grade logging framework built natively on Salesforce.

**If third-party packages are not allowed:** Build a custom framework using Platform Events (see the separate ClickUp ticket [86d202qta](https://app.clickup.com/t/86d202qta) for full implementation details).

### 7.2 Key Principles

- **Always use Platform Events** for log persistence - direct DML to a logging object gets rolled back on transaction failure
- **Sanitise all payloads** - Never log PII/PHI (NRIC, patient names, clinical data) in error messages
- **Log at appropriate levels** - ERROR for failures, WARN for potential issues, INFO for key milestones, DEBUG for development
- **Include context** - Class name, method name, transaction ID, record ID, user ID
- **Implement log retention** - Auto-delete logs based on severity (ERROR: 90 days, DEBUG: 7 days)
- **Set up alerts** - Email notifications for error spikes, integration failures, batch job failures

### 7.3 Where to Log

| Context | When to Log |
|---|---|
| **Triggers** | Catch-all in handler, log DML failures from `Database.SaveResult` |
| **Batch Apex** | Log per-chunk failures in `execute()`, summary in `finish()` |
| **Queueable** | Wrap `execute()` in try-catch, log all exceptions |
| **Callouts** | Log HTTP 4xx/5xx responses, callout exceptions, timeouts |
| **LWC** | Log server-side in Apex controller; client-side show toast |
| **Flows** | Use Fault Connector to call Apex action for logging |

---

## 8. FHIR & EHR Integration

### 8.1 Integration Architecture

- Use **MuleSoft** or equivalent middleware as the integration layer between Health Cloud and EHR systems
- Never connect Health Cloud directly to EHR databases
- Use **FHIR R4** as the standard for all clinical data exchange
- Health Cloud's Clinical Data Model aligns with FHIR resources, minimising transformation

### 8.2 FHIR Resource Mapping

| FHIR Resource | Health Cloud Object | Sync Direction |
|---|---|---|
| Patient | Account (Person Account) | Bi-directional |
| Condition | HealthCondition | EHR → Health Cloud |
| MedicationStatement | MedicationStatement | EHR → Health Cloud |
| AllergyIntolerance | AllergyIntolerance | EHR → Health Cloud |
| Observation (vitals, labs) | ClinicalObservation | EHR → Health Cloud |
| ServiceRequest (orders) | Custom or standard | Health Cloud → EHR |
| DiagnosticReport | Custom | EHR → Health Cloud |
| Practitioner | Contact / Account | Bi-directional |

### 8.3 Integration Best Practices

- **Define source of truth** per data element - EHR for clinical data, Health Cloud for engagement data
- **Implement conflict resolution** - Last-write-wins with audit trail, or EHR-always-wins for clinical data
- **Use idempotent operations** - Handle duplicate messages gracefully
- **Implement retry logic** - Exponential backoff for transient failures (max 3 retries)
- **Log all integration events** - Success and failure, with request/response (sanitised)
- **Test with vendor sandboxes** - Use EHR vendor FHIR sandbox endpoints for testing
- **Monitor API limits** - Track callout consumption against daily limits (100K per 24h)
- **Batch where possible** - Use FHIR Bundle for bulk operations instead of individual calls

### 8.4 Error Handling for Integrations

```apex
public class FHIRIntegrationService {

    private static final Integer MAX_RETRIES = 3;
    private static final Integer TIMEOUT_MS = 30000;

    public static HttpResponse callFHIREndpoint(
        String endpoint, String method, String body
    ) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:FHIR_EHR/' + endpoint);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/fhir+json');
        req.setTimeout(TIMEOUT_MS);
        if (String.isNotBlank(body)) req.setBody(body);

        HttpResponse res;
        try {
            res = new Http().send(req);
            if (res.getStatusCode() >= 400) {
                ErrorLogger.logIntegrationError(
                    'FHIR-' + endpoint.split('/')[0],
                    'FHIRIntegrationService',
                    res.getStatusCode(),
                    body, res.getBody(),
                    'FHIR API error: ' + res.getStatus()
                );
            }
        } catch (CalloutException ex) {
            ErrorLogger.logIntegrationError(
                'FHIR-' + endpoint.split('/')[0],
                'FHIRIntegrationService',
                0, body, null, ex.getMessage()
            );
            throw ex;
        }
        return res;
    }
}
```

### 8.5 Data Transformation Rules

- **Normalise code systems** - Map between ICD-10, SNOMED CT, LOINC consistently
- **Handle optional FHIR extensions** - Use Health Cloud custom fields for non-standard data
- **Date/time handling** - FHIR uses ISO 8601; convert to Salesforce DateTime on ingest
- **Null handling** - FHIR resources may omit fields; don't overwrite existing data with nulls

---

## 9. Security & Compliance

### 9.1 HIPAA / PDPA Compliance Checklist

- [ ] **Business Associate Agreement (BAA)** with Salesforce executed (HIPAA requirement)
- [ ] **Salesforce Shield** enabled (Platform Encryption, Event Monitoring, Field Audit Trail)
- [ ] **Data residency** confirmed (Singapore region for PDPA, appropriate region for HIPAA)
- [ ] **Person Account NRIC masking** - Field-level security masks NRIC for non-clinical profiles
- [ ] **MFA enforced** for all users
- [ ] **Session timeout** configured (30 minutes for clinical users)
- [ ] **IP restrictions** for clinical data access
- [ ] **Consent management** configured with granular opt-in/out

### 9.2 Access Control Model

| Profile | Object Access | Field Access | Record Access |
|---|---|---|---|
| **System Admin** | Full CRUD | All fields | All records |
| **Clinician** | Read/Edit patients, care plans | All clinical fields | Assigned care team + facility |
| **Care Coordinator** | Read/Edit patients, care plans, tasks | All clinical fields | Assigned patients |
| **Admin Staff** | Read/Create patients | Demographics only, NRIC masked | Own facility |
| **Management** | Read patients, dashboards | Aggregate data, no NRIC | All facilities (read-only) |
| **Integration User** | API access per integration | Scoped per integration | API-accessible records only |

### 9.3 Field-Level Security Rules

- **Always encrypt at rest:** NRIC, clinical notes, diagnosis codes, insurance details
- **Mask for non-clinical:** NRIC shows `S****567A`, phone shows `****4567`
- **Audit trail on:** All patient demographic fields, consent changes, care plan modifications
- **No bulk export:** Alert if >100 records exported; restrict export permission to admins

### 9.4 Sharing Model

- **Organisation-Wide Default:** Private for Person Accounts (patients)
- **Sharing Rules:** Criteria-based sharing by facility, care team membership
- **Manual Sharing:** Care coordinators can share patient records with specialists
- **Apex Managed Sharing:** For complex scenarios (cross-facility referrals)

### 9.5 Consent Management

- Capture consent digitally at registration (OmniStudio form)
- Granular consent: treatment, research, marketing, SMS, email (separate checkboxes)
- Consent withdrawal triggers automated data restriction workflow
- All consent changes logged with timestamp, user, and method

---

## 10. Data Migration

### 10.1 Migration Strategy

| Phase | Objects | Priority | Volume | Timeline |
|---|---|---|---|---|
| **Phase 1: Foundation** | Patients, Providers, Facilities | High | 10K-100K+ | Week 1-2 |
| **Phase 2: Clinical** | Conditions, Medications, Allergies | High | 50K-500K+ | Week 2-3 |
| **Phase 3: Operational** | Care Plans, Tasks, Appointments | Medium | 5K-50K | Week 3-4 |
| **Phase 4: Historical** | Notes, Documents, Correspondence | Low | Variable | Week 4+ |

### 10.2 Data Quality Rules

- **Deduplication:** Run duplicate detection on NRIC + DOB + Name before migration
- **Validation:** 100% NRIC uniqueness, no orphan records, all lookups resolved
- **Transformation:** Standardise date formats, address formats, code systems
- **Enrichment:** Map legacy codes to ICD-10/SNOMED where possible

### 10.3 Migration Tools

| Tool | Use Case | Best For |
|---|---|---|
| **Data Loader** | Simple bulk loads | <500K records, straightforward mapping |
| **Salesforce CLI (sf data)** | Scripted, repeatable loads | CI/CD pipeline integration |
| **MuleSoft** | Complex transformations | Multi-source migration, ongoing sync |
| **Informatica** | Enterprise ETL | Very large volumes, complex logic |

### 10.4 Migration Best Practices

- **Always migrate in sandbox first** - Full Copy or Partial Copy sandbox
- **Use external IDs** for upsert operations to enable re-runnable migrations
- **Disable triggers** during bulk loads using the TriggerControl bypass mechanism
- **Disable validation rules** temporarily, then re-enable and validate
- **Generate audit reports** - Record counts pre/post migration, exception logs
- **Document rollback plan** - Tested and ready before production migration
- **Validate with clinical staff** - Sample records reviewed by clinicians for accuracy

---

## 11. Testing Strategy

### 11.1 Test Coverage Requirements

| Type | Coverage Target | Responsibility |
|---|---|---|
| **Unit Tests** | 90%+ code coverage, all positive/negative paths | Developers |
| **Integration Tests** | All FHIR endpoints, all integration flows | Integration team |
| **System Tests** | End-to-end clinical scenarios | QA team |
| **UAT** | All user stories verified by clinical staff | Clinical champions |
| **Performance Tests** | Page load <3s, API response <2s | QA + DevOps |
| **Security Tests** | Penetration test, access control validation | Security team |
| **Regression Tests** | Core workflows after each deployment | Automated + QA |

### 11.2 Apex Test Best Practices

```apex
@IsTest
private class CarePlanServiceTest {

    @TestSetup
    static void setupTestData() {
        // Create test data once, share across test methods
        Account patient = TestDataFactory.createPatient('Test Patient');
        insert patient;
    }

    @IsTest
    static void testCreateCarePlan_Success() {
        Account patient = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        CarePlan result = CarePlanService.createFromTemplate(
            patient.Id, TestDataFactory.CARDIAC_TEMPLATE_ID
        );
        Test.stopTest();

        System.assertNotEquals(null, result.Id, 'Care plan should be created');
        System.assertEquals('Draft', result.Status, 'Status should be Draft');
    }

    @IsTest
    static void testCreateCarePlan_InvalidPatient() {
        Test.startTest();
        try {
            CarePlanService.createFromTemplate(null, TestDataFactory.CARDIAC_TEMPLATE_ID);
            System.assert(false, 'Should have thrown exception');
        } catch (CarePlanService.CarePlanException ex) {
            System.assert(ex.getMessage().contains('Patient ID required'));
        }
        Test.stopTest();
    }
}
```

### 11.3 Test Data Factory Pattern

- Create a `TestDataFactory` class with methods for all standard test records
- Use `@TestSetup` to create shared test data once per class
- Never depend on existing org data in tests (`SeeAllData=false` always)
- Create minimum viable test data (don't over-create)

### 11.4 UAT with Clinical Staff

- **Scenario-based testing:** Walk through real patient journeys (registration → care plan → follow-up)
- **Role-based testing:** Each user profile tests their specific workflows
- **Data validation:** Clinical staff verify migrated data accuracy
- **Edge cases:** Test with complex patients (multiple conditions, cross-facility care)

---

## 12. Deployment & CI/CD

### 12.1 Environment Strategy

```
Developer Sandbox (per developer)
        ↓
Integration Sandbox (shared)
        ↓
QA / UAT Sandbox (Full Copy)
        ↓
Staging Sandbox (Full Copy)
        ↓
Production
```

### 12.2 CI/CD Best Practices

- Use **Salesforce CLI (sf)** for all deployments
- Automate with **GitHub Actions** or equivalent CI/CD tool
- Run all tests on every PR (unit + integration)
- Use **source format** (not metadata format) for version control
- Deploy via **unlocked packages** where feasible for modularity
- **Never deploy directly to production** - Always go through the pipeline

### 12.3 Deployment Checklist

- [ ] All unit tests pass (90%+ coverage)
- [ ] No hardcoded IDs or org-specific values
- [ ] All Custom Metadata / Custom Labels deployed
- [ ] Permission sets included in deployment
- [ ] Post-deployment steps documented (data loads, manual config)
- [ ] Rollback plan documented

### 12.4 Source Control Rules

- **Branch strategy:** `main` (production) → `develop` (integration) → `feature/*` (per story)
- **Commit messages:** Follow conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`)
- **PR reviews:** Minimum 1 reviewer, mandatory for Apex changes
- **No credentials in source:** Use Named Credentials for all external connections

---

## 13. Performance Optimisation

### 13.1 SOQL Optimisation

- **Always use selective queries** - Filter on indexed fields (Id, Name, CreatedDate, custom indexed fields)
- **Use LIMIT** where appropriate
- **Avoid SELECT *** - Only query fields you need
- **Use relationship queries** instead of separate queries for related data
- **Consider Skinny Tables** for frequently queried large objects (request from Salesforce Support)

### 13.2 Page Performance

| Target | Metric | How to Measure |
|---|---|---|
| Page load | < 3 seconds | Lightning Usage App, Chrome DevTools |
| FlexCard render | < 2 seconds | Browser performance profiling |
| API response | < 2 seconds | Integration monitoring |
| Report generation | < 10 seconds | Salesforce Report Performance |

### 13.3 Large Data Volume (LDV) Strategies

- **Index custom fields** used in WHERE clauses and lookups
- **Archive old records** - Move resolved care plans and old logs to archive objects
- **Use Skinny Tables** for patient search and list views
- **Batch process** data-intensive operations
- **Consider Big Objects** for storing high-volume historical data (telemetry, audit logs)

---

## 14. Ongoing Operations

### 14.1 Release Management

Salesforce delivers 3 major releases per year. Plan for each:

| Release | Month | Action |
|---|---|---|
| Spring | February | Review release notes by Jan 15, test in sandbox by Jan 30 |
| Summer | June | Review release notes by May 15, test in sandbox by May 30 |
| Winter | October | Review release notes by Sep 15, test in sandbox by Sep 30 |

### 14.2 Monitoring Checklist

- [ ] **Daily:** Check error log dashboard, integration success rates
- [ ] **Weekly:** Review batch job completions, scheduled job health
- [ ] **Monthly:** Analyse adoption metrics (DAU, feature usage), storage consumption
- [ ] **Quarterly:** Conduct optimisation review, update care plan templates, review security

### 14.3 Technical Debt Management

- Track technical debt in backlog with `tech-debt` tag
- Allocate 15-20% of each sprint to technical debt reduction
- Prioritise: security issues > performance > code quality > documentation

---

## Sources

- [Salesforce Health Cloud Implementation Guide - Oxrow](https://oxrow.com/salesforce-health-cloud-implementation-guide-2025/)
- [Health Cloud Object Reference - Salesforce Developers](https://developer.salesforce.com/docs/atlas.en-us.health_cloud_object_reference.meta/health_cloud_object_reference/hc_care_management_data_model.htm)
- [FHIR Mapping in Health Cloud - Salesforce Developers](https://developer.salesforce.com/docs/atlas.en-us.health_cloud_object_reference.meta/health_cloud_object_reference/map_fhir_overview.htm)
- [LWC Error Handling - Salesforce Developers Blog](https://developer.salesforce.com/blogs/2020/08/error-handling-best-practices-for-lightning-web-components)
- [Apex Triggers Best Practices - Trailhead](https://trailhead.salesforce.com/content/learn/modules/apex_triggers/apex_triggers_bulk)
- [OmniStudio Best Practices - Apex Hours](https://www.apexhours.com/omnistudio-best-practices/)
- [Governor Limits Guide 2025](https://medium.com/@dev-nkp/salesforce-governor-limits-2025-complete-guide-to-understanding-and-managing-platform-boundaries-b52f886dc995)
- [Nebula Logger - GitHub](https://github.com/jongpie/NebulaLogger)
- [Salesforce HIPAA Compliance Guide](https://www.flosum.com/blog/hipaa-compliance-on-salesforce-a-comprehensive-guide-for-enterprises)
- [Advanced Apex Error Handling - DevOps Launchpad](https://devopslaunchpad.com/blog/advanced-apex-error-handling/)
- [Health Cloud Best Practices - Medium](https://medium.com/@johnsonharry/salesforce-health-cloud-implementation-best-practices-4905c22b9225)
- [Salesforce Data Migration Best Practices](https://advancedcommunities.com/blog/salesforce-data-migration-best-practices-steps-stages/)
