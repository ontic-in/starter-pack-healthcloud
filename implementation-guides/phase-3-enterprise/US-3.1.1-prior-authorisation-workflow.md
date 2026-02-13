# US-3.1.1: Prior Authorisation Workflow

> **Phase:** 3 - Enterprise | **Epic:** 3.1 - Utilisation Management | **Estimate:** L (2+ weeks)

## Overview

Implement a prior authorisation workflow with automated clinical criteria checking against InterQual/Milliman guidelines. Includes SLA tracking, approval/denial workflows, and appeals processing.

**Business Value:** Reduces prior auth turnaround from 5-7 days to 1-2 days, ensures consistent evidence-based decision making, and reduces administrative burden on UM staff by 40-50%.

## Prerequisites

- US-1.1.1 (Patient Profile) completed
- US-1.3.1 (Provider Directory) completed
- InterQual or Milliman clinical criteria licence obtained
- UM team roles and workflows documented

## Salesforce Configuration Steps

### Step 1: Create Utilisation Management Data Model

**Custom Object: PriorAuthRequest__c**

| Field | Type | Description |
|---|---|---|
| Patient | Lookup(Account) | |
| Requesting Provider | Lookup(Account) | |
| Procedure/Service | Lookup(OrderCatalogue__c) | |
| Diagnosis Code | Text (ICD-10) | |
| Clinical Justification | Long Text | |
| Urgency | Picklist(Routine, Urgent, Emergency) | |
| Status | Picklist | |
| Assigned Reviewer | Lookup(User) | |
| Decision | Picklist(Approved, Denied, Pended) | |
| Decision Date | DateTime | |
| Decision Rationale | Long Text | |
| SLA Due Date | DateTime | Auto-calculated |
| Supporting Documents | Related List (Files) | |

**Status Flow:** Submitted → Under Review → Approved / Denied / Pended → Closed

### Step 2: Auto-Check Clinical Criteria

**Integration: InterQual/Milliman API**
- On submission, auto-evaluate request against clinical criteria
- Return: Met / Not Met / Requires Review
- If Met → auto-approve (pending reviewer confirmation)
- If Not Met → route to physician reviewer
- If Requires Review → route to UM nurse

### Step 3: OmniScript for Request Submission

Steps: Select procedure → Enter diagnosis → Add clinical justification → Upload documents → Submit

### Step 4: SLA Tracking

| Urgency | SLA Target | Alert |
|---|---|---|
| Routine | 5 business days | Alert at 3 days |
| Urgent | 24 hours | Alert at 12 hours |
| Emergency | 4 hours | Alert at 2 hours |

**Dashboard:** Ageing requests, average turnaround, SLA compliance rate.

### Step 5: Appeals Workflow

If denied, requesting provider can submit appeal:
- Additional clinical documentation
- Peer-to-peer review request
- Appeal reviewed by senior physician
- Status: Appeal Submitted → Under Appeal Review → Appeal Approved / Upheld

## Testing Strategy

1. Submit routine request meeting criteria → auto-approval recommended
2. Submit request not meeting criteria → routed to reviewer
3. Deny request → provider submits appeal
4. SLA approaching deadline → alerts fire correctly
5. Dashboard shows accurate ageing and turnaround metrics

## Deployment Checklist

- [ ] PriorAuthRequest__c and related objects deployed
- [ ] InterQual/Milliman API integration configured
- [ ] Submission OmniScript deployed
- [ ] SLA tracking automation active
- [ ] Appeals workflow configured
- [ ] Dashboard deployed

## Dependencies

- **Blocked By:** US-1.1.1, US-1.3.1
- **Blocks:** US-3.1.2 (Concurrent Review extends UM model)
