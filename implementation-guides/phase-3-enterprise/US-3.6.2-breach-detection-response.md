# US-3.6.2: Breach Detection & Response Workflow

> **Phase:** 3 - Enterprise | **Epic:** 3.6 - NEHR & Regulatory | **Estimate:** M (1-2 weeks)

## Overview

Implement an automated PDPA data breach assessment and notification workflow with a 3-day countdown timer, auto-generated notification templates, and a DPO (Data Protection Officer) dashboard.

**Business Value:** Ensures compliance with PDPA's mandatory 3-day breach notification requirement. Reduces breach response time, minimises regulatory penalties, and provides structured incident management.

## Prerequisites

- US-1.6.1 (Digital Consent Capture) completed
- US-1.6.2 (Role-Based Access Controls) completed
- PDPA breach response policy documented by legal/compliance
- DPO appointed and registered with PDPC

## Salesforce Configuration Steps

### Step 1: Create Breach Management Data Model

**Custom Object: DataBreach__c**

| Field | Type | Description |
|---|---|---|
| Incident Title | Text | Brief description |
| Detection Date | DateTime | When breach was detected |
| Notification Deadline | Formula(DateTime) | Detection Date + 3 calendar days |
| Countdown Days | Formula(Number) | Deadline - NOW() |
| Severity | Picklist(Low, Medium, High, Critical) | Based on scoring |
| Breach Type | Picklist(Unauthorised Access, Data Loss, Disclosure, Modification) | |
| Affected Records Count | Number | Estimated patient records affected |
| Data Types Affected | Multi-Select(NRIC, Medical Records, Financial, Contact Info) | |
| Status | Picklist | |
| DPO Assigned | Lookup(User) | |
| Root Cause | Long Text | |
| Remediation Plan | Long Text | |
| PDPC Notified | Checkbox | |
| PDPC Notification Date | DateTime | |
| Patients Notified | Checkbox | |
| Patient Notification Date | DateTime | |

**Status Flow:** Detected → Assessing → Containment → Notification → Remediation → Closed

### Step 2: Severity Scoring Algorithm

**OmniScript: BreachAssessment**

Scoring factors:
| Factor | Points |
|---|---|
| NRIC data exposed | +30 |
| Medical records exposed | +25 |
| Financial data exposed | +20 |
| > 500 records affected | +15 |
| > 100 records affected | +10 |
| External party involved | +20 |
| Data encrypted at rest | -15 |
| Breach contained within 1 hour | -10 |

| Total Score | Severity |
|---|---|
| 0-20 | Low |
| 21-40 | Medium |
| 41-60 | High |
| 61+ | Critical |

### Step 3: 3-Day Countdown Timer

**Automation:**
- On breach detection: calculate Notification Deadline (Detection Date + 3 days)
- Countdown displayed prominently on breach record
- Alerts:
  - 48 hours remaining → DPO reminded
  - 24 hours remaining → DPO + Legal alerted
  - 12 hours remaining → DPO + Legal + CEO alerted
  - Overdue → URGENT flag, executive escalation

### Step 4: Auto-Generated Notification Templates

**PDPC Notification Template:**
```
NOTIFICATION OF DATA BREACH TO PDPC

Organisation: {OrgName}
DPO: {DPOName}, {DPOEmail}
Date of Notification: {Today}

1. Date breach detected: {DetectionDate}
2. Nature of breach: {BreachType}
3. Number of affected individuals: {AffectedCount}
4. Types of personal data affected: {DataTypes}
5. Measures taken to contain breach: {ContainmentActions}
6. Steps taken to mitigate harm: {RemediationPlan}
7. Contact for affected individuals: {ContactDetails}
```

**Patient Notification Template:**
```
Dear {PatientName},

We are writing to inform you of a data incident at {OrgName} that may have affected your personal information.

What happened: {BriefDescription}
What data was affected: {DataTypes}
What we are doing: {RemediationSummary}
What you can do: {PatientActions}

If you have questions, please contact our DPO at {DPOContact}.
```

### Step 5: DPO Dashboard

| Widget | Data |
|---|---|
| Active Incidents | Count by severity |
| Countdown Timer | Critical incidents with time remaining |
| Breach History | Timeline of past breaches |
| Average Response Time | Detection → Notification |
| Consent Anomalies | Unusual consent pattern changes |
| Audit Log Alerts | Suspicious access patterns |

### Step 6: Incident Log & Remediation Tracking

**Related List: BreachAction__c**

| Field | Type |
|---|---|
| Breach | Master-Detail(DataBreach__c) |
| Action Description | Text |
| Assigned To | Lookup(User) |
| Due Date | Date |
| Status | Picklist(Pending, In Progress, Completed) |
| Completed Date | DateTime |

Track all remediation actions to completion for regulatory evidence.

## Testing Strategy

1. Report breach → assessment OmniScript calculates severity correctly
2. 3-day countdown starts → alerts fire at 48h, 24h, 12h
3. Generate PDPC notification → template populated correctly
4. Generate patient notification → personalised per patient
5. Complete remediation actions → breach status moves to Closed
6. DPO dashboard shows accurate active incident count

## Deployment Checklist

- [ ] DataBreach__c and BreachAction__c deployed
- [ ] BreachAssessment OmniScript deployed
- [ ] Severity scoring formula active
- [ ] 3-day countdown timer automation active
- [ ] Notification templates created and approved by legal
- [ ] DPO dashboard deployed
- [ ] Escalation alerts configured
- [ ] Tested end-to-end breach lifecycle

## Dependencies

- **Blocked By:** US-1.6.1, US-1.6.2 (consent and security framework)
- **Blocks:** None (caps the regulatory compliance capability)
