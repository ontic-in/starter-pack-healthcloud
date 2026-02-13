# US-3.1.2: Concurrent Review

> **Phase:** 3 - Enterprise | **Epic:** 3.1 - Utilisation Management | **Estimate:** M (1-2 weeks)

## Overview

Track inpatient stays with daily concurrent review checklists and length-of-stay (LOS) monitoring. Auto-alerts when LOS exceeds expected benchmarks, with discharge planning tasks auto-created at admission.

**Business Value:** Ensures appropriate resource utilisation, reduces unnecessary inpatient days by 10-15%, and supports quality of care through proactive discharge planning.

## Prerequisites

- US-3.1.1 (Prior Authorisation) completed
- LOS benchmark data available by diagnosis/procedure

## Salesforce Configuration Steps

### Step 1: Create Inpatient Tracking Model

**Custom Object: InpatientAdmission__c**

| Field | Type |
|---|---|
| Patient | Lookup(Account) |
| Admission Date | DateTime |
| Expected Discharge Date | DateTime |
| Actual Discharge Date | DateTime |
| Primary Diagnosis | Text (ICD-10) |
| Procedure | Text |
| Attending Physician | Lookup(Account) |
| Status | Picklist(Admitted, Under Review, Discharge Planned, Discharged) |
| LOS Days | Formula(Number): TODAY - Admission Date |
| Expected LOS | Number (from benchmark) |
| LOS Variance | Formula: LOS Days - Expected LOS |

### Step 2: Daily Review Checklist

**Custom Object: ConcurrentReview__c**
- Master-Detail to InpatientAdmission__c
- Fields: Review Date, Reviewer, Clinical Status, Continued Stay Justified (Checkbox), Clinical Notes, Next Review Action

**Daily Review Criteria:**
- Is continued inpatient stay clinically justified?
- Progress toward discharge criteria
- Outstanding tests/procedures
- Barriers to discharge

### Step 3: LOS Benchmark Configuration

**Custom Metadata: LOSBenchmark__mdt**

| Diagnosis Group | Expected LOS | Alert Threshold | Escalation Threshold |
|---|---|---|---|
| Cardiac surgery | 7 days | Day 6 | Day 9 |
| Hip replacement | 4 days | Day 4 | Day 6 |
| Pneumonia | 5 days | Day 5 | Day 7 |
| General surgery | 3 days | Day 3 | Day 5 |

### Step 4: Auto-Alerts

**Scheduled Flow: LOSMonitoring**
- Runs: Daily at 7:00 AM SGT
- Query: Active admissions where LOS Days > Alert Threshold
- Alert: UM nurse reviewer + attending physician
- Escalation: If LOS > Escalation Threshold → UM manager alert

### Step 5: Discharge Planning Tasks

**On Admission (auto-created):**
1. Complete admission assessment (Day 0)
2. Identify discharge criteria (Day 1)
3. Social work assessment if needed (Day 1)
4. Arrange post-discharge follow-up (Day before expected discharge)
5. Medication reconciliation (Day of discharge)

## Testing Strategy

1. Create admission → discharge planning tasks auto-created
2. Complete daily review checklist → logged correctly
3. LOS exceeds alert threshold → UM nurse alerted
4. LOS exceeds escalation threshold → UM manager alerted
5. Patient discharged → status updated, actual LOS calculated

## Deployment Checklist

- [ ] InpatientAdmission__c deployed
- [ ] ConcurrentReview__c deployed
- [ ] LOSBenchmark__mdt populated
- [ ] LOSMonitoring scheduled flow active
- [ ] Auto-discharge planning tasks flow active
- [ ] Dashboard for LOS monitoring deployed

## Dependencies

- **Blocked By:** US-3.1.1
- **Blocks:** US-3.4.3 (Readmission prediction uses discharge data)
