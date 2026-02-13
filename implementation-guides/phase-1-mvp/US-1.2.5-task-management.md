# US-1.2.5: Task Management

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.2 - Basic Care Management | **Estimate:** S (1-3 days)

## Overview

Manage care plan tasks with due dates, assignments, status tracking, and automatic escalation for overdue items. Tasks are viewable per patient, per provider, and as a team dashboard.

**Business Value:** Ensures no care activities fall through the cracks, reduces missed follow-ups by 40-60%, and provides care coordinators with a unified view of all outstanding work.

## Prerequisites

- US-1.2.2 (Care Plan Creation) completed
- US-1.2.3 (Care Team Assignment) completed

## Salesforce Configuration Steps

### Step 1: Configure Task Status Lifecycle

| Status | API Value | Description | Transitions To |
|---|---|---|---|
| Pending | `Pending` | Created but not yet started | In Progress, Cancelled |
| In Progress | `In_Progress` | Actively being worked on | Completed, Pending, Cancelled |
| Completed | `Completed` | Done | — (terminal) |
| Cancelled | `Cancelled` | No longer needed | — (terminal) |

### Step 2: Configure CarePlanActivity Fields

**Standard + Custom Fields:**

| Field | API Name | Type | Description |
|---|---|---|---|
| Description | `Description__c` | Text(255) | What needs to be done |
| Assigned To | `AssignedToId` | Lookup(User) | Specific provider |
| Assigned Role | `Assigned_Role__c` | Picklist | Care team role |
| Due Date | `Due_Date__c` | Date | When task should be completed |
| Priority | `Priority__c` | Picklist | High, Medium, Low |
| Status | `Status__c` | Picklist | Pending, In Progress, Completed, Cancelled |
| Completed Date | `Completed_Date__c` | DateTime | When actually completed |
| Completed By | `Completed_By__c` | Lookup(User) | Who completed it |
| Is Overdue | `Is_Overdue__c` | Formula(Checkbox) | `Due_Date__c < TODAY() AND Status__c != 'Completed' AND Status__c != 'Cancelled'` |
| Days Overdue | `Days_Overdue__c` | Formula(Number) | `IF(Is_Overdue__c, TODAY() - Due_Date__c, 0)` |
| Care Plan | `CarePlanId` | Lookup(CarePlan) | Parent care plan |
| Source Template Task | `Source_Template_Task__c` | Lookup(CarePlanTemplateTask) | Original template task |

### Step 3: Configure Task List Views

**View 1: My Tasks (Provider)**
- Filter: AssignedToId = $User.Id, Status != Completed/Cancelled
- Columns: Patient Name, Description, Due Date, Priority, Status, Days Overdue
- Sort: Due Date ASC, Priority DESC
- Highlight: Overdue rows in red

**View 2: Patient Tasks (Patient Record)**
- Filter: CarePlan.PatientId = :AccountId
- Columns: Description, Assigned To, Due Date, Priority, Status
- Sort: Due Date ASC
- Grouped by: Status

**View 3: Team Dashboard (Care Coordinator)**
- Filter: CarePlan.CareTeam contains current user OR user is coordinator
- Columns: Patient, Description, Assigned To, Due Date, Priority, Status
- Sort: Priority DESC, Due Date ASC
- Summary: Total tasks, Overdue count, Completion rate this week

### Step 4: Configure Overdue Escalation

**Scheduled Flow: TaskOverdueEscalation**
- Runs: Daily at 8:00 AM SGT
- Criteria: `Is_Overdue__c = true`
- Actions by Days Overdue:

| Days Overdue | Action |
|---|---|
| 1-2 days | In-app reminder to assigned provider |
| 3-5 days | Email to assigned provider + care coordinator |
| 5+ days | Alert to care coordinator with escalation flag |
| 10+ days | Alert to clinical lead / supervisor |

### Step 5: Configure Quick Actions

