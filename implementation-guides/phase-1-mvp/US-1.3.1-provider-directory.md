# US-1.3.1: Provider Directory

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.3 - Provider Management | **Estimate:** S (1-3 days)

## Overview

Configure a searchable provider directory within Health Cloud, enabling care coordinators to find providers by specialty, location, availability, and language. Includes both internal and external referral providers.

**Business Value:** Reduces referral processing time from days to minutes by providing instant access to provider information, MCR (Singapore Medical Council Registration) numbers, and availability.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- Provider data collected (names, MCR numbers, specialties, facilities)

## Salesforce Configuration Steps

### Step 1: Configure Provider Account Record Type

1. Create Record Type on Account: `Healthcare_Provider`
2. Configure page layout for providers

**Standard + Custom Fields:**

| Field | API Name | Type | Description |
|---|---|---|---|
| Provider Name | `Name` | Text | Full name |
| MCR Number | `MCR_Number__c` | Text(10) | Singapore Medical Council Registration |
| Specialty | `Specialty__c` | Picklist | Cardiology, Endocrinology, General Practice, etc. |
| Sub-Specialty | `Sub_Specialty__c` | Text(100) | Specific area of focus |
| Facility | `Facility__c` | Lookup(Account) | Primary practice location |
| Contact Phone | `Phone` | Phone | Direct line |
| Contact Email | `PersonEmail` | Email | |
| Languages Spoken | `Languages__c` | Multi-Select Picklist | English, Mandarin, Malay, Tamil, Hokkien, Cantonese |
| Provider Type | `Provider_Type__c` | Picklist | Internal, External, Visiting |
| Accepting Referrals | `Accepting_Referrals__c` | Checkbox | Currently accepting new referrals |
| Current Patient Load | `Current_Patient_Load__c` | Number | Active care team memberships |
| Max Patient Capacity | `Max_Patient_Capacity__c` | Number | Maximum capacity |
| Next Available Slot | `Next_Available_Slot__c` | DateTime | From scheduling system |
| Active | `IsActive__c` | Checkbox | Provider currently practicing |

### Step 2: Configure Facility Object

Use Account record type `Healthcare_Facility`:

| Field | API Name | Type |
|---|---|---|
| Facility Name | `Name` | Text |
| Facility Type | `Facility_Type__c` | Picklist(Hospital, Polyclinic, Specialist Centre, Community Health) |
| Address | `BillingAddress` | Address |
| Phone | `Phone` | Phone |
| Operating Hours | `Operating_Hours__c` | Text(255) |
| Region | `Region__c` | Picklist(Central, North, South, East, West) |

### Step 3: Build Provider Search Component

**OmniScript: ProviderSearch**

Step 1 — Search Criteria:
- Specialty (picklist filter)
- Facility / Region (picklist filter)
- Language (multi-select filter)
- Accepting Referrals (checkbox, default: true)
- Free text search (name, MCR)

Step 2 — Results:
- DataRaptor: `DR-ProviderSearch`
- Display: Name, MCR, Specialty, Facility, Languages, Patient Load, Next Available
- Sort by: Next Available (soonest first) or Name
- Action: Select for referral, View profile

**DataRaptor: DR-ProviderSearch (Extract)**
```
SELECT Name, MCR_Number__c, Specialty__c, Facility__c,
       Languages__c, Current_Patient_Load__c, Next_Available_Slot__c
FROM Account
WHERE RecordType.DeveloperName = 'Healthcare_Provider'
  AND IsActive__c = true
  AND (Specialty__c = :specialty OR :specialty = null)
  AND (Facility__c = :facility OR :facility = null)
  AND (Accepting_Referrals__c = true OR :acceptingOnly = false)
ORDER BY Next_Available_Slot__c ASC
```

### Step 4: Provider Profile Page

Create provider detail view with:
- Demographics: Name, MCR, Specialty, Contact
- Facility: Primary location with map
- Availability: Calendar view of next 2 weeks
- Current Load: X/Y patients (progress bar)
- Qualifications: Degrees, certifications
- Referral stats: Average wait time, acceptance rate

### Step 5: Auto-Calculate Patient Load

**Scheduled Flow: UpdateProviderLoad**
- Runs: Daily at 6:00 AM SGT
- Action: Count active CareTeamMember records per provider
- Update: `Current_Patient_Load__c`

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| UpdateProviderLoad | Scheduled Flow | Daily patient load recalculation |
| MCR Validation | Validation Rule | Validates MCR format (e.g., M followed by 5 digits) |
| Capacity Alert | Flow | Alerts admin when provider reaches 90% capacity |

## Security & Access

| Profile | Search | View Profile | Edit Provider |
|---|---|---|---|
| Clinician | Yes | Yes | No |
| Care Coordinator | Yes | Yes | No |
| Admin Staff | Yes | Yes | Edit (non-clinical) |
| System Admin | Yes | Yes | Full Edit |

## Testing Strategy

**UAT Scenarios:**
1. Search by specialty "Cardiology" — returns cardiologists only
2. Filter by "Accepting Referrals" — excludes full-capacity providers
3. Search by language "Mandarin" — returns Mandarin-speaking providers
4. View provider profile — all fields displayed correctly
5. Verify MCR number validation blocks invalid formats

## Deployment Checklist

- [ ] Provider record type and page layout created
- [ ] Facility record type created
- [ ] All custom fields deployed
- [ ] ProviderSearch OmniScript deployed
- [ ] DR-ProviderSearch DataRaptor deployed
- [ ] UpdateProviderLoad scheduled flow active
- [ ] Provider data loaded (from migration or manual entry)
- [ ] MCR validation rule active

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| Directory includes name, specialty, facility, contact, MCR, availability | Open provider record, verify all fields |
| Search/filter by specialty, facility, language | Execute each search, verify results |
| Provider profile shows patient load and next slot | Open provider profile, verify display |
| Includes internal and external providers | Verify both types appear in search |

## Dependencies

- **Blocked By:** US-1.1.1 (Patient data model for Account)
- **Blocks:** US-1.3.2 (Internal Referral Workflow), US-1.5.2 (Provider Data Migration)
