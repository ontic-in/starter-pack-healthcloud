/**
 * @description Controller for Care Plan Template LWC components (US-1.2.1).
 *              Thin controller that delegates business logic to CarePlanTemplateService.
 */
public with sharing class CarePlanTemplateController {

    /**
     * @description Returns all active care plan templates with goal/task counts.
     * @return List of TemplateListItem wrappers.
     */
    @AuraEnabled(cacheable=true)
    public static List<CarePlanTemplateService.TemplateListItem> getTemplates() {
        try {
            return CarePlanTemplateService.getAllActiveTemplates();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Returns full template detail including goals and tasks.
     * @param templateId The CarePlanTemplate record ID.
     * @return TemplateDetail wrapper.
     */
    @AuraEnabled(cacheable=true)
    public static CarePlanTemplateService.TemplateDetail getTemplateDetail(Id templateId) {
        try {
            return CarePlanTemplateService.getTemplateDetail(templateId);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Creates or updates a care plan template. If isNewVersion is true,
     *              creates a new version via the versioning service.
     * @param templateJson JSON string of CarePlanTemplate fields.
     * @param isNewVersion Whether to create a new version (true) or save directly (false).
     * @return The saved or versioned CarePlanTemplate record.
     */
    @AuraEnabled
    public static CarePlanTemplate saveTemplate(String templateJson, Boolean isNewVersion) {
        try {
            CarePlanTemplate template = (CarePlanTemplate) JSON.deserialize(
                templateJson, CarePlanTemplate.class
            );
            if (isNewVersion && template.Id != null) {
                return CarePlanTemplateService.versionTemplate(template.Id);
            }
            if (template.Id != null) {
                SObjectAccessDecision decision = Security.stripInaccessible(
                    AccessType.UPDATABLE, new List<CarePlanTemplate>{ template }
                );
                update decision.getRecords();
                return (CarePlanTemplate) decision.getRecords()[0];
            } else {
                if (template.Version__c == null) {
                    template.Version__c = 1;
                }
                template.IsActive = true;
                SObjectAccessDecision decision = Security.stripInaccessible(
                    AccessType.CREATABLE, new List<CarePlanTemplate>{ template }
                );
                insert decision.getRecords();
                return (CarePlanTemplate) decision.getRecords()[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Saves a goal to a template (create or update).
     * @param goalJson JSON string of CarePlanTemplateGoal fields.
     * @return The saved CarePlanTemplateGoal record.
     */
    @AuraEnabled
    public static CarePlanTemplateGoal saveGoal(String goalJson) {
        try {
            CarePlanTemplateGoal goal = (CarePlanTemplateGoal) JSON.deserialize(
                goalJson, CarePlanTemplateGoal.class
            );
            if (goal.Id != null) {
                SObjectAccessDecision decision = Security.stripInaccessible(
                    AccessType.UPDATABLE, new List<CarePlanTemplateGoal>{ goal }
                );
                update decision.getRecords();
                return (CarePlanTemplateGoal) decision.getRecords()[0];
            } else {
                SObjectAccessDecision decision = Security.stripInaccessible(
                    AccessType.CREATABLE, new List<CarePlanTemplateGoal>{ goal }
                );
                insert decision.getRecords();
                return (CarePlanTemplateGoal) decision.getRecords()[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Saves a task to a template (create or update).
     * @param taskJson JSON string of CarePlanTemplateTask fields.
     * @return The saved CarePlanTemplateTask record.
     */
    @AuraEnabled
    public static CarePlanTemplateTask saveTask(String taskJson) {
        try {
            CarePlanTemplateTask task = (CarePlanTemplateTask) JSON.deserialize(
                taskJson, CarePlanTemplateTask.class
            );
            if (task.Id != null) {
                SObjectAccessDecision decision = Security.stripInaccessible(
                    AccessType.UPDATABLE, new List<CarePlanTemplateTask>{ task }
                );
                update decision.getRecords();
                return (CarePlanTemplateTask) decision.getRecords()[0];
            } else {
                SObjectAccessDecision decision = Security.stripInaccessible(
                    AccessType.CREATABLE, new List<CarePlanTemplateTask>{ task }
                );
                insert decision.getRecords();
                return (CarePlanTemplateTask) decision.getRecords()[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Deletes a goal from a template.
     * @param goalId The CarePlanTemplateGoal record ID.
     */
    @AuraEnabled
    public static void deleteGoal(Id goalId) {
        try {
            if (!Schema.sObjectType.CarePlanTemplateGoal.isDeletable()) {
                throw new AuraHandledException('Insufficient permissions to delete goal.');
            }
            delete [SELECT Id FROM CarePlanTemplateGoal WHERE Id = :goalId WITH SECURITY_ENFORCED LIMIT 1];
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Deletes a task from a template.
     * @param taskId The CarePlanTemplateTask record ID.
     */
    @AuraEnabled
    public static void deleteTask(Id taskId) {
        try {
            if (!Schema.sObjectType.CarePlanTemplateTask.isDeletable()) {
                throw new AuraHandledException('Insufficient permissions to delete task.');
            }
            delete [SELECT Id FROM CarePlanTemplateTask WHERE Id = :taskId WITH SECURITY_ENFORCED LIMIT 1];
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
