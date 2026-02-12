# Salesforce Health Cloud: Implementation Scenarios, Timelines & Demo Use Case

> **Document Version:** 1.0 | **Last Updated:** February 2026
> **Purpose:** Pre-sales reference guide covering implementation scenarios with realistic timelines/estimates, and a complete end-to-end demo use case for a Singapore-based healthcare organisation.

---

## Table of Contents

1. [Health Cloud Overview](#1-health-cloud-overview)
2. [Implementation Scenarios](#2-implementation-scenarios)
3. [Licensing & Cost Reference](#3-licensing--cost-reference)
4. [Risk Factors & Considerations](#4-risk-factors--considerations)
5. [End-to-End Demo Use Case: MediConnect Singapore](#5-end-to-end-demo-use-case-mediconnect-singapore)
6. [Appendix](#6-appendix)

---

## 1. Health Cloud Overview

Salesforce Health Cloud is a purpose-built CRM platform for healthcare and life sciences organisations. It extends Salesforce's core CRM capabilities with healthcare-specific data models, care management tools, and pre-built integrations for clinical systems.

### Core Capabilities

| Capability | Description |
|---|---|
| **Patient/Member 360** | Unified view of clinical, claims, social determinants, and engagement data |
| **Care Management** | Care plans, care teams, tasks, goals, and clinical protocols |
| **Provider Relationship Management** | Provider network management, credentialing, referral tracking |
| **Utilisation Management** | Prior authorisation, concurrent review, appeals & grievances |
| **Clinical Data Integration** | HL7 FHIR R4 native support, EHR integration, lab/pharmacy data |
| **OmniStudio & FlexCards** | Guided workflows and contextual UI components |
| **Intelligent Document Automation** | AI-powered document processing for clinical and admin workflows |
| **Agentforce for Health Cloud** | Generative AI agents for patient engagement, scheduling, triage |
| **Data Cloud for Healthcare** | Real-time data harmonisation across clinical and operational systems |

### Editions (as of 2026)

| Edition | Price (USD/user/month) | Key Differentiators |
|---|---|---|
| **Enterprise** | $350 | Clinical/insurance data models, care management, OmniStudio, FlexCards |
| **Unlimited** | $525 | + Predictive & generative AI, Premier Success Plan, full sandbox |
| **Agentforce 1 for Service** | $750 | + Agentforce agents, 2.5M Data Cloud credits, Slack, Analytics |
| **Agentforce 1 for Sales** | $750 | + Sales performance management, external partner apps |

---

## 2. Implementation Scenarios

### Scenario 1: Foundation / MVP - Patient 360 & Basic Care Management

**Best for:** Clinics, single-specialty practices, or organisations starting their digital transformation journey.

**Scope:**
- Patient 360 profile (demographics, conditions, medications, allergies)
- Basic care plans with goals and tasks
- Care team assignment and collaboration
- Provider directory and referral tracking
- Standard reports and dashboards
- Basic patient outreach (email/SMS)

**Team Composition:**
| Role | Count | Duration |
|---|---|---|
| Project Manager | 1 | Full duration |
| Solution Architect | 1 | First 4 weeks + final 2 weeks |
| Health Cloud Developer | 2 | Weeks 3-10 |
| QA/Testing | 1 | Weeks 6-10 |
| Change Management/Training | 1 | Weeks 8-12 |

**Timeline: 10-14 weeks**

| Phase | Duration | Key Activities |
|---|---|---|
| Discovery & Planning | 2 weeks | Requirements gathering, data audit, architecture design |
| Configuration & Build | 4-5 weeks | Data model setup, care plan templates, FlexCards, OmniStudio flows |
| Data Migration | 2-3 weeks | Patient/provider data mapping, cleansing, migration, validation |
| Testing & UAT | 2-3 weeks | System testing, UAT with clinical staff, defect resolution |
| Training & Go-Live | 1-2 weeks | End-user training, hypercare support, go-live |

**Estimated Investment:**

| Component | Low Estimate | High Estimate |
|---|---|---|
| Licensing (25 users, Enterprise, Year 1) | $105,000 | $105,000 |
| Implementation Services | $80,000 | $140,000 |
| Data Migration | $15,000 | $30,000 |
| Training & Change Management | $10,000 | $20,000 |
| **Total Year 1** | **$210,000** | **$295,000** |

---

### Scenario 2: Care Coordination Platform

**Best for:** Multi-site clinics, hospital groups, or integrated care networks needing cross-facility care coordination.

**Scope:**
- Everything in Scenario 1, plus:
- Advanced care plans with clinical protocols and evidence-based pathways
- Multi-disciplinary care team workflows (referrals, handoffs, escalations)
- Patient engagement: appointment reminders, health assessments, patient portal
- Integration with 1-2 EHR/EMR systems via HL7 FHIR
- Social determinants of health (SDOH) tracking
- Advanced dashboards with population health analytics

**Team Composition:**
| Role | Count | Duration |
|---|---|---|
| Project Manager | 1 | Full duration |
| Solution Architect | 1 | Full duration |
| Health Cloud Developer | 2-3 | Weeks 3-16 |
| Integration Specialist | 1 | Weeks 4-14 |
| QA/Testing | 1-2 | Weeks 10-18 |
| Change Management/Training | 1 | Weeks 14-20 |

**Timeline: 16-22 weeks**

| Phase | Duration | Key Activities |
|---|---|---|
| Discovery & Planning | 3 weeks | Clinical workflow mapping, integration architecture, FHIR resource mapping |
| Configuration & Build | 6-8 weeks | Care protocols, OmniStudio guided flows, engagement journeys |
| Integration Development | 4-5 weeks | FHIR API setup, EHR sync, real-time/batch data flows |
| Data Migration | 3-4 weeks | Historical patient data, care plans, provider networks |
| Testing & UAT | 3-4 weeks | Integration testing, clinical scenario testing, UAT |
| Training & Go-Live | 2 weeks | Role-based training, phased rollout, hypercare |

**Estimated Investment:**

| Component | Low Estimate | High Estimate |
|---|---|---|
| Licensing (50 users, Unlimited, Year 1) | $315,000 | $315,000 |
| Implementation Services | $180,000 | $300,000 |
| Integration Development | $60,000 | $120,000 |
| Data Migration | $25,000 | $50,000 |
| Training & Change Management | $20,000 | $35,000 |
| **Total Year 1** | **$600,000** | **$820,000** |

---

### Scenario 3: Enterprise Health Cloud - Full Digital Transformation

**Best for:** Large hospital systems, national healthcare providers, or organisations seeking end-to-end digital health operations.

**Scope:**
- Everything in Scenario 2, plus:
- Utilisation management (prior auth, concurrent review, appeals)
- Multi-channel patient engagement (portal, mobile app, chatbot, voice)
- Agentforce AI agents for patient triage, scheduling, and follow-up
- Advanced analytics with Data Cloud and Tableau CRM
- Integration with 3+ external systems (EHR, billing, pharmacy, labs, wearables)
- Custom Lightning components for clinical specialties
- Compliance engine for regulatory requirements (PDPA, HIPAA, etc.)

**Team Composition:**
| Role | Count | Duration |
|---|---|---|
| Programme Manager | 1 | Full duration |
| Solution Architect | 1-2 | Full duration |
| Health Cloud Developer | 3-4 | Weeks 4-28 |
| Integration Architect | 1 | Full duration |
| Integration Developer | 2 | Weeks 6-26 |
| Data Cloud Specialist | 1 | Weeks 8-24 |
| QA Lead + Testers | 2-3 | Weeks 16-30 |
| Change Management Lead | 1 | Weeks 20-34 |
| Trainers | 1-2 | Weeks 28-36 |

**Timeline: 28-40 weeks (typically phased across 2-3 releases)**

| Phase | Duration | Key Activities |
|---|---|---|
| Discovery & Architecture | 4-5 weeks | Enterprise architecture, integration strategy, data governance |
| Phase 1: Core Platform | 8-10 weeks | Patient 360, care management, first EHR integration |
| Phase 2: Advanced Features | 8-10 weeks | Utilisation management, multi-channel engagement, AI agents |
| Phase 3: Analytics & Optimisation | 4-6 weeks | Data Cloud, dashboards, population health analytics |
| Enterprise Testing | 4-5 weeks | End-to-end regression, performance, security testing |
| Phased Rollout | 4-6 weeks | Department-by-department go-live with hypercare |

**Estimated Investment:**

| Component | Low Estimate | High Estimate |
|---|---|---|
| Licensing (100 users, Agentforce, Year 1) | $900,000 | $900,000 |
| Implementation Services | $400,000 | $700,000 |
| Integration Development | $150,000 | $300,000 |
| Data Cloud & Analytics | $80,000 | $150,000 |
| Data Migration | $50,000 | $100,000 |
| Training & Change Management | $40,000 | $80,000 |
| **Total Year 1** | **$1,620,000** | **$2,230,000** |

---

### Scenario 4: Health Cloud for Payers (Insurance)

**Best for:** Health insurance companies, managed care organisations, or government health schemes.

**Scope:**
- Member 360 profile with claims history, benefits, and coverage details
- Utilisation management with prior authorisation workflows
- Appeals and grievances management
- Provider network management and credentialing
- Member engagement and wellness programmes
- Claims integration and benefits verification
- Regulatory compliance reporting

**Team Composition:**
| Role | Count | Duration |
|---|---|---|
| Project Manager | 1 | Full duration |
| Solution Architect (Payer domain) | 1 | Full duration |
| Health Cloud Developer | 2-3 | Weeks 3-20 |
| Integration Specialist | 1-2 | Weeks 4-18 |
| QA/Testing | 1-2 | Weeks 12-22 |
| Change Management/Training | 1 | Weeks 18-26 |

**Timeline: 20-28 weeks**

| Phase | Duration | Key Activities |
|---|---|---|
| Discovery & Planning | 3-4 weeks | Benefits structure mapping, claims workflow design, compliance requirements |
| Configuration & Build | 7-9 weeks | UM workflows, member portal, provider directory, A&G processes |
| Integration Development | 5-6 weeks | Claims system, eligibility verification, provider data feeds |
| Data Migration | 3-4 weeks | Member data, provider networks, historical claims |
| Testing & UAT | 3-4 weeks | End-to-end claims scenarios, compliance validation |
| Training & Go-Live | 2-3 weeks | Role-based training, phased rollout |

**Estimated Investment:**

| Component | Low Estimate | High Estimate |
|---|---|---|
| Licensing (75 users, Unlimited, Year 1) | $472,500 | $472,500 |
| Implementation Services | $250,000 | $400,000 |
| Integration Development | $100,000 | $200,000 |
| Data Migration | $30,000 | $60,000 |
| Training & Change Management | $25,000 | $40,000 |
| **Total Year 1** | **$877,500** | **$1,172,500** |

---

### Scenario 5: Life Sciences / Pharma - Patient Support & HCP Engagement

**Best for:** Pharmaceutical companies, medical device firms, or biotech organisations.

**Scope:**
- Patient support programme (PSP) management
- Healthcare professional (HCP) engagement and relationship tracking
- Adverse event and product complaint capture
- Clinical trial recruitment and patient matching
- Medical information request management
- Therapy management and adherence tracking
- Consent management and regulatory compliance

**Team Composition:**
| Role | Count | Duration |
|---|---|---|
| Project Manager | 1 | Full duration |
| Solution Architect (Life Sciences) | 1 | Full duration |
| Health Cloud Developer | 2 | Weeks 3-16 |
| Integration Specialist | 1 | Weeks 4-14 |
| QA/Testing | 1 | Weeks 10-18 |
| Regulatory/Compliance SME | 1 | Weeks 1-4, 14-18 |
| Training | 1 | Weeks 16-20 |

**Timeline: 16-22 weeks**

| Phase | Duration | Key Activities |
|---|---|---|
| Discovery & Compliance Planning | 3 weeks | PSP design, adverse event workflows, consent models, regulatory mapping |
| Configuration & Build | 6-7 weeks | PSP workflows, HCP portal, therapy tracking, consent engine |
| Integration Development | 3-4 weeks | Safety database, pharmacy hub, CRM data |
| Testing & Validation | 3-4 weeks | GxP validation (if applicable), compliance testing, UAT |
| Training & Go-Live | 2 weeks | Compliance training, go-live, pharmacovigilance readiness |

**Estimated Investment:**

| Component | Low Estimate | High Estimate |
|---|---|---|
| Licensing (40 users, Unlimited, Year 1) | $252,000 | $252,000 |
| Implementation Services | $160,000 | $280,000 |
| Integration Development | $50,000 | $100,000 |
| Validation & Compliance | $30,000 | $60,000 |
| Training & Change Management | $15,000 | $30,000 |
| **Total Year 1** | **$507,000** | **$722,000** |

---

### Scenario Comparison Summary

| Dimension | Scenario 1: MVP | Scenario 2: Care Coord. | Scenario 3: Enterprise | Scenario 4: Payer | Scenario 5: Life Sci. |
|---|---|---|---|---|---|
| **Timeline** | 10-14 wks | 16-22 wks | 28-40 wks | 20-28 wks | 16-22 wks |
| **Team Size** | 5-6 | 7-9 | 12-16 | 8-11 | 7-8 |
| **Total Year 1 Cost** | $210K-$295K | $600K-$820K | $1.6M-$2.2M | $878K-$1.2M | $507K-$722K |
| **Complexity** | Low | Medium | High | High | Medium |
| **Integration Effort** | Minimal | Moderate | Extensive | Extensive | Moderate |
| **Best Edition** | Enterprise | Unlimited | Agentforce | Unlimited | Unlimited |

> **Note:** All estimates assume standard implementation using Salesforce best practices. Actual costs vary based on geographic location of the implementation team, organisational complexity, data quality, and existing system landscape. Volume licensing discounts of 15-30% are common for 50+ user deployments. SI partner rates vary significantly by region (APAC rates are typically 20-40% lower than US/EU rates).

---

## 3. Licensing & Cost Reference

### Health Cloud Editions (2026 List Pricing)

| Edition | USD/User/Month | Best For |
|---|---|---|
| Enterprise | $350 | Mid-size providers, clinics, basic payer operations |
| Unlimited | $525 | Multi-site hospitals, payers, life sciences with AI needs |
| Agentforce 1 (Service) | $750 | Large enterprises requiring AI agents, Data Cloud, Slack |
| Agentforce 1 (Sales) | $750 | Pharma/MedTech with field sales and partner management |

### Common Add-Ons

| Add-On | Cost | Notes |
|---|---|---|
| Knowledge (Read-Write) | $75/user/month | Enterprise edition only |
| Live Chat Agent | $75/user/month | Enterprise edition only |
| Data Cloud Credits | Volume-based | Included in Agentforce editions (2.5M credits) |
| Shield (Platform Encryption) | ~30% of licence cost | Recommended for healthcare data compliance |
| MuleSoft Integration | $15,000-$50,000/year | For complex multi-system integration |

### Typical SI Partner Rate Ranges (APAC)

| Role | Daily Rate (USD) |
|---|---|
| Solution Architect | $1,200-$2,000 |
| Senior Developer | $800-$1,400 |
| Developer | $600-$1,000 |
| QA/Test Engineer | $500-$800 |
| Project Manager | $800-$1,200 |
| Change Management | $600-$1,000 |

---

## 4. Risk Factors & Considerations

### Technical Risks

| Risk | Impact | Mitigation |
|---|---|---|
| **EHR integration complexity** | Timeline delays of 4-8 weeks | Early FHIR API assessment, sandbox testing in Week 1 |
| **Data quality issues** | Migration rework, inaccurate Patient 360 | Data profiling in Discovery, cleansing before migration |
| **Performance at scale** | Slow page loads, timeout errors | Load testing early, optimise SOQL queries, indexing strategy |
| **Regulatory compliance gaps** | Go-live delays, legal exposure | Engage compliance SME from Day 1, audit trail configuration |

### Organisational Risks

| Risk | Impact | Mitigation |
|---|---|---|
| **Low user adoption** | Failed ROI, shadow systems | Early clinician involvement, phased rollout, champion network |
| **Scope creep** | Budget/timeline overrun | Strict change control, MoSCoW prioritisation |
| **Insufficient executive sponsorship** | Stalled decisions, resource conflicts | C-suite sponsor identified in Week 1, regular steering committee |
| **Clinical workflow disruption** | Staff resistance, patient safety concerns | Parallel run period, clinical validation of all workflows |

### Singapore-Specific Considerations

| Factor | Details |
|---|---|
| **PDPA Compliance** | Mandatory consent management, data access logging, breach notification within 3 days |
| **Health Information Bill (HIB)** | Upcoming legislation mandating private sector health data sharing with NEHR |
| **NEHR Integration** | National Electronic Health Record integration may be required for public-sector contracts |
| **Data Residency** | Consider Singapore-region Salesforce data centre or Shield encryption for sensitive data |
| **MOH Licensing** | Healthcare organisations must comply with Healthcare Services Act (HCSA) |
| **Multi-language Support** | English, Mandarin, Malay, Tamil support may be needed for patient-facing features |

---

## 5. End-to-End Demo Use Case: MediConnect Singapore

### Company Profile

| Attribute | Details |
|---|---|
| **Company Name** | MediConnect Singapore Pte Ltd |
| **Type** | Private integrated healthcare group |
| **Established** | 2015 |
| **Headquarters** | 1 Novena Medical Centre, #12-01, Singapore 308205 |
| **Facilities** | 1 hospital (180 beds), 6 polyclinics, 2 dental clinics, 1 TCM centre |
| **Staff** | 450 clinical staff, 200 administrative staff |
| **Patients** | ~85,000 active patients across all facilities |
| **Specialties** | Cardiology, Oncology, Orthopaedics, Family Medicine, Traditional Chinese Medicine |
| **Annual Revenue** | SGD 120M |
| **Current Systems** | Epic (hospital), clinic-built EMR (polyclinics), SAP (billing), WhatsApp (patient comms) |

### Business Challenges

1. **Fragmented patient data** - Hospital and polyclinic records are siloed. No single view of patient journey.
2. **Care coordination gaps** - Post-discharge follow-ups are manual. 18% readmission rate for cardiac patients.
3. **Patient engagement** - Appointment no-show rate of 22%. No proactive health reminders.
4. **Chronic disease management** - 12,000 patients with diabetes/hypertension lack structured care plans.
5. **Regulatory pressure** - Upcoming HIB requirements mandate NEHR data sharing from private providers.

### Implementation Approach: Scenario 2 (Care Coordination Platform)

**Edition:** Health Cloud Unlimited
**Users:** 60 (30 clinicians, 15 care coordinators, 10 admin staff, 5 management)
**Timeline:** 20 weeks
**Go-Live Target:** Q3 2026

---

### Demo Walkthrough

#### Scene 1: Patient Registration & 360 View

**Persona:** Nurse Rachel Tan, Patient Registration, Novena Medical Centre

**Context:** Mr. Lim Wei Ming, 62, arrives for his first visit at MediConnect's cardiology clinic. He was referred by his polyclinic GP after elevated blood pressure readings.

**Sample Patient Data:**

```
Patient: Lim Wei Ming (林伟明)
NRIC: S6234567A
DOB: 15 March 1964 (Age 62)
Gender: Male
Ethnicity: Chinese
Language: English, Mandarin
Address: Blk 204 Toa Payoh Lor 8, #08-123, Singapore 310204
Phone: +65 9123 4567
Email: weiming.lim@gmail.com
Emergency Contact: Mdm. Chen Shu Fen (Wife) - +65 9876 5432

Insurance:
- Primary: Great Eastern SupremeHealth P Plus
  Policy #: GE-SH-2024-88123
  Coverage: Ward B1, $1,500 annual outpatient cap
- Secondary: Medisave (CPF)
  Account: Available balance SGD 42,800

GP Referral Details:
- Referring Doctor: Dr. Priya Nair, MediConnect Toa Payoh Polyclinic
- Referral Date: 3 Feb 2026
- Reason: Persistent hypertension (BP 158/95 avg over 3 months)
- Current Medications: Amlodipine 5mg daily
```

**Health Cloud Demo Points:**
- **Patient 360 FlexCard** displays unified profile: demographics, insurance, referral source, Medisave balance
- **Timeline component** shows referral from polyclinic with clinical notes attached
- **Consent Management**: PDPA consent form captured digitally; patient opts in to SMS reminders, opts out of marketing

---

#### Scene 2: Clinical Assessment & Care Plan Creation

**Persona:** Dr. James Koh, Senior Cardiologist

**Context:** Dr. Koh reviews Mr. Lim's profile and creates a structured care plan after initial assessment.

**Clinical Assessment Data:**

```
Consultation Date: 12 Feb 2026
Presenting Complaint: Persistent hypertension, occasional chest tightness on exertion

Vitals:
- Blood Pressure: 162/98 mmHg
- Heart Rate: 82 bpm
- BMI: 27.4 (Height: 170cm, Weight: 79.2kg)
- SpO2: 97%

Conditions (Active):
- Essential Hypertension (ICD-10: I10) - Diagnosed 2023
- Hyperlipidaemia (ICD-10: E78.5) - Diagnosed 2024
- Pre-diabetes (ICD-10: R73.03) - Diagnosed 2025

Conditions (Historical):
- Dengue Fever (2019) - Resolved

Family History:
- Father: MI at age 58 (deceased)
- Mother: Type 2 Diabetes, Hypertension

Allergies:
- Penicillin (Rash - documented 2018)

Lab Results (ordered):
- Lipid Panel
- HbA1c
- Renal Function Panel
- ECG
- Echocardiogram

Medications (updated):
- Amlodipine 10mg daily (dose increased from 5mg)
- Losartan 50mg daily (new)
- Atorvastatin 20mg daily (new)
- Aspirin 100mg daily (new)
```

**Care Plan: Cardiovascular Risk Reduction Programme**

```
Care Plan Name: CV Risk Reduction - Lim Wei Ming
Template: MediConnect Cardiac Prevention Protocol v2.1
Status: Active
Start Date: 12 Feb 2026
Review Date: 12 May 2026 (3-month review)

Goals:
1. Blood Pressure Control
   - Target: <140/90 mmHg within 8 weeks
   - Measure: Home BP monitoring 2x daily

2. Lipid Management
   - Target: LDL <2.6 mmol/L within 12 weeks
   - Measure: Repeat lipid panel at Week 12

3. Weight Management
   - Target: Reduce BMI to <25 (target weight: 72kg) within 24 weeks
   - Measure: Weekly weigh-in at polyclinic

4. Pre-diabetes Reversal
   - Target: HbA1c <5.7% within 24 weeks
   - Measure: HbA1c test at Week 12 and Week 24

Care Team:
- Primary Cardiologist: Dr. James Koh
- Care Coordinator: Ms. Sarah Wong
- Referring GP: Dr. Priya Nair
- Dietitian: Ms. Aisha Binte Rahman
- Pharmacist: Mr. David Lee

Tasks:
| Task | Assigned To | Due Date | Status |
|---|---|---|---|
| Review ECG + Echo results | Dr. James Koh | 19 Feb 2026 | Pending |
| Schedule dietitian consult | Ms. Sarah Wong | 14 Feb 2026 | Pending |
| Patient education: BP monitoring | Ms. Sarah Wong | 13 Feb 2026 | Pending |
| Medication reconciliation | Mr. David Lee | 13 Feb 2026 | Pending |
| Follow-up appointment (2 weeks) | Ms. Sarah Wong | 26 Feb 2026 | Pending |
| Polyclinic BP check (weekly x4) | Dr. Priya Nair | Recurring | Pending |
```

**Health Cloud Demo Points:**
- **Care Plan builder** with MediConnect's custom cardiac protocol template
- **Care Team panel** showing multi-disciplinary team across hospital and polyclinic
- **Goal tracking** with measurable targets and automated progress indicators
- **Task assignment** across facilities - polyclinic tasks auto-assigned to GP
- **FHIR integration**: Lab orders sent to hospital LIS via FHIR R4 ServiceRequest

---

#### Scene 3: Care Coordination & Cross-Facility Handoff

**Persona:** Ms. Sarah Wong, Care Coordinator

**Context:** Two weeks post-consultation. Sarah manages Mr. Lim's care across MediConnect's network.

**Coordination Timeline:**

```
13 Feb 2026 - Patient Education Session (Completed)
  Sarah conducted 30-min session on home BP monitoring
  Patient demonstrated correct technique, issued Omron BP monitor
  Recorded in Health Cloud: Education Activity > BP Self-Monitoring

14 Feb 2026 - Dietitian Referral (Completed)
  Internal referral to Ms. Aisha at Novena clinic
  Appointment: 20 Feb 2026, 2:00 PM
  OmniStudio guided flow used for referral with auto-populated clinical data

19 Feb 2026 - Lab Results Review (Completed)
  ECG: Normal sinus rhythm, no ST changes
  Echo: LVEF 55%, mild LVH, no valvular disease
  Lipid Panel: TC 6.8, LDL 4.2, HDL 1.1, TG 2.8 mmol/L
  HbA1c: 6.1% (pre-diabetic range confirmed)
  eGFR: 78 mL/min (mild reduction)

  Dr. Koh reviewed via Health Cloud mobile app, added note:
  "LVH consistent with longstanding HTN. Aggressive BP control critical.
   Renal function borderline - monitor with ACEi/ARB therapy.
   Proceed with current plan. Review in 4 weeks."

20 Feb 2026 - Dietitian Consultation (Completed)
  Ms. Aisha created nutrition plan:
  - DASH diet education (reduced sodium <2g/day)
  - Calorie target: 1,800 kcal/day
  - Meal plan provided (culturally adapted for Chinese-Singaporean diet)
  - Reduce kopi-o intake to 1 cup/day, switch from white rice to brown

26 Feb 2026 - 2-Week Follow-up (Upcoming)
  Home BP Readings (submitted via patient portal):
  | Date | Morning | Evening |
  |---|---|---|
  | 14 Feb | 155/94 | 148/90 |
  | 17 Feb | 150/92 | 145/88 |
  | 20 Feb | 148/90 | 142/86 |
  | 23 Feb | 144/88 | 138/84 |
  | 25 Feb | 140/86 | 136/82 |

  Trend: Steady improvement. Approaching target.
```

**Health Cloud Demo Points:**
- **Activity Timeline** showing all touchpoints across facilities in chronological order
- **Care Plan Progress**: Goal 1 (BP) showing green trend arrow, on track
- **Cross-facility referral** via OmniStudio: polyclinic to hospital dietitian in 2 clicks
- **Patient-submitted data** flowing into Health Cloud via integration (API/portal)
- **Mobile clinician app**: Dr. Koh reviewing labs and adding notes from his phone
- **Automated alerts**: If BP readings spike above 160/100, care coordinator gets notified

---

#### Scene 4: Patient Engagement & Proactive Outreach

**Persona:** MediConnect Patient Engagement Team

**Context:** Health Cloud drives automated and semi-automated patient engagement.

**Engagement Scenarios for Mr. Lim:**

```
Automated Touchpoints (configured in Health Cloud):

1. Appointment Reminders
   - SMS (2 days before): "Hi Wei Ming, your cardiology follow-up with
     Dr. Koh is on 26 Feb at 10:00 AM, Novena Medical Centre, #05-08.
     Reply C to confirm, R to reschedule."
   - Status: Confirmed (patient replied C)

2. Medication Reminders (via WhatsApp Business API)
   - Daily 8:00 AM: "Good morning! Time for your morning medications:
     Amlodipine 10mg, Losartan 50mg, Atorvastatin 20mg, Aspirin 100mg"
   - Patient response rate: 85% acknowledgement

3. Health Assessment (monthly)
   - PHQ-2 depression screening (cardiac patients protocol)
   - Lifestyle assessment (exercise, diet adherence, smoking)
   - Auto-scored and flagged if concerning

4. Educational Content
   - Week 1: "Understanding Your Blood Pressure Numbers" (article)
   - Week 3: "Heart-Healthy Hawker Food Choices in Singapore" (video)
   - Week 5: "Exercise Guide for Beginners Over 60" (PDF)

5. Proactive Outreach (triggered by care plan rules)
   - IF: No BP reading submitted for 3+ days
   - THEN: SMS to patient + task created for care coordinator
   - "Hi Wei Ming, we notice you haven't logged your BP recently.
     Regular monitoring helps Dr. Koh track your progress.
     Need help with your BP monitor? Call us at 6123 4567."
```

**No-Show Prevention (Population Level):**

```
MediConnect No-Show Dashboard:

Before Health Cloud:
- Overall no-show rate: 22%
- Revenue impact: ~SGD 2.4M annually

After Health Cloud (projected Year 1):
- Target no-show rate: 12% (-10 percentage points)
- Projected savings: SGD 1.1M annually

Strategies Implemented:
- 2-day + same-day SMS reminders (automated)
- One-click reschedule via patient portal
- Waitlist management: cancelled slots auto-offered to waitlisted patients
- Predictive no-show scoring (Unlimited edition AI):
  high-risk patients get personal call from coordinator
```

**Health Cloud Demo Points:**
- **Journey Builder** showing automated engagement timeline
- **WhatsApp Business integration** for medication reminders
- **Patient portal** with BP logging, appointment management, secure messaging
- **No-show prediction** using AI scoring (Unlimited/Agentforce edition)
- **Engagement analytics dashboard**: response rates, content effectiveness, channel preferences

---

#### Scene 5: Population Health & Management Dashboards

**Persona:** Dr. Serena Loh, Chief Medical Officer, MediConnect

**Context:** Quarterly review of chronic disease management programme performance.

**Dashboard Data:**

```
MediConnect Chronic Disease Management Dashboard
Period: Q1 2026 (Jan-Mar)

PATIENT POPULATION
Total Active Patients: 85,412
Chronic Disease Patients: 12,847 (15.0%)
  - Diabetes: 5,234
  - Hypertension: 8,912
  - Hyperlipidaemia: 6,445
  - COPD/Asthma: 1,823
  (Note: patients may have multiple conditions)

New Enrolments This Quarter: 342
  - Cardiology pathway: 89
  - Diabetes pathway: 156
  - Respiratory pathway: 47
  - General chronic disease: 50

CARE PLAN COMPLIANCE
Active Care Plans: 8,234
  - On Track: 5,764 (70%)
  - At Risk: 1,893 (23%)
  - Off Track: 577 (7%)

OUTCOME METRICS
                          Baseline    Current    Target
Cardiac Readmission Rate: 18%        13.2%      <12%
Avg BP (HTN patients):    152/94     141/87     <140/90
HbA1c <7% (DM patients):  62%        71%        >80%
Appointment Adherence:     78%        88%        >90%

FACILITY PERFORMANCE
| Facility | Patients | Compliance | NPS |
|---|---|---|---|
| Novena Hospital | 3,245 | 74% | 72 |
| Toa Payoh Polyclinic | 2,456 | 68% | 65 |
| Bedok Polyclinic | 1,987 | 71% | 68 |
| Jurong West Polyclinic | 1,834 | 66% | 61 |
| Woodlands Polyclinic | 1,623 | 69% | 64 |
| Tampines Polyclinic | 1,702 | 72% | 67 |

TOP RISK PATIENTS (Auto-flagged by AI)
| Patient | Risk Score | Conditions | Flag Reason |
|---|---|---|---|
| Tan Ah Kow, 74M | 92/100 | DM, HTN, CKD3 | 3 missed appointments, HbA1c rising |
| Mdm Siti Aminah, 68F | 87/100 | HTN, CHF | ED visit last week, medication non-adherence |
| Raj Kumar, 55M | 84/100 | DM, Obesity | Weight gain +4kg in 1 month, no dietitian visit |
```

**Health Cloud Demo Points:**
- **Population health dashboard** with drill-down from org-level to individual patient
- **Risk stratification** using AI-powered scoring
- **Facility benchmarking** across MediConnect's network
- **Automated care gap identification**: patients missing screenings, overdue labs
- **Executive reporting**: ROI metrics, quality outcomes, operational KPIs

---

#### Scene 6: Compliance & Data Governance

**Persona:** Ms. Angela Teo, Data Protection Officer

**Context:** Ensuring PDPA compliance and preparing for Health Information Bill requirements.

**Compliance Configuration:**

```
PDPA COMPLIANCE FEATURES IN HEALTH CLOUD

1. Consent Management
   - Digital consent capture at registration (OmniStudio form)
   - Granular consent: treatment, research, marketing (separate checkboxes)
   - Consent withdrawal workflow with automated data restriction
   - Audit trail: all consent changes logged with timestamp and user

2. Data Access Controls
   - Role-based access: clinicians see clinical data, admin sees admin data
   - Record-level sharing: patients visible only to assigned care team
   - Field-level security: NRIC masked (shows S****567A) for non-clinical users
   - Login IP restrictions: clinical data accessible only from MediConnect network + VPN

3. Audit & Monitoring
   - Field History Tracking on all sensitive fields
   - Login History with device fingerprinting
   - Data Export alerts: notification if >100 records exported
   - Shield Event Monitoring (recommended add-on)

4. Data Retention
   - Clinical records: 7 years post last visit (MOH requirement)
   - Consent records: Retained indefinitely
   - Automated archival workflow at retention expiry

5. Breach Response
   - Automated breach assessment workflow
   - 3-day notification timer to PDPC (per PDPA requirement)
   - Patient notification templates pre-configured
   - Incident logging and remediation tracking

NEHR READINESS (for Health Information Bill)
   - FHIR R4 endpoints configured for NEHR data submission
   - Patient demographics, diagnoses, medications, allergies mapped
   - Consent check: auto-verify patient has not opted out of NEHR
   - Batch submission scheduler: daily sync at 2:00 AM SGT
```

**Health Cloud Demo Points:**
- **Consent management UI** with granular patient preferences
- **Shield encryption** for data at rest (NRIC, clinical notes)
- **Audit trail** showing complete data access history
- **NEHR integration readiness**: FHIR-based data submission pipeline
- **DPO dashboard**: consent rates, access anomalies, pending breach assessments

---

### Demo Data Summary: Key Sample Records

#### Patients

| Name | NRIC | Age | Gender | Ethnicity | Conditions | Care Plan |
|---|---|---|---|---|---|---|
| Lim Wei Ming | S6234567A | 62 | M | Chinese | HTN, Hyperlipidaemia, Pre-DM | CV Risk Reduction |
| Tan Ah Kow | S5012345B | 74 | M | Chinese | DM, HTN, CKD Stage 3 | Diabetes Comprehensive |
| Mdm Siti Aminah | S5867890C | 68 | F | Malay | HTN, CHF (NYHA II) | Heart Failure Mgmt |
| Raj Kumar | S7145678D | 55 | M | Indian | DM Type 2, Obesity (BMI 34) | Diabetes + Weight Mgmt |
| Emily Chen | S8523456E | 41 | F | Chinese | Asthma (moderate persistent) | Respiratory Care |
| Ahmad Bin Ismail | S7098765F | 52 | M | Malay | HTN, Gout | Chronic Disease General |
| Dr. Padma Lakshmi | S6578901G | 60 | F | Indian | DM, Osteoarthritis | Diabetes + Ortho |
| Yeo Mei Ling | S9034567H | 32 | F | Chinese | Gestational DM (pregnant) | Maternity + DM |

#### Providers

| Name | Role | Specialty | Facility | MCR No |
|---|---|---|---|---|
| Dr. James Koh | Senior Consultant | Cardiology | Novena Hospital | M12345A |
| Dr. Priya Nair | Family Physician | General Practice | Toa Payoh Polyclinic | M23456B |
| Dr. Serena Loh | CMO / Endocrinologist | Endocrinology | Novena Hospital | M34567C |
| Dr. Faizal Rahman | Consultant | Respiratory Medicine | Novena Hospital | M45678D |
| Ms. Aisha Binte Rahman | Allied Health | Dietetics | Novena Hospital | AH56789 |
| Mr. David Lee | Pharmacist | Clinical Pharmacy | Novena Hospital | P67890E |
| Ms. Sarah Wong | Care Coordinator | Care Management | Novena Hospital | N78901F |
| Dr. Wong Kai Wen | Consultant | Orthopaedics | Novena Hospital | M89012G |

#### Facilities

| Facility | Type | Address | Beds | Daily Patients |
|---|---|---|---|---|
| Novena Medical Centre | Hospital | 1 Novena Medical Centre, S(308205) | 180 | 350 |
| Toa Payoh Polyclinic | Polyclinic | Blk 204 Lor 8 Toa Payoh, S(310204) | - | 280 |
| Bedok Polyclinic | Polyclinic | 11 Bedok North St 1, S(469662) | - | 240 |
| Jurong West Polyclinic | Polyclinic | 50 Jurong West St 61, S(648201) | - | 220 |
| Woodlands Polyclinic | Polyclinic | 10 Woodlands St 31, S(738579) | - | 200 |
| Tampines Polyclinic | Polyclinic | 1 Tampines St 41, S(529203) | - | 210 |

---

### Demo Script: 30-Minute Executive Walkthrough

| Time | Scene | Key Message | Wow Moment |
|---|---|---|---|
| 0-3 min | Introduction | MediConnect's challenges and Health Cloud vision | Before/after comparison slide |
| 3-8 min | Scene 1: Patient 360 | Single unified view eliminates data silos | FlexCard showing referral chain from polyclinic to hospital |
| 8-15 min | Scene 2: Care Plan | Structured clinical protocols reduce variation | One-click care plan from template with auto-assigned tasks |
| 15-20 min | Scene 3: Care Coordination | Seamless cross-facility handoff | Real-time BP trend chart with data from patient's home |
| 20-25 min | Scene 4: Patient Engagement | Proactive outreach reduces no-shows | Live WhatsApp message demo + no-show prediction score |
| 25-28 min | Scene 5: Dashboards | Data-driven population health management | Drill from org KPI to individual at-risk patient in 3 clicks |
| 28-30 min | Scene 6: Compliance | PDPA-ready from Day 1 | Consent management + NEHR readiness |

---

## 6. Appendix

### A. Glossary

| Term | Definition |
|---|---|
| **PDPA** | Personal Data Protection Act - Singapore's data privacy law |
| **NEHR** | National Electronic Health Record - Singapore's national health data platform |
| **HIB** | Health Information Bill - upcoming legislation mandating health data sharing |
| **HCSA** | Healthcare Services Act - Singapore's healthcare facility licensing law |
| **FHIR** | Fast Healthcare Interoperability Resources - HL7 standard for health data exchange |
| **CPF/Medisave** | Central Provident Fund - Singapore's mandatory health savings scheme |
| **MCR** | Medical Council Registration number |
| **LVH** | Left Ventricular Hypertrophy |
| **DASH Diet** | Dietary Approaches to Stop Hypertension |

### B. Key Assumptions for Estimates

1. Implementation team is based in APAC (Singapore/India/Philippines rates)
2. Standard Salesforce best practices followed (no heavily custom-coded solutions)
3. Client organisation has dedicated project team members for requirements and UAT
4. Data quality is reasonable (no major cleansing projects required)
5. One primary EHR integration for Scenarios 2+ (additional EHRs add 4-6 weeks each)
6. Licensing costs based on 2026 list pricing (volume discounts not applied)
7. Multi-year contracts typically offer 10-20% discount on Year 2+ licensing

### C. References

- [Salesforce Health Cloud Implementation Guide 2025 - Oxrow](https://oxrow.com/salesforce-health-cloud-implementation-guide-2025/)
- [Salesforce Health Cloud Pricing](https://www.salesforce.com/healthcare-life-sciences/health-cloud/pricing/)
- [Health Cloud Features - Salesforce Ben](https://www.salesforceben.com/salesforce-health-cloud/)
- [Singapore PDPA Healthcare Guidelines - MOHT](https://www.moht.com.sg/pdpa/)
- [Digital Health Laws Singapore - ICLG](https://iclg.com/practice-areas/digital-health-laws-and-regulations/singapore)
- [Singapore Healthcare Data Protection - Lexology](https://www.lexology.com/library/detail.aspx?g=b032c7b1-aa1b-4815-b3ee-4d5d24747734)

---

> **Disclaimer:** All cost estimates, timelines, and pricing in this document are indicative and based on publicly available information as of February 2026. Actual costs will vary based on specific requirements, negotiations with Salesforce and implementation partners, and organisational complexity. Salesforce pricing is subject to change. This document is for planning and pre-sales purposes only.
