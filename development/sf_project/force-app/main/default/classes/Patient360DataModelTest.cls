/**
 * @description Test class for Patient 360 data model configuration (US-1.1.1).
 *              Validates custom fields, Health Cloud standard objects, and CRUD operations
 *              for patient demographics, conditions, medications, allergies, and insurance.
 */
@isTest
private class Patient360DataModelTest {

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    /**
     * @description Verify custom fields exist on Account (PersonAccount) for patient demographics.
     */
    @isTest
    static void testPatientDemographicFieldsExist() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Map<String, Schema.SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();

            Assert.isTrue(accountFields.containsKey('nric__c'), 'NRIC field should exist on Account');
            Assert.isTrue(accountFields.containsKey('ethnicity__c'), 'Ethnicity field should exist on Account');
            Assert.isTrue(accountFields.containsKey('emergency_contact_name__c'), 'Emergency Contact Name field should exist on Account');
            Assert.isTrue(accountFields.containsKey('emergency_contact_phone__c'), 'Emergency Contact Phone field should exist on Account');
            Assert.isTrue(accountFields.containsKey('emergency_contact_relationship__c'), 'Emergency Contact Relationship field should exist on Account');
        }
    }

    /**
     * @description Verify Medisave Balance custom field exists on MemberPlan.
     */
    @isTest
    static void testInsuranceFieldsExist() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Map<String, Schema.SObjectField> memberPlanFields = Schema.SObjectType.MemberPlan.fields.getMap();

            Assert.isTrue(memberPlanFields.containsKey('medisave_balance__c'), 'Medisave Balance field should exist on MemberPlan');
        }
    }

    /**
     * @description Verify Health Cloud standard objects are accessible.
     */
    @isTest
    static void testHealthCloudObjectsAccessible() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Assert.isTrue(HealthCondition.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(), 'HealthCondition should be accessible');
            Assert.isTrue(MedicationStatement.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(), 'MedicationStatement should be accessible');
            Assert.isTrue(AllergyIntolerance.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(), 'AllergyIntolerance should be accessible');
            Assert.isTrue(MemberPlan.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(), 'MemberPlan should be accessible');
            Assert.isTrue(CoverageBenefit.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(), 'CoverageBenefit should be accessible');
        }
    }

    /**
     * @description Create a Person Account patient record with custom demographic fields.
     */
    @isTest
    static void testCreatePatientWithDemographics() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Test.startTest();
            Account patient = TestDataFactory.createPatientWithDetails(
                'Mei Ling', 'Tan', 'S8515123A',
                new Account(
                    PersonBirthdate = Date.newInstance(1985, 3, 15),
                    PersonMobilePhone = '+6591234567',
                    Ethnicity__c = 'Chinese',
                    Emergency_Contact_Name__c = 'Wei Ming Tan',
                    Emergency_Contact_Phone__c = '+6591234567',
                    Emergency_Contact_Relationship__c = 'Spouse'
                )
            );
            Test.stopTest();

            Account result = [SELECT Id, FirstName, LastName, PersonBirthdate, NRIC__c, Ethnicity__c, Emergency_Contact_Name__c, Emergency_Contact_Phone__c, Emergency_Contact_Relationship__c FROM Account WHERE Id = :patient.Id];

            Assert.areEqual('S8515123A', result.NRIC__c, 'NRIC should be saved');
            Assert.areEqual('Chinese', result.Ethnicity__c, 'Ethnicity should be saved');
            Assert.areEqual('Wei Ming Tan', result.Emergency_Contact_Name__c, 'Emergency contact name should be saved');
            Assert.areEqual('+6591234567', result.Emergency_Contact_Phone__c, 'Emergency contact phone should be saved');
            Assert.areEqual('Spouse', result.Emergency_Contact_Relationship__c, 'Emergency contact relationship should be saved');
        }
    }

    /**
     * @description Verify NRIC uniqueness constraint.
     */
    @isTest
    static void testNRICUniqueness() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            TestDataFactory.createPatient('Patient', 'One', 'S9912345B');

            Test.startTest();
            try {
                TestDataFactory.createPatient('Patient', 'Two', 'S9912345B');
                Assert.fail('Should have thrown duplicate NRIC exception');
            } catch (DmlException e) {
                Assert.isTrue(e.getMessage().contains('DUPLICATE_VALUE') || e.getMessage().contains('duplicate'),
                    'Error should indicate duplicate value: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    /**
     * @description Create a HealthCondition record linked to a patient.
     */
    @isTest
    static void testCreateHealthCondition() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Account patient = TestDataFactory.createPatient('Test', 'Patient', 'S8801234C');

            Test.startTest();
            HealthCondition condition = TestDataFactory.createHealthCondition(
                patient.Id, 'Type 2 Diabetes Mellitus', 'Active', null,
                DateTime.newInstance(2024, 6, 1, 0, 0, 0)
            );
            Test.stopTest();

            HealthCondition result = [SELECT Id, PatientId, ProblemName, ConditionStatus, OnsetStartDateTime FROM HealthCondition WHERE Id = :condition.Id];

            Assert.areEqual(patient.Id, result.PatientId, 'Condition should be linked to patient');
            Assert.areEqual('Active', result.ConditionStatus, 'Status should be Active');
            Assert.areEqual('Type 2 Diabetes Mellitus', result.ProblemName, 'Problem name should match');
        }
    }

    /**
     * @description Create an AllergyIntolerance record linked to a patient.
     */
    @isTest
    static void testCreateAllergyIntolerance() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Account patient = TestDataFactory.createPatient('Test', 'Allergy', 'S8801235D');

            Test.startTest();
            AllergyIntolerance allergy = TestDataFactory.createAllergyIntolerance(
                patient.Id, 'Allergy', 'Severe', 'Active'
            );
            Test.stopTest();

            AllergyIntolerance result = [SELECT Id, PatientId, Name, Severity, Type, Status FROM AllergyIntolerance WHERE Id = :allergy.Id];

            Assert.areEqual(patient.Id, result.PatientId, 'Allergy should be linked to patient');
            Assert.areEqual('Severe', result.Severity, 'Severity should be Severe');
        }
    }

    /**
     * @description Create a MemberPlan with Medisave Balance for insurance tracking.
     */
    @isTest
    static void testCreateMemberPlanWithMedisave() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Account patient = TestDataFactory.createPatient('Test', 'Insurance', 'S8801236E');

            Test.startTest();
            MemberPlan plan = TestDataFactory.createMemberPlan(
                patient.Id, 'Medisave Plan', 'MS-2024-001', 'Active', 45000.00
            );
            Test.stopTest();

            MemberPlan result = [SELECT Id, MemberId, MemberNumber, Status, Medisave_Balance__c FROM MemberPlan WHERE Id = :plan.Id];

            Assert.areEqual(patient.Id, result.MemberId, 'Plan should be linked to patient');
            Assert.areEqual('MS-2024-001', result.MemberNumber, 'Member number should match');
            Assert.areEqual(45000.00, result.Medisave_Balance__c, 'Medisave balance should be saved');
        }
    }
}
