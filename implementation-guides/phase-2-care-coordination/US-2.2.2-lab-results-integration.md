# US-2.2.2: Lab Results Integration

> **Phase:** 2 - Care Coordination | **Epic:** 2.2 - EHR Integration | **Estimate:** L (2+ weeks)

## Overview

Sync lab results from the hospital LIS (Laboratory Information System) into Health Cloud via FHIR R4 DiagnosticReport and Observation resources. Results appear on the Patient 360 timeline with abnormal flagging.

**Business Value:** Eliminates clinician context-switching between systems, enables automatic care plan goal updates from lab values, and reduces time to clinical action on abnormal results from hours to minutes.

## Prerequisites

- US-2.2.1 (FHIR R4 Patient Sync) completed
- US-1.2.4 (Goal Tracking) completed
- Hospital LIS FHIR R4 endpoints available

## Salesforce Configuration Steps

### Step 1: Configure FHIR Resource Mapping

**DiagnosticReport → Health Cloud:**

| FHIR Field | HC Object/Field | Notes |
|---|---|---|
| subject.reference | PatientId (Account) | Matched by NRIC |
| code.coding | Test Name / LOINC code | |
| effectiveDateTime | Report Date | |
| status | Report Status | Final, Preliminary |
| result[] | Observation records | Child resources |

**Observation → Health Cloud:**

| FHIR Field | HC Object/Field | Notes |
|---|---|---|
| code.coding | Test Component Name | |
| valueQuantity.value | Result Value | |
| valueQuantity.unit | Unit | |
| referenceRange | Reference Range | Normal bounds |
| interpretation | Abnormal Flag | H=High, L=Low, N=Normal |

### Step 2: Abnormal Result Flagging

**Logic:**
- Compare result value against reference range
- Flag: High (H), Low (L), Critical High (HH), Critical Low (LL)
- Visual: Red badge for Critical, Amber for High/Low, Green for Normal

### Step 3: Auto-Update Care Plan Goals

**Flow: LabResultToGoal**
- Trigger: New Observation synced
- Maps common labs to care plan goals:
  - HbA1c → Diabetes HbA1c goal
  - LDL Cholesterol → Cardiac/Diabetes LDL goal
  - Creatinine → Renal function monitoring
- Creates GoalMeasurement__c record with Source = "Lab Result"

### Step 4: Timeline Integration

Configure lab results as timeline events:
- Icon: Beaker (green normal, red abnormal)
- Display: Test name, key values, abnormal flags
- Click: Navigate to full DiagnosticReport record

## Testing Strategy

1. Submit FHIR DiagnosticReport → verify appears in Health Cloud
2. Abnormal HbA1c → verify red flag on timeline and goal updated
3. Normal CBC → verify green display, no alerts
4. Critical potassium → verify Critical alert to physician

## Deployment Checklist

- [ ] FHIR DiagnosticReport/Observation mapping configured
- [ ] MuleSoft flow for LIS integration deployed
- [ ] Abnormal flagging logic tested
- [ ] LabResultToGoal flow active
- [ ] Timeline event type configured
- [ ] End-to-end tested with sample lab data

## Dependencies

- **Blocked By:** US-2.2.1 (FHIR Patient Sync), US-1.2.4 (Goal Tracking)
- **Blocks:** US-2.2.3 (Clinical Orders — results flow back via this)
