# [US-1.3.2] Internal Referral Workflow - Implementation

## Ticket
- **ID:** 86d1yxz6w
- **Title:** [US-1.3.2] Internal Referral Workflow
- **Epic:** 1.3 Provider Management | Phase: 1 MVP
- **Branch:** clickup-86d1yxz6w

## Architecture

```
referralWizard (LWC)
    └── ReferralController (thin @AuraEnabled)
            └── ReferralService (business logic)
                    ├── ClinicalServiceRequest (HC standard object)
                    ├── HealthcareProvider (provider selection)
                    ├── PatientContext (auto-populated)
                    └── Messaging.CustomNotification (bell notification)

PatientTimelineController
    └── getClinicalServiceRequests() → timeline integration
```

## Architecture Decisions
- **LWC wizard** over OmniStudio (consistent with existing LWC patterns)
- **ClinicalServiceRequest** over custom Referral__c (FHIR-aligned, uses standard fields)
- **Self-contained provider search** (not dependent on US-1.3.1 ProviderDirectoryService)

## Data Model

### ClinicalServiceRequest Custom Fields
| Field | Type | Purpose |
|-------|------|---------|
| Referral_Reason__c | LongTextArea(32768) | Clinical reason |
| Referral_Notes__c | LongTextArea(32768) | Additional notes |
| Referred_To_Provider__c | Lookup(HealthcareProvider) | Receiving provider |
| Specialty_Requested__c | Text(255) | Specialty label |

### Standard Fields Used
- PatientId, Status, Priority, RequesterId, AuthoredOn, Intent

## Acceptance Criteria

- [x] Guided LWC wizard for referral creation (4-step flow)
- [x] Auto-populates patient demographics, conditions, medications, allergies
- [x] Clinician adds referral reason and urgency (priority)
- [x] Receiving provider gets bell notification
- [x] Referral tracked on patient timeline (PatientTimelineController integration)

## File List

### New Files (16)
| File | Lines | Purpose |
|------|-------|---------|
| objects/ClinicalServiceRequest/fields/Referral_Reason__c.field-meta.xml | 12 | Custom field |
| objects/ClinicalServiceRequest/fields/Referral_Notes__c.field-meta.xml | 12 | Custom field |
| objects/ClinicalServiceRequest/fields/Referred_To_Provider__c.field-meta.xml | 14 | Custom field |
| objects/ClinicalServiceRequest/fields/Specialty_Requested__c.field-meta.xml | 11 | Custom field |
| objects/HealthcareProvider/fields/Is_Accepting_Patients__c.field-meta.xml | 8 | Custom field |
| notificationtypes/Referral_Notification.notiftype-meta.xml | 8 | Notification type |
| classes/ReferralService.cls | ~440 | Business logic |
| classes/ReferralService.cls-meta.xml | 5 | Meta |
| classes/ReferralController.cls | ~85 | Thin controller |
| classes/ReferralController.cls-meta.xml | 5 | Meta |
| lwc/referralWizard/referralWizard.js | ~310 | Wizard JS |
| lwc/referralWizard/referralWizard.html | ~270 | Wizard HTML |
| lwc/referralWizard/referralWizard.css | ~105 | Wizard CSS |
| lwc/referralWizard/referralWizard.js-meta.xml | 16 | LWC meta |
| permissionsets/Internal_Referral_Access.permissionset-meta.xml | ~90 | Permission set |
| classes/ReferralServiceTest.cls | ~230 | 10 test methods |
| classes/ReferralServiceTest.cls-meta.xml | 5 | Meta |
| classes/ReferralControllerTest.cls | ~145 | 6 test methods |
| classes/ReferralControllerTest.cls-meta.xml | 5 | Meta |

### Modified Files (3)
| File | Changes |
|------|---------|
| classes/PatientTimelineController.cls | +getClinicalServiceRequests() method, +call in clinical block |
| classes/PatientTimelineControllerTest.cls | +referral test data setup, +2 test methods |
| classes/TestDataFactory.cls | +createClinicalServiceRequest() factory |

## Test Coverage

### ReferralServiceTest (10 tests)
- testGetPatientContext_Success
- testGetPatientContext_NotFound
- testSearchProviders_ByName
- testSearchProviders_BySpecialty
- testSearchProviders_NoResults
- testGetSpecialtyOptions
- testCreateReferral_Success
- testCreateReferral_MissingReason
- testCreateReferral_MissingProvider
- testSearchProviders_EmptySearch

### ReferralControllerTest (6 tests)
- testGetPatientContext_Success
- testSearchProviders_Success
- testGetSpecialtyOptions_Success
- testSubmitReferral_Success
- testSubmitReferral_MalformedJson
- testSubmitReferral_MissingFields

### PatientTimelineControllerTest (+2 tests)
- testGetTimelineEventsIncludesReferrals
- testGetTimelineEventsReferralDetails

## Deployment Notes
```bash
sf project deploy start --source-dir force-app/ --target-org <org-alias>
```

### Post-Deployment
1. Assign `Internal_Referral_Access` permission set to clinician users
2. Add `referralWizard` LWC to Patient record page via Lightning App Builder
3. Verify `Referral_Notification` custom notification type is active
