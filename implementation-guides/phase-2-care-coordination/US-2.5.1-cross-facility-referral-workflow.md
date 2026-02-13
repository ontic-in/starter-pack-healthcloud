# US-2.5.1: Cross-Facility Referral Workflow

> **Phase:** 2 - Care Coordination | **Epic:** 2.5 - Cross-Facility Coordination | **Estimate:** M (1-2 weeks)

## Overview

Extend the internal referral workflow (US-1.3.2) to support cross-facility referrals (hospital to polyclinic and vice versa) with full clinical context transfer and bi-directional status tracking.

**Business Value:** Enables seamless transitions of care across the healthcare network, eliminates information loss during handoffs, and reduces referral processing time from days to hours.

## Prerequisites

- US-1.3.2 (Internal Referral Workflow) completed
- US-1.6.2 (Role-Based Access Controls) completed
- Multi-facility organisation structure configured
- Cross-facility data sharing agreement in place

## Salesforce Configuration Steps

### Step 1: Extend Referral OmniScript

**Modify CreateReferral OmniScript:**
- Add facility selection step (for cross-facility)
- Auto-detect: if receiving provider is at different facility → trigger cross-facility flow
- Auto-attach extended clinical summary (includes care plan, goals, recent results)

### Step 2: Configure Cross-Facility Data Sharing

**Sharing Rules:**
- When referral is created cross-facility:
  - Grant receiving provider Read access to patient record
  - Grant receiving facility Read access to clinical summary
  - Access expires 90 days after referral completion (or configurable)

### Step 3: Clinical Summary Auto-Attachment

Extend GenerateClinicalSummary Integration Procedure to include:
- Active care plans with goal status
- Recent lab results (last 6 months)
- Medication reconciliation list
- SDOH summary (if assessed)
- Care team members and roles

### Step 4: Bi-Directional Status Updates

| Status | Updated By | Visible To |
|---|---|---|
| Submitted | Referring facility | Both |
| Accepted | Receiving facility | Both |
| Scheduled | Receiving facility | Both |
| In Progress | Receiving facility | Both |
| Completed | Receiving facility | Both |
| Outcome Notes | Receiving provider | Referring provider |

**Real-Time Updates:** Platform Events publish status changes, both facilities subscribe.

### Step 5: Timeline Integration

- Referral events appear on patient timeline at BOTH facilities
- Badge indicates cross-facility referral (different from internal)

## Testing Strategy

1. Refer from Hospital A to Polyclinic B → referral appears at both
2. Polyclinic B accepts → Hospital A sees status update in real-time
3. Clinical summary includes care plan goals and recent results
4. After completion, receiving provider adds outcome notes → visible to referring provider
5. Access expires 90 days after referral completion

## Deployment Checklist

- [ ] Extended OmniScript deployed
- [ ] Cross-facility sharing rules configured
- [ ] Enhanced clinical summary Integration Procedure deployed
- [ ] Platform Events for status updates configured
- [ ] Timeline events visible cross-facility
- [ ] Access expiry automation active

## Dependencies

- **Blocked By:** US-1.3.2, US-1.6.2
- **Blocks:** US-2.5.2 (Shared Care Plan Visibility)