**Mark Complete Action:**
- Button on task record and list view
- Sets Status = Completed, Completed Date = NOW(), Completed By = current user
- Optional: Add completion notes

**Reassign Task Action:**
- Quick action to change AssignedToId
- Sends notification to new assignee
- Logs reassignment in task history

**Bulk Status Update:**
- Mass action on list view
- Select multiple tasks → Update status
- Useful for care coordinators managing multiple patients

### Step 6: Create Task Dashboard

**Dashboard: Care Plan Task Management**

| Widget | Type | Data |
|---|---|---|
| Overdue Tasks | KPI (large number, red) | Count of Is_Overdue__c = true |
| Tasks Due This Week | KPI | Count due within 7 days |
| Completion Rate | Gauge | Completed / Total this month |
| Tasks by Status | Donut chart | Pending, In Progress, Completed |
| Overdue by Provider | Bar chart | Grouped by AssignedTo |
| Tasks by Priority | Stacked bar | High/Medium/Low by status |

## Objects, Fields & Data Model

**Standard Object Modified:**
- `CarePlanActivity` (or `Task` linked to CarePlan) — enhanced with custom fields

**Custom Fields:** (listed in Step 2 above)

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| TaskOverdueEscalation | Scheduled Flow (daily) | Escalates overdue tasks by severity |
| TaskCompletionUpdate | Record-Triggered Flow | Sets Completed Date/By when status → Completed |
| TaskAssignmentNotification | Flow | Notifies provider when task assigned |
| TaskReassignmentLog | Apex Trigger | Logs task reassignment history |
| RecurringTaskGenerator | Scheduled Flow | Creates next instance of recurring tasks (e.g., quarterly HbA1c) |

## Security & Access

| Profile | View Own | View Team | Edit Own | Reassign | Bulk Update |
|---|---|---|---|---|---|
| Clinician | Yes | Yes | Yes | No | No |
| Care Coordinator | Yes | Yes | Yes | Yes | Yes |
| Nurse | Yes | No | Yes | No | No |
| Clinical Lead | Yes | All | Yes | Yes | Yes |

## Testing Strategy

**Unit Tests:**
- Task status transitions validated
- Is_Overdue formula calculates correctly
- Escalation flow fires at correct thresholds
- Recurring task generation creates next instance

**UAT Scenarios:**
1. Create care plan with tasks — all tasks appear with correct due dates
2. Provider marks task complete — status updates, completion date recorded
3. Task becomes overdue — reminder sent to provider
4. Task 5+ days overdue — care coordinator receives escalation
5. Care coordinator reassigns task — new provider notified
6. View "My Tasks" — shows only current user's tasks sorted by due date
7. Dashboard shows accurate overdue count and completion rate

## Deployment Checklist

- [ ] CarePlanActivity custom fields deployed
- [ ] Task status picklist values configured
- [ ] Is_Overdue and Days_Overdue formula fields active
- [ ] List views created (My Tasks, Patient Tasks, Team Dashboard)
- [ ] TaskOverdueEscalation scheduled flow active
- [ ] Quick actions deployed (Mark Complete, Reassign)
- [ ] Task Management dashboard deployed
- [ ] Notification flows active
- [ ] RecurringTaskGenerator scheduled flow active

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| Tasks have description, assigned to, due date, priority, status | Create task, verify all fields |
| Statuses: Pending → In Progress → Completed → Cancelled | Walk through transitions |
| Overdue tasks auto-flagged and escalated to care coordinator | Set task due date to yesterday, wait for escalation |
| Tasks viewable per patient, per provider, and team dashboard | Check all 3 list views |

## Dependencies

- **Blocked By:** US-1.2.2 (Care Plan Creation), US-1.2.3 (Care Team Assignment)
- **Blocks:** US-2.1.2 (Escalation Rules — escalation chain), US-2.3.1 (Appointment Reminders — task-based)
