# US-3.3.1: AI-Powered Patient Scheduling Agent

> **Phase:** 3 - Enterprise | **Epic:** 3.3 - Agentforce AI | **Estimate:** M (1-2 weeks)

## Overview

Deploy an Agentforce AI agent that enables patients to book, reschedule, or cancel appointments through natural language conversation. The agent checks provider availability, respects patient preferences, and confirms via SMS/WhatsApp.

**Business Value:** Eliminates phone-based scheduling (reduces call centre volume by 30-40%), available 24/7, and improves patient satisfaction with instant self-service booking.

## Prerequisites

- US-3.2.2 (Chatbot) completed
- US-1.3.1 (Provider Directory with availability)
- Agentforce licence provisioned

## Salesforce Configuration Steps

### Step 1: Configure Agentforce Agent

**Agent Name:** Patient Scheduling Assistant
**Channel:** Web Chat, Mobile App, WhatsApp

**Topics:**
1. Book Appointment
2. Reschedule Appointment
3. Cancel Appointment
4. Check Availability

### Step 2: Define Agent Actions

**Action: SearchAvailability**
- Inputs: Specialty (or Provider name), Preferred date range, Time preference
- Queries: Provider availability calendar
- Returns: List of available slots

**Action: BookAppointment**
- Inputs: PatientId, ProviderId, DateTime
- Creates: Event record in Salesforce
- Sends: Confirmation SMS/WhatsApp
- Updates: Provider availability

**Action: RescheduleAppointment**
- Inputs: Existing EventId, New DateTime
- Updates: Event record
- Captures: Reschedule reason
- Sends: Updated confirmation

**Action: CancelAppointment**
- Inputs: EventId
- Updates: Event status to Cancelled
- Captures: Cancellation reason
- Triggers: Waitlist notification (US-3.2.3)

### Step 3: Conversation Design

```
Patient: "I need to see a cardiologist next week"
Agent: "I found 3 available slots with cardiologists next week:
       1. Dr Tan, Mon 10 AM
       2. Dr Lee, Tue 2 PM
       3. Dr Wong, Thu 9 AM
       Which works best for you?"
Patient: "Tuesday afternoon"
Agent: "Confirmed: Dr Lee, Tuesday 14 Feb at 2:00 PM at Heart Centre.
       You'll receive a confirmation on WhatsApp. Anything else?"
```

### Step 4: Human Handoff

Escalation triggers:
- Patient requests human agent
- Complex request (multiple appointments, insurance questions)
- Agent confidence below 60%
- 3+ failed attempts to understand request

Transfer includes: full conversation transcript + patient context

### Step 5: Confirmation Messaging

After booking/reschedule/cancel:
- SMS confirmation (if SMS consent)
- WhatsApp confirmation (if WhatsApp consent)
- In-app notification
- Calendar invite (.ics file via email)

## Testing Strategy

1. "Book a doctor appointment" → agent asks specialty and date preferences
2. "Reschedule my Thursday appointment to Friday" → finds and updates
3. "Cancel my appointment" → confirms and triggers waitlist
4. Complex request → escalates to human agent
5. Confirmation received on correct channel

## Deployment Checklist

- [ ] Agentforce agent configured with scheduling topics
- [ ] All actions (search, book, reschedule, cancel) tested
- [ ] Availability integration with provider calendar
- [ ] Confirmation messaging on all channels
- [ ] Human handoff configured
- [ ] Deployed on web, mobile app, WhatsApp

## Dependencies

- **Blocked By:** US-3.2.2, US-1.3.1
- **Blocks:** None
