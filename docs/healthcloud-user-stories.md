# Health Cloud Implementation - User Stories

> **Document Version:** 1.0 | **Last Updated:** February 2026
> **Reference:** healthcloud-implementation-guide.md
> **Organisation:** Progressive implementation across 3 phases (MVP → Care Coordination → Enterprise)

---

## Phase 1: Foundation / MVP (Scenario 1) — 10-14 Weeks

### Epic 1.1: Patient 360

**US-1.1.1: Patient Profile Setup**
- **As a** clinic administrator
- **I want to** configure the Health Cloud Patient 360 data model with demographics, conditions, medications, and allergies
- **So that** all patient information is captured in a unified profile from Day 1
- **Acceptance Criteria:**
  - Patient record includes: name, NRIC, DOB, gender, ethnicity, language, address, phone, email, emergency contact
  - Conditions tracked with ICD-10 codes, status (active/resolved), and diagnosis date
  - Medications list with dosage, frequency, and prescribing physician
  - Allergies captured with reaction type and severity
  - Insurance information stored (policy number, coverage type, Medisave balance)
- **Estimate:** M

**US-1.1.2: Patient 360 FlexCard**
- **As a** clinician
- **I want to** see a unified FlexCard view of my patient's complete profile on a single screen
- **So that** I don't have to navigate multiple tabs to understand a patient's health status
- **Acceptance Criteria:**
  - FlexCard displays demographics, active conditions, current medications, allergies, and insurance at a glance
  - Clicking any section navigates to the full detail record
  - FlexCard loads within 2 seconds
  - Mobile-responsive for tablet use during consultations
- **Estimate:** S

**US-1.1.3: Patient Timeline**
- **As a** clinician
- **I want to** see a chronological timeline of all patient interactions, referrals, and clinical events
- **So that** I can quickly understand the patient's care journey
- **Acceptance Criteria:**
  - Timeline shows consultations, referrals, lab results, care plan changes, and communications
  - Events are filterable by type (clinical, administrative, engagement)
  - Each event shows date, provider, facility, and summary
  - Timeline loads historical data from migration
- **Estimate:** S

**US-1.1.4: Patient Search & Duplicate Detection**
- **As a** registration staff
- **I want to** search for patients by NRIC, name, or phone number with automatic duplicate detection
- **So that** I don't create duplicate patient records
- **Acceptance Criteria:**
  - Search by NRIC returns exact match
  - Search by name returns fuzzy matches (handles transliteration variations)
  - Duplicate detection triggers on NRIC, DOB + name combination
  - Merge workflow available for confirmed duplicates
- **Estimate:** S

---

### Epic 1.2: Basic Care Management

**US-1.2.1: Care Plan Templates**
- **As a** clinical lead
- **I want to** create standardised care plan templates for common conditions (diabetes, hypertension, cardiac)
- **So that** clinicians can quickly initiate evidence-based care plans from templates
- **Acceptance Criteria:**
  - At least 3 care plan templates created: Diabetes Management, Hypertension Control, Cardiac Risk Reduction
  - Each template includes: goals with measurable targets, standard tasks, care team roles, review schedule
  - Templates are versioned and can be updated without affecting active care plans
  - Clinical lead can create new templates without developer assistance
- **Estimate:** M

**US-1.2.2: Care Plan Creation & Assignment**
- **As a** clinician
- **I want to** create a care plan for a patient from a template and customise it for their specific needs
- **So that** the patient receives a structured, personalised treatment plan
- **Acceptance Criteria:**
  - Clinician selects a template and it auto-populates goals, tasks, and team
  - Goals can be modified (targets, timelines) per patient
  - Tasks can be added, removed, or reassigned
  - Care plan status: Draft → Active → Completed → Closed
  - Patient is notified when care plan is activated
- **Estimate:** M

**US-1.2.3: Care Team Assignment**
- **As a** care coordinator
- **I want to** assign a multi-disciplinary care team to a patient's care plan
- **So that** all team members know their responsibilities and can collaborate
- **Acceptance Criteria:**
  - Care team roles: Primary physician, specialist, care coordinator, nurse, allied health, pharmacist
  - Each team member can see the care plan and their assigned tasks
  - Team members receive notifications for new assignments
  - Care team panel visible on Patient 360 FlexCard
- **Estimate:** S

