# [US-1.2.1] Care Plan Templates

- **Ticket**: https://app.clickup.com/t/86d1yxwb6
- **Branch**: clickup-86d1yxwb6
- **Epic**: 1.2 Care Management | Phase: 1 MVP
- **Depends On**: None (first ticket in Epic 1.2)

## Acceptance Criteria

- [x] Clinical leads can create care plan templates with goals and tasks
- [x] Templates support ICD-10 codes and MOH guideline references
- [x] Template versioning: edit creates new version, original preserved for active care plans
- [x] Goals have target values, measures, and review frequencies
- [x] Tasks have assigned roles, frequencies, and priorities
- [x] Permission set controls access (no delete on templates, CRUD on goals/tasks)
- [x] Seed data provides 3 clinical templates (Diabetes, Hypertension, Cardiac Risk Reduction)

## Architecture

```
carePlanTemplateManager (Parent LWC - App Page)
  ├── Template list table with @wire(getTemplates)
  └── carePlanTemplateEditor (Child LWC - Modal)
        ├── Template detail form (view/edit/create modes)
        ├── Goals section with inline add
        └── Tasks section with inline add

Apex Layer:
  CarePlanTemplateController.cls (thin @AuraEnabled controller)
    └── CarePlanTemplateService.cls (business logic + SOQL)
          ├── getAllActiveTemplates() → TemplateListItem[]
          ├── getTemplateDetail(Id) → TemplateDetail
          └── versionTemplate(Id) → Id (deep-clone + increment)

Standard HC Objects:
  CarePlanTemplate ──┬── CarePlanTemplateGoal (children)
                     └── CarePlanTemplateTask (children)
```

## Data Model

### Custom Fields on Standard Objects (9 fields)

| Object | Field | Type | Details |
|---|---|---|---|
| CarePlanTemplate | Version__c | Number(2,0) | Default 1 |
| CarePlanTemplate | Previous_Version__c | Lookup(CarePlanTemplate) | Self-referential version chain |
| CarePlanTemplate | ICD10_Code__c | Text(10) | ICD-10 condition code |
| CarePlanTemplate | MOH_Guideline_Ref__c | Url | Link to MOH clinical guidelines |
| CarePlanTemplateGoal | Target_Value__c | Text(100) | Target value for the goal |
| CarePlanTemplateGoal | Measure__c | Text(100) | Measurement method |
| CarePlanTemplateGoal | Review_Frequency__c | Picklist (restricted) | Weekly/Fortnightly/Monthly/Quarterly/6-Monthly/Annually/Per Visit/Once |
| CarePlanTemplateTask | Assigned_Role__c | Picklist (restricted) | Primary Physician/Specialist/Care Coordinator/Nurse/Allied Health/Pharmacist/Admin Staff |
| CarePlanTemplateTask | Task_Frequency__c | Picklist (restricted) | Every Visit/Weekly/Fortnightly/Monthly/Quarterly/6-Monthly/Annually/Once |

## Components Created

| Component | Path | Purpose |
|---|---|---|
| Version__c | objects/CarePlanTemplate/fields/ | Template version number |
| Previous_Version__c | objects/CarePlanTemplate/fields/ | Version chain lookup |
| ICD10_Code__c | objects/CarePlanTemplate/fields/ | ICD-10 code |
| MOH_Guideline_Ref__c | objects/CarePlanTemplate/fields/ | Guideline URL |
| Target_Value__c | objects/CarePlanTemplateGoal/fields/ | Goal target value |
| Measure__c | objects/CarePlanTemplateGoal/fields/ | Goal measurement |
| Review_Frequency__c | objects/CarePlanTemplateGoal/fields/ | Goal review frequency |
| Assigned_Role__c | objects/CarePlanTemplateTask/fields/ | Task role assignment |
| Task_Frequency__c | objects/CarePlanTemplateTask/fields/ | Task frequency |
| Care_Plan_Template_Access | permissionsets/ | Permission set for template objects |
| CarePlanTemplateService.cls | classes/ | Service class - business logic + SOQL |
| CarePlanTemplateController.cls | classes/ | Thin LWC controller |
| CarePlanTemplateDataModelTest.cls | classes/ | Data model tests (3 methods) |
| CarePlanTemplateServiceTest.cls | classes/ | Service tests (6 methods) |
| CarePlanTemplateControllerTest.cls | classes/ | Controller tests (9 methods) |
| TestDataFactory.cls | classes/ | Updated with 3 new factory methods |
| carePlanTemplateManager | lwc/ | Parent LWC - template list (App Page) |
| carePlanTemplateEditor | lwc/ | Child LWC - template editor modal |
| seedCarePlanTemplates.apex | scripts/ | Seed data: 3 templates, 15 goals, 19 tasks |

