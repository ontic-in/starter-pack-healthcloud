# US-1.6.1: Digital Consent Capture

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.6 - PDPA Consent & Security | **Estimate:** M (1-2 weeks)

## Overview

Implement digital PDPA consent capture during patient registration using an OmniStudio guided form. Patients can provide granular consent for treatment, research, marketing, SMS, and email communications.

**Business Value:** Ensures PDPA compliance from Day 1, creates auditable consent records, eliminates paper consent forms, and enables channel-specific marketing/communications based on patient preferences.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- OmniStudio installed
- PDPA consent requirements reviewed by legal/compliance team

## Salesforce Configuration Steps

### Step 1: Configure Consent Objects

**Object: Individual** (Salesforce standard — linked to Person Account)

**Object: ContactPointTypeConsent** (or custom IndividualConsent__c)

| Field | API Name | Type |
|---|---|---|
| Individual | `IndividualId` | Lookup(Individual) |
| Purpose | `Purpose__c` | Picklist |
| Channel | `Channel__c` | Picklist |
| Consent Status | `ConsentStatus` | Picklist(OptIn, OptOut, NotProvided) |
| Capture Method | `Capture_Method__c` | Picklist(Digital, Paper, Verbal, Portal) |
| Captured Date | `CaptureDate` | DateTime |
| Captured By | `Captured_By__c` | Lookup(User) |
| Expiry Date | `Expiry_Date__c` | Date |
| IP Address | `IP_Address__c` | Text (for portal consent) |
| Consent Document Version | `Document_Version__c` | Text |

**Consent Purpose Values (PDPA-aligned):**

| Purpose | Description |
|---|---|
| Treatment | Use of data for medical treatment |
| Care Coordination | Sharing data with care team members |
| Referral Sharing | Sharing clinical data with referral providers |
| Research | Use of anonymised data for research |
| Marketing | Receiving marketing communications |
| Quality Improvement | Use of data for quality metrics |

**Consent Channel Values:**

| Channel | Description |
|---|---|
| SMS | Text message communications |
| Email | Email communications |
| WhatsApp | WhatsApp messages |
| Phone | Phone calls |
| Post | Physical mail |
| Portal | Patient portal notifications |

### Step 2: Create OmniScript — Consent Capture

**OmniScript: CaptureConsent**

**Step 1 — Patient Identification**
- Auto-populated from patient context
- Display: Name, NRIC (masked), DOB
- Confirm patient identity

**Step 2 — Treatment & Care Consent**
- Treatment data use: OptIn / OptOut (mandatory for treatment)
- Care team data sharing: OptIn / OptOut
- Referral data sharing: OptIn / OptOut
- Explanation text for each option (in patient's preferred language)

**Step 3 — Communication Preferences**
- SMS reminders: OptIn / OptOut
- Email communications: OptIn / OptOut
- WhatsApp messages: OptIn / OptOut
- Phone calls: OptIn / OptOut
- Marketing communications: OptIn / OptOut

**Step 4 — Research & Quality**
- Anonymised research participation: OptIn / OptOut
- Quality improvement data use: OptIn / OptOut

**Step 5 — Confirmation**
- Summary of all consent choices
- PDPA notice text (legally required disclosure)
- Digital signature capture (optional but recommended)
- Timestamp recorded automatically

### Step 3: Add Consent Display to Patient 360 FlexCard

**Child FlexCard: FC-ConsentStatus**
- Data Source: DR-PatientConsent
- Display: Compact grid showing each purpose/channel with green (OptIn) / red (OptOut) badges
- "Last Updated" timestamp
- Action: "Update Consent" button → launches CaptureConsent OmniScript

### Step 4: Configure Consent Audit Trail

Enable Field History Tracking on all consent fields:
- Track: ConsentStatus changes with old/new value, date, user
- Retention: Indefinite (regulatory requirement)

**Consent Audit Report:**
- All consent changes by patient
- Date, changed by, old value, new value
- Exportable for compliance reviews

### Step 5: Consent Enforcement Integration

**Apex Utility: ConsentChecker**
```
public class ConsentChecker {
    // Check if patient has opted in for a specific purpose+channel
    public static Boolean hasConsent(Id patientId, String purpose, String channel) {
        // Query IndividualConsent for the patient
        // Return true if OptIn, false if OptOut or NotProvided
    }
}
```

Used by:
- US-1.4.2 (Patient Care Reports — filter data based on consent)
- US-2.3.1 (SMS Reminders — check SMS consent before sending)
- US-2.3.2 (WhatsApp — check WhatsApp consent before sending)

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| CaptureConsent | OmniScript | Guided consent capture form |
| ConsentExpiryAlert | Scheduled Flow | Alert 30 days before consent expires |
| ConsentWithdrawal | Screen Flow | Process for patient to withdraw consent |
| ConsentAuditReport | Scheduled Report | Weekly consent audit for compliance team |

## Security & Access

| Profile | View Consent | Capture Consent | Modify Consent | View Audit |
|---|---|---|---|---|
| Registration Staff | Yes | Yes | No | No |
| Clinician | Yes | No | No | No |
| Care Coordinator | Yes | Yes | No | No |
| DPO / Compliance | Yes | No | Yes | Yes |
| System Admin | Yes | Yes | Yes | Yes |

## Testing Strategy

**UAT Scenarios:**
1. Capture consent during registration — all options presented
2. Patient opts out of SMS — verify SMS reminders not sent (Phase 2)
3. View consent on Patient 360 — all statuses displayed correctly
4. Update consent — audit trail shows old/new values
5. Consent expiry alert fires 30 days before expiry

## Deployment Checklist

- [ ] Individual object linked to Person Accounts
- [ ] Consent custom fields/object deployed
- [ ] CaptureConsent OmniScript deployed
- [ ] FC-ConsentStatus FlexCard added to Patient 360
- [ ] Field History Tracking enabled
- [ ] ConsentChecker Apex class deployed
- [ ] ConsentExpiryAlert scheduled flow active
- [ ] PDPA notice text approved by legal

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| OmniStudio form with granular options (treatment, research, marketing, SMS, email) | Complete OmniScript, verify all options |
| Patient can opt in/out per channel and purpose | Make selections, verify saved correctly |
| Consent recorded with timestamp, method, staff | Query consent record, verify fields |
| Consent viewable on Patient 360 | Open Patient 360, verify consent FlexCard |

## Dependencies

- **Blocked By:** US-1.1.1 (Patient Profile), US-1.1.2 (FlexCard for display)
- **Blocks:** US-1.4.2 (PDPA-aware reports), US-2.3.1 (SMS consent check), US-2.3.2 (WhatsApp consent check)
