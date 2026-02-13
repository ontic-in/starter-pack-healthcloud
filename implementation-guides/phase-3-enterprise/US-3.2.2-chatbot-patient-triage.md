# US-3.2.2: Chatbot for Patient Triage

> **Phase:** 3 - Enterprise | **Epic:** 3.2 - Multi-Channel Engagement | **Estimate:** L (2+ weeks)

## Overview

Deploy a symptom assessment chatbot using clinically validated decision trees that guides patients to appropriate care (self-care, book appointment, or visit ED). Chat history is saved to the patient record.

**Business Value:** Available 24/7, reduces inappropriate ED visits by 15-20%, guides patients to the right level of care, and reduces triage call volume by 25-35%.

## Prerequisites

- US-3.2.1 (Mobile App) completed or in parallel
- US-2.3.3 (Patient Portal) completed
- Clinical decision tree content validated by medical advisory

## Salesforce Configuration Steps

### Step 1: Choose Chatbot Platform

**Option A: Agentforce (recommended for Salesforce ecosystem)**
- Native Salesforce AI agent
- Deeply integrated with Health Cloud data
- Configurable topics and actions

**Option B: Einstein Bot**
- Dialog-based bot builder
- NLU model for intent recognition
- Good for structured decision trees

### Step 2: Design Symptom Assessment Flow

**Triage Decision Tree:**
1. "What symptoms are you experiencing?" (free text → NLU classification)
2. Classify into symptom categories: Chest Pain, Breathing Difficulty, Fever, Pain, GI, Skin, Mental Health, Other
3. Follow category-specific assessment:
   - Duration, severity (1-10), associated symptoms
   - Red flag checks (e.g., chest pain + shortness of breath → ED)
4. Triage output:
   - **Red (Emergency):** "Please go to the nearest ED immediately or call 995"
   - **Amber (Appointment):** "We recommend seeing a doctor. Book an appointment?"
   - **Green (Self-care):** "Based on your symptoms, try these self-care steps..."

### Step 3: Configure Chat Intents

| Intent | Examples | Action |
|---|---|---|
| Symptom Report | "I have a headache", "feeling dizzy" | Start triage flow |
| Book Appointment | "I need to see a doctor" | Launch scheduling |
| Medication Question | "What are my medications?" | Show medication list |
| General Health | "What is my BP target?" | Show care plan goals |
| Escalate | "Talk to a person", "I need help" | Transfer to live agent |

### Step 4: Chat History Integration

- All chat transcripts saved as CaseComment or custom ChatTranscript__c
- Linked to patient Account record
- Available on Patient 360 timeline
- Triage outcome logged with severity assessment

### Step 5: Live Agent Escalation

- Escalation triggers: patient requests human, high-severity assessment, bot confidence < 60%
- Routes to care coordinator during business hours
- After hours: routes to nurse helpline or displays ED/995 info
- Full chat transcript transferred to agent

### Step 6: Availability

- 24/7 via patient portal and mobile app
- Channels: Web chat widget, mobile app embedded, WhatsApp (optional)

## Testing Strategy

1. Report chest pain → bot escalates to "Go to ED" immediately
2. Report mild headache → self-care advice provided
3. Request to speak to human → live agent transfer
4. Check chat history → transcript saved on patient record
5. Test at 2 AM → bot responds (24/7 availability)

## Deployment Checklist

- [ ] Chatbot platform configured
- [ ] Symptom decision trees built and clinically validated
- [ ] Intent recognition trained
- [ ] Chat history integration active
- [ ] Live agent escalation configured
- [ ] Deployed on portal + mobile app
- [ ] 24/7 availability verified
- [ ] Clinical sign-off on triage logic

## Dependencies

- **Blocked By:** US-3.2.1, US-2.3.3
- **Blocks:** US-3.3.1 (AI Scheduling Agent extends chatbot)
