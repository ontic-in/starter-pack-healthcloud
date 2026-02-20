/**
 * @description Controller for Provider Directory LWC component (US-1.3.1).
 *              Thin controller that delegates business logic to ProviderDirectoryService.
 */
public with sharing class ProviderDirectoryController {

    /**
     * @description Searches providers based on filter criteria.
     * @param criteriaJson JSON string of SearchCriteria fields.
     * @return List of ProviderSearchResult wrappers.
     */
    @AuraEnabled(cacheable=true)
    public static List<ProviderDirectoryService.ProviderSearchResult> searchProviders(String criteriaJson) {
        try {
            ProviderDirectoryService.SearchCriteria criteria;
            if (String.isBlank(criteriaJson)) {
                criteria = new ProviderDirectoryService.SearchCriteria();
            } else {
                criteria = (ProviderDirectoryService.SearchCriteria) JSON.deserialize(
                    criteriaJson, ProviderDirectoryService.SearchCriteria.class
                );
            }
            return ProviderDirectoryService.searchProviders(criteria);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /**
     * @description Returns specialty options for filter combobox.
     * @return List of PicklistOption wrappers.
     */
    @AuraEnabled(cacheable=true)
    public static List<ProviderDirectoryService.PicklistOption> getSpecialtyOptions() {
        try {
            return ProviderDirectoryService.getSpecialtyPicklistValues();
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /**
     * @description Returns facility options for filter combobox.
     * @return List of PicklistOption wrappers.
     */
    @AuraEnabled(cacheable=true)
    public static List<ProviderDirectoryService.PicklistOption> getFacilityOptions() {
        try {
            return ProviderDirectoryService.getFacilityPicklistValues();
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /**
     * @description Returns full provider detail with specialties and facilities.
     * @param providerId The HealthcareProvider record ID.
     * @return ProviderDetail wrapper.
     */
    @AuraEnabled(cacheable=true)
    public static ProviderDirectoryService.ProviderDetail getProviderDetail(Id providerId) {
        try {
            return ProviderDirectoryService.getProviderDetail(providerId);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }
}
