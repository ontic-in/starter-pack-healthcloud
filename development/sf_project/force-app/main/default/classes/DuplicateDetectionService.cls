/**
 * @description Service class for patient duplicate detection (US-1.1.4).
 *              Provides name variant lookup using NameVariant__mdt custom metadata,
 *              match confidence scoring, and search term expansion for Singapore
 *              multilingual name transliterations.
 */
public with sharing class DuplicateDetectionService {

    /**
     * @description Retrieves all known name variants for a given name.
     *              Searches both Standard_Form__c and Variants__c in NameVariant__mdt.
     * @param name The name to look up variants for.
     * @return List of all variant forms including the standard form. Returns just
     *         the original name if no variants are found.
     */
    public static List<String> getNameVariants(String name) {
        if (String.isBlank(name)) {
            return new List<String>();
        }

        String searchName = name.trim();
        Set<String> allVariants = new Set<String>();

        List<NameVariant__mdt> standardMatches = [
            SELECT Standard_Form__c, Variants__c
            FROM NameVariant__mdt
            WHERE Standard_Form__c = :searchName
            WITH SECURITY_ENFORCED
        ];

        for (NameVariant__mdt nv : standardMatches) {
            allVariants.add(nv.Standard_Form__c);
            if (String.isNotBlank(nv.Variants__c)) {
                for (String v : nv.Variants__c.split(',')) {
                    allVariants.add(v.trim());
                }
            }
        }

        if (allVariants.isEmpty()) {
            List<NameVariant__mdt> allRecords = [
                SELECT Standard_Form__c, Variants__c
                FROM NameVariant__mdt
                WITH SECURITY_ENFORCED
            ];

            for (NameVariant__mdt nv : allRecords) {
                Set<String> variantSet = new Set<String>();
                variantSet.add(nv.Standard_Form__c.toLowerCase());
                if (String.isNotBlank(nv.Variants__c)) {
                    for (String v : nv.Variants__c.split(',')) {
                        variantSet.add(v.trim().toLowerCase());
                    }
                }

                if (variantSet.contains(searchName.toLowerCase())) {
                    allVariants.add(nv.Standard_Form__c);
                    if (String.isNotBlank(nv.Variants__c)) {
                        for (String v : nv.Variants__c.split(',')) {
                            allVariants.add(v.trim());
                        }
                    }
                    break;
                }
            }
        }

        if (allVariants.isEmpty()) {
            return new List<String>{ searchName };
        }

        return new List<String>(allVariants);
    }

    /**
     * @description Calculates a match confidence score between a candidate Account
     *              and the provided search criteria.
     * @param candidate The existing Account record to compare against.
     * @param nric NRIC to match.
     * @param firstName First name to match.
     * @param lastName Last name to match.
     * @param dob Date of birth to match.
     * @return Integer score from 0-100. 100 = definitive NRIC match.
     */
    public static Integer calculateMatchScore(
        Account candidate,
        String nric,
        String firstName,
        String lastName,
        Date dob
    ) {
        Integer score = 0;

        if (String.isNotBlank(nric) && String.isNotBlank(candidate.NRIC__c)
            && candidate.NRIC__c.equalsIgnoreCase(nric)) {
            return 100;
        }

        if (String.isNotBlank(lastName) && String.isNotBlank(candidate.LastName)) {
            if (candidate.LastName.equalsIgnoreCase(lastName)) {
                score += 25;
            } else {
                List<String> lastNameVariants = getNameVariants(lastName);
                for (String variant : lastNameVariants) {
                    if (candidate.LastName.equalsIgnoreCase(variant)) {
                        score += 20;
                        break;
                    }
                }
            }
        }

        if (String.isNotBlank(firstName) && String.isNotBlank(candidate.FirstName)) {
            if (candidate.FirstName.equalsIgnoreCase(firstName)) {
                score += 25;
            }
        }

        if (dob != null && candidate.PersonBirthdate != null
            && candidate.PersonBirthdate == dob) {
            score += 30;
        }

        return Math.min(score, 100);
    }

    /**
     * @description Expands a search name to include all known variant forms.
     *              Used to build inclusive SOQL LIKE clauses for fuzzy name search.
     * @param name The name to expand.
     * @return Set of all variant forms including the original name.
     */
    public static Set<String> expandSearchTerms(String name) {
        if (String.isBlank(name)) {
            return new Set<String>();
        }

        List<String> variants = getNameVariants(name.trim());
        return new Set<String>(variants);
    }
}
