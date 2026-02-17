# [US-1.1.1] Patient Profile Setup

- **Ticket**: https://app.clickup.com/t/86d1yxw5k
- **Branch**: main
- **Epic**: 1.1 Patient 360 | Phase: 1 MVP

## Acceptance Criteria

- [x] Patient record: name, NRIC, DOB, gender, ethnicity, language, address, phone, email, emergency contact
- [x] Conditions tracked with ICD-10 codes, status (active/resolved), diagnosis date
- [x] Medications list with dosage, frequency, prescribing physician
- [x] Allergies captured with reaction type and severity
- [x] Insurance information stored (policy number, coverage type, Medisave balance)

## Org Analysis

### Already Exists (Health Cloud Standard)
| Requirement | Object | Fields |
|---|---|---|
| Name, DOB, Gender, Language, Address, Phone, Email | Account (PersonAccount) | FirstName, LastName, PersonBirthdate, PersonGender, HealthCloudGA__PrimaryLanguage__pc, PersonMailingAddress, Phone, PersonEmail |
| Conditions with ICD-10, status, date | HealthCondition | ConditionCodeId, ConditionStatus, OnsetStartDateTime |
| Medications with dosage, frequency | MedicationStatement + PatientMedicationDosage | DosageQuantityNumerator, DosageRateNumerator |
| Allergies with reaction type, severity | AllergyIntolerance + PatientHealthReaction | ManifestedSymptomId, Severity |
| Insurance policy, coverage | MemberPlan + CoverageBenefit | MemberNumber, CoverageType |

### Custom Fields to Create (Gaps)
| Object | Field | Type | Purpose |
|---|---|---|---|
| Account | NRIC__c | Text(9), Unique | Singapore National ID |
| Account | Ethnicity__c | Picklist | Patient ethnicity |
| Account | Emergency_Contact_Name__c | Text(255) | Emergency contact |
| Account | Emergency_Contact_Phone__c | Phone | Emergency contact phone |
| Account | Emergency_Contact_Relationship__c | Picklist | Relationship to patient |
| MemberPlan | Medisave_Balance__c | Currency | Singapore Medisave balance |

### Additional Components
- Permission Set: Patient_360_Access
- Apex Test Class: Patient360DataModelTest

## Implementation Plan

### Phase 1: Custom Fields
1. Create 5 Account custom fields
2. Create 1 MemberPlan custom field

### Phase 2: Permission Set
1. Create Patient_360_Access permission set with access to all relevant fields

### Phase 3: Apex Test
1. Create test class that validates field creation and CRUD operations

### Phase 4: Deploy & Verify
1. Deploy all components
2. Run tests
3. Verify in org

## Progress Tracking

| Step | Status | Notes |
|---|---|---|
| Org analysis | Complete | HC standard objects installed |
| Custom fields created | Complete | 6 fields |
| Permission set created | Complete | Patient_360_Access |
| Apex test created | Complete | Patient360DataModelTest |
| Deployed to org | Pending | |
| Tests passing | Pending | |
| Manual verification | Pending | |
