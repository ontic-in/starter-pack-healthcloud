# US-2.1.1: Clinical Protocol Pathways

> **Phase:** 2 - Care Coordination | **Epic:** 2.1 - Advanced Care Plans | **Estimate:** L (2+ weeks)

## Overview

Configure evidence-based clinical protocol pathways with branching logic that adapt care plans based on patient responses and outcomes. Pathways automate task creation and escalations based on clinical milestones.

**Business Value:** Transforms static care plans into dynamic, adaptive protocols that respond to patient data in real-time. Reduces care gaps by 30-40% through automated milestone-based actions.

## Prerequisites

- US-1.2.1 (Care Plan Templates) completed
- US-1.2.4 (Goal Tracking) completed
- Clinical protocol documentation from medical advisory board

## Salesforce Configuration Steps

### Step 1: Design Pathway Architecture

Create 5 clinical pathways using OmniStudio Integration Procedures with decision logic:

**Pathway 1: Diabetes Management**
- Entry: HbA1c > 6.5% at diagnosis
- Branch 1: HbA1c < 7% → maintain current regimen, quarterly review
- Branch 2: HbA1c 7-8% → intensify medication, monthly review, dietitian referral
- Branch 3: HbA1c > 8% → specialist referral, bi-weekly monitoring, medication escalation

**Pathway 2-5:** Hypertension, Cardiac, Respiratory, Chronic Disease General (similar branching patterns)

### Step 2: Configure Pathway Engine

**Custom Objects:**

| Object | Purpose |
|---|---|
| ClinicalPathway__c | Pathway definition |
| PathwayStep__c | Individual decision/action node |
| PathwayBranch__c | Conditional branch between steps |
| PathwayExecution__c | Patient's progress through pathway |

**PathwayBranch__c Fields:**
- Condition Field: Which CarePlanGoal metric to evaluate
- Operator: Less Than, Greater Than, Between, Equals
- Threshold Value(s)
- Next Step (Lookup to PathwayStep__c)

### Step 3: Implement Decision Logic

**Integration Procedure: EvaluatePathway**
- Triggered when: New GoalMeasurement__c recorded
- Steps:
  1. Identify active PathwayExecution for patient
  2. Get current PathwayStep
  3. Evaluate all branches against current measurements
  4. Route to matching branch
  5. Execute step actions (create tasks, send alerts, update goals)

### Step 4: Configure Auto-Task Creation

When a pathway milestone is reached, auto-create care plan tasks:
- Task template stored on PathwayStep__c
- Assigned to care team role specified in pathway
- Due date calculated from milestone date + offset days

### Step 5: Version Management

- Each pathway has Version__c field
- Active pathways cannot be edited directly
- "New Version" action clones pathway with incremented version
- Existing patient executions continue on original version
- Change log tracks all modifications

## Security & Access

- Clinical Leads: Create and edit pathways
- Clinicians: View pathways, cannot edit
- System tracks all pathway executions for audit

## Testing Strategy

1. Walk through diabetes pathway with HbA1c = 6.8% → verify correct branch
2. Update HbA1c to 8.5% → verify escalation tasks created
3. Verify version change does not affect active patient pathways
4. Test all 5 pathways with boundary values

## Deployment Checklist

- [ ] Custom objects deployed
- [ ] 5 clinical pathways configured
- [ ] EvaluatePathway Integration Procedure deployed
- [ ] Auto-task creation tested per pathway
- [ ] Version management working
- [ ] Clinical SME sign-off on pathway logic

## Dependencies

- **Blocked By:** US-1.2.1, US-1.2.4
- **Blocks:** US-2.1.2 (Escalation Rules use pathway thresholds)
