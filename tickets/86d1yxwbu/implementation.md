# US-1.2.3: Care Team Assignment - Implementation

## Summary

Multi-disciplinary care team assignment using Health Cloud standard objects (`CareTeam`, `CareTeamMember`) with custom fields, three-tier Apex architecture, and an LWC panel for the Patient 360 record page.

## Architecture

```
careTeamPanel (LWC)
  └─ CareTeamController (thin @AuraEnabled controller)
       └─ CareTeamService (business logic, SOQL, DML)
            └─ CareTeam / CareTeamMember (standard HC objects)
```

## Files Created

### Custom Field Metadata
- [x] `objects/CareTeamMember/fields/Is_Primary__c.field-meta.xml` - Checkbox to mark primary physician
- [x] `objects/CareTeamMember/fields/Notification_Pref__c.field-meta.xml` - Picklist (All, Critical Only, None)

### Apex Classes
- [x] `classes/CareTeamService.cls` - Service layer with all business logic
  - `getCareTeamForPatient()` - Returns team + active members
  - `addTeamMember()` - Creates member with get-or-create team pattern
  - `updateTeamMember()` - Updates role, status, primary, notification
  - `removeTeamMember()` - Soft-delete (sets Inactive + end date)
  - `searchProviders()` - Name search with active patient counts
  - `validatePrimaryPhysicianRule()` - One primary per team
  - `sendAssignmentNotification()` - Best-effort custom notifications
- [x] `classes/CareTeamController.cls` - Thin controller, delegates to service
- [x] `classes/CareTeamServiceTest.cls` - 12 test methods
- [x] `classes/CareTeamControllerTest.cls` - 6 test methods

### LWC Component
- [x] `lwc/careTeamPanel/careTeamPanel.js` - Wire for data, imperative for mutations, modal state
- [x] `lwc/careTeamPanel/careTeamPanel.html` - Member cards, add/edit/remove modals, provider search
- [x] `lwc/careTeamPanel/careTeamPanel.css` - BEM styling with CSS custom properties
- [x] `lwc/careTeamPanel/careTeamPanel.js-meta.xml` - Exposed on Account record page

### Permission Set
- [x] `permissionsets/Care_Team_Access.permissionset-meta.xml` - CareTeam + CareTeamMember CRUD

### TestDataFactory Additions
- [x] `createProvider()` - Business account for providers
- [x] `createCareTeam()` - CareTeam linked to patient
- [x] `createCareTeamMember()` - CareTeamMember with role and primary flag

## Key Design Decisions

1. **One-primary rule in Apex** - Enforced via `validatePrimaryPhysicianRule()` rather than Validation Rule for better error messages and testability
2. **Get-or-create CareTeam** - Auto-creates team when adding first member (simplifies UX)
3. **Soft-delete pattern** - Sets `Status=Inactive` + `PeriodEndDate=today()` instead of hard delete
4. **Security** - `WITH SECURITY_ENFORCED` on all SOQL, `Security.stripInaccessible()` on all DML
5. **Best-effort notifications** - Custom Notification Type `Care_Team_Assignment`, silently fails if not configured

## Care Team Roles

| Role | API Value |
|---|---|
| Primary Physician | `Primary_Physician` |
| Specialist | `Specialist` |
| Care Coordinator | `Care_Coordinator` |
| Nurse | `Nurse` |
| Allied Health | `Allied_Health` |
| Pharmacist | `Pharmacist` |

## Testing

- **CareTeamServiceTest**: 12 methods covering all service operations + edge cases
- **CareTeamControllerTest**: 6 methods covering controller delegation + error handling
- Total: 18 test methods

## Deployment Steps

1. Deploy custom field metadata (`Is_Primary__c`, `Notification_Pref__c`)
2. Deploy Apex classes (Service, Controller, Tests, TestDataFactory)
3. Deploy LWC component (`careTeamPanel`)
4. Deploy permission set (`Care_Team_Access`)
5. Add `careTeamPanel` to Account record page via Lightning App Builder
6. Assign `Care_Team_Access` permission set to relevant users
7. (Optional) Create `Care_Team_Assignment` Custom Notification Type for assignment alerts
