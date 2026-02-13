# US-1.2.4: Goal Tracking & Progress

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.2 - Basic Care Management | **Estimate:** S (1-3 days)

## Overview

Track patient progress against care plan goals with measurable metrics, visual status indicators, and trend history. Goals display current values vs targets with colour-coded status (green/amber/red).

**Business Value:** Enables proactive identification of patients who are off track, reducing adverse events by 20-30%. Provides data-driven care management and supports evidence-based clinical decisions.

## Prerequisites

- US-1.2.2 (Care Plan Creation) completed
- Care plan goals created from templates

## Salesforce Configuration Steps

### Step 1: Configure Goal Measurement Fields

**Custom Fields on CarePlanGoal:**

| Field | API Name | Type | Description |
|---|---|---|---|
| Current Value | `Current_Value__c` | Text(50) | Latest measurement (e.g., "7.2%") |
| Current Value Numeric | `Current_Value_Numeric__c` | Number(10,2) | Numeric value for comparison |
| Target Value | `Target_Value__c` | Text(50) | Target (e.g., "< 7.0%") |
| Target Numeric | `Target_Numeric__c` | Number(10,2) | Numeric target for comparison |
| Target Operator | `Target_Operator__c` | Picklist | Less Than, Greater Than, Equal To, Between |
| Upper Threshold | `Upper_Threshold__c` | Number(10,2) | Amber zone upper bound |
| Lower Threshold | `Lower_Threshold__c` | Number(10,2) | Amber zone lower bound |
| Unit | `Unit__c` | Picklist | %, mmHg, mmol/L, kg/m², bpm, etc. |
| Last Measured Date | `Last_Measured_Date__c` | DateTime | When last measurement taken |
| Measured By | `Measured_By__c` | Lookup(User) | Who recorded measurement |
| Status | `Goal_Status__c` | Formula(Text) | Calculated: On Track / At Risk / Off Track |
| Trend | `Trend__c` | Formula(Text) | Improving / Stable / Declining |

### Step 2: Create Goal Status Calculation

**Formula Field: Goal_Status__c**

Logic:
```
IF(Target_Operator__c = "Less Than",
  IF(Current_Value_Numeric__c <= Target_Numeric__c, "On Track",
    IF(Current_Value_Numeric__c <= Upper_Threshold__c, "At Risk", "Off Track")),
  IF(Target_Operator__c = "Greater Than",
    IF(Current_Value_Numeric__c >= Target_Numeric__c, "On Track",
      IF(Current_Value_Numeric__c >= Lower_Threshold__c, "At Risk", "Off Track")),
    "On Track"))
```

**Example Configuration — HbA1c Goal:**
- Target: < 7.0%
- Upper Threshold: 8.0% (amber if between 7.0-8.0)
- Current Value: 7.2%
- Result: **At Risk** (amber)

### Step 3: Create Goal Measurement History

**Custom Object: GoalMeasurement__c**

| Field | API Name | Type |
|---|---|---|
| Care Plan Goal | `Care_Plan_Goal__c` | Master-Detail(CarePlanGoal) |
| Value | `Value__c` | Number(10,2) |
| Display Value | `Display_Value__c` | Text(50) |
| Measured Date | `Measured_Date__c` | DateTime |
| Measured By | `Measured_By__c` | Lookup(User) |
| Source | `Source__c` | Picklist(Manual, Lab Result, Device, Portal) |
| Notes | `Notes__c` | Text(255) |

### Step 4: Configure Auto-Update from Measurements

**Flow: UpdateGoalFromMeasurement**
- Trigger: New GoalMeasurement__c record created
- Action:
  1. Update CarePlanGoal.Current_Value_Numeric__c
  2. Update CarePlanGoal.Current_Value__c (formatted display)
  3. Update CarePlanGoal.Last_Measured_Date__c
  4. Calculate trend based on last 3 measurements
  5. If status changed to "Off Track" → trigger escalation (US-2.1.2)

