# [US-1.1.3] Patient Timeline

- **Ticket**: https://app.clickup.com/t/86d1yxw5w
- **Branch**: clickup-86d1yxw5w
- **Epic**: 1.1 Patient 360 | Phase: 1 MVP
- **Depends On**: [US-1.1.1] Patient Profile Setup (86d1yxw5k) - COMPLETE

## Acceptance Criteria

- [ ] Shows consultations, referrals, lab results, care plan changes, communications
- [ ] Filterable by type (clinical, administrative, engagement)
- [ ] Each event shows date, provider, facility, summary
- [ ] Loads historical data from migration

## Org Analysis

### Available Timeline Data Sources

| Object | Category | Key Fields | Purpose |
|---|---|---|---|
| ClinicalEncounter | Clinical | PatientId, StartDate, EndDate, Status, Category, FacilityId | Consultations, admissions |
| HealthCondition | Clinical | PatientId, ProblemName, ConditionStatus, OnsetStartDateTime | Diagnoses |
| MedicationStatement | Clinical | PatientId, Status, MedicationId, StartDateTime | Medication changes |
| AllergyIntolerance | Clinical | PatientId, Severity, Status, OnsetStartDateTime | Allergy records |
| CarePlan | Clinical | AccountId, Status, StartDate, EndDate | Care plan changes |
| CarePlanActivity | Clinical | CarePlanId, Status, ActivityDate | Care plan tasks |
| CareObservation | Clinical | PatientId, ObservationName, ObservationValue | Lab results, vitals |
| CareRequest | Clinical | PatientId, Status, Priority | Referrals |
| DiagnosticSummary | Clinical | PatientId, Status | Diagnostic reports |
| PatientMedicalProcedure | Clinical | PatientId, Status | Procedures |
| ClinicalServiceRequest | Clinical | PatientId, Status | Service requests |
| Task | Administrative | WhoId/WhatId, Subject, Status, ActivityDate | Admin tasks |
| Event | Administrative | WhoId/WhatId, Subject, StartDateTime | Appointments |
| Case | Engagement | AccountId, Subject, Status, CreatedDate | Communications, cases |

### ClinicalEncounter Key Fields (Primary Timeline Object)
- PatientId (Account reference)
- StartDate, EndDate (DateTime)
- Status (Picklist)
- Category (Picklist)
- FacilityId (Healthcare Facility reference)
- ServiceType (Picklist)

## Architecture

```
patientTimeline (Smart/Container LWC)
  Apex Controller: PatientTimelineController.cls
    @AuraEnabled(cacheable=true) getTimelineEvents(accountId, filterType)
    Queries multiple objects, merges into unified TimelineEvent wrapper
    Sorted by date descending
  HTML: Vertical timeline layout with filter bar
  CSS: BEM, timeline connector lines, responsive
  Navigation: NavigationMixin for click-through to source records
```

### TimelineEvent Wrapper Design
```
TimelineEvent {
    Id recordId        -- Source record ID
    String objectType  -- 'ClinicalEncounter', 'HealthCondition', etc.
    String category    -- 'clinical', 'administrative', 'engagement'
    String title       -- Event title/summary
    String description -- Event details
    DateTime eventDate -- When it happened
    String provider    -- Provider name (if available)
    String facility    -- Facility name (if available)
    String status      -- Event status
    String iconName    -- SLDS icon for the event type
}
```

## Implementation Plan

### Phase 1: Ticket Setup
1. Create ticket directory and implementation.md

### Phase 2: Apex Controller (TDD)
1. Write failing tests for PatientTimelineController
2. Implement controller with TimelineEvent wrapper
3. Deploy and verify tests pass

### Phase 3: LWC Component
1. Create meta.xml (Record Page target)
2. Create JS (wire service, filtering, navigation)
3. Create HTML (timeline layout with filter bar)
4. Create CSS (BEM, timeline connectors, responsive)

### Phase 4: Deploy & Verify
1. Deploy LWC to org
2. Run all tests

### Phase 5: Documentation
1. Update implementation.md
2. Post ClickUp completion comment

## Progress Tracking

| Step | Status | Notes |
|---|---|---|
| Ticket directory created | Complete | |
| Org analysis | Complete | 14 timeline-relevant objects available |
| Failing tests written | Complete | 6 tests, ClinicalEncounter.Name not writable (auto-number), Category required, Case blocked by SDO flow |
| Apex controller implemented | Complete | 9 source objects, Comparable sort, LIMIT 50, WITH SECURITY_ENFORCED |
| Apex deployed & tests pass | Complete | 19/19 all tests pass (100%) |
| LWC component created | Complete | Filter bar, vertical timeline, BEM CSS, responsive |
| LWC deployed | Complete | |
| Documentation updated | Complete | |
