/**
 * @description Service class for Care Plan Template business logic (US-1.2.1).
 *              Handles template listing, detail retrieval, and versioning.
 */
public with sharing class CarePlanTemplateService {

    /**
     * @description Wrapper for template list display with goal/task counts.
     */
    public class TemplateListItem {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String icd10Code;
        @AuraEnabled public Decimal version;
        @AuraEnabled public Boolean isActive;
        @AuraEnabled public Integer goalCount;
        @AuraEnabled public Integer taskCount;
        @AuraEnabled public DateTime lastModifiedDate;
    }

    /**
     * @description Full template detail wrapper including goals and tasks.
     */
    public class TemplateDetail {
        @AuraEnabled public CarePlanTemplate template;
        @AuraEnabled public List<CarePlanTemplateGoal> goals;
        @AuraEnabled public List<CarePlanTemplateTask> tasks;
    }

    /**
     * @description Returns all active templates with goal and task counts.
     * @return List of TemplateListItem wrappers.
     */
    public static List<TemplateListItem> getAllActiveTemplates() {
        List<CarePlanTemplate> templates = [
            SELECT Id, Name, Description, ICD10_Code__c, Version__c, IsActive,
                   LastModifiedDate,
                   (SELECT Id FROM CarePlanTemplateGoals),
                   (SELECT Id FROM CarePlanTemplateTasks)
            FROM CarePlanTemplate
            WHERE IsActive = true
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC
            LIMIT 200
        ];

        List<TemplateListItem> items = new List<TemplateListItem>();
        for (CarePlanTemplate t : templates) {
            TemplateListItem item = new TemplateListItem();
            item.id = t.Id;
            item.name = t.Name;
            item.description = t.Description;
            item.icd10Code = t.ICD10_Code__c;
            item.version = t.Version__c;
            item.isActive = t.IsActive;
            item.goalCount = t.CarePlanTemplateGoals.size();
            item.taskCount = t.CarePlanTemplateTasks.size();
            item.lastModifiedDate = t.LastModifiedDate;
            items.add(item);
        }
        return items;
    }

    /**
     * @description Returns full template detail including goals and tasks.
     * @param templateId The CarePlanTemplate record ID.
     * @return TemplateDetail wrapper with template, goals, and tasks.
     * @throws AuraHandledException if template not found.
     */
    public static TemplateDetail getTemplateDetail(Id templateId) {
        List<CarePlanTemplate> templates = [
            SELECT Id, Name, Description, ICD10_Code__c, MOH_Guideline_Ref__c,
                   Version__c, Previous_Version__c, IsActive
            FROM CarePlanTemplate
            WHERE Id = :templateId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (templates.isEmpty()) {
            throw new AuraHandledException('Template not found.');
        }

        TemplateDetail detail = new TemplateDetail();
        detail.template = templates[0];

        detail.goals = [
            SELECT Id, Name, Target_Value__c, Measure__c, Review_Frequency__c
            FROM CarePlanTemplateGoal
            WHERE CarePlanTemplateId = :templateId
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC
            LIMIT 50
        ];

        detail.tasks = [
            SELECT Id, Subject, Assigned_Role__c, Task_Frequency__c, Priority
            FROM CarePlanTemplateTask
            WHERE CarePlanTemplateId = :templateId
            WITH SECURITY_ENFORCED
            ORDER BY Subject ASC
            LIMIT 100
        ];

        return detail;
    }

    /**
     * @description Creates a new version of a template by deep-cloning.
     *              Original is deactivated; new version gets incremented version number.
     *              All goals and tasks are cloned to the new version.
     * @param originalTemplateId The ID of the template to version.
     * @return The new versioned CarePlanTemplate record.
     */
    public static CarePlanTemplate versionTemplate(Id originalTemplateId) {
        TemplateDetail original = getTemplateDetail(originalTemplateId);

        CarePlanTemplate newTemplate = original.template.clone(false, true, false, false);
        newTemplate.Version__c = (original.template.Version__c != null
            ? original.template.Version__c : 1) + 1;
        newTemplate.Previous_Version__c = originalTemplateId;
        newTemplate.IsActive = true;
        SObjectAccessDecision templateDecision = Security.stripInaccessible(
            AccessType.CREATABLE, new List<CarePlanTemplate>{ newTemplate }
        );
        insert templateDecision.getRecords();
        newTemplate = (CarePlanTemplate) templateDecision.getRecords()[0];

        original.template.IsActive = false;
        SObjectAccessDecision updateDecision = Security.stripInaccessible(
            AccessType.UPDATABLE, new List<CarePlanTemplate>{ original.template }
        );
        update updateDecision.getRecords();

        if (!original.goals.isEmpty()) {
            List<CarePlanTemplateGoal> newGoals = new List<CarePlanTemplateGoal>();
            for (CarePlanTemplateGoal g : original.goals) {
                CarePlanTemplateGoal cloned = g.clone(false, true, false, false);
                cloned.CarePlanTemplateId = newTemplate.Id;
                newGoals.add(cloned);
            }
            SObjectAccessDecision goalsDecision = Security.stripInaccessible(
                AccessType.CREATABLE, newGoals
            );
            insert goalsDecision.getRecords();
        }

        if (!original.tasks.isEmpty()) {
            List<CarePlanTemplateTask> newTasks = new List<CarePlanTemplateTask>();
            for (CarePlanTemplateTask t : original.tasks) {
                CarePlanTemplateTask cloned = t.clone(false, true, false, false);
                cloned.CarePlanTemplateId = newTemplate.Id;
                newTasks.add(cloned);
            }
            SObjectAccessDecision tasksDecision = Security.stripInaccessible(
                AccessType.CREATABLE, newTasks
            );
            insert tasksDecision.getRecords();
        }

        return newTemplate;
    }
}
