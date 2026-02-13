# US-1.4.1: Clinical Operations Dashboard

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.4 - Reports & Dashboards | **Estimate:** S (1-3 days)

## Overview

Build a dashboard showing patient volumes, care plan compliance, and provider utilisation. This gives clinic managers real-time visibility into operational performance.

**Business Value:** Enables data-driven clinic management, identifies bottlenecks in care delivery, and supports capacity planning. Reduces management reporting effort from hours of manual compilation to real-time access.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- US-1.2.2 (Care Plan Creation) completed
- US-1.2.4 (Goal Tracking) completed
- Sufficient data in system (or test data) for meaningful visualisations

## Salesforce Configuration Steps

### Step 1: Create Custom Report Types

**Report Type 1: Patient Overview**
- Primary: Account (Person Account, RecordType = Patient)
- Related: HealthCondition, CarePlan

**Report Type 2: Care Plan Compliance**
- Primary: CarePlan
- Related: CarePlanGoal, Account (Patient)

**Report Type 3: Provider Utilisation**
- Primary: CareTeamMember
- Related: Account (Provider), CareTeam

### Step 2: Build Reports

**R1: Active Patient Count**
- Type: Summary Report
- Object: Account (Patient)
- Filter: Active patients (has active care plan or visit in last 12 months)
- Group By: Facility, Specialty
- Summary: Record Count

**R2: New Patients This Month**
- Type: Summary Report
- Filter: CreatedDate = THIS_MONTH
- Group By: Week, Facility

**R3: Care Plan Status Distribution**
- Type: Summary Report
- Object: CarePlanGoal
- Group By: Goal_Status__c (On Track / At Risk / Off Track)
- Summary: Record Count, Percentage

**R4: Provider Patient Load**
- Type: Summary Report
- Object: CareTeamMember
- Filter: Status = Active
- Group By: Provider Name
- Summary: Count of patients, Average per provider

**R5: Appointment Fill Rate**
- Type: Summary Report
- Object: Event (Type = Appointment)
- Group By: Provider, Date
- Formula: Booked / Available slots

### Step 3: Build Dashboard

**Dashboard: Clinical Operations**

Layout (3-column):

| Row | Left | Centre | Right |
|---|---|---|---|
| 1 | **Total Active Patients** (KPI) | **New Patients This Month** (KPI) | **Care Plan Compliance Rate** (KPI) |
| 2 | **Patients by Facility** (Bar Chart) | **Care Plans by Status** (Donut) | **At Risk / Off Track Goals** (Table) |
| 3 | **Provider Utilisation** (Horizontal Bar) | **Patient Volume Trend** (Line Chart - 6 months) | **Appointment Fill Rate** (Gauge) |

### Step 4: Configure Filters

Dashboard Filters:
1. **Facility** — Filter all components by facility
2. **Date Range** — Last 30 days, Last 90 days, Last 12 months, Custom
3. **Specialty** — Filter by clinical specialty

### Step 5: Configure Refresh Schedule

- Schedule: Daily refresh at 6:00 AM SGT
- Data source: Live reports (not snapshots)
- Email distribution: Weekly summary to clinic managers

### Step 6: Set Up Dashboard Access

1. Create Dashboard folder: "Clinical Operations"
2. Share with: Clinic Manager, Clinical Lead, Management profiles
3. Pin to Health Cloud app home page for quick access

## Security & Access

- Dashboard visible to: Clinic Manager, Clinical Lead, Management, System Admin
- Underlying reports respect record-level sharing
- No patient PII visible in dashboard (aggregate data only)
- Facility filter ensures managers see only their facility data

## Testing Strategy

**UAT Scenarios:**
1. Open dashboard — all widgets load with correct data
2. Apply facility filter — all widgets update to show filtered data
3. Verify patient count matches actual patient records
4. Verify care plan compliance percentages are accurate
5. Check daily refresh produces updated numbers
6. Clinic manager at Facility A cannot see Facility B data

## Deployment Checklist

- [ ] Custom report types created
- [ ] All 5+ reports built and validated
- [ ] Dashboard created with all widgets
- [ ] Filters configured (Facility, Date, Specialty)
- [ ] Daily refresh scheduled
- [ ] Dashboard folder shared with correct profiles
- [ ] Dashboard pinned to app home page
- [ ] Weekly email distribution configured

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| Metrics: active patients, new patients, care plans by status | Verify KPIs match report totals |
| Provider utilisation: patients per provider, fill rate | Check provider bar chart and gauge |
| Filterable by facility, date range, specialty | Apply each filter, verify update |
| Dashboard refreshes daily | Check last refresh timestamp |

## Dependencies

- **Blocked By:** US-1.1.1, US-1.2.2, US-1.2.4 (data sources must exist)
- **Blocks:** US-2.4.2 (Population Health Dashboard extends this)
