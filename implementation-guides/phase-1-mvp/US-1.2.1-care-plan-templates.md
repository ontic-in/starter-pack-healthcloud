# US-1.2.1: Care Plan Templates

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.2 - Basic Care Management | **Estimate:** M (1-2 weeks)

## Overview

Create standardised care plan templates for common chronic conditions (diabetes, hypertension, cardiac) so clinicians can quickly initiate evidence-based care plans. Templates encode clinical best practices into reusable structures.

**Business Value:** Reduces care plan creation time from 30+ minutes to under 5 minutes. Ensures consistency of care across clinicians and standardises treatment protocols aligned with Singapore MOH clinical practice guidelines.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- Health Cloud Care Management features enabled
- Clinical SME input on care plan protocols for each condition

## Salesforce Configuration Steps

### Step 1: Enable Care Plan Templates

1. Navigate to **Setup > Health Cloud Admin > Care Plans**
2. Enable **Care Plan Templates**
3. Enable **Care Plan Template Goals** and **Care Plan Template Tasks**

### Step 2: Create Care Plan Template — Diabetes Management

**Template Record:**
- Name: `Diabetes Management Protocol`
- Description: Based on MOH Clinical Practice Guidelines for Diabetes Mellitus
- Status: Active
- Version: 1.0
- Condition: E11 (ICD-10 Type 2 Diabetes)

**Template Goals:**

| Goal | Target | Measure | Review |
|---|---|---|---|
| HbA1c Control | < 7.0% | HbA1c blood test | Every 3 months |
| Blood Pressure | < 140/90 mmHg | BP reading | Every visit |
| LDL Cholesterol | < 2.6 mmol/L | Lipid panel | Every 6 months |
| BMI Reduction | < 25 kg/m² | Weight/height | Monthly |
| Foot Assessment | No ulcers | Visual inspection | Every 6 months |
| Eye Screening | No retinopathy | Fundoscopy | Annually |

**Template Tasks:**

| Task | Assigned Role | Frequency | Priority |
|---|---|---|---|
| HbA1c blood test order | Primary Physician | Quarterly | High |
| Medication review | Primary Physician | Quarterly | High |
| Diet counselling session | Care Coordinator | Monthly | Medium |
| Exercise plan review | Allied Health | Monthly | Medium |
| Foot examination | Nurse | 6-monthly | Medium |
| Eye screening referral | Primary Physician | Annual | Medium |
| Patient education: diabetes self-management | Care Coordinator | Once (Week 1) | High |
| Medisave claim review | Admin Staff | Quarterly | Low |

### Step 3: Create Care Plan Template — Hypertension Control

**Template Record:**
- Name: `Hypertension Control Protocol`
- Condition: I10 (ICD-10 Essential Hypertension)

**Template Goals:**

| Goal | Target | Measure | Review |
|---|---|---|---|
| Systolic BP | < 140 mmHg | BP reading | Every visit |
| Diastolic BP | < 90 mmHg | BP reading | Every visit |
| Salt Intake | < 5g/day | Dietary assessment | Monthly |
| Exercise | 150 min/week | Patient report | Monthly |

**Template Tasks:**

| Task | Assigned Role | Frequency | Priority |
|---|---|---|---|
| BP measurement | Nurse | Every visit | High |
| Medication review | Primary Physician | Quarterly | High |
| Dietary sodium counselling | Care Coordinator | Monthly | Medium |
| Home BP monitoring setup | Nurse | Once (Week 1) | High |
| Renal function test | Primary Physician | Annually | Medium |

### Step 4: Create Care Plan Template — Cardiac Risk Reduction

**Template Record:**
- Name: `Cardiac Risk Reduction Protocol`
- Condition: I25 (ICD-10 Chronic Ischaemic Heart Disease)

**Template Goals:**

| Goal | Target | Measure | Review |
|---|---|---|---|
| LDL Cholesterol | < 1.8 mmol/L | Lipid panel | Quarterly |
| Resting Heart Rate | 60-80 bpm | ECG/pulse | Every visit |
| Exercise Tolerance | 6-min walk > 400m | Walk test | 6-monthly |
| Smoking Cessation | Non-smoker | Patient report | Every visit |
| Weight Management | BMI < 25 | Weight | Monthly |

