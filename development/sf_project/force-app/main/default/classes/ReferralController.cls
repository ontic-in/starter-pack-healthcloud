/**
 * @description Controller for Referral Wizard LWC (US-1.3.2).
 *              Thin controller that delegates business logic to ReferralService.
 */
public with sharing class ReferralController {

    /**
     * @description Returns patient context for the referral wizard.
     * @param accountId The patient Person Account ID.
     * @return PatientContext with demographics and clinical summary.
     */
    @AuraEnabled(cacheable=true)
    public static ReferralService.PatientContext getPatientContext(Id accountId) {
        try {
            return ReferralService.getPatientContext(accountId);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /**
     * @description Searches for providers by name and/or specialty.
     * @param searchTerm Optional name search term.
     * @param specialty Optional specialty filter.
     * @return List of matching ProviderOption records.
     */
    @AuraEnabled(cacheable=true)
    public static List<ReferralService.ProviderOption> searchProviders(
        String searchTerm, String specialty
    ) {
        try {
            return ReferralService.searchProviders(searchTerm, specialty);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /**
     * @description Returns specialty options for the filter dropdown.
     * @return List of PicklistOption records.
     */
    @AuraEnabled(cacheable=true)
    public static List<ReferralService.PicklistOption> getSpecialtyOptions() {
        try {
            return ReferralService.getSpecialtyOptions();
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /**
     * @description Submits a referral and sends notification to receiving provider.
     * @param requestJson JSON string of ReferralRequest fields.
     * @return ReferralResult with the created referral ID and status.
     */
    @AuraEnabled
    public static ReferralService.ReferralResult submitReferral(String requestJson) {
        try {
            return ReferralService.createReferral(requestJson);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }
}
