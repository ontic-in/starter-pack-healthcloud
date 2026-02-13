# US-1.1.3: Patient Timeline

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.1 - Patient 360 | **Estimate:** S (1-3 days)

## Overview

Configure the Health Cloud Patient Timeline to display a chronological view of all patient interactions, referrals, and clinical events. The timeline provides clinicians with a quick visual history of the patient's care journey.

**Business Value:** Enables clinicians to understand a patient's complete care history in under 30 seconds, reducing time spent reviewing notes and improving continuity of care across providers.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- Health Cloud managed package installed
- Lightning App Builder access

## Salesforce Configuration Steps

### Step 1: Enable Health Cloud Timeline

1. Navigate to **Setup > Health Cloud Admin**
2. Enable **Patient Timeline** feature
3. Configure Timeline Settings:
   - Default time range: 12 months
   - Max events per load: 50
   - Enable lazy loading for older events

### Step 2: Configure Timeline Event Types

| Event Type | Source Object | Icon | Colour |
|---|---|---|---|
| Consultation | Event (Type = Consultation) | stethoscope | Blue |
| Referral | ClinicalServiceRequest | arrow-right | Purple |
| Lab Result | DiagnosticReport / Observation | beaker | Green |
| Care Plan Change | CarePlan (history) | clipboard | Orange |
| Medication Change | MedicationStatement (history) | pill | Teal |
| Communication | Task (Type = Communication) | chat | Grey |
| Admission | ClinicalEncounter (Type = Inpatient) | hospital | Red |
| Discharge | ClinicalEncounter (Status = Discharged) | home | Green |

### Step 3: Configure Event Detail Fields

**Consultation Events:**
- Date & Time, Provider Name, Facility, Specialty
- Summary/Chief Complaint (first 200 chars)
- Link to full encounter record

**Referral Events:**
- Referral Date, Referring Provider, Receiving Provider
- Reason for Referral, Urgency
- Status (Pending, Accepted, Completed)

**Lab Result Events:**
- Test Date, Test Name, Key Values
- Abnormal flag (visual indicator)
- Link to full DiagnosticReport

**Care Plan Events:**
- Change Date, Changed By
- Change Type (Created, Goal Updated, Status Changed)
- Before/After values

### Step 4: Configure Filters

Create filter buttons on the timeline:

| Filter | Criteria | Default |
|---|---|---|
| All Events | No filter | Selected |
| Clinical | Consultations, Lab Results, Medications | |
| Administrative | Referrals, Communications, Scheduling | |
| Care Plans | Care Plan changes, Goal updates | |
| Last 30 Days | Date filter | |
| Last 6 Months | Date filter | |
| Last 12 Months | Date filter | |

### Step 5: Add Timeline to Record Page

1. Open **Lightning App Builder** for Patient Person Account page
2. Add **Health Cloud Timeline** component
3. Position below Patient 360 FlexCard
4. Configure default view: All Events, Last 12 Months

### Step 6: Historical Data Display

Configure timeline to display migrated historical data:
- Set `Show_Historical_Data__c` flag on timeline configuration
- Historical events tagged with source system identifier
- Visual indicator for migrated vs. native data (subtle badge)

## Objects, Fields & Data Model

**No new objects created.** Timeline reads from:

| Object | Event Mapping |
|---|---|
| Event | Consultations, Appointments |
| Task | Communications, Follow-ups |
| ClinicalServiceRequest | Referrals |
| ClinicalEncounter | Admissions, Discharges |
| DiagnosticReport | Lab Results |
| Observation | Individual test values |
| CarePlan | Care plan lifecycle events |
| MedicationStatement | Medication changes |

**Custom Field for Historical Tracking:**

| Field | API Name | Object | Type |
|---|---|---|---|
| Source System | `Source_System__c` | Multiple | Text(50) |
| Migration Date | `Migration_Date__c` | Multiple | DateTime |

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| Timeline Event Creator | Platform Event Trigger | Creates timeline entries for care plan status changes |
| Lab Result Alert | Flow | Highlights abnormal lab results on timeline with red indicator |
| Timeline Cache Refresh | Scheduled Flow | Refreshes timeline cache daily for frequently accessed patients |

## Security & Access

- Timeline respects object-level and field-level security
- Non-clinical users see administrative events only (no clinical details)
- Clinicians see all event types
- Events from other facilities visible only if user is on the care team

## Testing Strategy

**Unit Tests:**
- Verify each event type appears on timeline with correct icon and colour
- Test filter functionality (each filter returns correct subset)
- Test empty timeline for new patient

**UAT Scenarios:**
1. View timeline for patient with 50+ events across all types
2. Apply Clinical filter — only clinical events visible
3. Expand date range from 30 days to 12 months
4. Click a lab result event — navigates to full report
5. Verify historical migrated data displays with source badge
6. View timeline for patient with events across multiple facilities

## Deployment Checklist

- [ ] Timeline feature enabled
- [ ] All event types configured with icons and colours
- [ ] Filter buttons configured
- [ ] Timeline added to Patient record page
- [ ] Historical data display configured
- [ ] Event detail fields configured per type
- [ ] Performance verified with 100+ events

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| Timeline shows consultations, referrals, lab results, care plan changes, communications | Create test data for each type, verify display |
| Events are filterable by type | Click each filter, verify correct events shown |
| Each event shows date, provider, facility, summary | Expand event on timeline, verify fields |
| Timeline loads historical data from migration | Verify migrated events appear with source badge |

## Dependencies

- **Blocked By:** US-1.1.1 (Patient Profile Setup)
- **Blocks:** US-2.2.2 (Lab Results on Timeline), US-2.5.1 (Cross-Facility events on Timeline)
