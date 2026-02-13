# US-3.4.3: Predictive Readmission Model

> **Phase:** 3 - Enterprise | **Epic:** 3.4 - Data Cloud & Analytics | **Estimate:** L (2+ weeks)

## Overview

Predict which discharged patients are at high risk of readmission within 30 days. High-risk patients are auto-enrolled in a post-discharge follow-up programme. Target: reduce cardiac readmission from 18% to <12%.

**Business Value:** Reduces readmission penalties, improves patient outcomes, and saves $2,000-$5,000 per avoided readmission. A 6% reduction in cardiac readmissions saves $300K+ annually.

## Prerequisites

- US-3.4.1 (Unified Patient Profile) completed
- US-3.1.2 (Concurrent Review — discharge data)
- 24+ months of discharge and readmission data

## Salesforce Configuration Steps

### Step 1: Define Readmission Features

| Feature | Source |
|---|---|
| Primary diagnosis (ICD-10) | InpatientAdmission__c |
| Length of stay | InpatientAdmission__c |
| Age | Account |
| Number of comorbidities | HealthCondition |
| Prior admissions (12 months) | InpatientAdmission__c |
| SDOH risk score | SDOHAssessment__c |
| Medication count at discharge | MedicationStatement |
| Lives alone | SDOHAssessment__c |
| Discharge to home vs facility | InpatientAdmission__c |
| Post-discharge follow-up scheduled | Event |

### Step 2: Build Prediction Model

- **Platform:** Data Cloud + Einstein AI
- **Type:** Binary classification (readmit within 30 days: yes/no)
- **Output:** Readmission probability 0-100%
- **Scoring trigger:** On discharge (InpatientAdmission__c status → Discharged)

### Step 3: Post-Discharge Follow-Up Programme

**Auto-enrollment for high-risk patients (score > 60%):**

| Day | Action |
|---|---|
| Day 0 (Discharge) | Score calculated, high-risk flagged |
| Day 1 | Phone call from care coordinator |
| Day 3 | Medication reconciliation check |
| Day 7 | Symptom assessment (phone/portal) |
| Day 14 | Follow-up appointment (auto-scheduled) |
| Day 21 | Coordinator check-in |
| Day 30 | Programme completion assessment |

**Automated via Flow:** Auto-create tasks and appointments on discharge for high-risk patients.

### Step 4: Care Coordinator Worklist

**Daily Worklist: Post-Discharge Follow-Up**
- Filter: Recently discharged + readmission score > 60%
- Columns: Patient, Discharge Date, Score, Next Action, Days Since Discharge
- Urgent flag if patient misses scheduled follow-up

### Step 5: Outcome Tracking

**Custom Object: ReadmissionTracking__c**

| Field | Type |
|---|---|
| Patient | Lookup(Account) |
| Discharge Date | Date |
| Readmission Predicted | Checkbox |
| Prediction Score | Number |
| Actually Readmitted | Checkbox |
| Readmission Date | Date |
| Days to Readmission | Formula |
| Follow-Up Completed | Checkbox |

**Dashboard:**
- Predicted vs actual readmission rates
- Model accuracy (sensitivity, specificity)
- Readmission rate trend (monthly)
- Target tracking: 18% → <12% for cardiac

## Testing Strategy

1. Patient discharged with high comorbidity + prior readmission → scores High
2. High-risk patient → auto-enrolled in follow-up programme
3. Day 1 call task auto-created → coordinator completes
4. Patient readmitted → tracked against prediction
5. Dashboard shows predicted vs actual accurately

## Deployment Checklist

- [ ] Prediction model trained (AUC > 0.70)
- [ ] Scoring triggers on discharge
- [ ] Follow-up programme auto-enrollment active
- [ ] Coordinator worklist configured
- [ ] ReadmissionTracking__c deployed
- [ ] Outcome tracking dashboard deployed
- [ ] Baseline readmission rate documented

## Dependencies

- **Blocked By:** US-3.4.1, US-3.1.2
- **Blocks:** None (validates entire enterprise analytics capability)
