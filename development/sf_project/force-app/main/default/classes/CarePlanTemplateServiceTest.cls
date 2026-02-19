/**
 * @description Test class for CarePlanTemplateService (US-1.2.1).
 *              Tests template listing, detail retrieval, and versioning logic.
 */
@isTest
private class CarePlanTemplateServiceTest {

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
        TestDataFactory.createCarePlanTemplateGoal(
            template.Id, 'Blood Pressure', '< 140/90 mmHg', 'BP reading', 'Per Visit'
        );
        TestDataFactory.createCarePlanTemplateTask(
            template.Id, 'HbA1c blood test order', 'Primary Physician', 'Quarterly', 'High'
        );
        TestDataFactory.createCarePlanTemplateTask(
            template.Id, 'Medication review', 'Primary Physician', 'Quarterly', 'High'
        );

        TestDataFactory.createCarePlanTemplate(
            'Hypertension Control Protocol', 'I10', 1
        );
    }

    @isTest
    static void testGetAllActiveTemplates() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Test.startTest();
            List<CarePlanTemplateService.TemplateListItem> items =
                CarePlanTemplateService.getAllActiveTemplates();
            Test.stopTest();

            Assert.isTrue(items.size() >= 2, 'Should return at least 2 active templates');

            CarePlanTemplateService.TemplateListItem diabetes = null;
            for (CarePlanTemplateService.TemplateListItem item : items) {
                if (item.name == 'Diabetes Management Protocol') {
                    diabetes = item;
                    break;
                }
            }
            Assert.isNotNull(diabetes, 'Diabetes template should be in results');
            Assert.areEqual('E11', diabetes.icd10Code, 'ICD-10 code should match');
            Assert.areEqual(2, diabetes.goalCount, 'Should have 2 goals');
            Assert.areEqual(2, diabetes.taskCount, 'Should have 2 tasks');
        }
    }

    @isTest
    static void testGetTemplateDetail() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            CarePlanTemplate template = [
                SELECT Id FROM CarePlanTemplate
                WHERE ICD10_Code__c = 'E11' LIMIT 1
            ];

            Test.startTest();
            CarePlanTemplateService.TemplateDetail detail =
                CarePlanTemplateService.getTemplateDetail(template.Id);
            Test.stopTest();

            Assert.isNotNull(detail.template, 'Template should not be null');
            Assert.areEqual('E11', detail.template.ICD10_Code__c, 'ICD-10 should match');
            Assert.areEqual(2, detail.goals.size(), 'Should have 2 goals');
            Assert.areEqual(2, detail.tasks.size(), 'Should have 2 tasks');
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
                CarePlanTemplateService.getTemplateDetail(fakeId);
                Assert.fail('Should have thrown AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().length() > 0, 'Should have error message');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testVersionTemplate_ClonesAndIncrements() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            CarePlanTemplate original = [
                SELECT Id, Version__c FROM CarePlanTemplate
                WHERE ICD10_Code__c = 'E11' LIMIT 1
            ];

            Test.startTest();
            CarePlanTemplate newVersion =
                CarePlanTemplateService.versionTemplate(original.Id);
            Test.stopTest();

            Assert.isNotNull(newVersion.Id, 'New version should be created');
            Assert.areEqual(2, newVersion.Version__c, 'Version should be incremented to 2');
            Assert.areEqual(original.Id, newVersion.Previous_Version__c,
                'Should link to original via Previous_Version__c');
            Assert.isTrue(newVersion.IsActive, 'New version should be active');
        }
    }

    @isTest
    static void testVersionTemplate_OriginalDeactivated() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            CarePlanTemplate original = [
                SELECT Id FROM CarePlanTemplate
                WHERE ICD10_Code__c = 'E11' LIMIT 1
            ];

            Test.startTest();
            CarePlanTemplateService.versionTemplate(original.Id);
            Test.stopTest();

            CarePlanTemplate deactivated = [
                SELECT Id, IsActive FROM CarePlanTemplate
                WHERE Id = :original.Id
            ];
            Assert.isFalse(deactivated.IsActive, 'Original should be deactivated after versioning');
        }
    }

    @isTest
    static void testVersionTemplate_GoalsAndTasksCloned() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            CarePlanTemplate original = [
                SELECT Id FROM CarePlanTemplate
                WHERE ICD10_Code__c = 'E11' LIMIT 1
            ];

            Test.startTest();
            CarePlanTemplate newVersion =
                CarePlanTemplateService.versionTemplate(original.Id);
            Test.stopTest();

            List<CarePlanTemplateGoal> newGoals = [
                SELECT Id, Name FROM CarePlanTemplateGoal
                WHERE CarePlanTemplateId = :newVersion.Id
            ];
            List<CarePlanTemplateTask> newTasks = [
                SELECT Id FROM CarePlanTemplateTask
                WHERE CarePlanTemplateId = :newVersion.Id
            ];
            Assert.areEqual(2, newGoals.size(), 'Goals should be cloned to new version');
            Assert.areEqual(2, newTasks.size(), 'Tasks should be cloned to new version');

            List<CarePlanTemplateGoal> originalGoals = [
                SELECT Id FROM CarePlanTemplateGoal
                WHERE CarePlanTemplateId = :original.Id
            ];
            Assert.areEqual(2, originalGoals.size(), 'Original goals should still exist');
        }
    }
}
