# [US-1.1.4] Patient Search & Duplicate Detection

- **Ticket**: https://app.clickup.com/t/86d1yxw61
- **Branch**: clickup-86d1yxw61
- **Epic**: 1.1 Patient 360 | Phase: 1 MVP
- **Depends On**: [US-1.1.1] Patient Profile Setup (86d1yxw5k) - COMPLETE

## Acceptance Criteria

- [x] NRIC search returns exact match
- [x] Name search returns fuzzy matches (via NameVariant__mdt Singapore transliterations)
- [x] Duplicate detection on NRIC + DOB + name (with confidence scoring)
- [x] Merge workflow for confirmed duplicates (multi-step wizard with audit logging)

## Approach Decision

**LWC + Apex over OmniStudio** - OmniStudio not installed in org (same as US-1.1.2).
Built custom search controller, duplicate detection service, and merge controller backed by two LWC components.

## Architecture

```
patientSearchDuplicates (LWC - App Page/Tab)
  PatientSearchController.cls (search + duplicate check)
    DuplicateDetectionService.cls (scoring, name variants via NameVariant__mdt)
  patientMergeWizard (child LWC - modal merge workflow)
    PatientMergeController.cls (merge preview + Database.merge + audit)
      MergeAuditLog__c (compliance audit trail)
```

## Components Created

| Component | Path | Purpose |
|---|---|---|
| MergeAuditLog__c | objects/MergeAuditLog__c/ | Audit trail for merge operations (5 files) |
| NameVariant__mdt | objects/NameVariant__mdt/ | Singapore name transliteration metadata (3 files) |
| 6 CMT records | customMetadata/NameVariant.*.md-meta.xml | Muhammad, Tan, Lee, Wong, Ng, Kumar variants |
| DuplicateDetectionService.cls | classes/ | Name variant lookup, match scoring, term expansion |
| DuplicateDetectionServiceTest.cls | classes/ | 9 test methods |
| PatientSearchController.cls | classes/ | Search by NRIC/Name/Phone, duplicate check |
| PatientSearchControllerTest.cls | classes/ | 12 test methods |
| PatientMergeController.cls | classes/ | Merge preview, execution, audit logging |
| PatientMergeControllerTest.cls | classes/ | 6 test methods |
| patientSearchDuplicates LWC | lwc/patientSearchDuplicates/ | Main search UI (4 files) |
| patientMergeWizard LWC | lwc/patientMergeWizard/ | Merge wizard modal (4 files) |

## Modified Components

| Component | Changes |
|---|---|
| TestDataFactory.cls | Added createPatientsForSearchTests(), createMergeAuditLog() |
| Patient_360_Access.permissionset-meta.xml | Added MergeAuditLog__c object + field permissions |

## Key Decisions

1. **LWC over OmniScript**: OmniStudio not installed - built as LWC with equivalent functionality
2. **SOQL over SOSL for search**: Deterministic results, no daily limits, explicit control over name variant matching
3. **NameVariant__mdt for name mappings**: Admin-configurable, no code change needed to add variants
4. **Confidence scoring**: NRIC=100%, Name+DOB=80%+, Name variant=75%, enables prioritized results
5. **Database.merge() for merge**: Native Salesforce merge handles child record reparenting
6. **MergeAuditLog__c for compliance**: Tracks all merge operations with master/duplicate/user/changes

## Progress Tracking

| Step | Status | Notes |
|---|---|---|
| Data model (MergeAuditLog__c) | Complete | Object + 4 custom fields |
| Custom metadata (NameVariant__mdt) | Complete | Type + 6 variant records |
| DuplicateDetectionService (TDD) | Complete | 9 test methods, name variant + scoring |
| PatientSearchController (TDD) | Complete | 12 test methods, 3 search types + duplicate check |
| PatientMergeController (TDD) | Complete | 6 test methods, preview + merge + audit |
| TestDataFactory updated | Complete | 2 new factory methods |
| patientSearchDuplicates LWC | Complete | Search bar + results + duplicate panel |
| patientMergeWizard LWC | Complete | 4-step modal wizard |
| Permission set updated | Complete | MergeAuditLog__c permissions |
| Documentation | Complete | |