## Implementation Plan

### Phase 0: Verify Standard Objects
1. Confirmed CarePlanTemplate, CarePlanTemplateGoal, CarePlanTemplateTask are standard HC objects

### Phase 1: Custom Field Metadata (9 fields)
1. Created field XML files on 3 standard objects

### Phase 2: Permission Set
1. Created Care_Plan_Template_Access with CRUD on templates (no delete), CRUD+Delete on goals/tasks
2. Field permissions for all 9 custom fields
3. Tab visibility for CarePlanTemplate

### Phase 3: Apex TDD RED - Test Classes
1. CarePlanTemplateDataModelTest (3 tests): object accessibility, field existence, create with children
2. CarePlanTemplateServiceTest (6 tests): getAllActive, getDetail, invalidId, versionTemplate behavior
3. CarePlanTemplateControllerTest (9 tests): getTemplates, getDetail, invalidId, save/version/goal/task CRUD

### Phase 4: Apex TDD GREEN - Implementation
1. CarePlanTemplateService with wrapper classes and business logic
2. CarePlanTemplateController as thin @AuraEnabled layer
3. TestDataFactory updated with 3 new factory methods

### Phase 5: LWC Components
1. carePlanTemplateManager - parent App Page with template list table
2. carePlanTemplateEditor - child modal with form, goals, and tasks sections

### Phase 6: Seed Data
1. Anonymous Apex script creating 3 clinical templates with goals and tasks
2. Bulkified: 3 DML statements total

### Phase 7: Documentation
1. Created implementation.md

## Progress Tracking

| Step | Status | Notes |
|---|---|---|
| Standard objects verified | Complete | HC standard objects confirmed |
| 9 custom fields created | Complete | 4 on Template, 3 on Goal, 2 on Task |
| Permission set created | Complete | Care_Plan_Template_Access |
| Test classes written | Complete | 18 test methods across 3 classes |
| Implementation classes written | Complete | Service + Controller + TestDataFactory |
| LWC components created | Complete | Manager (4 files) + Editor (4 files) |
| Seed data script created | Complete | 3 templates, 15 goals, 19 tasks |
| Documentation | Complete | |

## Key Decisions

1. **Service/Controller pattern**: Business logic in CarePlanTemplateService, thin @AuraEnabled methods in CarePlanTemplateController
2. **Template versioning**: Clone template + goals + tasks, increment version, deactivate original, link via Previous_Version__c
3. **WITH SECURITY_ENFORCED**: All SOQL queries enforce field-level security
4. **Separate permission set**: Care_Plan_Template_Access kept separate from Patient_360_Access (different object scope)
5. **No delete on templates**: Templates cannot be deleted (may have active care plans), only deactivated
6. **Restricted picklists**: All picklist fields use restricted=true for data integrity
7. **CarePlanTemplateTask uses Subject**: Standard field is `Subject` not `Name` (Task-like object)
8. **Bulkified seed data**: 3 DML statements total instead of per-record inserts

## Seed Data Summary

| Template | ICD-10 | Goals | Tasks |
|---|---|---|---|
| Diabetes Type 2 Management | E11 | 6 | 8 |
| Hypertension Management | I10 | 4 | 5 |
| Cardiac Risk Reduction | I25 | 5 | 6 |

## Deploy Notes

- Standard objects require Health Cloud license and Care Plan Templates enabled in Setup
- Relationship API names in subqueries (CarePlanTemplateGoals, CarePlanTemplateTasks) may need verification against org
- Run seed data: `sf apex run --file scripts/seedCarePlanTemplates.apex`
