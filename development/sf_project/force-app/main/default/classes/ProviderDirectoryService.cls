/**
 * @description Service class for Provider Directory business logic (US-1.3.1).
 *              Handles provider search, filtering, and detail retrieval.
 *              Uses separate queries instead of subqueries to avoid
 *              child relationship name dependency on HC standard objects.
 */
public with sharing class ProviderDirectoryService {

    private static final String ERROR_PROVIDER_NOT_FOUND = 'Provider not found.';
    private static final Integer SEARCH_LIMIT = 200;
    private static final Integer PICKLIST_LIMIT = 500;
    private static final String DISPLAY_SEPARATOR = ', ';
    private static final String MULTISELECT_DELIMITER = ';';

    /**
     * @description Search criteria wrapper for provider search.
     */
    public class SearchCriteria {
        @AuraEnabled public String searchTerm;
        @AuraEnabled public List<String> specialtyNames;
        @AuraEnabled public List<String> facilityNames;
        @AuraEnabled public List<String> languages;
        @AuraEnabled public Boolean acceptingPatientsOnly;
    }

    /**
     * @description Flattened provider result for LWC display.
     */
    public class ProviderSearchResult {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String mcrNumber;
        @AuraEnabled public String practitionerName;
        @AuraEnabled public String specialtyDisplay;
        @AuraEnabled public String facilityDisplay;
        @AuraEnabled public String languagesDisplay;
        @AuraEnabled public Integer patientLoad;
        @AuraEnabled public DateTime nextAvailableSlot;
        @AuraEnabled public Boolean acceptingPatients;
        @AuraEnabled public Boolean isActive;
    }

    /**
     * @description Full provider detail with specialty and facility lists.
     */
    public class ProviderDetail {
        @AuraEnabled public HealthcareProvider provider;
        @AuraEnabled public String practitionerName;
        @AuraEnabled public String practitionerEmail;
        @AuraEnabled public String practitionerPhone;
        @AuraEnabled public List<String> specialties;
        @AuraEnabled public List<String> facilities;
    }

    /**
     * @description Generic picklist option for comboboxes.
     */
    public class PicklistOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public PicklistOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    /**
     * @description Searches providers based on criteria (name, specialty, facility, language, accepting).
     *              Uses separate pre-queries for specialty and facility filtering to avoid
     *              dependency on child relationship API names.
     * @param criteria SearchCriteria wrapper with filter parameters.
     * @return List of ProviderSearchResult wrappers.
     */
    public static List<ProviderSearchResult> searchProviders(SearchCriteria criteria) {
        Set<Id> providerIdsBySpecialty = null;
        Set<Id> practitionerIdsByFacility = null;

        // Pre-query: filter by specialty if specified
        if (criteria.specialtyNames != null && !criteria.specialtyNames.isEmpty()) {
            providerIdsBySpecialty = new Set<Id>();
            List<HealthcareProviderTaxonomy> taxonomies = [
                SELECT HealthcareProviderId
                FROM HealthcareProviderTaxonomy
                WHERE TaxonomyId IN (
                    SELECT Id FROM CareTaxonomy
                    WHERE Name IN :criteria.specialtyNames
                )
                WITH SECURITY_ENFORCED
            ];
            for (HealthcareProviderTaxonomy t : taxonomies) {
                providerIdsBySpecialty.add(t.HealthcareProviderId);
            }
            if (providerIdsBySpecialty.isEmpty()) {
                return new List<ProviderSearchResult>();
            }
        }

        // Pre-query: filter by facility if specified
        if (criteria.facilityNames != null && !criteria.facilityNames.isEmpty()) {
            practitionerIdsByFacility = new Set<Id>();
            List<HealthcarePractitionerFacility> pracFacilities = [
                SELECT PractitionerId
                FROM HealthcarePractitionerFacility
                WHERE AccountId IN (
                    SELECT Id FROM Account
                    WHERE Name IN :criteria.facilityNames
                )
                WITH SECURITY_ENFORCED
            ];
            for (HealthcarePractitionerFacility pf : pracFacilities) {
                practitionerIdsByFacility.add(pf.PractitionerId);
            }
            if (practitionerIdsByFacility.isEmpty()) {
                return new List<ProviderSearchResult>();
            }
        }

        // Build main query
        String query = 'SELECT Id, Name, MCR_Number__c, PractitionerId, '
            + 'Practitioner.Name, Languages__c, Current_Patient_Load__c, '
            + 'Next_Available_Slot__c, Is_Accepting_Patients__c, IsActive '
            + 'FROM HealthcareProvider '
            + 'WHERE IsActive = true ';

        // Name search
        String searchPattern;
        if (String.isNotBlank(criteria.searchTerm)) {
            searchPattern = '%' + String.escapeSingleQuotes(criteria.searchTerm.trim()) + '%';
            query += 'AND (Name LIKE :searchPattern OR Practitioner.Name LIKE :searchPattern '
                + 'OR MCR_Number__c LIKE :searchPattern) ';
        }

        // Specialty filter (from pre-query)
        if (providerIdsBySpecialty != null) {
            query += 'AND Id IN :providerIdsBySpecialty ';
        }

        // Facility filter (from pre-query)
        if (practitionerIdsByFacility != null) {
            query += 'AND PractitionerId IN :practitionerIdsByFacility ';
        }

        // Language filter (multi-select picklist INCLUDES)
        if (criteria.languages != null && !criteria.languages.isEmpty()) {
            List<String> languageClauses = new List<String>();
            for (String lang : criteria.languages) {
                languageClauses.add('Languages__c INCLUDES (\'' + String.escapeSingleQuotes(lang) + '\')');
            }
            query += 'AND (' + String.join(languageClauses, ' OR ') + ') ';
        }

        // Accepting patients filter
        if (criteria.acceptingPatientsOnly == true) {
            query += 'AND Is_Accepting_Patients__c = true ';
        }

        query += 'WITH SECURITY_ENFORCED ORDER BY Name ASC LIMIT ' + SEARCH_LIMIT;

        List<HealthcareProvider> providers = Database.query(query);

        if (providers.isEmpty()) {
            return new List<ProviderSearchResult>();
        }

        // Collect IDs for post-queries
        Set<Id> providerIds = new Set<Id>();
        Set<Id> practitionerIds = new Set<Id>();
        for (HealthcareProvider p : providers) {
            providerIds.add(p.Id);
            if (p.PractitionerId != null) {
                practitionerIds.add(p.PractitionerId);
            }
        }

        // Post-query: specialties per provider
        Map<Id, List<String>> specialtiesByProvider = getSpecialtiesByProvider(providerIds);

        // Post-query: facilities per practitioner
        Map<Id, List<String>> facilitiesByPractitioner = getFacilitiesByPractitioner(practitionerIds);

        // Build results
        List<ProviderSearchResult> results = new List<ProviderSearchResult>();
        for (HealthcareProvider p : providers) {
            ProviderSearchResult result = new ProviderSearchResult();
            result.id = p.Id;
            result.name = p.Name;
            result.mcrNumber = p.MCR_Number__c;
            result.practitionerName = p.Practitioner != null ? p.Practitioner.Name : null;
            result.languagesDisplay = formatMultiSelect(p.Languages__c);
            result.patientLoad = p.Current_Patient_Load__c != null
                ? p.Current_Patient_Load__c.intValue() : 0;
            result.nextAvailableSlot = p.Next_Available_Slot__c;
            result.acceptingPatients = p.Is_Accepting_Patients__c;
            result.isActive = p.IsActive;

            List<String> specs = specialtiesByProvider.get(p.Id);
            result.specialtyDisplay = specs != null ? String.join(specs, DISPLAY_SEPARATOR) : '';

            List<String> facs = facilitiesByPractitioner.get(p.PractitionerId);
            result.facilityDisplay = facs != null ? String.join(facs, DISPLAY_SEPARATOR) : '';

            results.add(result);
        }

        return results;
    }

    /**
     * @description Returns distinct active specialties for filter picklist.
     * @return List of PicklistOption wrappers.
     */
    public static List<PicklistOption> getSpecialtyPicklistValues() {
        List<CareSpecialty> specialties = [
            SELECT Id, Name
            FROM CareSpecialty
            WHERE IsActive = true
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC
            LIMIT :PICKLIST_LIMIT
        ];

        List<PicklistOption> options = new List<PicklistOption>();
        for (CareSpecialty s : specialties) {
            options.add(new PicklistOption(s.Name, s.Name));
        }
        return options;
    }

    /**
     * @description Returns distinct facility names for filter picklist.
     * @return List of PicklistOption wrappers.
     */
    public static List<PicklistOption> getFacilityPicklistValues() {
        List<Account> facilities = [
            SELECT Id, Name
            FROM Account
            WHERE Id IN (
                SELECT AccountId FROM HealthcarePractitionerFacility
                WHERE IsActive = true
            )
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC
            LIMIT :PICKLIST_LIMIT
        ];

        List<PicklistOption> options = new List<PicklistOption>();
        for (Account a : facilities) {
            options.add(new PicklistOption(a.Name, a.Name));
        }
        return options;
    }

    /**
     * @description Returns full provider detail with specialties and facilities.
     * @param providerId The HealthcareProvider record ID.
     * @return ProviderDetail wrapper.
     * @throws AuraHandledException if provider not found.
     */
    public static ProviderDetail getProviderDetail(Id providerId) {
        List<HealthcareProvider> providers = [
            SELECT Id, Name, MCR_Number__c, PractitionerId,
                   Practitioner.Name, Practitioner.Email, Practitioner.Phone,
                   Languages__c, Current_Patient_Load__c,
                   Next_Available_Slot__c, Is_Accepting_Patients__c, IsActive
            FROM HealthcareProvider
            WHERE Id = :providerId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (providers.isEmpty()) {
            AuraHandledException e = new AuraHandledException(ERROR_PROVIDER_NOT_FOUND);
            e.setMessage(ERROR_PROVIDER_NOT_FOUND);
            throw e;
        }

        HealthcareProvider provider = providers[0];
        ProviderDetail detail = new ProviderDetail();
        detail.provider = provider;
        detail.practitionerName = provider.Practitioner != null ? provider.Practitioner.Name : null;
        detail.practitionerEmail = provider.Practitioner != null ? provider.Practitioner.Email : null;
        detail.practitionerPhone = provider.Practitioner != null ? provider.Practitioner.Phone : null;

        Map<Id, List<String>> specMap = getSpecialtiesByProvider(new Set<Id>{ providerId });
        detail.specialties = specMap.containsKey(providerId) ? specMap.get(providerId) : new List<String>();

        Set<Id> practIds = new Set<Id>();
        if (provider.PractitionerId != null) {
            practIds.add(provider.PractitionerId);
        }
        Map<Id, List<String>> facMap = getFacilitiesByPractitioner(practIds);
        detail.facilities = facMap.containsKey(provider.PractitionerId)
            ? facMap.get(provider.PractitionerId) : new List<String>();

        return detail;
    }

    // ──────────────────────────────────────────────
    // Private helpers
    // ──────────────────────────────────────────────

    /**
     * @description Queries specialties for a set of provider IDs via HealthcareProviderTaxonomy.
     */
    private static Map<Id, List<String>> getSpecialtiesByProvider(Set<Id> providerIds) {
        Map<Id, List<String>> result = new Map<Id, List<String>>();
        if (providerIds == null || providerIds.isEmpty()) {
            return result;
        }

        List<HealthcareProviderTaxonomy> taxonomies = [
            SELECT HealthcareProviderId, TaxonomyId, CareTaxonomy.Name
            FROM HealthcareProviderTaxonomy
            WHERE HealthcareProviderId IN :providerIds
            WITH SECURITY_ENFORCED
        ];

        for (HealthcareProviderTaxonomy t : taxonomies) {
            String specName = t.CareTaxonomy != null ? t.CareTaxonomy.Name : null;
            if (String.isBlank(specName)) {
                continue;
            }
            if (!result.containsKey(t.HealthcareProviderId)) {
                result.put(t.HealthcareProviderId, new List<String>());
            }
            result.get(t.HealthcareProviderId).add(specName);
        }

        return result;
    }

    /**
     * @description Queries facilities for a set of practitioner IDs via HealthcarePractitionerFacility.
     */
    private static Map<Id, List<String>> getFacilitiesByPractitioner(Set<Id> practitionerIds) {
        Map<Id, List<String>> result = new Map<Id, List<String>>();
        if (practitionerIds == null || practitionerIds.isEmpty()) {
            return result;
        }

        List<HealthcarePractitionerFacility> pracFacilities = [
            SELECT PractitionerId, AccountId, Account.Name
            FROM HealthcarePractitionerFacility
            WHERE PractitionerId IN :practitionerIds
            AND IsActive = true
            WITH SECURITY_ENFORCED
        ];

        for (HealthcarePractitionerFacility pf : pracFacilities) {
            String facName = pf.Account != null ? pf.Account.Name : null;
            if (String.isBlank(facName)) {
                continue;
            }
            if (!result.containsKey(pf.PractitionerId)) {
                result.put(pf.PractitionerId, new List<String>());
            }
            result.get(pf.PractitionerId).add(facName);
        }

        return result;
    }

    /**
     * @description Formats a multi-select picklist value for display (semicolons to commas).
     */
    private static String formatMultiSelect(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        return value.replace(MULTISELECT_DELIMITER, DISPLAY_SEPARATOR);
    }
}
