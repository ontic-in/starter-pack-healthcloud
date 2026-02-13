# US-2.4.1: Social Determinants of Health Tracking

> **Phase:** 2 - Care Coordination | **Epic:** 2.4 - SDOH & Population Health | **Estimate:** S (1-3 days)

## Overview

Record social determinants of health (housing, employment, food security, social support) for patients using a standardised assessment form. SDOH data is visible on Patient 360 and integrated into risk scoring.

**Business Value:** SDOH factors account for 30-55% of health outcomes. Capturing these enables targeted interventions for vulnerable patients and supports population health management.

## Prerequisites

- US-1.1.1 (Patient Profile Setup) completed
- US-1.1.2 (Patient 360 FlexCard) completed
- SDOH assessment tool selected (e.g., PRAPARE, AHC-HRSN)

## Salesforce Configuration Steps

### Step 1: Create SDOH Data Model

**Custom Object: SDOHAssessment__c**

| Field | Type |
|---|---|
| Patient | Lookup(Account) |
| Assessment Date | Date |
| Assessed By | Lookup(User) |
| Housing Status | Picklist(Stable, At Risk, Homeless) |
| Employment Status | Picklist(Employed, Unemployed, Retired, Disabled) |
| Food Security | Picklist(Secure, Insecure, Severely Insecure) |
| Financial Strain | Picklist(None, Moderate, Severe) |
| Social Support | Picklist(Strong, Moderate, Weak, Isolated) |
| Transportation Access | Picklist(Own Vehicle, Public Transport, Limited, None) |
| Education Level | Picklist(Primary, Secondary, Tertiary, Post-Graduate) |
| Language Barrier | Checkbox |
| Overall Risk Score | Formula(Number) | Calculated from above |
| Notes | Long Text |

### Step 2: Create Assessment OmniScript

**OmniScript: SDOHAssessment**
- Guided questionnaire covering all SDOH domains
- Simple language for care coordinator use during patient interview
- Auto-calculates risk score on completion
- Saves to SDOHAssessment__c

### Step 3: Add to Patient 360 FlexCard

**Child FlexCard: FC-SDOHSummary**
- Display: Most recent assessment date and key risk flags
- Colour-coded badges: Green (no risk), Amber (moderate), Red (high risk)
- "Assess SDOH" action button

### Step 4: Risk Score Integration

SDOH risk score feeds into overall patient risk calculation (US-3.4.2):
- Housing instable: +15 points
- Food insecure: +20 points
- Socially isolated: +15 points
- Financial strain severe: +10 points

### Step 5: Population Reporting

Report: "SDOH Distribution by Facility"
- Group by SDOH factor, count patients in each category
- Identify clusters of food insecurity or housing instability by region

## Testing Strategy

1. Complete SDOH assessment → data saved, risk score calculated
2. View Patient 360 → SDOH summary with risk flags displayed
3. Population report → shows correct distribution

## Deployment Checklist

- [ ] SDOHAssessment__c object deployed
- [ ] SDOHAssessment OmniScript deployed
- [ ] FC-SDOHSummary FlexCard added to Patient 360
- [ ] Risk score formula tested
- [ ] Population report created

## Dependencies

- **Blocked By:** US-1.1.1, US-1.1.2
- **Blocks:** US-2.4.2 (Population Health Dashboard), US-3.4.2 (AI Risk Stratification)
