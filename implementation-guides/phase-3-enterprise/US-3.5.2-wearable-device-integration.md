# US-3.5.2: Wearable Device Data Integration

> **Phase:** 3 - Enterprise | **Epic:** 3.5 - Advanced Integrations | **Estimate:** M (1-2 weeks)

## Overview

Integrate wearable health device data (heart rate, steps, sleep, SpO2) from Apple Health and Google Fit into Health Cloud. Abnormal readings trigger care plan alerts.

**Business Value:** Provides continuous monitoring between visits, enables early detection of deterioration, and gives care teams a complete picture of patient's daily health. Studies show 15-25% better outcomes with continuous monitoring.

## Prerequisites

- US-1.2.4 (Goal Tracking) completed
- US-1.6.1 (Consent) completed — wearable data consent required
- Patient mobile app (US-3.2.1) or portal for data relay

## Salesforce Configuration Steps

### Step 1: Integration Architecture

**Data Flow:**
```
Wearable Device → Apple Health / Google Fit → Patient Mobile App → Health Cloud API
```

The mobile app acts as the relay — device data is aggregated by the health platform and sent to Salesforce via authenticated REST API calls.

### Step 2: Data Model

**Custom Object: WearableReading__c**

| Field | Type |
|---|---|
| Patient | Lookup(Account) |
| Reading Type | Picklist(Heart Rate, Steps, Sleep, SpO2, Activity) |
| Value | Number |
| Unit | Text |
| Reading Date | DateTime |
| Source Device | Text (e.g., "Apple Watch Series 9") |
| Source Platform | Picklist(Apple Health, Google Fit) |

### Step 3: Data Normalisation

| Reading Type | Unit | Normal Range | Alert Threshold |
|---|---|---|---|
| Resting Heart Rate | bpm | 60-100 | < 50 or > 120 |
| SpO2 | % | 95-100 | < 92 |
| Steps (daily) | count | 5000+ | < 1000 (3 consecutive days) |
| Sleep | hours | 6-9 | < 4 hours |

### Step 4: Alert Configuration

**Flow: WearableAlert**
- Trigger: New WearableReading__c with value outside normal range
- Critical: Heart rate > 150 or SpO2 < 90 → immediate alert to care team
- Warning: Values in threshold zone → logged, alert if persists 3+ days
- Notifications to: assigned care coordinator + primary physician

### Step 5: Patient 360 Integration

**Child FlexCard: FC-WearableData**
- Shows: Latest readings for each type with trend sparklines
- Colour coding: Green (normal), Amber (borderline), Red (alert)
- Time range: Last 7 days default, expandable to 30 days

### Step 6: Consent Management

- Wearable data sharing requires separate patient consent
- Consent captured in US-1.6.1 framework (Purpose: "Wearable Data Sharing")
- Patient can revoke at any time → stops data sync

## Testing Strategy

1. Apple Watch heart rate syncs → appears in Health Cloud
2. SpO2 drops to 89% → care team alerted immediately
3. Steps below 1000 for 3 days → warning alert generated
4. Patient without wearable consent → no data synced
5. Wearable data visible on Patient 360 with correct trends

## Deployment Checklist

- [ ] WearableReading__c deployed
- [ ] REST API endpoint for mobile app data submission
- [ ] Data normalisation and validation rules active
- [ ] WearableAlert flow active
- [ ] FC-WearableData FlexCard deployed
- [ ] Consent integration active
- [ ] Tested with Apple Health and Google Fit data

## Dependencies

- **Blocked By:** US-1.2.4, US-1.6.1, US-3.2.1 (mobile app as relay)
- **Blocks:** US-3.4.1 (Wearable data feeds unified profile)
