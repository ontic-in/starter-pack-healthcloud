# US-3.4.2: AI Risk Stratification

> **Phase:** 3 - Enterprise | **Epic:** 3.4 - Data Cloud & Analytics | **Estimate:** L (2+ weeks)

## Overview

Use AI to automatically risk-stratify all chronic disease patients with a 0-100 risk score. High-risk patients are surfaced in daily care coordinator worklists for proactive intervention.

**Business Value:** Enables proactive care management, reduces emergency admissions by 15-20% through early intervention, and optimises care coordinator workload by focusing on highest-risk patients.

## Prerequisites

- US-3.4.1 (Unified Patient Profile) completed
- US-2.4.1 (SDOH Tracking) completed
- US-1.2.4 (Goal Tracking) completed
- 12+ months of historical patient data

## Salesforce Configuration Steps

### Step 1: Define Risk Model Features

| Feature | Source | Category |
|---|---|---|
| Active condition count | HealthCondition | Clinical |
| Condition severity | HealthCondition | Clinical |
| Off-track goals count | CarePlanGoal | Clinical |
| HbA1c trend (3 months) | GoalMeasurement | Clinical |
| BP trend (3 months) | GoalMeasurement | Clinical |
| Appointment adherence % | Event history | Behavioural |
| Medication adherence % | MedicationAdherence__c | Behavioural |
| No-show count (12 months) | Event | Behavioural |
| SDOH risk score | SDOHAssessment__c | Social |
| Age | PersonBirthdate | Demographic |
| ED visits (12 months) | ClinicalEncounter | Utilisation |
| Hospital admissions (12 months) | InpatientAdmission__c | Utilisation |

### Step 2: Build AI Model

**Platform:** Data Cloud + Einstein AI

**Model Type:** Gradient Boosted Trees (classification/regression)
- Output: Risk score 0-100
- Categories: Low (0-40), Medium (40-70), High (70-100)
- Training data: 12+ months of patient outcomes
- Outcome variable: Hospitalisation or ED visit within 90 days

### Step 3: Daily Scoring Pipeline

**Scheduled Process:** Daily at 5:00 AM SGT
1. Extract features for all active chronic disease patients
2. Run through trained model
3. Store risk score on patient record (PatientRiskScore__c)
4. Store score history for trend tracking

### Step 4: Care Coordinator Worklist

**Custom List View: High Risk Patients**
- Filter: PatientRiskScore__c >= 70
- Columns: Patient Name, Risk Score, Top Risk Factors, Last Contact, Next Action
- Sort: Risk Score DESC
- Updated daily after scoring pipeline runs

**Dashboard Widget:** Risk distribution pie chart + high-risk patient count

### Step 5: Accuracy Monitoring

**Quarterly Model Review:**
- Compare predicted high-risk vs actual outcomes
- Metrics: Precision, Recall, F1 Score, AUC-ROC
- Retrain model if accuracy drops below threshold (AUC < 0.75)

## Testing Strategy

1. Patient with multiple comorbidities + poor adherence → scores High
2. Healthy patient with good adherence → scores Low
3. Care coordinator worklist shows high-risk patients sorted by score
4. Score recalculates daily after new data
5. Historical accuracy tracking shows model performance

## Deployment Checklist

- [ ] AI model trained and validated (AUC > 0.75)
- [ ] Daily scoring pipeline deployed
- [ ] PatientRiskScore__c field on Account
- [ ] Care coordinator worklist configured
- [ ] Risk distribution dashboard deployed
- [ ] Quarterly review process documented

## Dependencies

- **Blocked By:** US-3.4.1, US-2.4.1, US-1.2.4
- **Blocks:** US-3.4.3 (Readmission model uses similar infrastructure)
