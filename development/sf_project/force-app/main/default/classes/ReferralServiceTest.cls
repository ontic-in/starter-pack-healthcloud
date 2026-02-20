/**
 * @description Test class for ReferralService (US-1.3.2).
 *              Tests patient context retrieval, provider search,
 *              specialty options, referral creation, and validation.
 */
@isTest
private class ReferralServiceTest {

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @TestSetup
    static void setupTestData() {
        // Patient (Person Account)
        Account patient = TestDataFactory.createPatient('Li', 'Wei', 'S1234567A');

        // Health conditions
        TestDataFactory.createHealthCondition(
            patient.Id, 'Type 2 Diabetes', 'Active', 'Moderate',
            DateTime.now().addMonths(-6)
        );
        TestDataFactory.createHealthCondition(
            patient.Id, 'Hypertension', 'Active', 'Mild',
            DateTime.now().addMonths(-3)
        );

        // Medication
        TestDataFactory.createMedicationStatement(
            patient.Id, 'Metformin 500mg', 'Active',
            DateTime.now().addMonths(-6)
        );

        // Allergy
        TestDataFactory.createAllergyIntolerance(
            patient.Id, 'Allergy', 'Moderate', 'Active'
        );

        // Practitioners
        Contact drTan = new Contact(FirstName = 'Wei', LastName = 'Tan', Email = 'wei.tan@hospital.sg');
        Contact drLee = new Contact(FirstName = 'Mei', LastName = 'Lee', Email = 'mei.lee@hospital.sg');
        insert new List<Contact>{ drTan, drLee };

        // Healthcare providers
        HealthcareProvider providerTan = new HealthcareProvider(
            PractitionerId = drTan.Id,
            Name = 'Dr Wei Tan',
            Is_Accepting_Patients__c = true,
            IsActive = true
        );
        HealthcareProvider providerLee = new HealthcareProvider(
            PractitionerId = drLee.Id,
            Name = 'Dr Mei Lee',
            Is_Accepting_Patients__c = false,
            IsActive = true
        );
        insert new List<HealthcareProvider>{ providerTan, providerLee };

        // Specialties
        CareTaxonomy cardiology = new CareTaxonomy(Name = 'Cardiology');
        CareTaxonomy orthopedics = new CareTaxonomy(Name = 'Orthopedics');
        insert new List<CareTaxonomy>{ cardiology, orthopedics };

        // Provider-specialty junctions
        insert new List<HealthcareProviderTaxonomy>{
            new HealthcareProviderTaxonomy(HealthcareProviderId = providerTan.Id, TaxonomyId = cardiology.Id),
            new HealthcareProviderTaxonomy(HealthcareProviderId = providerLee.Id, TaxonomyId = orthopedics.Id)
        };

        // Facilities
        Account sgh = new Account(Name = 'SGH');
        insert sgh;
        insert new HealthcarePractitionerFacility(
            PractitionerId = drTan.Id,
            AccountId = sgh.Id,
            IsActive = true
        );
    }

    @isTest
    static void testGetPatientContext_Success() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE IsPersonAccount = true LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            ReferralService.PatientContext ctx = ReferralService.getPatientContext(patient.Id);
            Test.stopTest();

