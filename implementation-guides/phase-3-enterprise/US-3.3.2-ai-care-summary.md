# US-3.3.2: AI Care Summary Generation

> **Phase:** 3 - Enterprise | **Epic:** 3.3 - Agentforce AI | **Estimate:** M (1-2 weeks)

## Overview

Enable clinicians to generate an AI-powered care summary for a patient with one click before appointments. The summary includes recent changes, upcoming tasks, trend alerts, and outstanding items in a clinical, concise format.

**Business Value:** Reduces appointment prep time from 5 minutes to 30 seconds, ensures clinicians never miss critical patient updates, and improves consultation quality through comprehensive context.

## Prerequisites

- US-1.1.2 (Patient 360 FlexCard) completed
- US-1.2.4 (Goal Tracking) completed
- Agentforce or Einstein GPT licence provisioned

## Salesforce Configuration Steps

### Step 1: Configure AI Summary Action

**Agentforce Action: GenerateCareSummary**
- Input: PatientId
- Data Retrieved:
  - Recent HealthCondition changes (last 90 days)
  - Care Plan goal status changes
  - New GoalMeasurements (trends)
  - Overdue tasks
  - Recent referrals
  - Recent lab results with abnormal flags
  - Upcoming scheduled tasks/appointments
  - SDOH risk factors

### Step 2: Prompt Engineering

**System Prompt:**
```
You are a clinical decision support tool. Generate a concise care summary for a clinician reviewing a patient before an appointment.

Rules:
- Clinical tone: factual, concise, actionable
- Highlight CHANGES since last visit (not static information)
- Flag any ABNORMAL results or OFF-TRACK goals
- List OUTSTANDING items requiring clinician attention
- Maximum 200 words
- Use bullet points
- Do NOT include patient identifiers beyond first name
```

**Output Format:**
```
CARE SUMMARY — {Patient First Name} | {Date}

SINCE LAST VISIT ({Last Visit Date}):
• HbA1c increased from 6.8% to 7.2% (Off Track)
• BP readings stable at 135/82 (On Track)
• New medication: Metformin 500mg BD started 15 Jan

ATTENTION NEEDED:
• Overdue: Foot examination (due 3 weeks ago)
• Pending: Cardiology referral response
• Lab: LDL 3.1 mmol/L — above target of 2.6

UPCOMING:
• Eye screening due in 2 weeks
• HbA1c retest due in 4 weeks
```

### Step 3: Add to Patient 360

**Quick Action Button:** "Generate Summary" on Patient 360 FlexCard
- One-click generation
- Summary displayed in modal
- Actions: Save to record, Copy to clipboard, Edit before saving
- Saved summaries attached to patient record as note

### Step 4: Audit Trail

- All AI-generated summaries logged with:
  - Generation timestamp
  - Model version used
  - Whether clinician edited before saving
  - Source data references

### Step 5: Feedback Loop

- Clinician can rate summary (Helpful / Not Helpful)
- Feedback used to improve prompt and data selection
- Monthly review of summary quality metrics

## Testing Strategy

1. Generate summary for patient with multiple changes → captures all key changes
2. Patient with no changes → summary says "No significant changes since last visit"
3. Save summary → attached to patient record with audit trail
4. Edit summary before saving → edit tracked in audit
5. Generate for patient with abnormal labs → highlighted in summary

## Deployment Checklist

- [ ] Agentforce/Einstein GPT configured
- [ ] Data retrieval actions configured
- [ ] Prompt optimised and clinician-approved
- [ ] Quick Action on Patient 360
- [ ] Save/edit workflow implemented
- [ ] Audit trail active
- [ ] Feedback mechanism deployed

## Dependencies

- **Blocked By:** US-1.1.2, US-1.2.4, Agentforce licence
- **Blocks:** None (enhancement to clinician workflow)
