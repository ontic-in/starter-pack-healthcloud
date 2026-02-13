# US-1.2.2: Care Plan Creation & Assignment

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.2 - Basic Care Management | **Estimate:** M (1-2 weeks)

## Overview

Enable clinicians to create personalised care plans from templates using an OmniStudio guided flow. The flow auto-populates goals, tasks, and care team from the template while allowing customisation per patient.

**Business Value:** Standardises care delivery while preserving clinical flexibility. Reduces care plan setup from 30+ minutes of manual entry to under 5 minutes of guided template-based creation.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- US-1.2.1 (Care Plan Templates) completed
- OmniStudio managed package installed

## Salesforce Configuration Steps

### Step 1: Create OmniScript — Care Plan Creation

**OmniScript: CreateCarePlan**
- Type: Patient Action
- Entry Point: Patient Record Page (Action Button)

**Step 1: Select Template**
- Display available templates filtered by patient's active conditions
- Show template name, condition, description, number of goals/tasks
- Allow search/filter by condition
- DataRaptor: `DR-AvailableTemplates`

**Step 2: Review & Customise Goals**
- Auto-populated from template
- Editable fields per goal: Target value, target date, review frequency
- Add/remove goals
- Validation: at least one goal required

**Step 3: Review & Customise Tasks**
- Auto-populated from template
- Editable fields: description, assigned to (from care team), due date, priority
- Add/remove tasks
- Bulk date assignment: set care plan start date and auto-calculate all task dates

**Step 4: Assign Care Team**
- Pre-populated from template roles
- Clinician selects specific providers for each role
- Provider search by name, specialty
- DataRaptor: `DR-ProviderSearch`

**Step 5: Set Care Plan Details**
- Care Plan Name (auto-generated: "{Patient Name} - {Condition} - {Date}")
- Start Date (default: today)
- Target End Date (calculated from template duration)
- Status: Draft (default)
- Notes/Special Instructions (free text)

**Step 6: Confirmation**
- Summary of care plan: goals count, tasks count, team members
- Preview of first month's tasks
- Options: Save as Draft, Activate Now

### Step 2: Create DataRaptors

**DR-AvailableTemplates (Extract)**
- Source: CarePlanTemplate
- Filter: Status = Active
- Join: Patient's HealthConditions to match template ICD-10 codes
- Fields: Name, Description, ICD10_Code__c, goal count, task count

**DR-InstantiateCarePlan (Save)**
- Target: CarePlan, CarePlanGoal, CarePlanActivity
- Maps template data to live care plan objects
- Sets all relationships (patient, goals, tasks, team)

**DR-ProviderSearch (Extract)**
- Source: Account (Provider)
- Filter: RecordType = Provider, IsActive = true
- Fields: Name, Specialty, Facility, MCR Number

### Step 3: Configure Care Plan Status Lifecycle

| Status | Description | Transitions To |
|---|---|---|
| Draft | Created but not yet active | Active, Cancelled |
| Active | Patient is following this care plan | On Hold, Completed, Closed |
| On Hold | Temporarily paused | Active, Closed |
| Completed | All goals achieved | Closed |
| Closed | Ended (any reason) | — |

**Status Transition Rules (Apex):**
- Draft → Active: requires at least 1 goal and 1 task
- Active → Completed: all goals must be marked Complete or Cancelled
- Any → Closed: requires close reason (picklist)

### Step 4: Configure Notifications

| Trigger | Recipient | Channel | Message |
|---|---|---|---|
| Care Plan Activated | Patient | SMS (if consented) | "Your care plan for {Condition} has been created. Your care team will contact you shortly." |
| Care Plan Activated | Care Team | In-App | "New care plan assigned: {Patient} - {Condition}" |
| Status Change | Care Coordinator | In-App + Email | "Care plan status changed: {Old} → {New}" |

### Step 5: Add Action Button to Patient Record

1. Create Quick Action: `New_Care_Plan`
2. Link to OmniScript: `CreateCarePlan`
3. Pass context: `AccountId = {!Record.Id}`
4. Add to Patient Person Account page layout

## Objects, Fields & Data Model

**Standard Objects:**
- `CarePlan` — The patient's care plan instance
- `CarePlanGoal` — Individual goals within the care plan
- `CarePlanActivity` — Tasks/activities within the care plan

**Custom Fields on CarePlan:**

| Field | API Name | Type |
|---|---|---|
| Source Template | `Source_Template__c` | Lookup(CarePlanTemplate) |
| Template Version | `Template_Version__c` | Number |
| Close Reason | `Close_Reason__c` | Picklist(Completed, Transferred, Patient Request, Deceased, Other) |
| Special Instructions | `Special_Instructions__c` | Long Text |

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| CreateCarePlan OmniScript | OmniScript | Guided care plan creation flow |
| Status Transition Guard | Apex Trigger | Enforces valid status transitions |
| Activation Notification | Flow | Sends notifications on care plan activation |
| Task Date Calculator | Integration Procedure | Calculates task due dates from care plan start date + template frequency |

## Security & Access

| Profile | Create | Read | Edit Status | Delete |
|---|---|---|---|---|
| Clinician | Yes | Own patients | Yes | No |
| Care Coordinator | Yes | Assigned patients | Yes | No |
| Clinical Lead | Yes | All | Yes | No |
| Admin Staff | No | No | No | No |

## Testing Strategy

**Unit Tests:**
- OmniScript creates care plan with correct goals and tasks from template
- Status transition validation (invalid transitions blocked)
- Notification sent on activation
- Care plan linked to correct template version

**UAT Scenarios:**
1. Clinician creates diabetes care plan from template, customises HbA1c target
2. Care plan saves as Draft, then activates — notifications sent
3. Patient receives SMS notification (if consent given)
4. Care coordinator views newly assigned care plan
5. Attempt invalid status transition (Draft → Completed) — blocked

## Deployment Checklist

- [ ] CreateCarePlan OmniScript deployed and activated
- [ ] All DataRaptors deployed
- [ ] Status transition Apex trigger deployed
- [ ] Notification flows active
- [ ] Quick Action added to Patient page
- [ ] Custom fields on CarePlan deployed
- [ ] Care plan page layout configured with goals and tasks related lists

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| Template auto-populates goals, tasks, team | Select template in OmniScript, verify pre-fill |
| Goals modifiable per patient | Edit target values in step 2, save, verify |
| Tasks add/remove/reassign | Add/remove tasks in step 3, verify saved |
| Status: Draft → Active → Completed → Closed | Walk through each transition |
| Patient notified on activation | Activate care plan, verify SMS/notification |

## Dependencies

- **Blocked By:** US-1.2.1 (Care Plan Templates), US-1.1.1 (Patient Profile)
- **Blocks:** US-1.2.3 (Care Team Assignment), US-1.2.4 (Goal Tracking), US-1.2.5 (Task Management)