### Step 5: Configure Template Versioning

1. Create custom field `Version__c` (Number) on CarePlanTemplate
2. Create custom field `Previous_Version__c` (Lookup to CarePlanTemplate)
3. Implement versioning logic:
   - When template is updated, clone existing as new version
   - Increment version number
   - Active care plans continue using their original template version
   - New care plans use the latest version

### Step 6: Configure Template Admin UI

1. Create Lightning App Page: **Care Plan Template Manager**
2. Add list view: All Templates (Name, Condition, Version, Status, Last Modified)
3. Add template editor:
   - Edit goals (inline editable grid)
   - Edit tasks (inline editable grid)
   - Preview: show how the care plan will look when instantiated
4. Assign to Clinical Lead profile

## Objects, Fields & Data Model

**Standard Objects Used:**
- `CarePlanTemplate` — Template definition
- `CarePlanTemplateGoal` — Goal definitions within template
- `CarePlanTemplateTask` — Task definitions within template

**Custom Fields:**

| Object | Field | API Name | Type |
|---|---|---|---|
| CarePlanTemplate | Version | `Version__c` | Number |
| CarePlanTemplate | Previous Version | `Previous_Version__c` | Lookup(CarePlanTemplate) |
| CarePlanTemplate | ICD-10 Code | `ICD10_Code__c` | Text(10) |
| CarePlanTemplate | MOH Guideline Ref | `MOH_Guideline_Ref__c` | URL |
| CarePlanTemplateGoal | Target Value | `Target_Value__c` | Text(100) |
| CarePlanTemplateGoal | Measure | `Measure__c` | Text(100) |
| CarePlanTemplateGoal | Review Frequency | `Review_Frequency__c` | Picklist |
| CarePlanTemplateTask | Assigned Role | `Assigned_Role__c` | Picklist |
| CarePlanTemplateTask | Frequency | `Task_Frequency__c` | Picklist |

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| Template Version Control | Apex Trigger | On update: clones template, increments version |
| Template Activation Check | Validation Rule | Cannot deactivate template with active care plans |
| Template Usage Report | Scheduled Report | Weekly report on template usage by condition |

## Security & Access

| Profile | Templates | Goals | Tasks |
|---|---|---|---|
| Clinical Lead | Create/Read/Edit | Create/Read/Edit | Create/Read/Edit |
| Clinician | Read | Read | Read |
| Care Coordinator | Read | Read | Read |
| System Admin | Full Access | Full Access | Full Access |

## Testing Strategy

**Unit Tests:**
- Create template with goals and tasks, verify all created
- Version template, verify old version preserved
- Deactivate template with active care plans — blocked

**UAT Scenarios:**
1. Clinical lead creates new template from scratch
2. Clinical lead edits existing template — new version created
3. Clinician views templates — can see but not edit
4. Verify 3 templates (Diabetes, Hypertension, Cardiac) have all goals and tasks

## Deployment Checklist

- [ ] CarePlanTemplate feature enabled
- [ ] Custom fields deployed
- [ ] Diabetes Management template created with goals and tasks
- [ ] Hypertension Control template created with goals and tasks
- [ ] Cardiac Risk Reduction template created with goals and tasks
- [ ] Template Manager Lightning page deployed
- [ ] Version control automation active
- [ ] Clinical lead can create/edit templates
- [ ] Clinicians can view templates only

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| 3+ templates created (Diabetes, Hypertension, Cardiac) | Verify templates exist and are Active |
| Each includes goals, tasks, care team roles, review schedule | Open each template, verify all components |
| Templates versioned without affecting active care plans | Edit template, verify active plans unchanged |
| Clinical lead can create templates without developer | Log in as Clinical Lead, create new template |

## Dependencies

- **Blocked By:** US-1.1.1 (Patient Profile Setup — for condition linkage)
- **Blocks:** US-1.2.2 (Care Plan Creation), US-2.1.1 (Clinical Protocol Pathways)
