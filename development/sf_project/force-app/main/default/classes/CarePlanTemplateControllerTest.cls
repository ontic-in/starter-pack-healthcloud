/**
 * @description Test class for CarePlanTemplateController (US-1.2.1).
 *              Tests all LWC-facing controller methods.
 */
@isTest
private class CarePlanTemplateControllerTest {

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @TestSetup
    static void setupTestData() {
        CarePlanTemplate template = TestDataFactory.createCarePlanTemplate(
            'Diabetes Management Protocol', 'E11', 1
        );
        TestDataFactory.createCarePlanTemplateGoal(
            template.Id, 'HbA1c Control', '< 7.0%', 'HbA1c blood test', 'Quarterly'
        );
        TestDataFactory.createCarePlanTemplateTask(
            template.Id, 'HbA1c blood test order', 'Primary Physician', 'Quarterly', 'High'
        );
    }

    @isTest
    static void testGetTemplates() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Test.startTest();
            List<CarePlanTemplateService.TemplateListItem> templates =
                CarePlanTemplateController.getTemplates();
            Test.stopTest();

            Assert.isTrue(templates.size() >= 1, 'Should return at least 1 template');
        }
    }

    @isTest
    static void testGetTemplateDetail() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            CarePlanTemplate template = [
                SELECT Id FROM CarePlanTemplate WHERE ICD10_Code__c = 'E11' LIMIT 1
            ];

            Test.startTest();
            CarePlanTemplateService.TemplateDetail detail =
                CarePlanTemplateController.getTemplateDetail(template.Id);
            Test.stopTest();

            Assert.isNotNull(detail.template, 'Template should not be null');
            Assert.areEqual(1, detail.goals.size(), 'Should have 1 goal');
            Assert.areEqual(1, detail.tasks.size(), 'Should have 1 task');
        }
    }

    @isTest
    static void testGetTemplateDetail_InvalidId() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Id fakeId = CarePlanTemplate.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                .getKeyPrefix() + '000000000000';

            Test.startTest();
            try {
                CarePlanTemplateController.getTemplateDetail(fakeId);
                Assert.fail('Should have thrown AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().length() > 0, 'Should have error message');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testSaveTemplate_Create() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            String templateJson = JSON.serialize(new Map<String, Object>{
                'Name' => 'Test Template',
                'ICD10_Code__c' => 'Z99',
                'Version__c' => 1
            });

            Test.startTest();
            CarePlanTemplate result = CarePlanTemplateController.saveTemplate(templateJson, false);
            Test.stopTest();

            Assert.isNotNull(result.Id, 'Template should be created');
            CarePlanTemplate queried = [
                SELECT Name, ICD10_Code__c FROM CarePlanTemplate WHERE Id = :result.Id
            ];
            Assert.areEqual('Test Template', queried.Name, 'Name should match');
        }
    }

    @isTest
    static void testSaveTemplate_NewVersion() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            CarePlanTemplate original = [
                SELECT Id FROM CarePlanTemplate WHERE ICD10_Code__c = 'E11' LIMIT 1
            ];
            String templateJson = JSON.serialize(new Map<String, Object>{
                'Id' => original.Id
            });

            Test.startTest();
            CarePlanTemplate newVersion =
                CarePlanTemplateController.saveTemplate(templateJson, true);
            Test.stopTest();

            Assert.isNotNull(newVersion.Id, 'New version should be created');
            Assert.areEqual(2, newVersion.Version__c, 'Should be version 2');
        }
    }

    @isTest
    static void testSaveGoal() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            CarePlanTemplate template = [
                SELECT Id FROM CarePlanTemplate WHERE ICD10_Code__c = 'E11' LIMIT 1
            ];
            String goalJson = JSON.serialize(new Map<String, Object>{
                'CarePlanTemplateId' => template.Id,
                'Name' => 'New Test Goal',
                'Target_Value__c' => '< 5.0',
                'Measure__c' => 'Blood test',
                'Review_Frequency__c' => 'Monthly'
            });

            Test.startTest();
            CarePlanTemplateGoal result = CarePlanTemplateController.saveGoal(goalJson);
            Test.stopTest();

            Assert.isNotNull(result.Id, 'Goal should be created');
        }
    }

    @isTest
    static void testSaveTask() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            CarePlanTemplate template = [
                SELECT Id FROM CarePlanTemplate WHERE ICD10_Code__c = 'E11' LIMIT 1
            ];
            String taskJson = JSON.serialize(new Map<String, Object>{
                'CarePlanTemplateId' => template.Id,
                'Subject' => 'New Test Task',
                'Assigned_Role__c' => 'Nurse',
                'Task_Frequency__c' => 'Weekly',
                'Priority' => 'Medium'
            });

            Test.startTest();
            CarePlanTemplateTask result = CarePlanTemplateController.saveTask(taskJson);
            Test.stopTest();

            Assert.isNotNull(result.Id, 'Task should be created');
        }
    }

    @isTest
    static void testDeleteGoal() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            CarePlanTemplateGoal goal = [
                SELECT Id FROM CarePlanTemplateGoal LIMIT 1
            ];

            Test.startTest();
            CarePlanTemplateController.deleteGoal(goal.Id);
            Test.stopTest();

            List<CarePlanTemplateGoal> remaining = [
                SELECT Id FROM CarePlanTemplateGoal WHERE Id = :goal.Id
            ];
            Assert.areEqual(0, remaining.size(), 'Goal should be deleted');
        }
    }

    @isTest
    static void testDeleteTask() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            CarePlanTemplateTask task = [
                SELECT Id FROM CarePlanTemplateTask LIMIT 1
            ];

            Test.startTest();
            CarePlanTemplateController.deleteTask(task.Id);
            Test.stopTest();

            List<CarePlanTemplateTask> remaining = [
                SELECT Id FROM CarePlanTemplateTask WHERE Id = :task.Id
            ];
            Assert.areEqual(0, remaining.size(), 'Task should be deleted');
        }
    }
}
