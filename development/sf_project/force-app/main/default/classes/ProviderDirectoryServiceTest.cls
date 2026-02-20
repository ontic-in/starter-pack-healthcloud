/**
 * @description Test class for ProviderDirectoryService (US-1.3.1).
 *              Tests provider search, filtering, picklist retrieval,
 *              and detail view across multiple filter combinations.
 */
@isTest
private class ProviderDirectoryServiceTest {

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
            drTan.Id, 'Dr. Wei Tan', 'MCR-001', 'English;Mandarin', 45, true
        );
        HealthcareProvider provLee = TestDataFactory.createHealthcareProvider(
            drLee.Id, 'Dr. Mei Lee', 'MCR-002', 'English;Malay', 80, false
        );

        // Specialties (records needed for picklist queries; return values unused)
        TestDataFactory.createCareSpecialty('Cardiology', 'CARD');
        TestDataFactory.createCareSpecialty('Orthopedics', 'ORTH');

        // Taxonomies matching specialties
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
    static void testSearchProviders_NoFilters() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            ProviderDirectoryService.SearchCriteria criteria = new ProviderDirectoryService.SearchCriteria();

            Test.startTest();
            List<ProviderDirectoryService.ProviderSearchResult> results =
                ProviderDirectoryService.searchProviders(criteria);
            Test.stopTest();

            Assert.isNotNull(results, 'Results should not be null');
            Assert.isTrue(results.size() >= 2, 'Should return at least 2 active providers');
        }
    }

    @isTest
    static void testSearchProviders_ByName() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            ProviderDirectoryService.SearchCriteria criteria = new ProviderDirectoryService.SearchCriteria();
            criteria.searchTerm = 'Wei Tan';

            Test.startTest();
            List<ProviderDirectoryService.ProviderSearchResult> results =
                ProviderDirectoryService.searchProviders(criteria);
            Test.stopTest();

            Assert.isNotNull(results, 'Results should not be null');
            Assert.isTrue(results.size() >= 1, 'Should find at least 1 provider matching name');

            Boolean foundTan = false;
            for (ProviderDirectoryService.ProviderSearchResult r : results) {
                if (r.name == 'Dr. Wei Tan') {
                    foundTan = true;
                    break;
                }
            }
            Assert.isTrue(foundTan, 'Should find Dr. Wei Tan in results');
        }
    }

    @isTest
    static void testSearchProviders_BySpecialty() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            ProviderDirectoryService.SearchCriteria criteria = new ProviderDirectoryService.SearchCriteria();
            criteria.specialtyNames = new List<String>{ 'Cardiology' };

            Test.startTest();
            List<ProviderDirectoryService.ProviderSearchResult> results =
                ProviderDirectoryService.searchProviders(criteria);
            Test.stopTest();

            Assert.isNotNull(results, 'Results should not be null');
            Assert.isTrue(results.size() >= 1, 'Should return at least 1 provider for Cardiology');

            Boolean foundTan = false;
            for (ProviderDirectoryService.ProviderSearchResult r : results) {
                if (r.name == 'Dr. Wei Tan') {
                    foundTan = true;
                    break;
                }
            }
            Assert.isTrue(foundTan, 'Dr. Wei Tan should be in Cardiology results');
        }
    }

    @isTest
    static void testSearchProviders_ByFacility() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            ProviderDirectoryService.SearchCriteria criteria = new ProviderDirectoryService.SearchCriteria();
            criteria.facilityNames = new List<String>{ 'Changi General Hospital' };

            Test.startTest();
            List<ProviderDirectoryService.ProviderSearchResult> results =
                ProviderDirectoryService.searchProviders(criteria);
            Test.stopTest();

            Assert.isNotNull(results, 'Results should not be null');
            Assert.isTrue(results.size() >= 1, 'Should return at least 1 provider for Changi');

            Boolean foundLee = false;
            for (ProviderDirectoryService.ProviderSearchResult r : results) {
                if (r.name == 'Dr. Mei Lee') {
                    foundLee = true;
                    break;
                }
            }
            Assert.isTrue(foundLee, 'Dr. Mei Lee should be in Changi General Hospital results');
        }
    }

    @isTest
    static void testSearchProviders_ByLanguage() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            ProviderDirectoryService.SearchCriteria criteria = new ProviderDirectoryService.SearchCriteria();
            criteria.languages = new List<String>{ 'Mandarin' };

            Test.startTest();
            List<ProviderDirectoryService.ProviderSearchResult> results =
                ProviderDirectoryService.searchProviders(criteria);
            Test.stopTest();

            Assert.isNotNull(results, 'Results should not be null');
            Assert.isTrue(results.size() >= 1, 'Should return at least 1 provider for Mandarin');

            Boolean foundTan = false;
            for (ProviderDirectoryService.ProviderSearchResult r : results) {
                if (r.name == 'Dr. Wei Tan') {
                    foundTan = true;
                    break;
                }
            }
            Assert.isTrue(foundTan, 'Dr. Wei Tan should be in Mandarin language results');
        }
    }

    @isTest
    static void testSearchProviders_AcceptingOnly() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            ProviderDirectoryService.SearchCriteria criteria = new ProviderDirectoryService.SearchCriteria();
            criteria.acceptingPatientsOnly = true;

            Test.startTest();
            List<ProviderDirectoryService.ProviderSearchResult> results =
                ProviderDirectoryService.searchProviders(criteria);
            Test.stopTest();

            Assert.isNotNull(results, 'Results should not be null');
            Assert.isTrue(results.size() >= 1, 'Should return at least 1 accepting provider');

            for (ProviderDirectoryService.ProviderSearchResult r : results) {
                Assert.isTrue(r.acceptingPatients, 'All results should be accepting patients');
            }
        }
    }

    @isTest
    static void testSearchProviders_CombinedFilters() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            ProviderDirectoryService.SearchCriteria criteria = new ProviderDirectoryService.SearchCriteria();
            criteria.specialtyNames = new List<String>{ 'Cardiology' };
            criteria.languages = new List<String>{ 'English' };
            criteria.acceptingPatientsOnly = true;

            Test.startTest();
            List<ProviderDirectoryService.ProviderSearchResult> results =
                ProviderDirectoryService.searchProviders(criteria);
            Test.stopTest();

            Assert.isNotNull(results, 'Results should not be null');
            Assert.isTrue(results.size() >= 1, 'Should return at least 1 provider matching all filters');

            for (ProviderDirectoryService.ProviderSearchResult r : results) {
                Assert.isTrue(r.acceptingPatients, 'All results should be accepting patients');
            }
        }
    }

    @isTest
    static void testSearchProviders_NoResults() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            ProviderDirectoryService.SearchCriteria criteria = new ProviderDirectoryService.SearchCriteria();
            criteria.searchTerm = 'NonExistentProviderXYZ12345';

            Test.startTest();
            List<ProviderDirectoryService.ProviderSearchResult> results =
                ProviderDirectoryService.searchProviders(criteria);
            Test.stopTest();

            Assert.isNotNull(results, 'Results should not be null');
            Assert.areEqual(0, results.size(), 'Should return empty list for non-matching search');
        }
    }

    @isTest
    static void testGetSpecialtyPicklistValues() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Test.startTest();
            List<ProviderDirectoryService.PicklistOption> options =
                ProviderDirectoryService.getSpecialtyPicklistValues();
            Test.stopTest();

            Assert.isNotNull(options, 'Options should not be null');
            Assert.isTrue(options.size() >= 2, 'Should return at least 2 specialty options');

            Set<String> labels = new Set<String>();
            for (ProviderDirectoryService.PicklistOption opt : options) {
                Assert.isNotNull(opt.label, 'Label should not be null');
                Assert.isNotNull(opt.value, 'Value should not be null');
                labels.add(opt.label);
            }
            Assert.isTrue(labels.contains('Cardiology'), 'Should contain Cardiology option');
            Assert.isTrue(labels.contains('Orthopedics'), 'Should contain Orthopedics option');
        }
    }

    @isTest
    static void testGetFacilityPicklistValues() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Test.startTest();
            List<ProviderDirectoryService.PicklistOption> options =
                ProviderDirectoryService.getFacilityPicklistValues();
            Test.stopTest();

            Assert.isNotNull(options, 'Options should not be null');
            Assert.isTrue(options.size() >= 2, 'Should return at least 2 facility options');

            Set<String> labels = new Set<String>();
            for (ProviderDirectoryService.PicklistOption opt : options) {
                Assert.isNotNull(opt.label, 'Label should not be null');
                Assert.isNotNull(opt.value, 'Value should not be null');
                labels.add(opt.label);
            }
            Assert.isTrue(labels.contains('Singapore General Hospital'), 'Should contain SGH option');
            Assert.isTrue(labels.contains('Changi General Hospital'), 'Should contain CGH option');
        }
    }

    @isTest
    static void testGetProviderDetail_Success() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            HealthcareProvider provider = [
                SELECT Id FROM HealthcareProvider
                WHERE MCR_Number__c = 'MCR-001' LIMIT 1
            ];

            Test.startTest();
            ProviderDirectoryService.ProviderDetail detail =
                ProviderDirectoryService.getProviderDetail(provider.Id);
            Test.stopTest();

            Assert.isNotNull(detail, 'Detail should not be null');
            Assert.isNotNull(detail.provider, 'Provider should not be null');
            Assert.areEqual('MCR-001', detail.provider.MCR_Number__c, 'MCR number should match');
            Assert.isNotNull(detail.practitionerName, 'Practitioner name should not be null');
            Assert.isTrue(detail.specialties.size() >= 1, 'Should have at least 1 specialty');
            Assert.isTrue(detail.facilities.size() >= 1, 'Should have at least 1 facility');
        }
    }

    @isTest
    static void testGetProviderDetail_NotFound() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            Id fakeId = HealthcareProvider.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                .getKeyPrefix() + '000000000000';

            Test.startTest();
            try {
                ProviderDirectoryService.getProviderDetail(fakeId);
                Assert.fail('Should have thrown AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().length() > 0, 'Should have error message');
            }
            Test.stopTest();
        }
    }
}
