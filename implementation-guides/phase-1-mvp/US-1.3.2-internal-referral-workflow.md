# US-1.3.2: Internal Referral Workflow

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.3 - Provider Management | **Estimate:** M (1-2 weeks)

## Overview

Implement an OmniStudio guided flow for clinicians to refer patients to other providers within the network. The referral auto-populates clinical context and notifies the receiving provider.

**Business Value:** Eliminates paper-based referrals, reduces referral processing time from 3-5 days to same-day, and ensures receiving providers have complete clinical context for the first visit.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- US-1.3.1 (Provider Directory) completed
- OmniStudio installed

## Salesforce Configuration Steps

### Step 1: Configure ClinicalServiceRequest Object

**Object:** `ClinicalServiceRequest` (Health Cloud standard)

| Field | API Name | Type |
|---|---|---|
| Patient | `PatientId` | Lookup(Account) |
| Referring Provider | `RequesterId` | Lookup(Account) |
| Receiving Provider | `PerformerId` | Lookup(Account) |
| Referral Reason | `ReasonText` | Long Text |
| Urgency | `Priority` | Picklist(Routine, Urgent, Emergency) |
| Specialty Requested | `Specialty_Requested__c` | Picklist |
| Status | `Status` | Picklist |
| Clinical Summary | `Clinical_Summary__c` | Long Text |
| Referral Date | `AuthoredOn` | DateTime |
| Appointment Date | `Appointment_Date__c` | DateTime |
| Outcome Notes | `Outcome_Notes__c` | Long Text |

**Referral Status Lifecycle:**

| Status | Description | Next |
|---|---|---|
| Draft | Being prepared | Submitted |
| Submitted | Sent to receiving provider | Accepted, Rejected |
| Accepted | Receiving provider accepted | Scheduled |
| Rejected | Receiving provider declined | Submitted (re-route) |
| Scheduled | Appointment booked | Completed |
| Completed | Referral visit done, notes added | — |
| Cancelled | Referral no longer needed | — |

### Step 2: Create OmniScript — Referral Creation

**OmniScript: CreateReferral**

**Step 1 — Patient Context (Auto-populated)**
- Patient Name, NRIC, DOB, Gender
- Active Conditions (from HealthCondition)
- Current Medications (from MedicationStatement)
- Known Allergies (from AllergyIntolerance)
- All read-only, pre-filled from patient record

**Step 2 — Referral Details**
- Reason for Referral (text area)
- Urgency: Routine / Urgent / Emergency
- Specialty Requested (picklist)
- Additional Notes / Clinical Questions
- Attach documents (optional file upload)

**Step 3 — Select Receiving Provider**
- Embedded ProviderSearch (from US-1.3.1)
- Filtered by requested specialty
- Shows availability and patient load
- Clinician selects provider

**Step 4 — Review & Submit**
- Summary: Patient, Reason, Urgency, Provider
- Clinical summary auto-generated from patient data
- Edit option for clinical summary
- Submit button

### Step 3: Auto-Generate Clinical Summary

**Integration Procedure: GenerateClinicalSummary**
- Inputs: PatientId
- Gathers: Demographics, Active Conditions (with ICD-10), Current Medications, Allergies, Recent Care Plan Goals
- Output: Formatted text summary

Template:
```
REFERRAL CLINICAL SUMMARY
Patient: {Name}, {NRIC_Display}, {Age}y {Gender}
DOB: {DOB}

ACTIVE CONDITIONS:
- {Condition1} ({ICD10}) - {Status} since {OnsetDate}
- {Condition2} ({ICD10}) - {Status} since {OnsetDate}

CURRENT MEDICATIONS:
- {Med1} {Dosage} {Frequency}
- {Med2} {Dosage} {Frequency}

ALLERGIES:
- {Allergen1} ({Criticality}) - {Reaction}

CARE PLAN GOALS:
- {Goal1}: Current {Value} vs Target {Target} ({Status})
```

### Step 4: Configure Notifications

| Event | Recipient | Channel |
|---|---|---|
| Referral Submitted | Receiving Provider | In-App + Email |
| Referral Accepted | Referring Provider | In-App |
| Referral Rejected | Referring Provider | In-App + Email |
| Referral Scheduled | Patient (if consented) | SMS |
| Referral Completed | Referring Provider | In-App |

### Step 5: Add Referral to Patient Timeline

Configure timeline event type for referrals:
- Icon: Arrow-right (purple)
- Display: Referral date, Receiving Provider, Specialty, Status
- Click: Navigate to ClinicalServiceRequest record

### Step 6: Create Referral Tracking Dashboard

| Widget | Data |
|---|---|
| Open Referrals | Count by status |
| Average Processing Time | Submitted → Scheduled |
| Rejection Rate | Rejected / Total |
| Referrals by Specialty | Bar chart |
| Top Referring Providers | Table |

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| CreateReferral OmniScript | OmniScript | Guided referral creation |
| GenerateClinicalSummary | Integration Procedure | Auto-generates clinical summary |
| ReferralStatusNotification | Flow | Sends notifications on status changes |
| ReferralTimelineEvent | Apex Trigger | Creates timeline event for referral |
| ReferralSLAAlert | Scheduled Flow | Alerts if referral not actioned within SLA |

**SLA Configuration:**
- Routine: Action within 5 business days
- Urgent: Action within 1 business day
- Emergency: Action within 4 hours

## Security & Access

- Referring clinician: Full access to referrals they created
- Receiving provider: Read access to referral and patient clinical summary
- Care Coordinator: View and manage all referrals for their patients
- Patient data in clinical summary respects PDPA consent

## Testing Strategy

**UAT Scenarios:**
1. Clinician creates referral — patient data auto-populated
2. Clinical summary generated correctly with conditions, meds, allergies
3. Receiving provider gets notification with referral details
4. Provider accepts referral — referring clinician notified
5. Referral appears on patient timeline
6. Urgent referral not actioned in 24h — SLA alert fires

## Deployment Checklist

- [ ] ClinicalServiceRequest custom fields deployed
- [ ] Status picklist configured
- [ ] CreateReferral OmniScript deployed
- [ ] GenerateClinicalSummary Integration Procedure deployed
- [ ] Notification flows active
- [ ] Timeline event type configured
- [ ] Referral dashboard deployed
- [ ] SLA alert scheduled flow active

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| OmniStudio guided flow for referral creation | Launch OmniScript, complete all steps |
| Auto-populates patient demographics, conditions, notes | Verify pre-filled data matches patient record |
| Clinician can add referral reason and urgency | Fill in referral details, verify saved |
| Receiving provider gets notification | Submit referral, verify notification |
| Referral tracked on patient timeline | Check timeline after referral submission |

## Dependencies

- **Blocked By:** US-1.3.1 (Provider Directory), US-1.1.1 (Patient Profile), US-1.1.3 (Timeline)
- **Blocks:** US-2.5.1 (Cross-Facility Referral — extends this workflow)
