# US-2.3.3: Patient Portal - Home Readings

> **Phase:** 2 - Care Coordination | **Epic:** 2.3 - Patient Engagement | **Estimate:** M (1-2 weeks)

## Overview

Build a patient-facing web portal where patients can log home BP, blood glucose, and weight readings. Readings flow into Health Cloud and automatically update care plan goal tracking.

**Business Value:** Enables continuous monitoring between visits, detects deterioration early, and engages patients in their own care. Studies show 20-30% better outcomes with home monitoring.

## Prerequisites

- US-1.2.4 (Goal Tracking) completed
- Salesforce Experience Cloud licence provisioned
- Domain configured for portal (e.g., patient.mediconnect.sg)

## Salesforce Configuration Steps

### Step 1: Create Experience Cloud Site

1. Enable Digital Experiences
2. Create site: "Patient Health Portal"
3. Template: Customer Service (or Build Your Own LWR)
4. Domain: patient.{orgdomain}.com
5. Enable self-registration (verify by NRIC + DOB)

### Step 2: Build Reading Entry Components

**LWC: homeReadingEntry**
- Form fields:
  - Reading Type: BP, Blood Glucose, Weight (tabs)
  - BP: Systolic (number), Diastolic (number)
  - Glucose: Value (number), Timing (Fasting/Post-meal)
  - Weight: Value (number)
  - Date/Time (default: now)
  - Notes (optional)
- Validation: realistic ranges (BP 60-250, Glucose 2-30, Weight 20-200)
- Submit → creates GoalMeasurement__c with Source = "Portal"

### Step 3: Build Trend Visualisation

**LWC: readingTrendChart**
- Line chart showing last 30 readings
- Reference lines for target values (from care plan goals)
- Colour zones: green (on target), amber (approaching threshold), red (exceeded)
- Toggle between BP, Glucose, Weight views

### Step 4: Missing Reading Detection

**Scheduled Flow: MissingReadingAlert**
- Runs: Daily at 10:00 AM SGT
- Query: Patients with active care plans requiring home readings
- If no reading in 3+ days → send reminder (email/WhatsApp per preference)
- If no reading in 7+ days → create care coordinator task

### Step 5: Portal Security

- Authentication: Username/password + optional MFA
- Patient sees only their own data (sharing rules)
- API access limited to GoalMeasurement creation
- Session timeout: 30 minutes

## Testing Strategy

1. Patient logs BP reading → appears in Health Cloud, goal updated
2. Patient views trend chart → shows last 30 readings correctly
3. No reading for 3 days → patient gets reminder
4. Patient cannot see other patients' data
5. Invalid reading (BP 400) → validation error shown

## Deployment Checklist

- [ ] Experience Cloud site created and configured
- [ ] homeReadingEntry LWC deployed
- [ ] readingTrendChart LWC deployed
- [ ] GoalMeasurement integration with portal working
- [ ] MissingReadingAlert scheduled flow active
- [ ] Portal security verified
- [ ] Patient self-registration tested

## Dependencies

- **Blocked By:** US-1.2.4 (Goal Tracking)
- **Blocks:** US-3.2.1 (Mobile App extends portal functionality)
