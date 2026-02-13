# US-1.1.4: Patient Search & Duplicate Detection

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.1 - Patient 360 | **Estimate:** S (1-3 days)

## Overview

Configure global patient search by NRIC, name, or phone number with automatic duplicate detection to prevent creation of duplicate patient records. Includes fuzzy matching for multilingual name transliterations common in Singapore.

**Business Value:** Prevents costly duplicate records (average $25-50 per duplicate to resolve), ensures data integrity, and supports accurate patient identification critical for clinical safety.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- NRIC field configured as external ID

## Salesforce Configuration Steps

### Step 1: Configure Global Search

1. Navigate to **Setup > Search Settings**
2. Enable searchable fields on Person Account:
   - `NRIC__pc` (exact match, high priority)
   - `FirstName` + `LastName` (fuzzy match)
   - `Phone`, `PersonMobilePhone`
   - `PersonEmail`

3. Configure Search Layouts for Person Account:
   - Display columns: Name, NRIC_Display__pc, PersonBirthdate, Gender__pc, Phone
   - Sort by: Relevance

### Step 2: Create NRIC Search Component

Build a custom LWC or OmniScript for NRIC-based exact search:

**OmniScript: PatientSearch**
- Step 1: Search Input
  - Field: Search Term (Text)
  - Field: Search Type (Picklist: NRIC, Name, Phone)
- Step 2: Results Display
  - DataRaptor: DR-PatientSearch
  - Display: Name, NRIC (masked for non-clinical), DOB, Gender, Phone
  - Action: Navigate to Patient Record

**DataRaptor: DR-PatientSearch**
- NRIC search: `WHERE NRIC__pc = :searchTerm`
- Name search: `WHERE FirstName LIKE :searchTerm OR LastName LIKE :searchTerm`
- Phone search: `WHERE Phone = :searchTerm OR PersonMobilePhone = :searchTerm`

### Step 3: Configure Duplicate Rules

**Duplicate Rule 1: NRIC Exact Match**
- Object: Person Account (Patient)
- Matching Rule: `NRIC_Match`
- Action on Create: **Block** (prevent duplicate creation)
- Action on Edit: **Alert** (warn but allow)
- Alert message: "A patient with this NRIC already exists: {Name} ({NRIC_Display__pc})"

**Matching Rule: NRIC_Match**
- Field: `NRIC__pc`
- Match Type: Exact
- Match confidence: 100%

**Duplicate Rule 2: Name + DOB Match**
- Object: Person Account (Patient)
- Matching Rule: `NameDOB_Match`
- Action on Create: **Alert** (warn, allow override)
- Action on Edit: **Alert**

**Matching Rule: NameDOB_Match**
- Field 1: `FirstName` — Fuzzy (First Name match)
- Field 2: `LastName` — Fuzzy (Last Name match)
- Field 3: `PersonBirthdate` — Exact
- Match confidence: 85%+

### Step 4: Configure Fuzzy Name Matching

Singapore-specific name transliteration handling:

**Custom Metadata: NameVariant__mdt**
| Standard Form | Variants |
|---|---|
| Muhammad | Mohammad, Mohamed, Mohamad, Mohd |
| Tan | Chen (陈), Chan |
| Lee | Li (李), Ly |
| Wong | Wang (王), Huang, Ong |
| Ng | Wu (吴), Woo |
| Kumar | Kumaran, Kumari |

Create an Apex class `NameVariantMatcher` that:
1. Looks up custom metadata for name variants
2. Expands search to include known transliterations
3. Returns additional potential matches for review

### Step 5: Configure Merge Workflow

**OmniScript: PatientMerge**
- Step 1: Select Master Record
  - Display both records side-by-side
  - Recommend master based on: most recent activity, most complete data
- Step 2: Field-by-Field Comparison
  - Highlight differences between records
  - User selects which value to keep per field
- Step 3: Related Record Reassignment
  - Show all related records (conditions, medications, care plans)
  - Preview: "X conditions, Y medications will be moved to master record"
- Step 4: Confirmation & Merge
  - Summary of all changes
  - Audit log entry created
  - Non-master record soft-deleted (archived)

### Step 6: Registration Search Prompt

Configure auto-search during patient registration:
1. When staff enters NRIC in registration form, auto-trigger search
2. If match found: display existing record, offer to navigate
3. If no match: continue with new registration
4. If potential match (fuzzy): display candidates, require staff to confirm "New Patient"

## Objects, Fields & Data Model

**Custom Metadata:**
- `NameVariant__mdt` — stores Singapore name transliteration mappings

**Custom Object:**
- `MergeAuditLog__c` — tracks all patient merge operations

| Field | API Name | Type |
|---|---|---|
| Master Record | `Master_Record__c` | Lookup(Account) |
| Merged Record | `Merged_Record_Id__c` | Text(18) |
| Merged By | `Merged_By__c` | Lookup(User) |
| Merge Date | `CreatedDate` | DateTime |
| Fields Changed | `Fields_Changed__c` | Long Text |

## Automation & Flows

| Automation | Type | Description |
|---|---|---|
| NRIC Auto-Search | Flow | Triggers search when NRIC entered during registration |
| Duplicate Alert | Duplicate Rule | Blocks/alerts on duplicate creation |
| Merge Audit | Apex Trigger | Logs merge operations to MergeAuditLog__c |
| Post-Merge Cleanup | Flow | Reassigns related records and cleans up references |

## Security & Access

- Search results respect record-level sharing — users only see patients they have access to
- NRIC display in search results follows masking rules per profile
- Merge operations restricted to System Admin and Data Steward profiles
- Merge audit log read-only for all users

## Testing Strategy

**Unit Tests:**
- NRIC exact match returns correct patient
- Name fuzzy match returns transliteration variants
- Duplicate rule blocks creation of duplicate NRIC
- Merge workflow correctly reassigns related records
- Merge audit log created on every merge

**UAT Scenarios:**
1. Search by NRIC "S1234567A" — returns exact match
2. Search by name "Mohamed" — returns "Muhammad" variants
3. Attempt to create patient with existing NRIC — blocked with message
4. Create two similar patients, merge them, verify data consolidated
5. Verify search results show masked NRIC for admin staff

## Deployment Checklist

- [ ] Global search configured for Person Account fields
- [ ] PatientSearch OmniScript deployed
- [ ] DR-PatientSearch DataRaptor deployed
- [ ] Duplicate Rule (NRIC) active
- [ ] Duplicate Rule (Name+DOB) active
- [ ] Matching Rules deployed and active
- [ ] NameVariant custom metadata populated
- [ ] PatientMerge OmniScript deployed
- [ ] MergeAuditLog custom object deployed
- [ ] Registration auto-search flow active

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| Search by NRIC returns exact match | Search for known NRIC, verify result |
| Search by name returns fuzzy matches | Search "Mohamed", verify "Muhammad" appears |
| Duplicate detection triggers on NRIC | Attempt duplicate creation, verify block |
| Duplicate detection on DOB + name combination | Create similar patient, verify alert |
| Merge workflow available for confirmed duplicates | Execute merge, verify data consolidation |

## Dependencies

- **Blocked By:** US-1.1.1 (Patient Profile Setup)
- **Blocks:** US-1.5.1 (Data Migration pre-migration dedup)
