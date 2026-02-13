# US-1.1.1: Patient Profile Setup

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.1 - Patient 360 | **Estimate:** M (1-2 weeks)

## Overview

Configure the Health Cloud Patient 360 data model with demographics, conditions, medications, and allergies to create a unified patient profile. This is the foundational data model upon which all other Health Cloud features are built.

**Business Value:** Eliminates fragmented patient records across departments, provides clinicians with a single source of truth, and ensures Singapore regulatory compliance (PDPA, NRIC handling).

## Prerequisites

- Salesforce Health Cloud licence provisioned
- Health Cloud managed package installed
- OmniStudio managed package installed
- System Administrator access to the org
- Data dictionary from legacy system (for field mapping)

## Salesforce Configuration Steps

### Step 1: Enable Person Accounts

1. Navigate to **Setup > Account Settings**
2. Enable **Person Accounts** (irreversible - confirm with stakeholders)
3. Create Person Account record type: `Patient`
4. Map default Person Account page layout

### Step 2: Configure Patient Demographics

**Standard Fields (Person Account):**
- `FirstName`, `LastName`, `MiddleName`
- `PersonBirthdate` (Date of Birth)
- `PersonEmail`, `Phone`, `PersonMobilePhone`
- `PersonMailingAddress` (Street, City, PostalCode, Country)
- `Gender__pc` (Health Cloud standard)

**Custom Fields for Singapore Context:**

| Field Label | API Name | Type | Details |
|---|---|---|---|
| NRIC/FIN | `NRIC__pc` | Text(9) | Encrypted, unique, external ID |
| Ethnicity | `Ethnicity__pc` | Picklist | Chinese, Malay, Indian, Eurasian, Others |
| Preferred Language | `Preferred_Language__pc` | Picklist | English, Mandarin, Malay, Tamil, Others |
| Nationality | `Nationality__pc` | Picklist | Singapore Citizen, PR, Foreigner |
| Emergency Contact Name | `Emergency_Contact_Name__pc` | Text(100) | |
| Emergency Contact Phone | `Emergency_Contact_Phone__pc` | Phone | |
| Emergency Contact Relationship | `Emergency_Contact_Relationship__pc` | Picklist | Spouse, Parent, Child, Sibling, Other |

### Step 3: Configure Health Conditions

**Object:** `HealthCondition` (Health Cloud standard)

| Field Label | API Name | Type | Details |
|---|---|---|---|
| Condition Name | `Name` | Text | Auto-populated from ICD-10 lookup |
| ICD-10 Code | `CodeId` | Lookup(CodeSet) | Link to ICD-10 code set |
| Status | `ClinicalStatus` | Picklist | Active, Recurrence, Relapse, Inactive, Remission, Resolved |
| Verification | `VerificationStatus` | Picklist | Confirmed, Provisional, Differential, Refuted |
| Onset Date | `OnsetDateTime` | Date | When condition first diagnosed |
| Abatement Date | `AbatementDateTime` | Date | When condition resolved (if applicable) |
| Severity | `Severity` | Picklist | Mild, Moderate, Severe |
| Patient | `PatientId` | Lookup(Account) | Link to patient Person Account |
| Diagnosing Provider | `Diagnosing_Provider__c` | Lookup(Account) | Link to provider account |

**ICD-10 Code Set Setup:**
1. Navigate to **Setup > Code Sets**
2. Import ICD-10-AM (Australian Modification, used in Singapore) code set
3. Configure commonly used codes for quick access (E11 Diabetes, I10 Hypertension, I25 Ischemic Heart Disease)

### Step 4: Configure Medications

**Object:** `MedicationStatement` (Health Cloud standard)

| Field Label | API Name | Type | Details |
|---|---|---|---|
| Medication Name | `Name` | Text | Drug name |
| Dosage | `Dosage__c` | Text(100) | e.g., "500mg" |
| Frequency | `Frequency__c` | Picklist | OD, BD, TDS, QDS, PRN, Weekly |
| Route | `Route__c` | Picklist | Oral, IV, SC, IM, Topical, Inhaled |
| Status | `Status` | Picklist | Active, On-hold, Completed, Stopped |
| Start Date | `EffectivePeriodStart` | Date | |
| End Date | `EffectivePeriodEnd` | Date | |
| Prescribing Physician | `Prescriber__c` | Lookup(Account) | Provider who prescribed |
| Patient | `PatientId` | Lookup(Account) | |
| Notes | `Notes__c` | Long Text | Special instructions |

### Step 5: Configure Allergies

**Object:** `AllergyIntolerance` (Health Cloud standard)