**US-1.2.4: Goal Tracking & Progress**
- **As a** clinician
- **I want to** track patient progress against care plan goals with measurable metrics
- **So that** I can identify patients who are on track, at risk, or off track
- **Acceptance Criteria:**
  - Goals display current value vs. target (e.g., BP 142/86 vs target <140/90)
  - Visual indicators: green (on track), amber (at risk), red (off track)
  - Progress automatically updated when new measurements are recorded
  - Goal history shows trend over time
- **Estimate:** S

**US-1.2.5: Task Management**
- **As a** care coordinator
- **I want to** manage care plan tasks with due dates, assignments, and status tracking
- **So that** nothing falls through the cracks in patient care
- **Acceptance Criteria:**
  - Tasks have: description, assigned to, due date, priority, status
  - Task statuses: Pending → In Progress → Completed → Cancelled
  - Overdue tasks auto-flagged and escalated to care coordinator
  - Tasks viewable per patient, per provider, and as a team dashboard
- **Estimate:** S

---

### Epic 1.3: Provider Management

**US-1.3.1: Provider Directory**
- **As a** care coordinator
- **I want to** search a provider directory by specialty, location, and availability
- **So that** I can quickly find and assign the right provider for a referral
- **Acceptance Criteria:**
  - Directory includes: name, specialty, facility, contact, MCR number, availability
  - Search/filter by specialty, facility, and language spoken
  - Provider profile shows current patient load and next available slot
  - Directory includes both internal and external referral providers
- **Estimate:** S

**US-1.3.2: Internal Referral Workflow**
- **As a** clinician
- **I want to** refer a patient to another provider within the network using a guided workflow
- **So that** the referral includes all necessary clinical context and the receiving provider is notified
- **Acceptance Criteria:**
  - OmniStudio guided flow for referral creation
  - Referral auto-populates patient demographics, conditions, and relevant notes
  - Referring clinician can add referral reason and urgency
  - Receiving provider gets notification with referral details
  - Referral tracked on patient timeline
- **Estimate:** M

---

### Epic 1.4: Reports & Dashboards

**US-1.4.1: Clinical Operations Dashboard**
- **As a** clinic manager
- **I want to** see a dashboard showing patient volumes, care plan compliance, and provider utilisation
- **So that** I can monitor clinic performance and identify bottlenecks
- **Acceptance Criteria:**
  - Metrics: total active patients, new patients this month, care plans (on track/at risk/off track)
  - Provider utilisation: patients per provider, appointment fill rate
  - Filterable by facility, date range, and specialty
  - Dashboard refreshes daily
- **Estimate:** S

**US-1.4.2: Patient Care Reports**
- **As a** clinician
- **I want to** generate patient care summary reports for referrals and discharge
- **So that** receiving providers have complete context on the patient's history and current plan
- **Acceptance Criteria:**
  - Report includes: demographics, conditions, medications, allergies, care plan summary, recent results
  - Exportable as PDF
  - Auto-generated from Health Cloud data (no manual entry)
  - Compliant with PDPA (excludes sensitive data based on consent)
- **Estimate:** S

---

### Epic 1.5: Data Migration

**US-1.5.1: Patient Data Migration**
- **As a** project team
- **I want to** migrate existing patient demographic data from the legacy system into Health Cloud
- **So that** clinicians have historical context from Day 1
- **Acceptance Criteria:**
  - All active patients migrated (demographics, conditions, allergies, medications)
  - Data validation: 100% NRIC uniqueness, no orphan records
  - Duplicate detection run pre-migration with resolution
  - Migration audit report generated showing counts and exceptions
  - Rollback plan documented and tested
- **Estimate:** L

**US-1.5.2: Provider Data Migration**
- **As a** project team
- **I want to** migrate provider directory data into Health Cloud
- **So that** the referral network is available at go-live
- **Acceptance Criteria:**
  - All active providers migrated (demographics, specialties, facilities, MCR numbers)
  - Provider-facility relationships maintained
  - Validation: no duplicate providers, all MCR numbers valid
- **Estimate:** S

---

### Epic 1.6: PDPA Consent & Security

