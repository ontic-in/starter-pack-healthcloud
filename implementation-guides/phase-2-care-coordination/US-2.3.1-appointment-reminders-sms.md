# US-2.3.1: Appointment Reminders (SMS)

> **Phase:** 2 - Care Coordination | **Epic:** 2.3 - Patient Engagement | **Estimate:** M (1-2 weeks)

## Overview

Send automated SMS appointment reminders to patients 2 days before and same-day morning. Patients can reply C (confirm) or R (reschedule). All responses are logged in Health Cloud.

**Business Value:** Reduces no-show rates by 40-50% (industry benchmark), recovers lost revenue from missed appointments, and improves patient compliance with care schedules.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- US-1.6.1 (Digital Consent Capture) completed — SMS consent required
- SMS gateway provisioned (Twilio, MessageBird, or local SG provider)

## Salesforce Configuration Steps

### Step 1: SMS Gateway Integration

Configure SMS provider via:
- **Option A:** Salesforce Marketing Cloud SMS
- **Option B:** Custom REST callout to Twilio/MessageBird
- Named Credential for authentication
- Singapore sender ID registration (SGNIC regulations)

### Step 2: Configure Reminder Schedule

**Scheduled Flow: AppointmentReminder**
- Runs: Daily at 6:00 AM SGT
- Query: Events where Date = TODAY + 2 OR Date = TODAY
- For each event:
  1. Check SMS consent via ConsentChecker utility
  2. If consented: send reminder
  3. If not consented: skip (log skip reason)

### Step 3: SMS Message Templates

**2-Day Reminder:**
```
Hi {FirstName}, reminder: You have an appointment on {Date} at {Time} with Dr {ProviderName} at {FacilityName}. Reply C to confirm or R to reschedule. - {ClinicName}
```

**Same-Day Reminder:**
```
Hi {FirstName}, your appointment is TODAY at {Time} with Dr {ProviderName} at {FacilityName}. See you soon! Reply C to confirm. - {ClinicName}
```

### Step 4: Response Handling

**Inbound SMS Handler (Apex):**
- Parse reply: C = Confirm, R = Reschedule
- C: Update Event status to Confirmed, log response
- R: Create reschedule task for admin staff, send acknowledgement SMS
- Other: Send "Sorry, please reply C or R" message

### Step 5: Logging & Reporting

- All SMS sent/received logged in Activity (Task) on patient record
- Dashboard: SMS sent, delivery rate, response rate, no-show rate comparison

## Testing Strategy

1. Schedule appointment for T+2 → verify SMS sent at 6 AM
2. Reply "C" → verify appointment confirmed
3. Reply "R" → verify reschedule task created
4. Patient without SMS consent → verify no SMS sent
5. Verify SMS delivery rate > 95%

## Deployment Checklist

- [ ] SMS gateway configured with Named Credential
- [ ] Singapore sender ID registered
- [ ] Reminder flow deployed and scheduled
- [ ] Message templates approved by compliance
- [ ] Inbound response handler deployed
- [ ] Consent checking integrated
- [ ] Reporting dashboard created

## Dependencies

- **Blocked By:** US-1.6.1 (Consent), US-1.1.1 (Patient data)
- **Blocks:** US-3.2.3 (No-Show Prediction uses reminder response data)
