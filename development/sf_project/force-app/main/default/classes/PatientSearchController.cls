/**
 * @description Controller for Patient Search and Duplicate Detection LWC (US-1.1.4).
 *              Provides search by NRIC, name (with fuzzy matching via name variants),
 *              and phone number. Includes duplicate detection with confidence scoring.
 */
public with sharing class PatientSearchController {

    private static final String NRIC_PATTERN = '[STFGstfg]\\d{7}[A-Za-z]';

    /**
     * @description Wrapper class for search results with confidence scoring.
     */
    public class SearchResult implements Comparable {
        @AuraEnabled public Account patient;
        @AuraEnabled public Integer matchConfidence;
        @AuraEnabled public String matchReason;

        public Integer compareTo(Object other) {
            SearchResult otherResult = (SearchResult) other;
            return otherResult.matchConfidence - this.matchConfidence;
        }
    }

    /**
     * @description Searches for patients by the specified criteria.
     * @param searchTerm The value to search for.
     * @param searchType The type of search: NRIC, Name, or Phone.
     * @return List of SearchResult with matched patients and confidence scores.
     * @throws AuraHandledException for invalid input or search type.
     */
    @AuraEnabled
    public static List<SearchResult> searchPatients(String searchTerm, String searchType) {
        if (String.isBlank(searchTerm)) {
            throw new AuraHandledException('Search term is required.');
        }

        String term = searchTerm.trim();

        if (searchType == 'NRIC') {
            return searchByNRIC(term);
        } else if (searchType == 'Name') {
            return searchByName(term);
        } else if (searchType == 'Phone') {
            return searchByPhone(term);
        } else {
            throw new AuraHandledException('Invalid search type: ' + searchType);
        }
    }

    /**
     * @description Checks for potential duplicate patients based on NRIC, name, and DOB.
     * @param nric NRIC to check.
     * @param firstName Patient first name.
     * @param lastName Patient last name.
     * @param dob Patient date of birth.
     * @return List of SearchResult with potential duplicates and confidence scores.
     */
    @AuraEnabled
    public static List<SearchResult> checkDuplicates(
        String nric,
        String firstName,
        String lastName,
        Date dob
    ) {
        Map<Id, SearchResult> resultMap = new Map<Id, SearchResult>();

        if (String.isNotBlank(nric)) {
            String normalizedNric = nric.toUpperCase().trim();
            List<Account> nricMatches = [
                SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate,
                       PersonMobilePhone, PersonEmail, Ethnicity__c
                FROM Account
                WHERE NRIC__c = :normalizedNric
                AND IsPersonAccount = true
                WITH SECURITY_ENFORCED
                LIMIT 10
            ];

            for (Account a : nricMatches) {
                SearchResult sr = new SearchResult();
                sr.patient = a;
                sr.matchConfidence = 100;
                sr.matchReason = 'NRIC Exact Match';
                resultMap.put(a.Id, sr);
            }
        }

        if (String.isNotBlank(lastName)) {
            Set<String> nameVariants = DuplicateDetectionService.expandSearchTerms(lastName);

            List<Account> nameMatches = [
                SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate,
                       PersonMobilePhone, PersonEmail, Ethnicity__c
                FROM Account
                WHERE LastName IN :nameVariants
                AND IsPersonAccount = true
                WITH SECURITY_ENFORCED
                LIMIT 50
            ];

            for (Account a : nameMatches) {
                if (!resultMap.containsKey(a.Id)) {
                    Integer score = DuplicateDetectionService.calculateMatchScore(
                        a, nric, firstName, lastName, dob
                    );
                    if (score > 0) {
                        SearchResult sr = new SearchResult();
                        sr.patient = a;
                        sr.matchConfidence = score;
                        sr.matchReason = buildMatchReason(a, firstName, lastName, dob);
                        resultMap.put(a.Id, sr);
                    }
                }
            }
        }

        List<SearchResult> results = resultMap.values();
        results.sort();
        return results;
    }

    private static List<SearchResult> searchByNRIC(String nric) {
        String normalized = nric.toUpperCase().trim();

        if (!Pattern.matches(NRIC_PATTERN, normalized)) {
            throw new AuraHandledException('Invalid NRIC format. Expected format: S1234567A');
        }

        List<Account> matches = [
            SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate,
                   PersonMobilePhone, PersonEmail, Ethnicity__c
            FROM Account
            WHERE NRIC__c = :normalized
            AND IsPersonAccount = true
            WITH SECURITY_ENFORCED
            LIMIT 10
        ];

        List<SearchResult> results = new List<SearchResult>();
        for (Account a : matches) {
            SearchResult sr = new SearchResult();
            sr.patient = a;
            sr.matchConfidence = 100;
            sr.matchReason = 'NRIC Exact Match';
            results.add(sr);
        }
        return results;
    }

    private static List<SearchResult> searchByName(String name) {
        Set<String> expandedNames = DuplicateDetectionService.expandSearchTerms(name);

        List<Account> matches = [
            SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate,
                   PersonMobilePhone, PersonEmail, Ethnicity__c
            FROM Account
            WHERE (LastName IN :expandedNames OR FirstName IN :expandedNames)
            AND IsPersonAccount = true
            WITH SECURITY_ENFORCED
            LIMIT 50
        ];

        List<SearchResult> results = new List<SearchResult>();
        for (Account a : matches) {
            SearchResult sr = new SearchResult();
            sr.patient = a;
            sr.matchConfidence = calculateNameConfidence(a, name, expandedNames);
            sr.matchReason = 'Name Match';
            results.add(sr);
        }
        results.sort();
        return results;
    }

    private static List<SearchResult> searchByPhone(String phone) {
        String normalizedPhone = phone.trim().replaceAll('[^0-9+]', '');
        // Also try without country code prefix for +65 numbers
        String shortPhone = normalizedPhone.startsWith('+65')
            ? normalizedPhone.substring(3)
            : normalizedPhone;
        Set<String> phoneVariants = new Set<String>{ normalizedPhone, shortPhone };

        List<Account> matches = [
            SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate,
                   PersonMobilePhone, PersonEmail, Ethnicity__c
            FROM Account
            WHERE (PersonMobilePhone IN :phoneVariants OR Phone IN :phoneVariants)
            AND IsPersonAccount = true
            WITH SECURITY_ENFORCED
            LIMIT 10
        ];

        List<SearchResult> results = new List<SearchResult>();
        for (Account a : matches) {
            SearchResult sr = new SearchResult();
            sr.patient = a;
            sr.matchConfidence = 100;
            sr.matchReason = 'Phone Exact Match';
            results.add(sr);
        }
        return results;
    }

    private static Integer calculateNameConfidence(
        Account a, String searchName, Set<String> expandedNames
    ) {
        if (a.LastName != null && a.LastName.equalsIgnoreCase(searchName)) {
            return 90;
        }
        if (a.FirstName != null && a.FirstName.equalsIgnoreCase(searchName)) {
            return 90;
        }
        return 75;
    }

    private static String buildMatchReason(
        Account a, String firstName, String lastName, Date dob
    ) {
        List<String> reasons = new List<String>();

        if (String.isNotBlank(lastName) && a.LastName != null
            && a.LastName.equalsIgnoreCase(lastName)) {
            reasons.add('Last Name');
        }
        if (String.isNotBlank(firstName) && a.FirstName != null
            && a.FirstName.equalsIgnoreCase(firstName)) {
            reasons.add('First Name');
        }
        if (dob != null && a.PersonBirthdate != null && a.PersonBirthdate == dob) {
            reasons.add('DOB');
        }

        if (reasons.isEmpty()) {
            reasons.add('Name Variant');
        }

        return String.join(reasons, ' + ') + ' Match';
    }
}