**US-1.6.1: Digital Consent Capture**
- **As a** registration staff
- **I want to** capture PDPA consent digitally during patient registration using a guided form
- **So that** we have auditable consent records for all patients
- **Acceptance Criteria:**
  - OmniStudio consent form with granular options: treatment, research, marketing, SMS, email
  - Patient can opt in/out per channel and purpose
  - Consent recorded with timestamp, method (digital/paper), and staff who collected it
  - Consent viewable on Patient 360
- **Estimate:** M

**US-1.6.2: Role-Based Access Controls**
- **As a** system administrator
- **I want to** configure role-based access so clinicians see clinical data and admin staff see administrative data only
- **So that** patient data access complies with PDPA minimum necessary principle
- **Acceptance Criteria:**
  - Profiles: Clinician, Care Coordinator, Admin Staff, Management, System Admin
  - Field-level security: NRIC masked for non-clinical users (shows S****567A)
  - Record-level sharing: patients visible only to assigned care team + facility staff
  - Audit trail enabled on all sensitive fields
- **Estimate:** M

---

## Phase 2: Care Coordination Platform (Scenario 2) — 16-22 Weeks

*Builds on all Phase 1 stories*

### Epic 2.1: Advanced Care Plans

**US-2.1.1: Clinical Protocol Pathways**
- **As a** clinical lead
- **I want to** configure evidence-based clinical protocol pathways with branching logic
- **So that** care plans adapt based on patient responses and clinical outcomes
- **Acceptance Criteria:**
  - Pathways support conditional logic (IF HbA1c > 7% THEN escalate medication review)
  - Pathways trigger automated task creation based on patient milestones
  - Protocol versions tracked with change history
  - At least 5 clinical pathways: Diabetes, HTN, Cardiac, Respiratory, Chronic Disease General
- **Estimate:** L

**US-2.1.2: Care Plan Escalation Rules**
- **As a** care coordinator
- **I want to** receive automatic alerts when a patient's care plan metrics go off track
- **So that** I can intervene early before the condition worsens
- **Acceptance Criteria:**
  - Configurable thresholds per goal (e.g., BP > 160/100 triggers alert)
  - Escalation chain: care coordinator → primary physician → specialist
  - Alert delivery via in-app notification + email
  - Escalation history logged on the care plan
- **Estimate:** M

---

### Epic 2.2: EHR Integration (FHIR R4)

**US-2.2.1: FHIR R4 Patient Sync**
- **As a** system
- **I want to** sync patient demographics between Health Cloud and the hospital EHR via FHIR R4
- **So that** patient data is consistent across systems without manual re-entry
- **Acceptance Criteria:**
  - Bi-directional sync for Patient resource (demographics, contact, identifiers)
  - Sync triggers on create/update in either system
  - Conflict resolution: EHR is source of truth for clinical data, Health Cloud for engagement data
  - Error handling: failed syncs logged and retried (max 3 attempts), admin notified
  - Sync latency < 5 minutes
- **Estimate:** L

**US-2.2.2: Lab Results Integration**
- **As a** clinician
- **I want to** see lab results from the hospital LIS automatically appear in Health Cloud
- **So that** I can review results without switching to the EHR system
- **Acceptance Criteria:**
  - FHIR DiagnosticReport and Observation resources synced from LIS
  - Results displayed on Patient 360 timeline with date, test name, values, and reference ranges
  - Abnormal results visually flagged (red/amber)
  - Results update care plan goal progress automatically (e.g., HbA1c → diabetes goal)
- **Estimate:** L

**US-2.2.3: Clinical Orders Integration**
- **As a** clinician
- **I want to** create lab/imaging orders in Health Cloud that are sent to the hospital LIS/RIS via FHIR
- **So that** I can order tests without leaving the Health Cloud interface
- **Acceptance Criteria:**
  - FHIR ServiceRequest sent to LIS/RIS
  - Order catalogue available (common labs, imaging, procedures)
  - Order status tracked: Ordered → In Progress → Completed
  - Results flow back via US-2.2.2
- **Estimate:** L

---

### Epic 2.3: Patient Engagement

**US-2.3.1: Appointment Reminders (SMS)**
- **As a** patient
- **I want to** receive SMS reminders 2 days and same-day before my appointment
- **So that** I don't forget my appointments and can reschedule if needed
- **Acceptance Criteria:**
  - Automated SMS: 2 days before + same day morning
  - Message includes: date, time, provider name, location
  - Patient can reply C (confirm) or R (reschedule)
  - Responses logged in Health Cloud
  - Opt-out respected per PDPA consent
