# US-1.2.3: Care Team Assignment

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.2 - Basic Care Management | **Estimate:** S (1-3 days)

## Overview

Configure multi-disciplinary care team assignment to patient care plans. Care teams define who is responsible for the patient's care and enable role-based task assignment and notifications.

**Business Value:** Ensures clear accountability for patient care, enables coordinated multi-disciplinary treatment, and provides visibility into care team composition on the Patient 360 FlexCard.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- US-1.2.2 (Care Plan Creation) completed
- Provider accounts created in the system

## Salesforce Configuration Steps

### Step 1: Configure Care Team Roles

Navigate to **Setup > Health Cloud Admin > Care Team**

| Role | API Value | Description |
|---|---|---|
| Primary Physician | `Primary_Physician` | Lead clinician managing the patient |
| Specialist | `Specialist` | Consulting specialist (cardiologist, endocrinologist, etc.) |
| Care Coordinator | `Care_Coordinator` | Coordinates care plan activities and follow-ups |
| Nurse | `Nurse` | Nursing care and routine monitoring |
| Allied Health | `Allied_Health` | Physiotherapist, dietitian, psychologist |
| Pharmacist | `Pharmacist` | Medication management and review |

### Step 2: Configure CareTeam and CareTeamMember Objects

**CareTeam Object:**
- One CareTeam per patient (not per care plan)
- Linked to Patient Account
- Status: Active / Inactive

**CareTeamMember Configuration:**

| Field | API Name | Type |
|---|---|---|
| Care Team | `CareTeamId` | Lookup(CareTeam) |
| Member | `AccountId` | Lookup(Account - Provider) |
| Role | `Role` | Picklist (configured in Step 1) |
| Start Date | `PeriodStartDate` | Date |
| End Date | `PeriodEndDate` | Date |
| Status | `Status` | Picklist (Active, Inactive) |
| Is Primary | `Is_Primary__c` | Checkbox |

### Step 3: Create Care Team Assignment Flow

**Flow: AssignCareTeam**
- Triggered from: Care Plan creation OmniScript (Step 4) or standalone action
- Steps:
  1. Check if patient already has a CareTeam → if yes, reuse
  2. If no CareTeam, create one for the patient
  3. For each template role, search and select provider
  4. Create CareTeamMember records
  5. Send notification to each new team member

**Provider Selection UI:**
- Search by name, specialty, facility
- Show current patient load (count of active care team memberships)
- Show next available slot (if scheduling integrated)
- Filter by language spoken (Singapore multilingual context)

### Step 4: Configure Notifications

| Event | Recipient | Channel |
|---|---|---|
| Added to care team | New team member | In-App + Email |
| Removed from care team | Removed member | In-App |
| New task assigned | Specific team member | In-App + Email |
| Care plan status change | All team members | In-App |

**Notification Template (Added to Care Team):**
```
Subject: New Care Team Assignment
Body: You have been added to the care team for {Patient Name} as {Role}.
Care Plan: {Care Plan Name}
View Patient: {Link to Patient Record}
```

### Step 5: Add Care Team to Patient 360 FlexCard

**Child FlexCard: FC-CareTeam**
- Data Source: DataRaptor `DR-PatientCareTeam`
- Display: Role icon, Provider name, Specialty, Phone
- Layout: Compact list with role badges
- Action: Click provider name → navigate to provider record

**DataRaptor: DR-PatientCareTeam (Extract)**
- Source: CareTeamMember
- Join: Account (Provider details)
- Filter: `CareTeam.PatientId = :AccountId AND Status = 'Active'`
- Sort: Role (Primary first)

### Step 6: Care Team Dashboard View

Create list views for providers to see their care team assignments:

**My Patients (per provider):**
- Filter: CareTeamMember.AccountId = current user's provider account
- Columns: Patient Name, Role, Care Plan, Last Activity, Next Task Due
- Sort: Next Task Due (ascending)

## Objects, Fields & Data Model

**Standard Objects:**
- `CareTeam` — Group of providers assigned to a patient
- `CareTeamMember` — Individual provider assignment with role

**Custom Fields:**

| Object | Field | API Name | Type |
|---|---|---|---|
| CareTeamMember | Is Primary | `Is_Primary__c` | Checkbox |
| CareTeamMember | Notification Preference | `Notification_Pref__c` | Picklist(All, Critical Only, None) |

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| AssignCareTeam | Screen Flow | Guided care team assignment |
| New Member Notification | Flow | Sends notification when added to team |
| Task Assignment Sync | Apex Trigger | When care plan task assigned to role, maps to specific team member |
| One Primary Rule | Validation Rule | Only one Primary Physician per CareTeam |

## Security & Access

- Care team members can view the patient's care plan and their assigned tasks
- Non-care-team providers cannot see patient clinical data (unless facility-level access)
- Care Coordinators can manage care team composition
- Clinicians can view but not modify care team (request changes through coordinator)

## Testing Strategy

**Unit Tests:**
- Create care team, add members, verify roles
- Validate one-primary-physician rule
- Notification sent on team assignment
- Care team appears on Patient 360 FlexCard

**UAT Scenarios:**
1. Create new care plan — care team auto-suggested from template
2. Add specialist to existing care team — notification sent
3. View Patient 360 — care team panel shows all members with roles
4. Provider logs in — sees "My Patients" list with assignments
5. Remove team member — notification sent, member loses patient access

## Deployment Checklist

- [ ] Care Team roles configured
- [ ] CareTeam and CareTeamMember objects configured
- [ ] Custom fields deployed
- [ ] AssignCareTeam flow deployed
- [ ] Notification flows active
- [ ] FC-CareTeam FlexCard added to Patient 360
- [ ] "My Patients" list view created
- [ ] One-primary validation rule active

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| Roles: Primary physician, specialist, coordinator, nurse, allied health, pharmacist | Check picklist values on CareTeamMember |
| Team members see care plan and their tasks | Log in as team member, verify access |
| Notifications for new assignments | Add team member, verify notification received |
| Care team visible on Patient 360 FlexCard | Open Patient 360, verify care team panel |

## Dependencies

- **Blocked By:** US-1.2.2 (Care Plan Creation), US-1.1.2 (FlexCard for display)
- **Blocks:** US-1.2.5 (Task Management — tasks assigned to team members), US-2.5.2 (Shared Care Plan Visibility)
