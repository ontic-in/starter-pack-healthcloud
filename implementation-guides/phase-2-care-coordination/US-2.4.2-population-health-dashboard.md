# US-2.4.2: Population Health Dashboard

> **Phase:** 2 - Care Coordination | **Epic:** 2.4 - SDOH & Population Health | **Estimate:** M (1-2 weeks)

## Overview

Create a population-level health outcomes dashboard for the CMO showing patient counts by condition, care plan compliance rates, outcome trends, and facility benchmarking with drill-down capability.

**Business Value:** Enables data-driven healthcare strategy, identifies systemic care gaps, benchmarks facilities against each other, and supports resource allocation decisions.

## Prerequisites

- US-1.4.1 (Clinical Operations Dashboard) completed
- US-2.4.1 (SDOH Tracking) completed
- CRM Analytics (Tableau CRM) licence available
- Sufficient data volume for meaningful analytics

## Salesforce Configuration Steps

### Step 1: Create CRM Analytics Dataset

**Dataflow: PopulationHealth**
- Sources: Account (Patient), HealthCondition, CarePlan, CarePlanGoal, SDOHAssessment__c, CareTeamMember, Event
- Joins: Patient → Conditions, Patient → CarePlans → Goals, Patient → SDOH
- Output: Denormalised dataset for analytics

### Step 2: Build Dashboard Widgets

**Level 1 — Organisation Overview:**
- Total patients by condition (bar chart)
- Care plan compliance rate (gauge: % on track)
- Risk stratification distribution (High/Medium/Low pie chart)
- Outcome trends (line chart: 6-month compliance trend)

**Level 2 — Facility Drill-Down:**
- Click facility → see that facility's metrics
- Benchmarking table: compliance %, NPS, readmission rate side by side
- Patient counts by department

**Level 3 — Department/Individual:**
- Click department → see provider-level metrics
- Click patient → navigate to Patient 360 record

### Step 3: Configure Facility Benchmarking

| Metric | Calculation |
|---|---|
| Compliance Rate | On Track Goals / Total Goals |
| Patient Satisfaction (NPS) | Survey score (if captured) |
| Readmission Rate | Readmissions / Discharges within 30 days |
| Average LOS | Total inpatient days / Admissions |
| No-Show Rate | No-shows / Total appointments |

### Step 4: Risk Stratification View

- High Risk: Risk score > 70 (red segment)
- Medium Risk: 40-70 (amber segment)
- Low Risk: < 40 (green segment)
- List of high-risk patients with current care plan status

### Step 5: Export & Distribution

- PDF export for board presentations
- Excel export for custom analysis
- Scheduled email: weekly summary to CMO and clinical leads
- Daily auto-refresh at 5:00 AM SGT

## Testing Strategy

1. Drill from org → facility → department → patient
2. Verify compliance rate matches manual calculation
3. Benchmarking table shows correct side-by-side metrics
4. PDF export renders all widgets correctly
5. Scheduled email delivered with current data

## Deployment Checklist

- [ ] CRM Analytics dataflow created
- [ ] All dashboard widgets built
- [ ] Drill-down navigation configured
- [ ] Benchmarking calculations verified
- [ ] PDF/Excel export working
- [ ] Scheduled email configured
- [ ] CMO and clinical leads have access

## Dependencies

- **Blocked By:** US-1.4.1, US-2.4.1
- **Blocks:** US-3.4.2 (Risk stratification view extended with AI)