- **Estimate:** M

**US-2.3.2: WhatsApp Medication Reminders**
- **As a** patient on a chronic medication plan
- **I want to** receive daily WhatsApp reminders with my medication list
- **So that** I maintain medication adherence
- **Acceptance Criteria:**
  - Daily message at configured time (default 8 AM) via WhatsApp Business API
  - Message lists current medications with dosage
  - Patient can acknowledge receipt
  - Non-acknowledgement after 3 days triggers care coordinator task
  - Opt-in required (separate from SMS consent)
- **Estimate:** M

**US-2.3.3: Patient Portal - Home Readings**
- **As a** patient
- **I want to** log my home BP readings, blood glucose, and weight via a patient portal
- **So that** my care team can monitor my progress between visits
- **Acceptance Criteria:**
  - Web portal with simple data entry forms for BP, glucose, weight
  - Readings flow into Health Cloud and update care plan goal tracking
  - Patient can view their own trend charts
  - Missing readings (3+ days) trigger automated outreach
- **Estimate:** M

**US-2.3.4: Health Education Content Delivery**
- **As a** care coordinator
- **I want to** schedule automated health education content to patients based on their condition
- **So that** patients receive relevant information that supports their care plan
- **Acceptance Criteria:**
  - Content library: articles, videos, PDFs linked to conditions
  - Delivery schedule configurable per care plan template (e.g., Week 1: BP education, Week 3: diet tips)
  - Content sent via email or WhatsApp based on patient preference
  - Delivery and open rates tracked
- **Estimate:** S

---

### Epic 2.4: SDOH & Population Health

**US-2.4.1: Social Determinants of Health Tracking**
- **As a** care coordinator
- **I want to** record social determinants (housing, employment, food security, social support) for patients
- **So that** we can identify non-clinical factors affecting health outcomes
- **Acceptance Criteria:**
  - SDOH assessment form (based on standard screening tools)
  - SDOH data visible on Patient 360
  - SDOH flags integrated into risk scoring
  - Reporting by SDOH category across patient population
- **Estimate:** S

**US-2.4.2: Population Health Dashboard**
- **As a** CMO
- **I want to** see population-level health outcomes across all facilities
- **So that** I can identify care gaps, benchmark facilities, and track programme effectiveness
- **Acceptance Criteria:**
  - Metrics: patient counts by condition, care plan compliance rates, outcome trends
  - Drill-down: organisation → facility → department → individual patient
  - Facility benchmarking: compliance %, NPS, readmission rates side by side
  - Risk stratification: high/medium/low risk patient counts with AI scoring
  - Dashboard refreshes daily, exportable to PDF/Excel
- **Estimate:** M

---

### Epic 2.5: Cross-Facility Coordination

**US-2.5.1: Cross-Facility Referral Workflow**
- **As a** care coordinator
- **I want to** refer patients across facilities (hospital ↔ polyclinic) with full clinical context transfer
- **So that** the receiving facility has everything they need without re-collecting information
- **Acceptance Criteria:**
  - OmniStudio guided flow for cross-facility referral
  - Clinical summary auto-attached (conditions, medications, care plan, recent results)
  - Receiving facility notified in real-time
  - Referral tracked on patient timeline across both facilities
  - Bi-directional status updates (accepted, scheduled, completed)
- **Estimate:** M

**US-2.5.2: Shared Care Plan Visibility**
- **As a** GP at a polyclinic
- **I want to** see the specialist care plan created at the hospital for my referred patient
- **So that** I can coordinate follow-up care aligned with the specialist's plan
- **Acceptance Criteria:**
  - Care plans visible to all care team members regardless of facility
  - GP can add tasks and notes to the shared care plan
  - Changes visible in real-time across facilities
  - Access controlled by care team membership (not facility)
- **Estimate:** S

---

## Phase 3: Enterprise Digital Transformation (Scenario 3) — 28-40 Weeks

*Builds on all Phase 1 & 2 stories*

### Epic 3.1: Utilisation Management

