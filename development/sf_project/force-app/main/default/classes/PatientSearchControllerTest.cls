/**
 * @description Test class for PatientSearchController (US-1.1.4).
 *              Tests patient search by NRIC, name, and phone, plus
 *              duplicate detection with confidence scoring.
 */
@isTest
private class PatientSearchControllerTest {

    @TestSetup
    static void setupTestData() {
        TestDataFactory.createPatientsForSearchTests();
    }

    @isTest
    static void testSearchByNRIC_ExactMatch() {
        Test.startTest();
        List<PatientSearchController.SearchResult> results =
            PatientSearchController.searchPatients('S8515360A', 'NRIC');
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return exactly one match');
        Assert.areEqual('S8515360A', results[0].patient.NRIC__c, 'Should match the searched NRIC');
        Assert.areEqual(100, results[0].matchConfidence, 'NRIC match should be 100% confidence');
    }

    @isTest
    static void testSearchByNRIC_NoMatch() {
        Test.startTest();
        List<PatientSearchController.SearchResult> results =
            PatientSearchController.searchPatients('S0000000X', 'NRIC');
        Test.stopTest();

        Assert.isTrue(results.isEmpty(), 'Should return empty list for non-existent NRIC');
    }

    @isTest
    static void testSearchByNRIC_InvalidFormat() {
        Test.startTest();
        try {
            PatientSearchController.searchPatients('INVALID', 'NRIC');
            Assert.fail('Should throw exception for invalid NRIC format');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Invalid NRIC'),
                'Error should mention invalid NRIC format');
        }
        Test.stopTest();
    }

    @isTest
    static void testSearchByName_ExactMatch() {
        Test.startTest();
        List<PatientSearchController.SearchResult> results =
            PatientSearchController.searchPatients('Tan', 'Name');
        Test.stopTest();

        Assert.isFalse(results.isEmpty(), 'Should return results for name search');
        Boolean foundTan = false;
        for (PatientSearchController.SearchResult r : results) {
            if (r.patient.LastName == 'Tan') {
                foundTan = true;
                break;
            }
        }
        Assert.isTrue(foundTan, 'Should include patient with last name Tan');
    }

    @isTest
    static void testSearchByName_VariantMatch() {
        Test.startTest();
        List<PatientSearchController.SearchResult> results =
            PatientSearchController.searchPatients('Chen', 'Name');
        Test.stopTest();

        Assert.isFalse(results.isEmpty(), 'Should return results for variant name search');
    }

    @isTest
    static void testSearchByName_NoMatch() {
        Test.startTest();
        List<PatientSearchController.SearchResult> results =
            PatientSearchController.searchPatients('Nonexistent', 'Name');
        Test.stopTest();

        Assert.isTrue(results.isEmpty(), 'Should return empty for non-matching name');
    }

    @isTest
    static void testSearchByPhone_ExactMatch() {
        Test.startTest();
        List<PatientSearchController.SearchResult> results =
            PatientSearchController.searchPatients('+6591234567', 'Phone');
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one phone match');
        Assert.areEqual('+6591234567', results[0].patient.PersonMobilePhone,
            'Should match the searched phone');
    }

    @isTest
    static void testSearchByPhone_NoMatch() {
        Test.startTest();
        List<PatientSearchController.SearchResult> results =
            PatientSearchController.searchPatients('+6500000000', 'Phone');
        Test.stopTest();

        Assert.isTrue(results.isEmpty(), 'Should return empty for non-matching phone');
    }

    @isTest
    static void testSearchByInvalidType() {
        Test.startTest();
        try {
            PatientSearchController.searchPatients('test', 'InvalidType');
            Assert.fail('Should throw exception for invalid search type');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Invalid search type'),
                'Error should mention invalid search type');
        }
        Test.stopTest();
    }

    @isTest
    static void testSearchWithBlankTerm() {
        Test.startTest();
        try {
            PatientSearchController.searchPatients('', 'NRIC');
            Assert.fail('Should throw exception for blank search term');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Search term'),
                'Error should mention search term requirement');
        }
        Test.stopTest();
    }

    @isTest
    static void testCheckDuplicates_NRICMatch() {
        Test.startTest();
        List<PatientSearchController.SearchResult> results =
            PatientSearchController.checkDuplicates(
                'S8515360A', 'Mei Ling', 'Tan', Date.newInstance(1985, 3, 15)
            );
        Test.stopTest();

        Assert.isFalse(results.isEmpty(), 'Should find duplicates');
        Assert.areEqual(100, results[0].matchConfidence,
            'NRIC match should be 100% confidence');
    }

    @isTest
    static void testCheckDuplicates_NameDOBMatch() {
        Test.startTest();
        List<PatientSearchController.SearchResult> results =
            PatientSearchController.checkDuplicates(
                'S0000000X', 'Mei Ling', 'Tan', Date.newInstance(1985, 3, 15)
            );
        Test.stopTest();

        Assert.isFalse(results.isEmpty(), 'Should find potential duplicates by name+DOB');
        Assert.isTrue(results[0].matchConfidence >= 80,
            'Name+DOB match should be 80%+, got: ' + results[0].matchConfidence);
    }

    @isTest
    static void testCheckDuplicates_NoMatch() {
        Test.startTest();
        List<PatientSearchController.SearchResult> results =
            PatientSearchController.checkDuplicates(
                'S0000000X', 'Unique', 'Person', Date.newInstance(2000, 1, 1)
            );
        Test.stopTest();

        Assert.isTrue(results.isEmpty(), 'Should return empty for unique patient data');
    }
}
