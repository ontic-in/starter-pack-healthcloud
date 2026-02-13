# US-3.4.1: Unified Patient Profile (Data Cloud)

> **Phase:** 3 - Enterprise | **Epic:** 3.4 - Data Cloud & Analytics | **Estimate:** L (2+ weeks)

## Overview

Harmonise patient data from Health Cloud, EHR, billing (SAP), and engagement systems (WhatsApp, patient portal) into a unified Data Cloud profile. Uses NRIC + DOB for identity resolution across systems.

**Business Value:** Creates a single source of truth across all systems, enables cross-system analytics and AI, and provides every team with a consistent, complete view of the patient.

## Prerequisites

- US-2.2.1 (FHIR R4 Patient Sync) completed
- Salesforce Data Cloud licence provisioned
- All source system APIs available

## Salesforce Configuration Steps

### Step 1: Configure Data Streams

| Source System | Data Stream | Objects/Data |
|---|---|---|
| Health Cloud | CRM Connector | Patient, CarePlan, Goals, Conditions, Medications |
| Hospital EHR | FHIR R4 / API | Clinical encounters, Diagnoses, Procedures |
| SAP Billing | MuleSoft Connector | Invoices, Claims, Payments |
| WhatsApp | Messaging API | Message history, Delivery, Read receipts |
| Patient Portal | Experience Cloud | Logins, Readings, Page views |

### Step 2: Identity Resolution

**Match Rules:**
- Primary: NRIC (exact match) — 100% confidence
- Secondary: DOB + Last Name (fuzzy) — 85% confidence
- Tertiary: Phone + Email — 70% confidence

**Resolution Priority:** Health Cloud record is the master identity

### Step 3: Unified Profile Schema

| Category | Data Points |
|---|---|
| Demographics | From Health Cloud (master) |
| Clinical | Conditions, Meds, Allergies (EHR + HC merged) |
| Financial | Insurance, Claims, Payments (SAP) |
| Engagement | Messages sent/read, Portal activity, App usage |
| Behavioural | Appointment adherence, Medication adherence, Reading compliance |

### Step 4: Calculated Insights

| Insight | Calculation |
|---|---|
| Engagement Score | Weighted: portal logins + reading compliance + message response rate |
| Risk Score | Clinical data + adherence + SDOH (feeds US-3.4.2) |
| Revenue Value | 12-month billing total from SAP |
| Channel Preference | Most responded-to channel (SMS, WhatsApp, Email) |

### Step 5: Activation Targets

- **Health Cloud:** Unified profile feeds Patient 360 FlexCard
- **Marketing Cloud:** Segmentation for health campaigns
- **Analytics:** CRM Analytics datasets for population health
- **AI Models:** Input for risk stratification (US-3.4.2) and readmission prediction (US-3.4.3)

### Step 6: Data Refresh

- Real-time: Health Cloud and Portal events (< 15 min latency)
- Near-real-time: EHR sync (< 30 min)
- Batch: SAP billing (daily at 3:00 AM SGT)

## Testing Strategy

1. Patient exists in HC + EHR + SAP → unified profile shows all data
2. Update phone in EHR → reflected in unified profile within 15 min
3. Identity resolution matches across 3 systems using NRIC
4. Calculated insights compute correctly
5. Data freshness meets SLA (< 15 min for real-time streams)

## Deployment Checklist

- [ ] Data Cloud provisioned and connected to org
- [ ] All 5 data streams configured
- [ ] Identity resolution rules deployed
- [ ] Unified profile schema configured
- [ ] Calculated insights active
- [ ] Activation targets configured
- [ ] Data refresh verified within SLA
- [ ] End-to-end profile unification tested

## Dependencies

- **Blocked By:** US-2.2.1 (FHIR sync), US-3.5.1 (SAP integration)
- **Blocks:** US-3.4.2 (AI Risk Stratification), US-3.4.3 (Readmission Prediction)