**Flow: AutoUpdateFromLabResult**
- Trigger: New Observation record linked to patient
- Action:
  1. Match observation type to care plan goal measure
  2. Create GoalMeasurement__c from observation value
  3. Triggers UpdateGoalFromMeasurement flow

### Step 5: Create Goal Progress Visualisation

**FlexCard: FC-GoalProgress**
- Display per goal:
  - Goal name and target
  - Current value with status badge (colour-coded)
  - Mini sparkline showing trend (last 6 measurements)
  - Days since last measurement
  - "Record Measurement" quick action button

**Status Badge Styling:**
| Status | Colour | Icon |
|---|---|---|
| On Track | Green (#27AE60) | Check circle |
| At Risk | Amber (#F39C12) | Warning triangle |
| Off Track | Red (#E74C3C) | X circle |

**Trend Indicator:**
| Trend | Arrow | Colour |
|---|---|---|
| Improving | ↑ | Green |
| Stable | → | Grey |
| Declining | ↓ | Red |

### Step 6: Create Goal Summary Dashboard

**Dashboard: Care Plan Goals Overview**
- Widget 1: Pie chart — goals by status (On Track / At Risk / Off Track)
- Widget 2: Table — Off Track goals with patient name, goal, current vs target
- Widget 3: Bar chart — goals by condition type
- Filters: Care Coordinator, Facility, Condition, Date Range

## Objects, Fields & Data Model

**Standard Object Modified:**
- `CarePlanGoal` — additional custom fields for measurement tracking

**Custom Object Created:**
- `GoalMeasurement__c` — historical measurement records

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| UpdateGoalFromMeasurement | Record-Triggered Flow | Updates goal current value when new measurement recorded |
| AutoUpdateFromLabResult | Record-Triggered Flow | Creates measurement from lab observation |
| Goal Status Change Alert | Flow | Notifies care coordinator when goal status changes |
| Trend Calculator | Apex | Calculates trend from last 3 measurements |
| Stale Goal Alert | Scheduled Flow | Alerts if goal not measured within expected frequency |

## Security & Access

- Clinicians and Care Coordinators: Read/Edit goals and measurements
- Nurses: Record measurements (create GoalMeasurement__c)
- Patients (portal): View own goals and trend (Phase 2)
- Admin Staff: No access to clinical goal data

## Testing Strategy

**Unit Tests:**
- Goal status formula calculates correctly for all operators
- New measurement updates goal current value
- Trend calculated correctly (improving/stable/declining)
- Lab result auto-creates measurement

**UAT Scenarios:**
1. Record BP measurement — goal status updates to "On Track" (green)
2. Record high HbA1c — goal changes to "Off Track" (red)
3. View goal history — sparkline shows 6 data points
4. Dashboard shows correct distribution of goal statuses
5. Stale alert fires for goal not measured in 30 days

## Deployment Checklist

- [ ] Custom fields on CarePlanGoal deployed
- [ ] GoalMeasurement__c custom object deployed
- [ ] Goal status formula field active
- [ ] UpdateGoalFromMeasurement flow active
- [ ] AutoUpdateFromLabResult flow active
- [ ] FC-GoalProgress FlexCard deployed
- [ ] Goal Summary dashboard deployed
- [ ] Stale goal alert scheduled flow active

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| Goals display current vs target (e.g., BP 142/86 vs <140/90) | Open care plan goal, verify display |
| Visual indicators: green/amber/red | Record values in each zone, verify colours |
| Auto-update from new measurements | Record measurement, verify goal updates |
| Goal history shows trend over time | View sparkline with 6+ measurements |

## Dependencies

- **Blocked By:** US-1.2.2 (Care Plan Creation)
- **Blocks:** US-2.1.2 (Escalation Rules — triggers on Off Track), US-2.3.3 (Home Readings update goals)
