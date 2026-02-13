# US-2.2.1: FHIR R4 Patient Sync

> **Phase:** 2 - Care Coordination | **Epic:** 2.2 - EHR Integration | **Estimate:** L (2+ weeks)

## Overview

Implement bi-directional patient demographic synchronisation between Health Cloud and the hospital EHR via FHIR R4 APIs. EHR is the source of truth for clinical data; Health Cloud is the source for engagement data.

**Business Value:** Eliminates dual data entry, ensures data consistency across systems, and provides a unified patient view. Reduces registration errors by 60-80%.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- Hospital EHR FHIR R4 endpoints available
- MuleSoft Anypoint Platform provisioned (or Health Cloud FHIR R4 APIs)
- Network connectivity between Salesforce and EHR established
- FHIR R4 Patient resource mapping agreed with EHR team

## Salesforce Configuration Steps

### Step 1: Enable Health Cloud FHIR R4 APIs

1. Navigate to **Setup > Health Cloud Admin > Interoperability**
2. Enable FHIR R4 API endpoints
3. Configure Connected App for EHR system authentication
4. Set up Named Credential for outbound calls to EHR

### Step 2: Configure FHIR Patient Resource Mapping

**Inbound (EHR → Health Cloud):**

| FHIR Patient Field | Health Cloud Field | Notes |
|---|---|---|
| identifier[NRI].value | NRIC__pc | Singapore NRIC |
| name.family | LastName | |
| name.given | FirstName | |
| birthDate | PersonBirthdate | |
| gender | Gender__pc | Map: male→Male, female→Female |
| telecom[phone].value | Phone | |
| telecom[email].value | PersonEmail | |
| address | PersonMailingAddress | Parse components |

**Outbound (Health Cloud → EHR):**

| Health Cloud Field | FHIR Patient Field | Notes |
|---|---|---|
| NRIC__pc | identifier[NRI] | |
| Preferred_Language__pc | communication.language | |
| Emergency_Contact_Name__pc | contact.name | |
| Emergency_Contact_Phone__pc | contact.telecom | |

### Step 3: Implement Sync Architecture

**MuleSoft Integration Flow:**

```
EHR (FHIR R4) ←→ MuleSoft ←→ Salesforce Health Cloud

Inbound Flow (EHR → HC):
1. EHR sends FHIR Patient resource (create/update webhook)
2. MuleSoft receives and transforms
3. MuleSoft upserts to Salesforce using NRIC as external ID
4. Salesforce returns success/failure

Outbound Flow (HC → EHR):
1. Salesforce Platform Event on Patient update
2. MuleSoft subscribes to event
3. MuleSoft transforms to FHIR Patient resource
4. MuleSoft PUTs to EHR FHIR endpoint
5. EHR returns success/failure
```

### Step 4: Conflict Resolution Logic

| Field Category | Source of Truth | Resolution |
|---|---|---|
| Clinical demographics (DOB, Gender) | EHR | EHR always wins |
| Contact info (Phone, Email, Address) | Last updated | Most recent timestamp wins |
| Engagement preferences (Language, SMS consent) | Health Cloud | HC always wins |
| NRIC | EHR | EHR always wins (validated at source) |

**Conflict Log:** Store all conflicts in SyncConflict__c for review.

### Step 5: Error Handling & Retry

| Error Type | Action | Retry |
|---|---|---|
| Network timeout | Log, retry | 3 attempts, exponential backoff |
| FHIR validation error | Log, notify admin | No auto-retry |
| Duplicate detected | Log, route to data steward | No auto-retry |
| Auth failure | Log, alert IT | No auto-retry |

**Custom Object: SyncLog__c** — tracks all sync operations with status, timestamp, error details.

### Step 6: Monitoring Dashboard

- Sync success rate (last 24h, 7d, 30d)
- Failed syncs requiring attention
- Average sync latency
- Records synced per day

## Testing Strategy

1. Create patient in EHR → verify appears in Health Cloud within 5 min
2. Update phone in Health Cloud → verify updated in EHR within 5 min
3. Conflicting update (both systems) → verify correct source of truth wins
4. Network failure → verify retry logic and error logging
5. Bulk sync: 1000 patient updates → verify all sync within SLA

## Deployment Checklist

- [ ] FHIR R4 APIs enabled in Health Cloud
- [ ] MuleSoft integration flows deployed
- [ ] Named Credentials configured
- [ ] FHIR resource mapping validated
- [ ] Conflict resolution logic tested
- [ ] Error handling and retry mechanism active
- [ ] SyncLog__c object deployed
- [ ] Monitoring dashboard created
- [ ] End-to-end sync tested (both directions)

## Dependencies

- **Blocked By:** US-1.1.1 (Patient data model)
- **Blocks:** US-2.2.2 (Lab Results), US-2.2.3 (Clinical Orders), US-3.6.1 (NEHR)
