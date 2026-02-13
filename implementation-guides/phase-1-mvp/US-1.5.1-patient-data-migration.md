# US-1.5.1: Patient Data Migration

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.5 - Data Migration | **Estimate:** L (2+ weeks)

## Overview

Migrate existing patient demographic data, conditions, allergies, and medications from the legacy system into Health Cloud. This ensures clinicians have historical context from Day 1 of go-live.

**Business Value:** Eliminates the need for clinicians to manually re-enter patient history, ensures continuity of care from legacy to new system, and prevents loss of critical clinical data.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed — target data model ready
- US-1.1.4 (Duplicate Detection) completed — dedup rules active
- Legacy system data dictionary and sample extracts obtained
- Data quality assessment completed
- Migration sandbox environment provisioned

## Salesforce Configuration Steps

### Step 1: Data Discovery & Mapping

**Source System Analysis:**
- Identify all tables/files containing patient data
- Document field-level mapping from legacy to Health Cloud
- Identify data quality issues (nulls, invalid formats, duplicates)

**Field Mapping Matrix:**

| Legacy Field | Health Cloud Object | HC Field API | Transform |
|---|---|---|---|
| patient_id | Account (Person) | External_Legacy_Id__c | Direct |
| full_name | Account | FirstName + LastName | Split on space |
| nric | Account | NRIC__pc | Validate checksum |
| dob | Account | PersonBirthdate | Format: YYYY-MM-DD |
| gender | Account | Gender__pc | Map: M→Male, F→Female |
| ethnicity | Account | Ethnicity__pc | Map to picklist values |
| phone | Account | Phone | Standardise +65 format |
| email | Account | PersonEmail | Validate format |
| address | Account | PersonMailingAddress | Parse components |
| condition_code | HealthCondition | CodeId | Map to ICD-10 code set |
| condition_name | HealthCondition | Name | Direct |
| condition_status | HealthCondition | ClinicalStatus | Map to picklist |
| medication_name | MedicationStatement | Name | Standardise drug names |
| dosage | MedicationStatement | Dosage__c | Direct |
| allergy | AllergyIntolerance | Name | Direct |
| allergy_reaction | AllergyIntolerance | Reaction_Type__c | Direct |

### Step 2: Data Cleansing Rules

| Rule | Description | Action |
|---|---|---|
| NRIC Format | Must match S/T/F/G/M + 7 digits + letter | Flag invalid, manual review |
| NRIC Checksum | Validate NRIC checksum digit | Flag invalid |
| NRIC Uniqueness | No duplicate NRICs in source | Merge duplicates pre-migration |
| DOB Range | Must be between 1900-01-01 and today | Flag out-of-range |
| Phone Format | Standardise to +65XXXXXXXX | Auto-format |
| Email Validation | Valid email format | Flag invalid |
| Condition Codes | Map to ICD-10 | Flag unmapped codes |
| Required Fields | Name, NRIC, DOB required | Reject incomplete records |

### Step 3: Pre-Migration Deduplication

1. Extract all NRICs from legacy system
2. Run duplicate detection: group by NRIC
3. For each duplicate group:
   - Identify master record (most recent, most complete)
   - Merge data from duplicate into master
   - Log merge decisions
4. Validate: 100% NRIC uniqueness post-dedup

### Step 4: Migration Approach

**Tool Selection:**
- **< 50K records:** Salesforce Data Loader (CLI batch mode)
- **> 50K records:** MuleSoft or Informatica ETL
- **Complex transforms:** Custom Apex batch + Data Loader

**Migration Sequence (order matters):**

| Step | Object | Dependencies | Est. Records |
|---|---|---|---|
| 1 | Account (Patient) | None | All active patients |
| 2 | HealthCondition | Account (Patient FK) | ~3x patients |
| 3 | MedicationStatement | Account (Patient FK) | ~5x patients |
| 4 | AllergyIntolerance | Account (Patient FK) | ~1x patients |
| 5 | MemberPlan | Account (Patient FK) | ~1x patients |

