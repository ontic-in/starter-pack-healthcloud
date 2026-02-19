/**
 * @description Test class for DuplicateDetectionService (US-1.1.4).
 *              Tests name variant lookup, match scoring, and search term expansion
 *              for Singapore multilingual name transliterations.
 */
@isTest
private class DuplicateDetectionServiceTest {

    @TestSetup
    static void setupTestData() {
        Account patient = TestDataFactory.createPatientWithDetails(
            'Mei Ling', 'Tan', 'S8515360A',
            new Account(
                PersonBirthdate = Date.newInstance(1985, 3, 15),
                PersonMobilePhone = '+6591234567',
                PersonEmail = 'meiling.tan@test.com'
            )
        );
    }

    @isTest
    static void testGetNameVariants_KnownName() {
        List<String> variants = DuplicateDetectionService.getNameVariants('Tan');

        Assert.isFalse(variants.isEmpty(), 'Should return variants for known name');
        Assert.isTrue(variants.contains('Tan'), 'Should include the standard form');
        Assert.isTrue(variants.contains('Chen'), 'Should include Chen variant');
        Assert.isTrue(variants.contains('Chan'), 'Should include Chan variant');
    }

    @isTest
    static void testGetNameVariants_VariantForm() {
        List<String> variants = DuplicateDetectionService.getNameVariants('Chen');

        Assert.isFalse(variants.isEmpty(), 'Should return variants when searching by variant form');
        Assert.isTrue(variants.contains('Tan'), 'Should include standard form Tan');
        Assert.isTrue(variants.contains('Chen'), 'Should include the searched variant');
    }

    @isTest
    static void testGetNameVariants_UnknownName() {
        List<String> variants = DuplicateDetectionService.getNameVariants('Smith');

        Assert.areEqual(1, variants.size(), 'Should return only the original name');
        Assert.areEqual('Smith', variants[0], 'Should return the original name');
    }

    @isTest
    static void testCalculateMatchScore_ExactNRIC() {
        List<Account> patients = [
            SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate
            FROM Account
            WHERE NRIC__c = 'S8515360A'
            LIMIT 1
        ];
        Account candidate = patients[0];

        Integer score = DuplicateDetectionService.calculateMatchScore(
            candidate, 'S8515360A', 'Mei Ling', 'Tan', Date.newInstance(1985, 3, 15)
        );

        Assert.areEqual(100, score, 'Exact NRIC match should return 100');
    }

    @isTest
    static void testCalculateMatchScore_NameDOBMatch() {
        List<Account> patients = [
            SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate
            FROM Account
            WHERE NRIC__c = 'S8515360A'
            LIMIT 1
        ];
        Account candidate = patients[0];

        Integer score = DuplicateDetectionService.calculateMatchScore(
            candidate, 'S0000000X', 'Mei Ling', 'Tan', Date.newInstance(1985, 3, 15)
        );

        Assert.isTrue(score >= 80, 'Name + DOB match should score 80+, got: ' + score);
    }

    @isTest
    static void testCalculateMatchScore_NameVariantMatch() {
        List<Account> patients = [
            SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate
            FROM Account
            WHERE NRIC__c = 'S8515360A'
            LIMIT 1
        ];
        Account candidate = patients[0];

        Integer score = DuplicateDetectionService.calculateMatchScore(
            candidate, 'S0000000X', 'Mei Ling', 'Chen', Date.newInstance(1985, 3, 15)
        );

        Assert.isTrue(score > 0, 'Name variant match should return positive score, got: ' + score);
    }

    @isTest
    static void testCalculateMatchScore_NoMatch() {
        List<Account> patients = [
            SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate
            FROM Account
            WHERE NRIC__c = 'S8515360A'
            LIMIT 1
        ];
        Account candidate = patients[0];

        Integer score = DuplicateDetectionService.calculateMatchScore(
            candidate, 'S0000000X', 'John', 'Smith', Date.newInstance(2000, 1, 1)
        );

        Assert.areEqual(0, score, 'Completely different record should score 0');
    }

    @isTest
    static void testExpandSearchTerms_KnownName() {
        Set<String> terms = DuplicateDetectionService.expandSearchTerms('Mohamed');

        Assert.isTrue(terms.size() > 1, 'Should expand to multiple variants');
        Assert.isTrue(terms.contains('Mohamed'), 'Should include the original term');
        Assert.isTrue(terms.contains('Muhammad'), 'Should include standard form');
    }

    @isTest
    static void testExpandSearchTerms_UnknownName() {
        Set<String> terms = DuplicateDetectionService.expandSearchTerms('Nonexistent');

        Assert.areEqual(1, terms.size(), 'Unknown name should return only original');
        Assert.isTrue(terms.contains('Nonexistent'), 'Should contain the original term');
    }
}