**US-3.1.1: Prior Authorisation Workflow**
- **As a** utilisation management staff
- **I want to** process prior authorisation requests with automated clinical criteria checking
- **So that** approvals are faster and consistent with evidence-based guidelines
- **Acceptance Criteria:**
  - Request form captures: procedure, diagnosis, clinical justification, supporting documents
  - Auto-check against clinical criteria (InterQual/Milliman rules)
  - Workflow: Submitted → Under Review → Approved/Denied/Pended
  - SLA tracking: average turnaround time, ageing requests dashboard
  - Appeals workflow for denied requests
- **Estimate:** L

**US-3.1.2: Concurrent Review**
- **As a** UM nurse reviewer
- **I want to** track inpatient stays with daily concurrent review and length-of-stay monitoring
- **So that** we ensure appropriate utilisation while maintaining quality of care
- **Acceptance Criteria:**
  - Daily review checklist linked to admission
  - LOS compared against benchmarks by diagnosis/procedure
  - Auto-alerts when LOS exceeds expected range
  - Discharge planning tasks auto-created at admission
- **Estimate:** M

---

### Epic 3.2: Multi-Channel Patient Engagement

**US-3.2.1: Patient Mobile App Integration**
- **As a** patient
- **I want to** access my health information, appointments, and care plan through a mobile app
- **So that** I can manage my health on the go
- **Acceptance Criteria:**
  - App features: appointment booking/rescheduling, care plan view, medication list, secure messaging
  - Home readings submission (BP, glucose, weight)
  - Push notifications for reminders and alerts
  - Biometric login (fingerprint/face)
  - PDPA consent management within app
- **Estimate:** L

**US-3.2.2: Chatbot for Patient Triage**
- **As a** patient
- **I want to** use a chatbot to describe my symptoms and get guidance on next steps
- **So that** I know whether to visit the clinic, go to ED, or manage at home
- **Acceptance Criteria:**
  - Symptom assessment using clinically validated decision trees
  - Output: self-care advice, book appointment, or go to ED
  - Chat history saved to patient record
  - Escalation to live agent (care coordinator) if needed
  - Available 24/7 via web portal and mobile app
- **Estimate:** L

**US-3.2.3: No-Show Prediction & Prevention**
- **As a** patient engagement team
- **I want to** use AI to predict which patients are likely to no-show and proactively intervene
- **So that** we reduce no-show rates and revenue loss
- **Acceptance Criteria:**
  - Predictive model scores patients 0-100 for no-show risk
  - High-risk patients (>70 score) get personal call from coordinator
  - Medium-risk (40-70) get additional SMS reminder
  - Waitlist management: cancelled slots auto-offered to waitlisted patients
  - Dashboard tracks prediction accuracy and no-show rate trends
- **Estimate:** M

---

### Epic 3.3: Agentforce AI

**US-3.3.1: AI-Powered Patient Scheduling Agent**
- **As a** patient
- **I want to** book, reschedule, or cancel appointments by chatting with an AI agent
- **So that** I don't have to call the clinic during business hours
- **Acceptance Criteria:**
  - Natural language understanding for scheduling requests
  - Agent checks provider availability and patient preferences
  - Handles rescheduling and cancellation with reason capture
  - Confirms via SMS/WhatsApp after booking
  - Seamless handoff to human agent for complex requests
- **Estimate:** M

**US-3.3.2: AI Care Summary Generation**
- **As a** clinician
- **I want to** generate an AI-powered care summary for a patient before their appointment
- **So that** I'm prepared with the latest context in 30 seconds instead of 5 minutes
- **Acceptance Criteria:**
  - One-click summary generation from Patient 360
  - Summary includes: recent changes, upcoming tasks, trend alerts, outstanding items
  - Tone: clinical, concise, actionable
  - Clinician can edit before saving to record
  - Audit trail on AI-generated content
- **Estimate:** M

---

### Epic 3.4: Data Cloud & Advanced Analytics

**US-3.4.1: Unified Patient Profile (Data Cloud)**
- **As a** system
- **I want to** harmonise patient data from Health Cloud, EHR, billing, and engagement systems into a unified Data Cloud profile
- **So that** every team has a consistent, complete view of the patient
- **Acceptance Criteria:**
  - Data streams: Health Cloud, Epic EHR, SAP billing, WhatsApp engagement, patient portal
  - Identity resolution: match patients across systems using NRIC + DOB
  - Unified profile available for segmentation, analytics, and AI
  - Real-time data refresh (< 15 min latency)
