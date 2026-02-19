/**
 * @description Test class for Care Plan Template data model (US-1.2.1).
 *              Validates standard objects, custom fields, and CRUD operations.
 */
@isTest
private class CarePlanTemplateDataModelTest {

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @isTest
    static void testCarePlanTemplateObjectsAccessible() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Assert.isTrue(
                CarePlanTemplate.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(),
                'CarePlanTemplate should be accessible'
            );
            Assert.isTrue(
                CarePlanTemplateGoal.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(),
                'CarePlanTemplateGoal should be accessible'
            );
            Assert.isTrue(
                CarePlanTemplateTask.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(),
                'CarePlanTemplateTask should be accessible'
            );
        }
    }

    @isTest
    static void testCustomFieldsExist() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Map<String, Schema.SObjectField> templateFields =
                Schema.SObjectType.CarePlanTemplate.fields.getMap();
            Assert.isTrue(templateFields.containsKey('version__c'), 'Version__c should exist on CarePlanTemplate');
            Assert.isTrue(templateFields.containsKey('previous_version__c'), 'Previous_Version__c should exist');
            Assert.isTrue(templateFields.containsKey('icd10_code__c'), 'ICD10_Code__c should exist');
            Assert.isTrue(templateFields.containsKey('moh_guideline_ref__c'), 'MOH_Guideline_Ref__c should exist');

            Map<String, Schema.SObjectField> goalFields =
                Schema.SObjectType.CarePlanTemplateGoal.fields.getMap();
            Assert.isTrue(goalFields.containsKey('target_value__c'), 'Target_Value__c should exist on Goal');
            Assert.isTrue(goalFields.containsKey('measure__c'), 'Measure__c should exist on Goal');
            Assert.isTrue(goalFields.containsKey('review_frequency__c'), 'Review_Frequency__c should exist on Goal');

            Map<String, Schema.SObjectField> taskFields =
                Schema.SObjectType.CarePlanTemplateTask.fields.getMap();
            Assert.isTrue(taskFields.containsKey('assigned_role__c'), 'Assigned_Role__c should exist on Task');
            Assert.isTrue(taskFields.containsKey('task_frequency__c'), 'Task_Frequency__c should exist on Task');
        }
    }

    @isTest
    static void testCreateTemplateWithGoalsAndTasks() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Test.startTest();
            CarePlanTemplate template = TestDataFactory.createCarePlanTemplate(
                'Diabetes Management Protocol', 'E11', 1
            );
            CarePlanTemplateGoal goal = TestDataFactory.createCarePlanTemplateGoal(
                template.Id, 'HbA1c Control', '< 7.0%', 'HbA1c blood test', 'Quarterly'
            );
            CarePlanTemplateTask task = TestDataFactory.createCarePlanTemplateTask(
                template.Id, 'HbA1c blood test order', 'Primary Physician', 'Quarterly', 'High'
            );
            Test.stopTest();

            Assert.isNotNull(template.Id, 'Template should be created');
            Assert.isNotNull(goal.Id, 'Goal should be created');
            Assert.isNotNull(task.Id, 'Task should be created');

            CarePlanTemplate queried = [
                SELECT Id, Name, ICD10_Code__c, Version__c
                FROM CarePlanTemplate WHERE Id = :template.Id
            ];
            Assert.areEqual('E11', queried.ICD10_Code__c, 'ICD-10 code should match');
            Assert.areEqual(1, queried.Version__c, 'Version should be 1');
        }
    }
}
