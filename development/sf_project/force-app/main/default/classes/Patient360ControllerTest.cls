/**
 * @description Test class for Patient360Controller (US-1.1.2).
 *              Validates the Patient 360 LWC controller returns correct data
 *              for demographics, conditions, medications, allergies, and insurance.
 */
@isTest
private class Patient360ControllerTest {

    @TestSetup
    static void setupTestData() {
        Account patient = TestDataFactory.createPatientWithDetails(
            'Mei Ling', 'Tan', 'S8515360A',
            new Account(
                PersonBirthdate = Date.newInstance(1985, 3, 15),
                PersonEmail = 'meiling.tan@test.com',
                PersonMobilePhone = '+6591234567',
                Ethnicity__c = 'Chinese',
                Emergency_Contact_Name__c = 'Wei Ming Tan',
                Emergency_Contact_Phone__c = '+6598765432',
                Emergency_Contact_Relationship__c = 'Spouse'
            )
        );

        TestDataFactory.createHealthCondition(
            patient.Id, 'Type 2 Diabetes Mellitus', 'Active', 'Moderate',
            DateTime.newInstance(2024, 6, 1, 0, 0, 0)
        );

        TestDataFactory.createMedicationStatement(
            patient.Id, 'Metformin 500mg', 'Active',
            DateTime.newInstance(2024, 6, 15, 0, 0, 0)
        );

        TestDataFactory.createAllergyIntolerance(
            patient.Id, 'Allergy', 'Severe', 'Active'
        );

        TestDataFactory.createMemberPlan(
            patient.Id, 'Medisave Plan', 'MS-2024-360', 'Active', 45000.00
        );
    }

    /**
     * @description Happy path: Verify controller returns all 5 data sections
     *              for a patient with linked clinical and insurance records.
     */
    @isTest
    static void testGetPatient360Data() {
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(testUser) {
            Account patient = [SELECT Id FROM Account WHERE NRIC__c = 'S8515360A' LIMIT 1];

            Test.startTest();
            Patient360Controller.Patient360Data result =
                Patient360Controller.getPatient360Data(patient.Id);
            Test.stopTest();

            Assert.isNotNull(result, 'Result should not be null');

            // Demographics
            Assert.isNotNull(result.demographics, 'Demographics should not be null');
            Assert.areEqual('Mei Ling', result.demographics.FirstName, 'First name should match');
            Assert.areEqual('Tan', result.demographics.LastName, 'Last name should match');
            Assert.areEqual('S8515360A', result.demographics.NRIC__c, 'NRIC should match');
            Assert.areEqual('Chinese', result.demographics.Ethnicity__c, 'Ethnicity should match');

            // Conditions
            Assert.isNotNull(result.conditions, 'Conditions list should not be null');
            Assert.areEqual(1, result.conditions.size(), 'Should have 1 condition');
            Assert.areEqual('Type 2 Diabetes Mellitus', result.conditions[0].ProblemName, 'Condition name should match');
            Assert.areEqual('Active', result.conditions[0].ConditionStatus, 'Condition status should match');

            // Medications
            Assert.isNotNull(result.medications, 'Medications list should not be null');
            Assert.areEqual(1, result.medications.size(), 'Should have 1 medication');
            Assert.areEqual('Active', result.medications[0].Status, 'Medication status should match');

            // Allergies
            Assert.isNotNull(result.allergies, 'Allergies list should not be null');
            Assert.areEqual(1, result.allergies.size(), 'Should have 1 allergy');
            Assert.areEqual('Severe', result.allergies[0].Severity, 'Allergy severity should match');

            // Insurance
            Assert.isNotNull(result.insurance, 'Insurance list should not be null');
            Assert.areEqual(1, result.insurance.size(), 'Should have 1 insurance plan');
            Assert.areEqual('MS-2024-360', result.insurance[0].MemberNumber, 'Member number should match');
            Assert.areEqual(45000.00, result.insurance[0].Medisave_Balance__c, 'Medisave balance should match');
        }
    }

    /**
     * @description Verify controller returns empty lists (not nulls) when
     *              patient has no linked clinical or insurance records.
     */
    @isTest
    static void testGetPatient360DataNoRecords() {
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(testUser) {
            Account emptyPatient = TestDataFactory.createPatient('Empty', 'Patient', 'S9900001Z');

            Test.startTest();
            Patient360Controller.Patient360Data result =
                Patient360Controller.getPatient360Data(emptyPatient.Id);
            Test.stopTest();

            Assert.isNotNull(result, 'Result should not be null');
            Assert.isNotNull(result.demographics, 'Demographics should not be null');
            Assert.areEqual('Empty', result.demographics.FirstName, 'First name should match');

            Assert.isNotNull(result.conditions, 'Conditions should be empty list, not null');
            Assert.areEqual(0, result.conditions.size(), 'Should have 0 conditions');

            Assert.isNotNull(result.medications, 'Medications should be empty list, not null');
            Assert.areEqual(0, result.medications.size(), 'Should have 0 medications');

            Assert.isNotNull(result.allergies, 'Allergies should be empty list, not null');
            Assert.areEqual(0, result.allergies.size(), 'Should have 0 allergies');

            Assert.isNotNull(result.insurance, 'Insurance should be empty list, not null');
            Assert.areEqual(0, result.insurance.size(), 'Should have 0 insurance plans');
        }
    }

    /**
     * @description Verify controller throws AuraHandledException for invalid Account ID.
     */
    @isTest
    static void testGetPatient360DataInvalidId() {
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(testUser) {
            Id fakeAccountId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '000000000000';

            Test.startTest();
            try {
                Patient360Controller.getPatient360Data(fakeAccountId);
                Assert.fail('Should have thrown AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().length() > 0, 'Exception should have a message');
            }
            Test.stopTest();
        }
    }
}
