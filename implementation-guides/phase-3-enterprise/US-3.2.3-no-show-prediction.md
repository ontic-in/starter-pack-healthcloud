# US-3.2.3: No-Show Prediction & Prevention

> **Phase:** 3 - Enterprise | **Epic:** 3.2 - Multi-Channel Engagement | **Estimate:** M (1-2 weeks)

## Overview

Use AI to predict which patients are likely to no-show for appointments and proactively intervene based on risk level. Includes waitlist management to fill cancelled slots.

**Business Value:** Reduces no-show rates from 15-20% to <8%, recovers $500K-$1M annually in lost revenue for a mid-size clinic network, and improves appointment access for all patients.

## Prerequisites

- US-2.3.1 (Appointment Reminders) completed
- 12+ months of historical appointment data (for model training)
- Einstein Prediction Builder or Data Cloud AI licence

## Salesforce Configuration Steps

### Step 1: Build Prediction Model

**Features for No-Show Prediction:**

| Feature | Source | Weight |
|---|---|---|
| Historical no-show count | Event history | High |
| Days since booking | Event | Medium |
| Appointment type | Event | Medium |
| Day of week | Event | Low |
| Time of day | Event | Low |
| Distance from clinic | Patient address | Medium |
| SMS reminder response | US-2.3.1 data | High |
| Age | Patient DOB | Low |
| Chronic condition count | HealthCondition | Medium |
| Last visit date | Event history | Medium |

**Model:** Einstein Prediction Builder or custom ML model in Data Cloud

### Step 2: Risk Score Assignment

| Score | Risk Level | Intervention |
|---|---|---|
| 0-40 | Low | Standard reminders only |
| 40-70 | Medium | Extra SMS reminder (day before) |
| 70-100 | High | Personal call from coordinator |

### Step 3: Intervention Workflow

**Scheduled Flow: NoShowIntervention**
- Runs: Daily at 8:00 AM SGT for T+2 appointments
- Query appointments → calculate/retrieve risk scores
- For each appointment:
  - High risk → create task for coordinator: "Call {Patient} to confirm appointment on {Date}"
  - Medium risk → queue extra SMS reminder
  - Low risk → standard reminder flow

### Step 4: Waitlist Management

**Custom Object: AppointmentWaitlist__c**

| Field | Type |
|---|---|
| Patient | Lookup(Account) |
| Preferred Provider | Lookup(Account) |
| Preferred Date Range | Date Range |
| Urgency | Picklist |
| Status | Picklist(Waiting, Offered, Booked, Expired) |

**When slot opens (cancellation or predicted no-show confirmed):**
1. Query waitlist for matching criteria
2. Auto-send SMS/WhatsApp: "A slot is available on {Date} at {Time}. Reply Y to book."
3. First response books the slot
4. Timeout after 2 hours → offer to next person

### Step 5: Tracking Dashboard

- Prediction accuracy: predicted no-shows vs actual
- No-show rate trend (monthly, with/without intervention)
- Intervention success rate
- Waitlist fill rate
- Revenue recovered through filled slots

## Testing Strategy

1. Patient with 5 historical no-shows → scores High risk
2. High risk patient → coordinator receives call task
3. Appointment cancelled → waitlist patients notified
4. Waitlist patient replies Y → slot booked automatically
5. Dashboard shows accurate prediction vs actual rates

## Deployment Checklist

- [ ] Prediction model trained and deployed
- [ ] Risk score visible on appointment records
- [ ] NoShowIntervention scheduled flow active
- [ ] AppointmentWaitlist__c deployed
- [ ] Waitlist auto-fill automation active
- [ ] Dashboard with accuracy tracking deployed

## Dependencies

- **Blocked By:** US-2.3.1 (reminder data), historical appointment data
- **Blocks:** None (enhances engagement capabilities)
