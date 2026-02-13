# US-1.6.2: Role-Based Access Controls

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.6 - PDPA Consent & Security | **Estimate:** M (1-2 weeks)

## Overview

Configure role-based access controls ensuring clinicians see clinical data and admin staff see administrative data only. Implements PDPA minimum necessary principle with NRIC masking and audit trails.

**Business Value:** Ensures PDPA compliance, prevents unauthorised access to sensitive patient data, and creates an auditable security framework that satisfies regulatory requirements.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- Security requirements document from compliance team
- List of all user roles and data access needs

## Salesforce Configuration Steps

### Step 1: Create Profiles

| Profile | Base Profile | Description |
|---|---|---|
| HC Clinician | Standard User | Doctors, specialists — full clinical access |
| HC Care Coordinator | Standard User | Care coordinators — clinical + coordination |
| HC Nurse | Standard User | Nurses — clinical observation access |
| HC Admin Staff | Standard User | Registration, billing — administrative only |
| HC Management | Read Only | Clinic managers — reporting and oversight |
| HC System Admin | System Administrator | IT administrators |

### Step 2: Configure Field-Level Security

**Person Account (Patient) Fields:**

| Field | Clinician | Coordinator | Nurse | Admin Staff | Management |
|---|---|---|---|---|---|
| Name | R/W | R/W | R | R/W | R |
| NRIC__pc (raw) | R | R | Hidden | Hidden | Hidden |
| NRIC_Display__pc (masked) | R | R | R | R | R |
| PersonBirthdate | R/W | R/W | R | R/W | R |
| Gender__pc | R/W | R/W | R | R/W | R |
| Ethnicity__pc | R/W | R | R | R/W | R |
| Phone | R/W | R/W | R | R/W | R |
| PersonEmail | R/W | R/W | R | R/W | R |
| Emergency Contact | R/W | R/W | R | R/W | R |

**HealthCondition:**

| Field | Clinician | Coordinator | Nurse | Admin Staff | Management |
|---|---|---|---|---|---|
| All fields | R/W | R | R | Hidden | R |

**MedicationStatement:**

| Field | Clinician | Coordinator | Nurse | Admin Staff | Management |
|---|---|---|---|---|---|
| All fields | R/W | R | R | Hidden | R |

**AllergyIntolerance:**

| Field | Clinician | Coordinator | Nurse | Admin Staff | Management |
|---|---|---|---|---|---|
| All fields | R/W | R | R | Hidden | R |

**MemberPlan (Insurance):**

| Field | Clinician | Coordinator | Nurse | Admin Staff | Management |
|---|---|---|---|---|---|
| All fields | R | R | Hidden | R/W | R |

### Step 3: Configure NRIC Masking

**Formula Field: NRIC_Display__pc**
```
IF(
  LEN(NRIC__pc) = 9,
  LEFT(NRIC__pc, 1) & "****" & RIGHT(NRIC__pc, 3),
  NRIC__pc
)
```
Example: S1234567A → S****67A

- Full NRIC (NRIC__pc): visible only to Clinician and Coordinator profiles
- Masked NRIC (NRIC_Display__pc): visible to all profiles
- Use Shield Platform Encryption on NRIC__pc for at-rest encryption

### Step 4: Configure Record-Level Sharing

**Sharing Model:**
- Organisation-Wide Default for Person Account: **Private**
- Sharing is granted through:

| Mechanism | Scope |
|---|---|
| Care Team Membership | Care team members see their assigned patients |
| Facility Sharing Rule | Staff at facility see patients registered at that facility |
| Management Role Hierarchy | Managers see all patients at their facility and below |

**Sharing Rules:**

| Rule | Based On | Shares With | Access Level |
|---|---|---|---|
| Care Team Access | CareTeamMember.AccountId | Team member user | Read/Write |
| Facility Staff Access | Patient.Facility__c | Facility sharing group | Read Only |
| Coordinator All Access | Role = Care Coordinator | Care Coordinator group | Read/Write |

### Step 5: Enable Audit Trail

**Field History Tracking — Enable on:**
- Person Account: NRIC__pc, Name, PersonBirthdate
- HealthCondition: ClinicalStatus, Severity
- MedicationStatement: Status, Dosage__c
- AllergyIntolerance: Criticality
- Consent fields: all ConsentStatus changes

**Login History:**
- Monitor login times and IP addresses
- Alert on unusual access patterns (after-hours, unfamiliar IP)

**Setup Audit Trail:**
- Track all permission and security configuration changes
- Retain for regulatory period (minimum 5 years per PDPA)

### Step 6: Create Permission Sets for Elevated Access

| Permission Set | Purpose | Grants |
|---|---|---|
| PS_ViewFullNRIC | Registration staff verifying identity | Read access to NRIC__pc |
| PS_ClinicalDataExport | Compliance team data extraction | Export permission on clinical objects |
| PS_MergePatients | Data steward merge operations | Merge permission on Person Accounts |

### Step 7: Configure Session Security

- Session timeout: 15 minutes of inactivity
- Force re-login for sensitive operations (accessing NRIC)
- IP range restrictions for clinic network
- Multi-factor authentication for System Admin and DPO profiles

## Objects, Fields & Data Model

No new objects. Configuration on existing objects as detailed above.

**Key Formula Fields:**
- `NRIC_Display__pc` — masked NRIC for non-clinical display

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| Unauthorized Access Alert | Event Monitoring | Alert when user accesses patient outside their care team |
| NRIC Access Log | Apex Trigger | Logs every time full NRIC field is queried |
| Quarterly Access Review | Scheduled Report | List of users and their access levels for review |

## Security & Access

This IS the security configuration — see Steps 1-7 above for complete details.

## Testing Strategy

**Unit Tests:**
- Log in as each profile, verify visible/hidden fields
- Admin Staff cannot see clinical conditions or medications
- Clinician can see full NRIC, Admin Staff sees masked
- User cannot access patient outside their care team

**UAT Scenarios:**
1. Clinician views patient — sees all clinical data including full NRIC
2. Admin Staff views same patient — no conditions/medications visible, NRIC masked
3. Nurse records observation — can create but not edit diagnosis
4. Management views reports — aggregate data only, no edit
5. Provider not on care team tries to access patient — access denied
6. Audit trail shows all NRIC access events

## Deployment Checklist

- [ ] All 6 profiles created and configured
- [ ] Field-level security set for all objects per matrix
- [ ] NRIC_Display__pc formula field deployed
- [ ] Shield Platform Encryption enabled on NRIC__pc
- [ ] OWD set to Private for Person Account
- [ ] Sharing rules configured (Care Team, Facility, Coordinator)
- [ ] Permission sets created (ViewFullNRIC, DataExport, MergePatients)
- [ ] Field History Tracking enabled on sensitive fields
- [ ] Session security settings configured
- [ ] Audit trail enabled
- [ ] Tested with each profile type

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| Profiles: Clinician, Coordinator, Admin Staff, Management, System Admin | Verify 6 profiles exist in Setup |
| NRIC masked for non-clinical users (S****567A) | Log in as Admin Staff, check NRIC display |
| Record-level sharing: patients visible only to care team + facility | Access patient as non-team member, verify denied |
| Audit trail enabled on all sensitive fields | Edit sensitive field, verify history tracking |

## Dependencies

- **Blocked By:** US-1.1.1 (Patient data model must exist for FLS configuration)
- **Blocks:** All features (security must be in place before go-live)
