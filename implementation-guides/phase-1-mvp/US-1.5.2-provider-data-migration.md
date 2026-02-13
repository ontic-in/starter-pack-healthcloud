# US-1.5.2: Provider Data Migration

> **Phase:** 1 - Foundation/MVP | **Epic:** 1.5 - Data Migration | **Estimate:** S (1-3 days)

## Overview

Migrate provider directory data (demographics, specialties, facilities, MCR numbers) into Health Cloud so the referral network is available at go-live.

**Business Value:** Ensures the provider directory is populated from Day 1, enabling immediate use of the referral workflow without manual data entry.

## Prerequisites

- US-1.3.1 (Provider Directory) completed — target data model ready
- Provider data extract from legacy system / MOH registry
- MCR number validation reference data

## Salesforce Configuration Steps

### Step 1: Data Mapping

| Legacy Field | HC Object | HC Field | Transform |
|---|---|---|---|
| provider_id | Account | External_Legacy_Id__c | Direct |
| name | Account | Name | Direct |
| mcr_number | Account | MCR_Number__c | Validate format |
| specialty | Account | Specialty__c | Map to picklist |
| facility_name | Account | Facility__c | Lookup to Facility account |
| phone | Account | Phone | Format +65 |
| email | Account | PersonEmail | Validate |
| languages | Account | Languages__c | Map to multi-select |
| provider_type | Account | Provider_Type__c | Map: Internal/External |

### Step 2: Migration Sequence

| Step | Object | Records |
|---|---|---|
| 1 | Account (Facility) | ~10-50 facilities |
| 2 | Account (Provider) | ~100-1000 providers |
| 3 | Provider-Facility relationships | 1:many |

### Step 3: Data Validation

| Check | Expected |
|---|---|
| MCR format valid | 100% match M + 5 digits pattern |
| No duplicate providers | 0 duplicates by MCR number |
| All providers linked to facility | 0 orphan providers |
| Specialty values mapped | 100% valid picklist values |

### Step 4: Execution

1. Load facilities first (parent records)
2. Load providers with facility lookups
3. Run validation queries
4. Generate audit report

## Testing Strategy

**UAT:** Care coordinators verify 20 known providers have correct MCR, specialty, and facility linkage.

## Deployment Checklist

- [ ] Facility records loaded
- [ ] Provider records loaded
- [ ] MCR numbers validated
- [ ] Provider-facility relationships verified
- [ ] No duplicate providers
- [ ] Audit report generated
- [ ] Care coordinator UAT sign-off

## Acceptance Criteria Verification

| Criteria | How to Verify |
|---|---|
| All active providers migrated | Count comparison |
| Provider-facility relationships maintained | Query providers without facility |
| No duplicate providers | Group by MCR, check count > 1 |
| All MCR numbers valid | Regex validation on MCR_Number__c |

## Dependencies

- **Blocked By:** US-1.3.1 (Provider Directory data model)
- **Blocks:** US-1.3.2 (Referral Workflow — needs providers), US-1.2.3 (Care Team — needs providers)
