# US-2.3.4: Health Education Content Delivery

> **Phase:** 2 - Care Coordination | **Epic:** 2.3 - Patient Engagement | **Estimate:** S (1-3 days)

## Overview

Schedule automated health education content delivery to patients based on their condition and care plan stage. Content is delivered via email or WhatsApp based on patient preference.

**Business Value:** Informed patients have 30% better outcomes. Automated delivery eliminates manual coordination effort and ensures consistent patient education aligned with care plan stages.

## Prerequisites

- US-1.2.2 (Care Plan Creation) completed
- US-1.6.1 (Consent) completed
- Email and/or WhatsApp channels configured (US-2.3.1, US-2.3.2)

## Salesforce Configuration Steps

### Step 1: Create Content Library

**Custom Object: HealthContent__c**

| Field | Type |
|---|---|
| Title | Text |
| Content Type | Picklist(Article, Video, PDF, Infographic) |
| Condition | Picklist(Diabetes, Hypertension, Cardiac, General Wellness) |
| Care Plan Week | Number (delivery week in care plan lifecycle) |
| URL | URL (link to content) |
| Language | Picklist(English, Mandarin, Malay, Tamil) |
| Summary | Long Text (preview text for message) |

### Step 2: Configure Delivery Schedule

**Custom Object: ContentSchedule__c**

| Field | Type |
|---|---|
| Care Plan Template | Lookup(CarePlanTemplate) |
| Content | Lookup(HealthContent__c) |
| Delivery Week | Number (week from care plan start) |
| Channel | Picklist(Email, WhatsApp, Both) |

**Example — Diabetes Care Plan:**
- Week 1: "Understanding Your Diabetes Diagnosis" (Article)
- Week 2: "Blood Sugar Monitoring Guide" (Video)
- Week 4: "Healthy Eating for Diabetes" (PDF)
- Week 8: "Exercise and Diabetes" (Article)
- Week 12: "Managing Diabetes Long-term" (Article)

### Step 3: Delivery Engine

**Scheduled Flow: ContentDelivery**
- Runs: Daily at 9:00 AM SGT
- Query: Active care plans where current week matches a ContentSchedule
- For each match:
  1. Check patient consent for the delivery channel
  2. Check patient language preference → select matching content
  3. Send via email or WhatsApp
  4. Log delivery in ContentDeliveryLog__c

### Step 4: Tracking

**ContentDeliveryLog__c** tracks: Patient, Content, Delivery Date, Channel, Delivered (bool), Opened (bool for email).

## Testing Strategy

1. Activate care plan → Week 1 content delivered next morning
2. Patient with Mandarin preference → receives Mandarin content
3. Patient without email consent → WhatsApp delivery instead
4. Track open rates in delivery log

## Deployment Checklist

- [ ] HealthContent__c populated with content for 3 conditions
- [ ] ContentSchedule__c configured for each care plan template
- [ ] ContentDelivery scheduled flow active
- [ ] ContentDeliveryLog__c tracking working
- [ ] Multi-language content available

## Dependencies

- **Blocked By:** US-1.2.2, US-1.6.1, US-2.3.1 or US-2.3.2 (delivery channels)
- **Blocks:** None
