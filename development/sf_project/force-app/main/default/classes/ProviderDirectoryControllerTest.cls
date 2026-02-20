/**
 * @description Test class for ProviderDirectoryController (US-1.3.1).
 *              Tests all LWC-facing controller methods including search,
 *              picklist retrieval, detail view, and error handling.
 */
@isTest
private class ProviderDirectoryControllerTest {

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @TestSetup
    static void setupTestData() {
        // Practitioner contacts
        Contact drTan = new Contact(FirstName = 'Wei', LastName = 'Tan', Email = 'wei.tan@hospital.sg', Phone = '91234567');
        Contact drLee = new Contact(FirstName = 'Mei', LastName = 'Lee', Email = 'mei.lee@hospital.sg', Phone = '98765432');
        insert new List<Contact>{ drTan, drLee };

        // Healthcare providers
        HealthcareProvider provTan = TestDataFactory.createHealthcareProvider(
            drTan.Id, 'Dr. Wei Tan', 'MCR-101', 'English;Mandarin', 45, true
        );
        HealthcareProvider provLee = TestDataFactory.createHealthcareProvider(
            drLee.Id, 'Dr. Mei Lee', 'MCR-102', 'English;Malay', 80, false
        );

        // Specialties (records needed for picklist queries; return values unused)
        TestDataFactory.createCareSpecialty('Cardiology', 'CARD');
        TestDataFactory.createCareSpecialty('Orthopedics', 'ORTH');

        // Taxonomies
        CareTaxonomy cardiologyTax = TestDataFactory.createCareTaxonomy('Cardiology');
        CareTaxonomy orthopedicsTax = TestDataFactory.createCareTaxonomy('Orthopedics');

        // Provider-Taxonomy junctions
        TestDataFactory.createProviderTaxonomy(provTan.Id, cardiologyTax.Id);
        TestDataFactory.createProviderTaxonomy(provLee.Id, orthopedicsTax.Id);

        // Facility accounts
        Account sgh = TestDataFactory.createFacilityAccount('Singapore General Hospital');
        Account cgh = TestDataFactory.createFacilityAccount('Changi General Hospital');

        // Practitioner-Facility junctions
        TestDataFactory.createPractitionerFacility(drTan.Id, sgh.Id);
        TestDataFactory.createPractitionerFacility(drLee.Id, cgh.Id);
    }

    @isTest
    static void testSearchProviders_Success() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            ProviderDirectoryService.SearchCriteria criteria = new ProviderDirectoryService.SearchCriteria();
            criteria.specialtyNames = new List<String>{ 'Cardiology' };
            criteria.acceptingPatientsOnly = true;
            String criteriaJson = JSON.serialize(criteria);

            Test.startTest();
            List<ProviderDirectoryService.ProviderSearchResult> results =
                ProviderDirectoryController.searchProviders(criteriaJson);
            Test.stopTest();

            Assert.isNotNull(results, 'Results should not be null');
            Assert.isTrue(results.size() >= 1, 'Should return at least 1 provider');

            Boolean foundTan = false;
            for (ProviderDirectoryService.ProviderSearchResult r : results) {
                if (r.name == 'Dr. Wei Tan') {
                    foundTan = true;
                    break;
                }
            }
            Assert.isTrue(foundTan, 'Dr. Wei Tan should be in results');
        }
    }

    @isTest
    static void testSearchProviders_EmptyCriteria() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Test.startTest();
            List<ProviderDirectoryService.ProviderSearchResult> resultsNull =
                ProviderDirectoryController.searchProviders(null);
            List<ProviderDirectoryService.ProviderSearchResult> resultsBlank =
                ProviderDirectoryController.searchProviders('');
            Test.stopTest();

            Assert.isNotNull(resultsNull, 'Null criteria should return non-null results');
            Assert.isTrue(resultsNull.size() >= 2, 'Null criteria should return all active providers');

            Assert.isNotNull(resultsBlank, 'Blank criteria should return non-null results');
            Assert.isTrue(resultsBlank.size() >= 2, 'Blank criteria should return all active providers');
        }
    }

    @isTest
    static void testGetSpecialtyOptions_Success() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Test.startTest();
            List<ProviderDirectoryService.PicklistOption> options =
                ProviderDirectoryController.getSpecialtyOptions();
            Test.stopTest();

            Assert.isNotNull(options, 'Options should not be null');
            Assert.isTrue(options.size() >= 2, 'Should return at least 2 specialty options');

            Set<String> labels = new Set<String>();
            for (ProviderDirectoryService.PicklistOption opt : options) {
                labels.add(opt.label);
            }
            Assert.isTrue(labels.contains('Cardiology'), 'Should contain Cardiology');
            Assert.isTrue(labels.contains('Orthopedics'), 'Should contain Orthopedics');
        }
    }

    @isTest
    static void testGetFacilityOptions_Success() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Test.startTest();
            List<ProviderDirectoryService.PicklistOption> options =
                ProviderDirectoryController.getFacilityOptions();
            Test.stopTest();

            Assert.isNotNull(options, 'Options should not be null');
            Assert.isTrue(options.size() >= 2, 'Should return at least 2 facility options');

            Set<String> labels = new Set<String>();
            for (ProviderDirectoryService.PicklistOption opt : options) {
                labels.add(opt.label);
            }
            Assert.isTrue(labels.contains('Singapore General Hospital'), 'Should contain SGH');
            Assert.isTrue(labels.contains('Changi General Hospital'), 'Should contain CGH');
        }
    }

    @isTest
    static void testGetProviderDetail_Success() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            HealthcareProvider provider = [
                SELECT Id FROM HealthcareProvider
                WHERE MCR_Number__c = 'MCR-101' LIMIT 1
            ];

            Test.startTest();
            ProviderDirectoryService.ProviderDetail detail =
                ProviderDirectoryController.getProviderDetail(provider.Id);
            Test.stopTest();

            Assert.isNotNull(detail, 'Detail should not be null');
            Assert.isNotNull(detail.provider, 'Provider should not be null');
            Assert.areEqual('MCR-101', detail.provider.MCR_Number__c, 'MCR number should match');
            Assert.isNotNull(detail.practitionerName, 'Practitioner name should not be null');
            Assert.isTrue(detail.specialties.size() >= 1, 'Should have at least 1 specialty');
            Assert.isTrue(detail.facilities.size() >= 1, 'Should have at least 1 facility');
        }
    }

    @isTest
    static void testGetProviderDetail_InvalidId() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Id fakeId = HealthcareProvider.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                .getKeyPrefix() + '000000000000';

            Test.startTest();
            try {
                ProviderDirectoryController.getProviderDetail(fakeId);
                Assert.fail('Should have thrown AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().length() > 0, 'Should have error message');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testSearchProviders_MalformedJson() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            String badJson = '{ this is not valid json }';

            Test.startTest();
            try {
                ProviderDirectoryController.searchProviders(badJson);
                Assert.fail('Should have thrown AuraHandledException for malformed JSON');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().length() > 0, 'Should have error message');
            }
            Test.stopTest();
        }
    }
}
