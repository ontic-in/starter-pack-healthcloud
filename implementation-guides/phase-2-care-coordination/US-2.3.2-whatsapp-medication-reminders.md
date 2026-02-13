# US-2.3.2: WhatsApp Medication Reminders

> **Phase:** 2 - Care Coordination | **Epic:** 2.3 - Patient Engagement | **Estimate:** M (1-2 weeks)

## Overview

Send daily WhatsApp reminders to chronic medication patients listing their current medications. Non-acknowledgement for 3+ days triggers a care coordinator follow-up task.

**Business Value:** Improves medication adherence by 25-35%, particularly important for Singapore's ageing population managing multiple chronic conditions. WhatsApp has 80%+ penetration in Singapore.

## Prerequisites

- US-1.1.1 (Patient Profile) completed
- US-1.6.1 (Consent) completed — separate WhatsApp opt-in
- WhatsApp Business API account provisioned (Meta Business verification)

## Salesforce Configuration Steps

### Step 1: WhatsApp Business API Setup

1. Register WhatsApp Business Account through Meta Business Manager
2. Verify business identity
3. Create message templates (must be pre-approved by Meta)
4. Configure webhook for inbound messages
5. Named Credential for API authentication

### Step 2: Message Template (Meta-approved)

```
Hi {{1}}, here's your daily medication reminder:

{{2}}

Please take your medications as prescribed. Tap ✓ to confirm you've taken them today.

If you have questions, contact your care team at {{3}}.
```

Variables: {1}=Name, {2}=Medication list, {3}=Clinic phone

### Step 3: Daily Reminder Flow

**Scheduled Flow: MedicationReminder**
- Runs: Daily at 8:00 AM SGT (configurable per patient)
- Query: Patients with active MedicationStatements AND WhatsApp consent
- For each patient:
  1. Build medication list from active MedicationStatement records
  2. Format: "- {DrugName} {Dosage} ({Frequency})"
  3. Send via WhatsApp Business API
  4. Log as Activity on patient record

### Step 4: Acknowledgement Tracking

**Custom Object: MedicationAdherence__c**

| Field | Type |
|---|---|
| Patient | Lookup(Account) |
| Date | Date |
| Reminder Sent | Checkbox |
| Acknowledged | Checkbox |
| Acknowledged Time | DateTime |
| Days Without Ack | Formula(Number) |

**Inbound WhatsApp Handler:**
- Patient taps "✓" → mark today's adherence as acknowledged
- Store acknowledgement timestamp

### Step 5: Non-Adherence Escalation

**Scheduled Flow: AdherenceCheck**
- Runs: Daily at 12:00 PM SGT
- Query: Patients with 3+ consecutive days without acknowledgement
- Action: Create care coordinator task with priority High
  - "Patient {Name} has not acknowledged medication reminders for {X} days. Please follow up."

## Testing Strategy

1. Patient with active medications and WhatsApp consent → receives daily reminder
2. Patient acknowledges → adherence record updated
3. No acknowledgement for 3 days → coordinator task created
4. Patient without WhatsApp consent → no message sent
5. Medication changed → next day reminder reflects new list

## Deployment Checklist

- [ ] WhatsApp Business API configured
- [ ] Message template approved by Meta
- [ ] MedicationReminder scheduled flow active
- [ ] MedicationAdherence__c object deployed
- [ ] Inbound acknowledgement handler active
- [ ] AdherenceCheck escalation flow active
- [ ] WhatsApp consent integrated with US-1.6.1

## Dependencies

- **Blocked By:** US-1.6.1 (WhatsApp consent), US-1.1.1 (Medication data)
- **Blocks:** US-3.4.2 (Adherence data feeds AI risk stratification)
