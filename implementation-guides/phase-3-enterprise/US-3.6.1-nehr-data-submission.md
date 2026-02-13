# US-3.6.1: NEHR Data Submission

> **Phase:** 3 - Enterprise | **Epic:** 3.6 - NEHR & Regulatory | **Estimate:** L (2+ weeks)

## Overview

Automatically submit required patient data to Singapore's National Electronic Health Records (NEHR) via FHIR R4. Includes patient opt-out checking, batch processing, audit logging, and reconciliation reporting.

**Business Value:** Ensures compliance with Singapore's upcoming Health Information Bill (HIB), which mandates data contribution to NEHR. Non-compliance carries significant regulatory penalties.

## Prerequisites

- US-2.2.1 (FHIR R4 Patient Sync) completed
- NEHR sandbox/test environment credentials obtained
- NEHR FHIR R4 conformance statement reviewed
- IHiS (Integrated Health Information Systems) onboarding completed

## Salesforce Configuration Steps

### Step 1: NEHR FHIR R4 Endpoint Configuration

1. Named Credential: `NEHR_FHIR_Endpoint`
2. Authentication: mTLS (mutual TLS with client certificate)
3. Base URL: NEHR FHIR R4 endpoint (provided by IHiS)
4. Test endpoint for sandbox validation

### Step 2: Data Mapping to NEHR FHIR Resources

| NEHR Requirement | FHIR Resource | HC Source |
|---|---|---|
| Patient demographics | Patient | Account (Person Account) |
| Diagnoses | Condition | HealthCondition |
| Medications | MedicationStatement | MedicationStatement |
| Allergies | AllergyIntolerance | AllergyIntolerance |
| Immunisations | Immunization | Immunization__c |
| Procedures | Procedure | ClinicalEncounter / Event |

**Singapore-Specific FHIR Extensions:**
- NRIC as identifier (system: `http://www.nric.gov.sg`)
- Singapore ethnicity codes
- Singapore facility identifiers (HCI codes)

### Step 3: Patient Opt-Out Check

**Before each submission:**
1. Query patient's NEHR consent status
2. If opted out → skip submission, log skip reason
3. If not opted out → proceed with submission
4. Opt-out status synced from NEHR registry (or captured in Health Cloud)

### Step 4: Batch Submission Process

**Scheduled Apex Batch: NEHRBatchSubmission**
- Runs: Daily at 2:00 AM SGT (off-peak)
- Scope: All patient records modified since last submission
- Batch size: 200 records per batch
- Process:
  1. Query modified records since last run
  2. Check opt-out status per patient
  3. Transform to FHIR Bundle
  4. Submit to NEHR endpoint
  5. Process response (success/failure per resource)
  6. Log results to NEHRSubmissionLog__c

### Step 5: Audit Logging

**Custom Object: NEHRSubmissionLog__c**

| Field | Type |
|---|---|
| Patient | Lookup(Account) |
| Submission Date | DateTime |
| Resource Type | Picklist(Patient, Condition, Medication, etc.) |
| FHIR Resource ID | Text |
| Status | Picklist(Success, Failed, Skipped) |
| Error Message | Long Text |
| Retry Count | Number |
| Batch Job ID | Text |

### Step 6: Reconciliation Report

**Weekly Report: NEHR Submission Reconciliation**
- Total records due for submission
- Successfully submitted
- Failed (with error breakdown)
- Skipped (opt-out)
- Retry queue count
- Compliance rate (% submitted vs required)

**Dashboard for compliance team:**
- Submission success rate trend
- Outstanding failures requiring manual intervention
- Opt-out rate
- Records pending retry

### Step 7: Error Handling & Retry

| Error | Action | Retry |
|---|---|---|
| Network failure | Queue for retry | Next batch run |
| FHIR validation error | Log detail, alert admin | Manual fix required |
| Patient not found in NEHR | Create new record | Automatic |
| Auth failure | Alert IT immediately | Manual |
| Rate limit exceeded | Throttle + queue | Next batch run |

Max retries: 3 per record. After 3 failures → route to manual review queue.

## Security & Access

- NEHR credentials stored in Named Credential (encrypted)
- mTLS certificate managed by IT security team
- Submission logs accessible to: Compliance team, System Admin
- Patient data encrypted in transit (TLS 1.2+)

## Testing Strategy

1. Submit test patient to NEHR sandbox → verify FHIR resource accepted
2. Patient with opt-out → verify skipped in log
3. Invalid FHIR resource → verify error logged with detail
4. Batch of 1000 records → verify all processed within SLA
5. Reconciliation report shows accurate counts
6. Network failure → verify retry on next batch run

## Deployment Checklist

- [ ] NEHR endpoint configured with mTLS
- [ ] FHIR resource mapping validated against NEHR conformance
- [ ] Opt-out check integrated
- [ ] NEHRBatchSubmission scheduled job deployed
- [ ] NEHRSubmissionLog__c deployed
- [ ] Reconciliation report and dashboard deployed
- [ ] Error handling and retry mechanism tested
- [ ] IHiS certification/validation completed
- [ ] Production connectivity test passed

## Dependencies

- **Blocked By:** US-2.2.1 (FHIR infrastructure), US-1.6.1 (Consent — opt-out)
- **Blocks:** US-3.6.2 (compliance framework builds on NEHR infrastructure)