### Step 5: Migration Execution

**Sandbox Migration (Rehearsal):**
1. Load patient accounts (batch of 200)
2. Validate: record counts, field completeness, NRIC uniqueness
3. Load conditions — validate FK relationships
4. Load medications — validate FK relationships
5. Load allergies — validate FK relationships
6. Run data quality report
7. Fix issues, repeat until clean

**Production Migration:**
1. Schedule migration window (weekend, off-hours)
2. Disable triggers and validation rules (performance)
3. Execute migration in sequence
4. Re-enable triggers and validation rules
5. Run post-migration validation
6. Generate migration audit report

### Step 6: Post-Migration Validation

**Validation Checks:**

| Check | Expected Result |
|---|---|
| Patient record count | Source count = Target count |
| NRIC uniqueness | 0 duplicates |
| Orphan conditions | 0 conditions without patient FK |
| Orphan medications | 0 medications without patient FK |
| Field completeness | Name: 100%, NRIC: 100%, DOB: 100%, Phone: 95%+ |
| ICD-10 mapping | 100% conditions have valid ICD-10 code |

**Migration Audit Report:**
- Total records attempted per object
- Successfully migrated
- Failed (with error details)
- Skipped (with reason)
- Data quality metrics

### Step 7: Rollback Plan

**Rollback Procedure:**
1. Identify scope of rollback (full or partial)
2. Delete migrated records by batch using External_Legacy_Id__c
3. Order: Allergies → Medications → Conditions → Patients (reverse of load)
4. Verify deletion counts match load counts
5. Re-run migration from corrected source

**Rollback Testing:**
- Execute rollback in sandbox after rehearsal migration
- Verify clean state: zero migrated records, no orphans
- Document rollback duration (for production planning)

## Objects, Fields & Data Model

**Custom Field for Tracking:**

| Object | Field | API Name | Type |
|---|---|---|---|
| Account | Legacy ID | `External_Legacy_Id__c` | Text(50), External ID |
| Account | Migration Date | `Migration_Date__c` | DateTime |
| Account | Migration Source | `Migration_Source__c` | Text(50) |
| All objects | Source System | `Source_System__c` | Text(50) |

## Security & Access

- Migration executed by System Admin or dedicated migration user
- Legacy data access controlled by data sharing agreement
- NRIC data encrypted in transit (SFTP with PGP encryption)
- Post-migration: access controlled by Health Cloud security model

## Testing Strategy

- **Rehearsal migration** in Full sandbox (minimum 2 rehearsals)
- **Spot-check** 50 random patient records against legacy source
- **Automated validation** scripts for counts, completeness, uniqueness
- **UAT:** Clinicians verify 10 known patients have correct data

## Deployment Checklist

- [ ] Data mapping document signed off by clinical SME
- [ ] Cleansing rules defined and tested
- [ ] Pre-migration dedup completed (0 duplicate NRICs)
- [ ] Rehearsal 1 completed in sandbox
- [ ] Rehearsal 2 completed in sandbox (clean run)
- [ ] Migration audit report template ready
- [ ] Rollback plan documented and tested
- [ ] Production migration window scheduled
- [ ] Post-migration validation scripts ready
- [ ] Clinical UAT sign-off on sample records

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| All active patients migrated (demographics, conditions, allergies, meds) | Record count comparison source vs target |
| 100% NRIC uniqueness | Query: `SELECT NRIC__pc, COUNT(Id) FROM Account GROUP BY NRIC__pc HAVING COUNT(Id) > 1` |
| No orphan records | Query child objects where parent FK is null |
| Duplicate detection run pre-migration with resolution | Dedup log showing merged records |
| Migration audit report generated | Report with counts and exceptions |
| Rollback plan documented and tested | Rollback executed in sandbox |

## Dependencies

- **Blocked By:** US-1.1.1 (Target data model), US-1.1.4 (Duplicate detection rules)
- **Blocks:** US-1.1.3 (Timeline shows historical data), all Phase 1 features (need data to function)
