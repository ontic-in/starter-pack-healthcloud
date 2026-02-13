# US-1.1.2: Patient 360 FlexCard

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.1 - Patient 360 | **Estimate:** S (1-3 days)

## Overview

Build a unified OmniStudio FlexCard that displays a patient's complete profile on a single screen, including demographics, active conditions, medications, allergies, and insurance. This is the primary clinician interface for patient interactions.

**Business Value:** Reduces clinician time spent navigating between tabs from ~3 minutes to <10 seconds per patient. Improves consultation quality by making critical information instantly visible.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- OmniStudio managed package installed and configured
- FlexCard Designer access
- DataRaptor Designer access

## Salesforce Configuration Steps

### Step 1: Create DataRaptors

**DR-PatientDemographics (Extract)**
- Source: Account (Person Account)
- Fields: FirstName, LastName, NRIC_Display__pc, PersonBirthdate, Gender__pc, Ethnicity__pc, Preferred_Language__pc, Phone, PersonEmail, PersonMailingAddress
- Filter: `Id = :AccountId`

**DR-PatientConditions (Extract)**
- Source: HealthCondition
- Fields: Name, CodeId (ICD-10), ClinicalStatus, Severity, OnsetDateTime
- Filter: `PatientId = :AccountId AND ClinicalStatus = 'Active'`
- Sort: OnsetDateTime DESC, limit 10

**DR-PatientMedications (Extract)**
- Source: MedicationStatement
- Fields: Name, Dosage__c, Frequency__c, Route__c, Status, Prescriber__c
- Filter: `PatientId = :AccountId AND Status = 'Active'`

**DR-PatientAllergies (Extract)**
- Source: AllergyIntolerance
- Fields: Name, AllergyCategory, Criticality, Reaction_Type__c, Reaction_Severity__c
- Filter: `PatientId = :AccountId`

**DR-PatientInsurance (Extract)**
- Source: MemberPlan
- Fields: Name, MemberId, Coverage_Type__c, Medisave_Balance__c, Status
- Filter: `AccountId = :AccountId AND Status = 'Active'`

### Step 2: Create Parent FlexCard

**FlexCard Name:** `Patient360Card`
- **Data Source:** DR-PatientDemographics
- **Input Parameters:** `AccountId` (passed from record page context)

**Layout Structure:**
```
┌──────────────────────────────────────────────────────────┐
│ PATIENT HEADER                                            │
│ [Photo] Name | NRIC | Age | Gender | Language             │
├────────────────────┬─────────────────────────────────────┤
│ ACTIVE CONDITIONS   │ CURRENT MEDICATIONS                  │
│ (Child FlexCard)    │ (Child FlexCard)                     │
├────────────────────┼─────────────────────────────────────┤
│ ALLERGIES           │ INSURANCE & COVERAGE                 │
│ (Child FlexCard)    │ (Child FlexCard)                     │
└────────────────────┴─────────────────────────────────────┘
```

### Step 3: Create Child FlexCards

**FC-ActiveConditions:**
- Data Source: DR-PatientConditions
- Display: Condition name, ICD-10 code, severity badge (colour-coded)
- Action: Click navigates to HealthCondition record
- Empty State: "No active conditions recorded"

**FC-CurrentMedications:**
- Data Source: DR-PatientMedications
- Display: Drug name, dosage, frequency in compact list
- Action: Click navigates to MedicationStatement record
- Empty State: "No active medications"

**FC-Allergies:**
- Data Source: DR-PatientAllergies
- Display: Allergen name, criticality badge (red for High), reaction type
- Highlight: High criticality allergies with red border
- Empty State: "No known allergies (NKA)"

**FC-Insurance:**
- Data Source: DR-PatientInsurance
- Display: Provider name, policy number, coverage type, Medisave balance
- Empty State: "No insurance on file"

### Step 4: Configure Styling & Responsiveness

- **Desktop:** 2-column grid layout (conditions+allergies left, medications+insurance right)
- **Tablet (< 1024px):** Single column, stacked sections
- **Colour Coding:**
  - Severity badges: Mild (green), Moderate (amber), Severe (red)
  - Criticality: Low (grey), High (red)
  - Active status: Green dot indicator

### Step 5: Performance Optimisation

- Enable FlexCard caching (TTL: 30 seconds)
- Use lazy loading for child FlexCards below the fold
- Limit DataRaptor results: Conditions (10), Medications (20), Allergies (all)
- Target: < 2 second full render time

### Step 6: Add to Patient Record Page

1. Navigate to **Setup > Lightning App Builder**
2. Edit the Patient Person Account record page
3. Add OmniStudio FlexCard component
4. Set FlexCard Name: `Patient360Card`
5. Map input: `AccountId = {!Record.Id}`
6. Place in prominent position (top of page)

## Objects, Fields & Data Model

No new objects. Reads from objects configured in US-1.1.1:
- `Account` (Person Account - Patient)
- `HealthCondition`
- `MedicationStatement`
- `AllergyIntolerance`
- `MemberPlan`

## Automation & Flows

| Component | Type | Description |
|---|---|---|
| DR-PatientDemographics | DataRaptor Extract | Fetches patient demographic data |
| DR-PatientConditions | DataRaptor Extract | Fetches active conditions |
| DR-PatientMedications | DataRaptor Extract | Fetches current medications |
| DR-PatientAllergies | DataRaptor Extract | Fetches all allergies |
| DR-PatientInsurance | DataRaptor Extract | Fetches active insurance plans |

## Security & Access

- FlexCard respects underlying object FLS — non-clinical users will not see clinical fields
- NRIC Display field shows masked value for non-clinical profiles
- Insurance balance visible only to profiles with MemberPlan read access

## Testing Strategy

**Unit Tests:**
- Verify each DataRaptor returns correct data for test patient
- Test with patient having no conditions/medications (empty states)
- Test with patient having 20+ conditions (scroll/pagination)

**UAT Scenarios:**
1. Open Patient 360 for patient with full data — all sections populated
2. Open Patient 360 for new patient — empty states display correctly
3. Click condition — navigates to condition record
4. View on tablet — responsive layout works
5. Measure page load — under 2 seconds

**Performance Test:**
- Load FlexCard with patient having maximum data points
- Verify render time < 2 seconds across 10 consecutive loads

## Deployment Checklist

- [ ] All 5 DataRaptors created and activated
- [ ] Parent FlexCard created and activated
- [ ] 4 child FlexCards created and activated
- [ ] FlexCard added to Patient record page layout
- [ ] Responsive design verified on desktop and tablet
- [ ] Performance verified < 2 seconds
- [ ] Empty state messages configured
- [ ] Click-through navigation working

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| FlexCard displays demographics, conditions, medications, allergies, insurance | Open FlexCard for patient with all data types |
| Clicking any section navigates to full detail | Click each section, verify navigation |
| Loads within 2 seconds | Chrome DevTools performance audit |
| Mobile-responsive for tablet use | Open in tablet viewport (1024px) |

## Dependencies

- **Blocked By:** US-1.1.1 (Patient Profile Setup)
- **Blocks:** US-1.2.3 (Care Team visible on FlexCard), US-1.6.1 (Consent visible on FlexCard)
