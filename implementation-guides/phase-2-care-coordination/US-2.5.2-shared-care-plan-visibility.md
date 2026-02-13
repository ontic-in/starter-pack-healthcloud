# US-2.5.2: Shared Care Plan Visibility

> **Phase:** 2 - Care Coordination | **Epic:** 2.5 - Cross-Facility Coordination | **Estimate:** S (1-3 days)

## Overview

Enable GPs at polyclinics to view specialist care plans created at the hospital for referred patients, and contribute tasks and notes to the shared care plan. Access is controlled by care team membership, not facility.

**Business Value:** Ensures coordinated follow-up care between specialists and GPs, eliminates information silos between facilities, and reduces duplicate or conflicting treatments.

## Prerequisites

- US-1.2.2 (Care Plan Creation) completed
- US-1.2.3 (Care Team Assignment) completed
- US-2.5.1 (Cross-Facility Referral) completed

## Salesforce Configuration Steps

### Step 1: Configure Care Plan Sharing

**Sharing Model Change:**
- Care Plan OWD: Private
- Grant access based on CareTeamMember, NOT facility

**Sharing Rule: CareTeamCarePlanAccess**
- When a provider is added to CareTeam:
  - Grant Read/Write access to all active CarePlans for that patient
  - This works regardless of the provider's facility

### Step 2: Cross-Facility Team Membership

When a cross-facility referral is accepted:
- Automatically add receiving provider to patient's CareTeam
- Role: Specialist (or as specified in referral)
- Access: Active for duration of referral + 90 days

### Step 3: GP Contribution Capabilities

GP at polyclinic can:
- View specialist care plan (goals, tasks, progress)
- Add tasks to the care plan (assigned to self or team)
- Add notes/comments to existing goals
- Cannot modify specialist's goals or tasks (Read-Only)

### Step 4: Real-Time Collaboration

- Platform Events: Care plan changes publish events
- All care team members (regardless of facility) receive in-app notifications
- Changes visible within seconds across facilities

### Step 5: Access Control

| Action | Specialist (Hospital) | GP (Polyclinic) | Coordinator |
|---|---|---|---|
| View Care Plan | Full | Full (if on team) | Full |
| Edit Own Goals/Tasks | Yes | No | Yes |
| Add New Tasks | Yes | Yes | Yes |
| Add Notes | Yes | Yes | Yes |
| Close Care Plan | Yes | No | Yes |

## Testing Strategy

1. Specialist creates care plan → GP (on care team) can view it
2. GP adds follow-up task → visible to specialist in real-time
3. GP NOT on care team → cannot see the care plan
4. GP adds notes to specialist's goal → note visible, goal unchanged
5. Provider removed from team → loses care plan access

## Deployment Checklist

- [ ] Care Plan sharing rules reconfigured for team-based access
- [ ] Auto-add receiving provider to CareTeam on referral acceptance
- [ ] GP contribution permissions configured
- [ ] Platform Events for real-time updates active
- [ ] Access expiry automation (90 days post-referral)

## Dependencies

- **Blocked By:** US-1.2.2, US-1.2.3, US-2.5.1
- **Blocks:** None (completes cross-facility coordination)
