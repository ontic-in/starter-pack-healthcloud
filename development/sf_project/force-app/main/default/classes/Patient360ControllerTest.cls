/**
 * @description Test class for Patient360Controller (US-1.1.2).
 *              Validates the Patient 360 LWC controller returns correct data
 *              for demographics, conditions, medications, allergies, and insurance.
 */
@isTest
private class Patient360ControllerTest {

    @TestSetup
    static void setupTestData() {
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Person Account').getRecordTypeId();

        Account patient = new Account(
            RecordTypeId = personAccountRTId,
            FirstName = 'Mei Ling',
            LastName = 'Tan',
            PersonBirthdate = Date.newInstance(1985, 3, 15),
            PersonEmail = 'meiling.tan@test.com',
            PersonMobilePhone = '+6591234567',
            NRIC__c = 'S8515360A',
            Ethnicity__c = 'Chinese',
            Emergency_Contact_Name__c = 'Wei Ming Tan',
            Emergency_Contact_Phone__c = '+6598765432',
            Emergency_Contact_Relationship__c = 'Spouse'
        );
        insert patient;

        HealthCondition condition = new HealthCondition(
            PatientId = patient.Id,
            ProblemName = 'Type 2 Diabetes Mellitus',
            ConditionStatus = 'Active',
            Severity = 'Moderate',
            OnsetStartDateTime = DateTime.newInstance(2024, 6, 1, 0, 0, 0)
        );
        insert condition;

        Medication med = new Medication(
            Name = 'Metformin 500mg'
        );
        insert med;

        MedicationStatement medication = new MedicationStatement(
            PatientId = patient.Id,
            MedicationId = med.Id,
            Status = 'Active',
            StartDateTime = DateTime.newInstance(2024, 6, 15, 0, 0, 0)
        );
        insert medication;

        AllergyIntolerance allergy = new AllergyIntolerance(
            PatientId = patient.Id,
            Type = 'Allergy',
            Severity = 'Severe',
            Status = 'Active'
        );
        insert allergy;

        MemberPlan insurance = new MemberPlan(
            MemberId = patient.Id,
            Name = 'Medisave Plan',
            MemberNumber = 'MS-2024-360',
            Status = 'Active',
            Medisave_Balance__c = 45000.00
        );
        insert insurance;
    }

    /**
     * @description Happy path: Verify controller returns all 5 data sections
     *              for a patient with linked clinical and insurance records.
     */
    @isTest
    static void testGetPatient360Data() {
        Account patient = [SELECT Id FROM Account WHERE NRIC__c = 'S8515360A' LIMIT 1];

        Test.startTest();
        Patient360Controller.Patient360Data result =
            Patient360Controller.getPatient360Data(patient.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');

        // Demographics
        System.assertNotEquals(null, result.demographics, 'Demographics should not be null');
        System.assertEquals('Mei Ling', result.demographics.FirstName, 'First name should match');
        System.assertEquals('Tan', result.demographics.LastName, 'Last name should match');
        System.assertEquals('S8515360A', result.demographics.NRIC__c, 'NRIC should match');
        System.assertEquals('Chinese', result.demographics.Ethnicity__c, 'Ethnicity should match');

        // Conditions
        System.assertNotEquals(null, result.conditions, 'Conditions list should not be null');
        System.assertEquals(1, result.conditions.size(), 'Should have 1 condition');
        System.assertEquals('Type 2 Diabetes Mellitus', result.conditions[0].ProblemName, 'Condition name should match');
        System.assertEquals('Active', result.conditions[0].ConditionStatus, 'Condition status should match');

        // Medications
        System.assertNotEquals(null, result.medications, 'Medications list should not be null');
        System.assertEquals(1, result.medications.size(), 'Should have 1 medication');
        System.assertEquals('Active', result.medications[0].Status, 'Medication status should match');

        // Allergies
        System.assertNotEquals(null, result.allergies, 'Allergies list should not be null');
        System.assertEquals(1, result.allergies.size(), 'Should have 1 allergy');
        System.assertEquals('Severe', result.allergies[0].Severity, 'Allergy severity should match');

        // Insurance
        System.assertNotEquals(null, result.insurance, 'Insurance list should not be null');
        System.assertEquals(1, result.insurance.size(), 'Should have 1 insurance plan');
        System.assertEquals('MS-2024-360', result.insurance[0].MemberNumber, 'Member number should match');
        System.assertEquals(45000.00, result.insurance[0].Medisave_Balance__c, 'Medisave balance should match');
    }

    /**
     * @description Verify controller returns empty lists (not nulls) when
     *              patient has no linked clinical or insurance records.
     */
    @isTest
    static void testGetPatient360DataNoRecords() {
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Person Account').getRecordTypeId();

        Account emptyPatient = new Account(
            RecordTypeId = personAccountRTId,
            FirstName = 'Empty',
            LastName = 'Patient',
            NRIC__c = 'S9900001Z'
        );
        insert emptyPatient;

        Test.startTest();
        Patient360Controller.Patient360Data result =
            Patient360Controller.getPatient360Data(emptyPatient.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.demographics, 'Demographics should not be null');
        System.assertEquals('Empty', result.demographics.FirstName, 'First name should match');

        System.assertNotEquals(null, result.conditions, 'Conditions should be empty list, not null');
        System.assertEquals(0, result.conditions.size(), 'Should have 0 conditions');

        System.assertNotEquals(null, result.medications, 'Medications should be empty list, not null');
        System.assertEquals(0, result.medications.size(), 'Should have 0 medications');

        System.assertNotEquals(null, result.allergies, 'Allergies should be empty list, not null');
        System.assertEquals(0, result.allergies.size(), 'Should have 0 allergies');

        System.assertNotEquals(null, result.insurance, 'Insurance should be empty list, not null');
        System.assertEquals(0, result.insurance.size(), 'Should have 0 insurance plans');
    }

    /**
     * @description Verify controller throws AuraHandledException for invalid Account ID.
     */
    @isTest
    static void testGetPatient360DataInvalidId() {
        // Use a fabricated Account ID that doesn't exist
        Id fakeAccountId = Account.SObjectType.getDescribe().getKeyPrefix() + '000000000000';

        Test.startTest();
        try {
            Patient360Controller.getPatient360Data(fakeAccountId);
            System.assert(false, 'Should have thrown AuraHandledException');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().length() > 0, 'Exception should have a message');
        }
        Test.stopTest();
    }
}
