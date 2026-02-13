# US-2.2.3: Clinical Orders Integration

> **Phase:** 2 - Care Coordination | **Epic:** 2.2 - EHR Integration | **Estimate:** L (2+ weeks)

## Overview

Enable clinicians to create lab and imaging orders within Health Cloud that are sent to the hospital LIS/RIS via FHIR R4 ServiceRequest. Order status is tracked through completion, with results flowing back via US-2.2.2.

**Business Value:** Clinicians can order tests without leaving Health Cloud, reducing context switching and ensuring orders are linked to the care plan for complete tracking.

## Prerequisites

- US-2.2.1 (FHIR R4 Patient Sync) completed
- US-2.2.2 (Lab Results Integration) completed
- Hospital LIS/RIS accepts FHIR ServiceRequest

## Salesforce Configuration Steps

### Step 1: Configure Order Catalogue

**Custom Object: OrderCatalogue__c**

| Field | Type | Description |
|---|---|---|
| Test Name | Text | e.g., "Complete Blood Count" |
| LOINC Code | Text | Standard lab code |
| Category | Picklist | Laboratory, Imaging, Procedure |
| Department | Text | Lab, Radiology, etc. |
| Typical Turnaround | Text | e.g., "2 hours", "24 hours" |
| Requires Fasting | Checkbox | |
| Special Instructions | Long Text | |

Populate with common Singapore lab orders (FBC, RP, LFT, Lipids, HbA1c, etc.).

### Step 2: Create Order Entry OmniScript

**OmniScript: CreateClinicalOrder**
1. Select test(s) from catalogue (searchable, multi-select)
2. Set urgency: Routine / Urgent / STAT
3. Add clinical indication / notes
4. Review and submit

### Step 3: FHIR ServiceRequest Mapping

| HC Field | FHIR ServiceRequest Field |
|---|---|
| Patient | subject.reference |
| Test Code | code.coding (LOINC) |
| Urgency | priority |
| Clinical Notes | note |
| Ordering Clinician | requester |

### Step 4: Order Status Tracking

| Status | Description |
|---|---|
| Ordered | Sent to LIS/RIS |
| Accepted | LIS/RIS accepted the order |
| In Progress | Sample collected / imaging scheduled |
| Completed | Results available (triggers US-2.2.2) |
| Cancelled | Order cancelled |

### Step 5: Orders on Patient Timeline

- Icon: Clipboard (orange)
- Display: Test ordered, urgency, status, ordering clinician
- Status updates reflect in real-time

## Testing Strategy

1. Order HbA1c test → verify FHIR ServiceRequest sent to LIS
2. LIS sends status updates → verify status tracked in Health Cloud
3. Results arrive → verify linked to original order
4. Urgent order → verify priority flag transmitted correctly

## Deployment Checklist

- [ ] OrderCatalogue__c populated
- [ ] CreateClinicalOrder OmniScript deployed
- [ ] FHIR ServiceRequest outbound integration deployed
- [ ] Status tracking inbound integration deployed
- [ ] Timeline event type configured
- [ ] End-to-end order-to-result flow tested

## Dependencies

- **Blocked By:** US-2.2.1, US-2.2.2
- **Blocks:** None directly (completes the EHR integration epic)
