# US-3.5.1: Billing System Integration (SAP)

> **Phase:** 3 - Enterprise | **Epic:** 3.5 - Advanced Integrations | **Estimate:** L (2+ weeks)

## Overview

Sync patient encounters and insurance claims between Health Cloud and SAP billing system. Includes insurance eligibility verification and claims status tracking visible in Health Cloud.

**Business Value:** Automates billing workflow, reduces claims submission time from 5 days to 1 day, and provides clinicians visibility into insurance status without switching systems.

## Prerequisites

- US-1.1.1 (Patient Profile with insurance) completed
- SAP integration endpoints available (BAPI/RFC or REST API via SAP CPI)
- MuleSoft licence for integration middleware

## Salesforce Configuration Steps

### Step 1: Integration Architecture

```
Health Cloud ←→ MuleSoft ←→ SAP (S/4HANA or ECC)

Outbound (HC → SAP):
- Patient encounter data (after consultation)
- Diagnosis codes, procedures, services

Inbound (SAP → HC):
- Insurance eligibility verification response
- Claim status updates (submitted, approved, rejected, paid)
- Payment reconciliation data
```

### Step 2: Encounter Data Mapping

| HC Field | SAP Field | Direction |
|---|---|---|
| Patient NRIC | Business Partner ID | HC → SAP |
| Consultation Date | Service Date | HC → SAP |
| Diagnosis (ICD-10) | Diagnosis Code | HC → SAP |
| Procedure codes | Service Items | HC → SAP |
| Provider MCR | Performing Physician | HC → SAP |
| Claim Number | Claim Reference | SAP → HC |
| Claim Status | Status Code | SAP → HC |
| Approved Amount | Payment Amount | SAP → HC |

### Step 3: Insurance Eligibility Check

**Pre-Appointment Flow:**
1. Before appointment → call SAP eligibility API
2. Returns: coverage status, remaining benefits, co-pay amount
3. Display on appointment record for front desk staff
4. Alert if patient's coverage expired or insufficient

### Step 4: Claims Tracking in Health Cloud

**Custom Object: InsuranceClaim__c**

| Field | Type |
|---|---|
| Patient | Lookup(Account) |
| Encounter | Lookup(Event) |
| Claim Number | Text (from SAP) |
| Status | Picklist(Submitted, Under Review, Approved, Rejected, Paid) |
| Submitted Date | Date |
| Amount Claimed | Currency |
| Amount Approved | Currency |
| Rejection Reason | Text |

### Step 5: Reconciliation Dashboard

- Claims by status (pie chart)
- Average claim processing time
- Rejection rate by reason
- Outstanding receivables
- Monthly revenue reconciliation

## Testing Strategy

1. Complete consultation → encounter data sent to SAP
2. Pre-appointment eligibility check → returns coverage info
3. Claim submitted in SAP → status updates in Health Cloud
4. Claim rejected → rejection reason visible in HC
5. Reconciliation dashboard matches SAP totals

## Deployment Checklist

- [ ] MuleSoft integration flows deployed (outbound + inbound)
- [ ] Named Credentials for SAP configured
- [ ] Encounter data mapping validated
- [ ] Eligibility check flow active
- [ ] InsuranceClaim__c deployed
- [ ] Reconciliation dashboard deployed
- [ ] End-to-end claim lifecycle tested

## Dependencies

- **Blocked By:** US-1.1.1 (Patient/insurance data)
- **Blocks:** US-3.4.1 (Billing data feeds unified profile)
