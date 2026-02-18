# [US-1.1.2] Patient 360 FlexCard (LWC)

- **Ticket**: https://app.clickup.com/t/86d1yxw5r
- **Branch**: clickup-86d1yxw5r
- **Epic**: 1.1 Patient 360 | Phase: 1 MVP
- **Depends On**: [US-1.1.1] Patient Profile Setup (86d1yxw5k) - COMPLETE

## Acceptance Criteria

- [x] FlexCard displays demographics, active conditions, current medications, allergies, and insurance at a glance
- [x] Clicking any section navigates to full detail record
- [x] Loads within 2 seconds (single Apex call with cacheable=true wire service)
- [x] Mobile-responsive for tablet use during consultations (CSS grid with @media breakpoint at 768px)

## Approach Decision

**OmniStudio FlexCards NOT installed in org** - Building as an LWC component instead.
This provides: no additional packages needed, full UI/UX control, easier maintenance.

## Org Analysis

### Available Data (from US-1.1.1)

| Object | Key Fields for Display |
|---|---|
| Account (PersonAccount) | FirstName, LastName, PersonBirthdate, PersonEmail, PersonMobilePhone, NRIC__c, Ethnicity__c, Emergency_Contact_Name__c, Emergency_Contact_Phone__c, Emergency_Contact_Relationship__c |
| HealthCondition | PatientId, ProblemName, ConditionStatus, Severity, OnsetStartDateTime |
| MedicationStatement | PatientId, Status, MedicationId, StartDateTime, EndDateTime |
| AllergyIntolerance | PatientId, Name, Type, Severity, Status, Category |
| MemberPlan | MemberId, Name, MemberNumber, Status, Medisave_Balance__c |

## Architecture

```
patient360View (Smart/Container LWC)
  Apex Controller: Patient360Controller.cls
    Single @AuraEnabled(cacheable=true) method: getPatient360Data(accountId)
    Returns wrapper with all 5 sections in one call
  HTML: Card-based layout with 5 sections
  CSS: BEM + SLDS grid, mobile-responsive
  Navigation: NavigationMixin for click-through to detail records
```

## Components Created

| Component | Path | Purpose |
|---|---|---|
| Patient360Controller.cls | classes/Patient360Controller.cls | Apex controller - single query method |
| Patient360ControllerTest.cls | classes/Patient360ControllerTest.cls | Apex test (3 tests) |
| patient360View LWC | lwc/patient360View/ | UI component (js, html, css, meta.xml) |

## Implementation Plan

### Phase 1: Ticket Setup
1. Create ticket directory and implementation.md

### Phase 2: Apex Controller (TDD)
1. Write failing test class (3 tests)
2. Implement controller with wrapper class
3. Deploy and verify tests pass

### Phase 3: LWC Component
1. Create meta.xml (Record Page target)
2. Create JS (wire service, navigation, error handling)
3. Create HTML (5-section card layout)
4. Create CSS (BEM, responsive)

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
| Failing tests written | Complete | 3 tests - TDD red phase confirmed |
| Apex controller implemented | Complete | Wrapper class + 5 SOQL queries with SECURITY_ENFORCED |
| Apex deployed & tests pass | Complete | 3/3 controller tests + 8 data model tests = 11/11 pass |
| LWC component created | Complete | 4 files: js, html, css, meta.xml |
| LWC deployed | Complete | All 12 tests pass (100%) |
| Documentation updated | Complete | |

## Test Results

```
Tests Ran:            12
Pass Rate:            100%
Test Run Id:          707Kh0000C4jBac
Test Execution Time:  12114 ms
```

## Key Decisions

1. **LWC over FlexCard**: OmniStudio not installed in org - built as LWC with equivalent functionality
2. **Single Apex call**: One controller method returns all 5 data sections to meet 2-second SLA
3. **Wire service with cacheable=true**: Reactive data loading with automatic Salesforce caching
4. **Medication reference**: MedicationStatement requires Medication parent record (discovered during TDD)
5. **BEM + SLDS**: CSS follows project CSS Architecture Guide conventions
6. **NavigationMixin**: Standard Salesforce navigation for click-through to detail records and related lists