- **Estimate:** L

**US-3.4.2: AI Risk Stratification**
- **As a** CMO
- **I want to** use AI to automatically risk-stratify all chronic disease patients
- **So that** care teams can prioritise high-risk patients for proactive intervention
- **Acceptance Criteria:**
  - Risk score (0-100) calculated for all chronic disease patients
  - Factors: clinical data, appointment adherence, medication compliance, SDOH, age
  - Top risk patients surfaced in daily care coordinator worklist
  - Risk scores refresh daily
  - Model accuracy tracked and reported quarterly
- **Estimate:** L

**US-3.4.3: Predictive Readmission Model**
- **As a** quality team
- **I want to** predict which discharged patients are at high risk of readmission within 30 days
- **So that** we can deploy post-discharge interventions to reduce readmission rates
- **Acceptance Criteria:**
  - Model scores discharged patients on readmission risk
  - High-risk patients auto-enrolled in post-discharge follow-up programme
  - Care coordinator receives daily worklist of high-risk discharges
  - Track predicted vs. actual readmission rates
  - Target: reduce cardiac readmission rate from 18% to <12%
- **Estimate:** L

---

### Epic 3.5: Advanced Integrations

**US-3.5.1: Billing System Integration (SAP)**
- **As a** billing administrator
- **I want to** sync patient encounters and insurance claims between Health Cloud and SAP
- **So that** billing is automated and claims are submitted faster
- **Acceptance Criteria:**
  - Encounter data (consultation, procedures, diagnosis codes) sent to SAP
  - Insurance eligibility verification before appointment
  - Claims status (submitted, approved, rejected) visible in Health Cloud
  - Reconciliation dashboard for billing team
- **Estimate:** L

**US-3.5.2: Wearable Device Data Integration**
- **As a** patient with a prescribed wearable device
- **I want to** have my wearable health data (heart rate, activity, sleep) flow into Health Cloud
- **So that** my care team has a more complete picture of my daily health
- **Acceptance Criteria:**
  - Integration with common health platforms (Apple Health, Google Fit)
  - Data types: heart rate, steps, sleep, SpO2
  - Abnormal readings trigger care plan alerts
  - Patient consent required for wearable data sharing
  - Data displayed on Patient 360 timeline
- **Estimate:** M

---

### Epic 3.6: NEHR & Regulatory Compliance

**US-3.6.1: NEHR Data Submission**
- **As a** compliance team
- **I want to** automatically submit required patient data to Singapore's NEHR via FHIR R4
- **So that** we comply with the upcoming Health Information Bill requirements
- **Acceptance Criteria:**
  - FHIR R4 endpoints configured for NEHR submission
  - Data submitted: demographics, diagnoses, medications, allergies, immunisations
  - Patient opt-out check before each submission
  - Batch submission daily at 2:00 AM SGT
  - Submission audit log with success/failure tracking
  - Reconciliation report for compliance team
- **Estimate:** L

**US-3.6.2: Breach Detection & Response Workflow**
- **As a** Data Protection Officer
- **I want to** have an automated breach assessment and notification workflow
- **So that** we meet the PDPA 3-day breach notification requirement
- **Acceptance Criteria:**
  - Breach assessment form with severity scoring
  - 3-day countdown timer triggered on breach detection
  - Auto-generated notification templates for PDPC and affected patients
  - Incident log with remediation tracking
  - DPO dashboard: open incidents, breach history, consent anomalies
- **Estimate:** M

---

## Summary

| Phase | Epic Count | User Story Count | Estimated Duration |
|---|---|---|---|
| Phase 1: MVP | 6 epics | 14 stories | 10-14 weeks |
| Phase 2: Care Coordination | 5 epics | 10 stories | 16-22 weeks |
| Phase 3: Enterprise | 6 epics | 12 stories | 28-40 weeks |
| **Total** | **17 epics** | **36 stories** | **Progressive** |

### T-Shirt Size Legend
- **XS**: < 1 day
- **S**: 1-3 days
- **M**: 1-2 weeks
- **L**: 2+ weeks (consider splitting)

---

> **Note:** User stories are sized relative to implementation effort. Stories marked "L" should be broken into sub-tasks during sprint planning. Phase dependencies are sequential — Phase 2 builds on Phase 1, Phase 3 builds on Phase 2.
