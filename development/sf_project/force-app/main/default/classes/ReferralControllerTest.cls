/**
 * @description Test class for ReferralController (US-1.3.2).
 *              Tests all LWC-facing controller methods including patient context,
 *              provider search, specialty options, referral submission, and error handling.
 */
@isTest
private class ReferralControllerTest {

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @TestSetup
    static void setupTestData() {
        // Patient
        Account patient = TestDataFactory.createPatient('Aisha', 'Binte Rahman', 'S9876543B');

        // Health condition
        TestDataFactory.createHealthCondition(
            patient.Id, 'Asthma', 'Active', 'Mild',
            DateTime.now().addMonths(-12)
        );

        // Practitioners (MCR-201/202 to avoid collision with service test)
        Contact drAhmad = new Contact(FirstName = 'Ahmad', LastName = 'Ibrahim', Email = 'ahmad@hospital.sg');
        Contact drChen = new Contact(FirstName = 'Chen', LastName = 'Xiu', Email = 'chen@hospital.sg');
        insert new List<Contact>{ drAhmad, drChen };

        // Providers
        HealthcareProvider provAhmad = new HealthcareProvider(
            PractitionerId = drAhmad.Id,
            Name = 'Dr Ahmad Ibrahim',
            Is_Accepting_Patients__c = true,
            IsActive = true
        );
        HealthcareProvider provChen = new HealthcareProvider(
            PractitionerId = drChen.Id,
            Name = 'Dr Chen Xiu',
            Is_Accepting_Patients__c = true,
            IsActive = true
        );
        insert new List<HealthcareProvider>{ provAhmad, provChen };

        // Specialty
        CareTaxonomy pulmonology = new CareTaxonomy(Name = 'Pulmonology');
        insert pulmonology;
        insert new HealthcareProviderTaxonomy(
            HealthcareProviderId = provAhmad.Id,
            TaxonomyId = pulmonology.Id
        );
    }

    @isTest
    static void testGetPatientContext_Success() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE IsPersonAccount = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            ReferralService.PatientContext ctx = ReferralController.getPatientContext(patient.Id);
            Test.stopTest();

            Assert.isNotNull(ctx, 'Context should not be null');
            Assert.areEqual('Aisha', ctx.firstName, 'First name should match');
        }
    }

    @isTest
    static void testSearchProviders_Success() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<ReferralService.ProviderOption> results = ReferralController.searchProviders('Ahmad', null);
            Test.stopTest();

            Assert.isTrue(results.size() >= 1, 'Should find at least 1 provider');
        }
    }

    @isTest
    static void testGetSpecialtyOptions_Success() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<ReferralService.PicklistOption> options = ReferralController.getSpecialtyOptions();
            Test.stopTest();

            Assert.isTrue(options.size() >= 1, 'Should have at least Pulmonology');
        }
    }

    @isTest
    static void testSubmitReferral_Success() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE IsPersonAccount = true LIMIT 1];
        HealthcareProvider provider = [SELECT Id FROM HealthcareProvider WHERE Name = 'Dr Ahmad Ibrahim' LIMIT 1];

        System.runAs(testUser) {
            ReferralService.ReferralRequest request = new ReferralService.ReferralRequest();
            request.patientId = patient.Id;
            request.referredToProviderId = provider.Id;
            request.reason = 'Persistent asthma requiring specialist evaluation';
            request.priority = 'Routine';
            request.specialtyRequested = 'Pulmonology';

            Test.startTest();
            ReferralService.ReferralResult result = ReferralController.submitReferral(
                JSON.serialize(request)
            );
            Test.stopTest();

            Assert.isNotNull(result.referralId, 'Referral ID should not be null');
            Assert.areEqual('Active', result.status, 'Status should be Active');
        }
    }

    @isTest
    static void testSubmitReferral_MalformedJson() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            try {
                ReferralController.submitReferral('{ invalid json }');
                Assert.fail('Should have thrown AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isNotNull(e.getMessage(), 'Error message should not be null');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testSubmitReferral_MissingFields() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            ReferralService.ReferralRequest request = new ReferralService.ReferralRequest();
            request.patientId = null;
            request.reason = 'Test reason';

            Test.startTest();
            try {
                ReferralController.submitReferral(JSON.serialize(request));
                Assert.fail('Should have thrown AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(
                    e.getMessage().contains('Patient ID is required'),
                    'Should contain missing patient message'
                );
            }
            Test.stopTest();
        }
    }
}
