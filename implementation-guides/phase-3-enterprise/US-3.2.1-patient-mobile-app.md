# US-3.2.1: Patient Mobile App Integration

> **Phase:** 3 - Enterprise | **Epic:** 3.2 - Multi-Channel Engagement | **Estimate:** L (2+ weeks)

## Overview

Enable patients to access health information, appointments, care plans, and secure messaging through a mobile app with biometric login and push notifications.

**Business Value:** Empowers patients to manage their health on the go, increases engagement by 40-60%, and reduces call centre volume by 30% through self-service capabilities.

## Prerequisites

- US-2.3.3 (Patient Portal) completed
- US-1.6.1 (Consent) completed
- iOS/Android development capability or Salesforce Mobile SDK

## Salesforce Configuration Steps

### Step 1: Mobile App Architecture

**Option A: Salesforce Mobile SDK**
- Native iOS + Android using Salesforce Mobile SDK
- Connects to Health Cloud REST APIs
- Offline capability for reading cached data

**Option B: Experience Cloud Mobile-Optimized**
- Progressive Web App (PWA) from Experience Cloud
- No app store deployment needed
- Limited push notification support

**Recommended:** Option A for full native experience

### Step 2: Core Features

| Feature | Data Source | API |
|---|---|---|
| Appointments | Event | REST API |
| Care Plan View | CarePlan, CarePlanGoal | REST API |
| Medication List | MedicationStatement | REST API |
| Home Readings | GoalMeasurement__c | REST API (create) |
| Secure Messaging | Task / LiveMessage | Messaging API |
| Push Notifications | Custom Notification | Push API |

### Step 3: Biometric Authentication

- Implement fingerprint/face recognition using device APIs
- Initial login: Username + Password + MFA
- Subsequent: Biometric only (token refresh in background)
- Session timeout: 24 hours for biometric, 30 min for password

### Step 4: Push Notification Setup

| Notification Type | Trigger |
|---|---|
| Appointment Reminder | 2 days before + same day |
| Medication Reminder | Daily at configured time |
| Lab Results Available | New DiagnosticReport synced |
| Care Plan Update | CarePlan status change |
| Message from Care Team | New secure message |

Configure Salesforce Custom Notifications + Push via Firebase (Android) and APNs (iOS).

### Step 5: PDPA Consent Management

- In-app consent management screen
- Patient can update consent preferences
- Changes sync to Health Cloud consent records
- Clear explanation of each consent category

## Testing Strategy

1. Patient logs in with biometric → sees dashboard with appointments
2. View care plan → goals and progress displayed correctly
3. Submit home BP reading → data appears in Health Cloud
4. Receive push notification for appointment → taps to view details
5. Send secure message → care team receives in Salesforce

## Deployment Checklist

- [ ] Mobile app built and tested (iOS + Android)
- [ ] Health Cloud REST APIs configured
- [ ] Biometric authentication implemented
- [ ] Push notification infrastructure deployed
- [ ] App store submission (TestFlight + Play Store Beta)
- [ ] PDPA consent management in app
- [ ] User acceptance testing with patient panel

## Dependencies

- **Blocked By:** US-2.3.3 (Portal), US-1.6.1 (Consent)
- **Blocks:** US-3.2.2 (Chatbot accessible via app)