            Assert.isNotNull(ctx, 'Patient context should not be null');
            Assert.areEqual('Li', ctx.firstName, 'First name should match');
            Assert.areEqual('Wei', ctx.lastName, 'Last name should match');
            Assert.areEqual('S1234567A', ctx.nric, 'NRIC should match');
            Assert.isTrue(ctx.conditions.size() >= 2, 'Should have at least 2 conditions');
            Assert.isTrue(ctx.medications.size() >= 1, 'Should have at least 1 medication');
            Assert.isTrue(ctx.allergies.size() >= 1, 'Should have at least 1 allergy');
        }
    }

    @isTest
    static void testGetPatientContext_NotFound() {
        User testUser = getTestUser();
        Id fakeId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
            .getKeyPrefix() + '000000000000';

        System.runAs(testUser) {
            Test.startTest();
            try {
                ReferralService.getPatientContext(fakeId);
                Assert.fail('Should have thrown AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().contains('Patient not found'), 'Should contain not found message');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testSearchProviders_ByName() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<ReferralService.ProviderOption> results = ReferralService.searchProviders('Wei', null);
            Test.stopTest();

            Assert.isTrue(results.size() >= 1, 'Should find at least 1 provider');
            Boolean foundTan = false;
            for (ReferralService.ProviderOption opt : results) {
                if (opt.name == 'Dr Wei Tan') {
                    foundTan = true;
                }
            }
            Assert.isTrue(foundTan, 'Should find Dr Wei Tan');
        }
    }

    @isTest
    static void testSearchProviders_BySpecialty() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<ReferralService.ProviderOption> results = ReferralService.searchProviders(null, 'Cardiology');
            Test.stopTest();

            Assert.isTrue(results.size() >= 1, 'Should find at least 1 cardiologist');
        }
    }

    @isTest
    static void testSearchProviders_NoResults() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<ReferralService.ProviderOption> results = ReferralService.searchProviders(null, 'Neurology');
            Test.stopTest();

            Assert.areEqual(0, results.size(), 'Should return empty list for non-existent specialty');
        }
    }

    @isTest
    static void testGetSpecialtyOptions() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<ReferralService.PicklistOption> options = ReferralService.getSpecialtyOptions();
            Test.stopTest();

            Assert.isTrue(options.size() >= 2, 'Should have at least Cardiology and Orthopedics');
        }
    }

    @isTest
    static void testCreateReferral_Success() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE IsPersonAccount = true LIMIT 1];
        HealthcareProvider provider = [SELECT Id FROM HealthcareProvider WHERE Name = 'Dr Wei Tan' LIMIT 1];

        System.runAs(testUser) {
            ReferralService.ReferralRequest request = new ReferralService.ReferralRequest();
            request.patientId = patient.Id;
            request.referredToProviderId = provider.Id;
            request.reason = 'Patient requires cardiac evaluation for chest pain';
            request.priority = 'Urgent';
            request.specialtyRequested = 'Cardiology';

            Test.startTest();
            ReferralService.ReferralResult result = ReferralService.createReferral(
                JSON.serialize(request)
            );
            Test.stopTest();

            Assert.isNotNull(result.referralId, 'Referral ID should not be null');
            Assert.areEqual('Active', result.status, 'Status should be Active');

            ClinicalServiceRequest csr = [
                SELECT PatientId, Referred_To_Provider__c, Referral_Reason__c,
                       Priority, Status, Intent
                FROM ClinicalServiceRequest
                WHERE Id = :result.referralId
            ];
            Assert.areEqual(patient.Id, csr.PatientId, 'Patient should match');
            Assert.areEqual(provider.Id, csr.Referred_To_Provider__c, 'Provider should match');
            Assert.areEqual('Urgent', csr.Priority, 'Priority should match');
            Assert.areEqual('order', csr.Intent, 'Intent should be order');
        }
    }

    @isTest
    static void testCreateReferral_MissingReason() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE IsPersonAccount = true LIMIT 1];
        HealthcareProvider provider = [SELECT Id FROM HealthcareProvider WHERE Name = 'Dr Wei Tan' LIMIT 1];

        System.runAs(testUser) {
            ReferralService.ReferralRequest request = new ReferralService.ReferralRequest();
            request.patientId = patient.Id;
            request.referredToProviderId = provider.Id;
            request.reason = '';
            request.priority = 'Routine';

            Test.startTest();
            try {
                ReferralService.createReferral(JSON.serialize(request));
                Assert.fail('Should have thrown AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(
                    e.getMessage().contains('Referral reason is required'),
                    'Should contain missing reason message'
                );
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testCreateReferral_MissingProvider() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE IsPersonAccount = true LIMIT 1];

        System.runAs(testUser) {
            ReferralService.ReferralRequest request = new ReferralService.ReferralRequest();
            request.patientId = patient.Id;
            request.referredToProviderId = null;
            request.reason = 'Test reason';
            request.priority = 'Routine';

            Test.startTest();
            try {
                ReferralService.createReferral(JSON.serialize(request));
                Assert.fail('Should have thrown AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(
                    e.getMessage().contains('Referred-to provider is required'),
                    'Should contain missing provider message'
                );
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testSearchProviders_EmptySearch() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<ReferralService.ProviderOption> results = ReferralService.searchProviders('', '');
            Test.stopTest();

            Assert.isTrue(results.size() >= 2, 'Should return all active providers');
        }
    }
}