| Field Label | API Name | Type | Details |
|---|---|---|---|
| Allergen | `Name` | Text | Substance causing allergy |
| Category | `AllergyCategory` | Picklist | Food, Medication, Environment, Biologic |
| Type | `AllergyIntoleranceType` | Picklist | Allergy, Intolerance |
| Criticality | `Criticality` | Picklist | Low, High, Unable to Assess |
| Reaction Type | `Reaction_Type__c` | Text(255) | e.g., "Anaphylaxis", "Rash" |
| Reaction Severity | `Reaction_Severity__c` | Picklist | Mild, Moderate, Severe |
| Onset Date | `OnsetDateTime` | Date | |
| Patient | `PatientId` | Lookup(Account) | |
| Verified By | `Verified_By__c` | Lookup(User) | Clinician who confirmed |

### Step 6: Configure Insurance & Coverage

**Object:** `MemberPlan` (Health Cloud standard) + custom fields

| Field Label | API Name | Type | Details |
|---|---|---|---|
| Insurance Provider | `Name` | Text | e.g., "Great Eastern", "AIA" |
| Policy Number | `MemberId` | Text | Insurance policy number |
| Coverage Type | `Coverage_Type__c` | Picklist | Integrated Shield Plan, Medisave, MediShield Life, Private, Corporate |
| Medisave Balance | `Medisave_Balance__c` | Currency | Current CPF Medisave balance |
| Coverage Start | `EffectiveFrom` | Date | |
| Coverage End | `EffectiveTo` | Date | |
| Status | `Status` | Picklist | Active, Inactive, Pending |
| Patient | `AccountId` | Lookup(Account) | |

### Step 7: Configure Page Layouts

1. Create Patient Person Account page layout with sections:
   - **Demographics** (name, NRIC, DOB, gender, ethnicity, language, contact)
   - **Emergency Contact** (name, phone, relationship)
   - **Health Conditions** (related list)
   - **Medications** (related list)
   - **Allergies** (related list)
   - **Insurance & Coverage** (related list)
2. Assign layout to Patient record type

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| NRIC Validation | Validation Rule | Validates NRIC format: starts with S/T/F/G/M, 7 digits, ends with checksum letter |
| NRIC Uniqueness | Duplicate Rule | Prevents creation of patient with existing NRIC |
| Age Calculation | Formula Field | `FLOOR((TODAY() - PersonBirthdate) / 365.25)` |
| New Patient Notification | Flow | Notifies assigned clinic coordinator when new patient registered |

## Security & Access

| Profile | Demographics | NRIC | Conditions | Medications | Allergies | Insurance |
|---|---|---|---|---|---|---|
| Clinician | Read/Edit | Read (Full) | Read/Edit | Read/Edit | Read/Edit | Read |
| Care Coordinator | Read/Edit | Read (Full) | Read | Read | Read | Read |
| Admin Staff | Read/Edit | Read (Masked) | Hidden | Hidden | Hidden | Read/Edit |
| Management | Read | Read (Masked) | Read | Read | Read | Read |

- **NRIC Masking:** Use formula field `NRIC_Display__pc` that shows `LEFT(NRIC__pc,1) & "****" & RIGHT(NRIC__pc,3)` for non-clinical users
- **Encryption:** Enable Shield Platform Encryption on `NRIC__pc` field

## Testing Strategy

**Unit Tests:**
- Validate NRIC format validation rule (valid/invalid formats)
- Verify duplicate detection on NRIC
- Test field-level security per profile

**UAT Scenarios:**
1. Register new patient with full demographics, verify all fields saved
2. Add conditions with ICD-10 codes, verify lookup works
3. Add medications and allergies, verify related lists display
4. Verify NRIC masking for admin staff profile
5. Verify insurance/Medisave balance display

## Deployment Checklist

- [ ] Person Accounts enabled
- [ ] Patient record type created
- [ ] All custom fields deployed
- [ ] ICD-10 code set imported
- [ ] Validation rules active
- [ ] Duplicate rules active
- [ ] Page layouts assigned
- [ ] Field-level security configured per profile
- [ ] Shield encryption enabled on NRIC
- [ ] Smoke test: create patient with all data points

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| Patient record includes name, NRIC, DOB, gender, ethnicity, language, address, phone, email, emergency contact | Create test patient, verify all fields visible and editable |
| Conditions tracked with ICD-10 codes, status, diagnosis date | Add HealthCondition record, verify ICD-10 lookup and status picklist |
| Medications list with dosage, frequency, prescribing physician | Add MedicationStatement, verify all fields |
| Allergies with reaction type and severity | Add AllergyIntolerance, verify reaction fields |
| Insurance info (policy number, coverage type, Medisave balance) | Add MemberPlan, verify Medisave balance field |

## Dependencies

- **Blocks:** US-1.1.2 (FlexCard), US-1.1.3 (Timeline), US-1.1.4 (Search), US-1.2.1 (Care Plans), US-1.5.1 (Data Migration), US-1.6.1 (Consent)
- **Blocked By:** None (this is the foundation)
