# US-2.1.2: Care Plan Escalation Rules

> **Phase:** 2 - Care Coordination | **Epic:** 2.1 - Advanced Care Plans | **Estimate:** M (1-2 weeks)

## Overview

Configure automatic alerts when patient care plan metrics go off track, with a configurable escalation chain from care coordinator to primary physician to specialist.

**Business Value:** Enables early intervention before conditions worsen, reducing emergency visits by 15-25%. Ensures no at-risk patient falls through the cracks with automated escalation.

## Prerequisites

- US-1.2.4 (Goal Tracking) completed
- US-1.2.3 (Care Team Assignment) completed
- US-2.1.1 (Clinical Protocol Pathways) completed or parallel

## Salesforce Configuration Steps

### Step 1: Configure Escalation Thresholds

**Custom Object: EscalationRule__c**

| Field | API Name | Type |
|---|---|---|
| Care Plan Goal | `Care_Plan_Goal__c` | Lookup(CarePlanGoal) |
| Metric | `Metric__c` | Picklist(HbA1c, BP Systolic, BP Diastolic, LDL, BMI, etc.) |
| Warning Threshold | `Warning_Threshold__c` | Number |
| Critical Threshold | `Critical_Threshold__c` | Number |
| Operator | `Operator__c` | Picklist(Greater Than, Less Than) |
| Level 1 Role | `Level1_Role__c` | Picklist (Care Coordinator) |
| Level 2 Role | `Level2_Role__c` | Picklist (Primary Physician) |
| Level 3 Role | `Level3_Role__c` | Picklist (Specialist) |
| Level 1 Delay | `Level1_Delay_Hours__c` | Number (0 = immediate) |
| Level 2 Delay | `Level2_Delay_Hours__c` | Number (24 = next day) |
| Level 3 Delay | `Level3_Delay_Hours__c` | Number (72 = 3 days) |

### Step 2: Implement Escalation Engine

**Record-Triggered Flow: EvaluateEscalation**
- Trigger: GoalMeasurement__c created or updated
- Logic:
  1. Get active EscalationRule__c for the goal's metric
  2. Compare measurement value against thresholds
  3. If Warning threshold breached → Level 1 alert
  4. If Critical threshold breached → Level 1 + Level 2 alert
  5. Create EscalationEvent__c record for tracking

**Scheduled Flow: EscalationFollow up**
- Runs: Every 4 hours
- Checks: Open escalations not acknowledged within delay period
- Action: Promote to next level in chain

### Step 3: Configure Alert Delivery

| Level | Channel | Template |
|---|---|---|
| Level 1 (Coordinator) | In-App + Email | "Patient {Name} - {Metric} at {Value} (threshold: {Threshold})" |
| Level 2 (Physician) | In-App + Email + SMS | "ESCALATION: Patient {Name} requires physician review - {Metric} at {Value}" |
| Level 3 (Specialist) | In-App + Email + SMS + Phone Task | "URGENT ESCALATION: Patient {Name} - specialist review needed" |

### Step 4: Create Escalation History

**Custom Object: EscalationEvent__c**

| Field | Type | Description |
|---|---|---|
| Patient | Lookup(Account) | |
| Care Plan Goal | Lookup(CarePlanGoal) | |
| Trigger Value | Number | Value that triggered escalation |
| Threshold Breached | Text | Warning or Critical |
| Current Level | Number | 1, 2, or 3 |
| Acknowledged | Checkbox | Team member acknowledged |
| Acknowledged By | Lookup(User) | |
| Acknowledged Date | DateTime | |
| Resolution Notes | Long Text | |

### Step 5: Configure Escalation Dashboard

- Open escalations by level (pie chart)
- Average time to acknowledge per level
- Most escalated patients (intervention priority list)
- Escalation trends over time

## Testing Strategy

1. Record BP of 165/95 → verify Level 1 alert to coordinator
2. No acknowledgement in 24h → verify Level 2 to physician
3. No acknowledgement in 72h → verify Level 3 to specialist
4. Acknowledge escalation → verify chain stops
5. Escalation history shows complete audit trail

## Deployment Checklist

- [ ] EscalationRule__c and EscalationEvent__c deployed
- [ ] Default rules created for common metrics (HbA1c, BP, LDL)
- [ ] EvaluateEscalation flow active
- [ ] EscalationFollowUp scheduled flow active
- [ ] Notification templates configured
- [ ] Escalation dashboard deployed

## Dependencies

- **Blocked By:** US-1.2.4, US-1.2.3, US-2.1.1
- **Blocks:** None (enhances existing care management)
