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

            System.assert(accountFields.containsKey('nric__c'), 'NRIC field should exist on Account');
            System.assert(accountFields.containsKey('ethnicity__c'), 'Ethnicity field should exist on Account');
            System.assert(accountFields.containsKey('emergency_contact_name__c'), 'Emergency Contact Name field should exist on Account');
            System.assert(accountFields.containsKey('emergency_contact_phone__c'), 'Emergency Contact Phone field should exist on Account');
            System.assert(accountFields.containsKey('emergency_contact_relationship__c'), 'Emergency Contact Relationship field should exist on Account');
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

            System.assert(memberPlanFields.containsKey('medisave_balance__c'), 'Medisave Balance field should exist on MemberPlan');
        }
    }

    /**
     * @description Verify Health Cloud standard objects are accessible.
     */
    @isTest
    static void testHealthCloudObjectsAccessible() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            System.assert(HealthCondition.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(), 'HealthCondition should be accessible');
            System.assert(MedicationStatement.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(), 'MedicationStatement should be accessible');
            System.assert(AllergyIntolerance.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(), 'AllergyIntolerance should be accessible');
            System.assert(MemberPlan.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(), 'MemberPlan should be accessible');
            System.assert(CoverageBenefit.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible(), 'CoverageBenefit should be accessible');
        }
    }

    /**
     * @description Create a Person Account patient record with custom demographic fields.
     */
    @isTest
    static void testCreatePatientWithDemographics() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

            Account patient = new Account(
                RecordTypeId = personAccountRTId,
                FirstName = 'Mei Ling',
                LastName = 'Tan',
                PersonBirthdate = Date.newInstance(1985, 3, 15),
                NRIC__c = 'S8515123A',
                Ethnicity__c = 'Chinese',
                Emergency_Contact_Name__c = 'Wei Ming Tan',
                Emergency_Contact_Phone__c = '+6591234567',
                Emergency_Contact_Relationship__c = 'Spouse'
            );

            Test.startTest();
            insert patient;
            Test.stopTest();

            Account result = [SELECT Id, FirstName, LastName, PersonBirthdate, NRIC__c, Ethnicity__c, Emergency_Contact_Name__c, Emergency_Contact_Phone__c, Emergency_Contact_Relationship__c FROM Account WHERE Id = :patient.Id];

            System.assertEquals('S8515123A', result.NRIC__c, 'NRIC should be saved');
            System.assertEquals('Chinese', result.Ethnicity__c, 'Ethnicity should be saved');
            System.assertEquals('Wei Ming Tan', result.Emergency_Contact_Name__c, 'Emergency contact name should be saved');
            System.assertEquals('+6591234567', result.Emergency_Contact_Phone__c, 'Emergency contact phone should be saved');
            System.assertEquals('Spouse', result.Emergency_Contact_Relationship__c, 'Emergency contact relationship should be saved');
        }
    }

    /**
     * @description Verify NRIC uniqueness constraint.
     */
    @isTest
    static void testNRICUniqueness() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

            Account patient1 = new Account(
                RecordTypeId = personAccountRTId,
                FirstName = 'Patient',
                LastName = 'One',
                NRIC__c = 'S9912345B'
            );
            insert patient1;

            Account patient2 = new Account(
                RecordTypeId = personAccountRTId,
                FirstName = 'Patient',
                LastName = 'Two',
                NRIC__c = 'S9912345B'
            );

            Test.startTest();
            try {
                insert patient2;
                System.assert(false, 'Should have thrown duplicate NRIC exception');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('DUPLICATE_VALUE') || e.getMessage().contains('duplicate'),
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
            Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

            Account patient = new Account(
                RecordTypeId = personAccountRTId,
                FirstName = 'Test',
                LastName = 'Patient',
                NRIC__c = 'S8801234C'
            );
            insert patient;

            HealthCondition condition = new HealthCondition(
                PatientId = patient.Id,
                ProblemName = 'Type 2 Diabetes Mellitus',
                ConditionStatus = 'Active',
                OnsetStartDateTime = DateTime.newInstance(2024, 6, 1, 0, 0, 0)
            );

            Test.startTest();
            insert condition;
            Test.stopTest();

            HealthCondition result = [SELECT Id, PatientId, ProblemName, ConditionStatus, OnsetStartDateTime FROM HealthCondition WHERE Id = :condition.Id];

            System.assertEquals(patient.Id, result.PatientId, 'Condition should be linked to patient');
            System.assertEquals('Active', result.ConditionStatus, 'Status should be Active');
            System.assertEquals('Type 2 Diabetes Mellitus', result.ProblemName, 'Problem name should match');
        }
    }

    /**
     * @description Create an AllergyIntolerance record linked to a patient.
     */
    @isTest
    static void testCreateAllergyIntolerance() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

            Account patient = new Account(
                RecordTypeId = personAccountRTId,
                FirstName = 'Test',
                LastName = 'Allergy',
                NRIC__c = 'S8801235D'
            );
            insert patient;

            AllergyIntolerance allergy = new AllergyIntolerance(
                PatientId = patient.Id,
                Severity = 'Severe',
                Type = 'Allergy',
                Status = 'Active'
            );

            Test.startTest();
            insert allergy;
            Test.stopTest();

            AllergyIntolerance result = [SELECT Id, PatientId, Name, Severity, Type, Status FROM AllergyIntolerance WHERE Id = :allergy.Id];

            System.assertEquals(patient.Id, result.PatientId, 'Allergy should be linked to patient');
            System.assertEquals('Severe', result.Severity, 'Severity should be Severe');
        }
    }

    /**
     * @description Create a MemberPlan with Medisave Balance for insurance tracking.
     */
    @isTest
    static void testCreateMemberPlanWithMedisave() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

            Account patient = new Account(
                RecordTypeId = personAccountRTId,
                FirstName = 'Test',
                LastName = 'Insurance',
                NRIC__c = 'S8801236E'
            );
            insert patient;

            MemberPlan plan = new MemberPlan(
                MemberId = patient.Id,
                Name = 'Medisave Plan',
                MemberNumber = 'MS-2024-001',
                Status = 'Active',
                Medisave_Balance__c = 45000.00
            );

            Test.startTest();
            insert plan;
            Test.stopTest();

            MemberPlan result = [SELECT Id, MemberId, MemberNumber, Status, Medisave_Balance__c FROM MemberPlan WHERE Id = :plan.Id];

            System.assertEquals(patient.Id, result.MemberId, 'Plan should be linked to patient');
            System.assertEquals('MS-2024-001', result.MemberNumber, 'Member number should match');
            System.assertEquals(45000.00, result.Medisave_Balance__c, 'Medisave balance should be saved');
        }
    }
}
