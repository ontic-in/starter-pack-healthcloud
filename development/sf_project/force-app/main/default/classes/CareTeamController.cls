/**
 * @description Thin controller for Care Team LWC components (US-1.2.3).
 *              Delegates all business logic to CareTeamService.
 */
public with sharing class CareTeamController {

    /**
     * @description Returns the care team and active members for a patient.
     * @param patientAccountId The patient Account ID.
     * @return CareTeamDetail wrapper with team and member list.
     */
    @AuraEnabled(cacheable=true)
    public static CareTeamService.CareTeamDetail getCareTeamForPatient(Id patientAccountId) {
        try {
            return CareTeamService.getCareTeamForPatient(patientAccountId);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Adds a new member to the patient's care team.
     * @param patientAccountId The patient Account ID.
     * @param providerAccountId The provider Account ID.
     * @param role Care team role.
     * @param isPrimary Whether this is the primary physician.
     * @param notificationPref Notification preference.
     * @return The inserted CareTeamMember record.
     */
    @AuraEnabled
    public static CareTeamMember addTeamMember(
        Id patientAccountId,
        Id providerAccountId,
        String role,
        Boolean isPrimary,
        String notificationPref
    ) {
        try {
            return CareTeamService.addTeamMember(
                patientAccountId, providerAccountId, role, isPrimary, notificationPref
            );
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Updates an existing care team member.
     * @param memberId The CareTeamMember record ID.
     * @param role Updated role.
     * @param status Updated status.
     * @param isPrimary Updated primary flag.
     * @param notificationPref Updated notification preference.
     * @return The updated CareTeamMember record.
     */
    @AuraEnabled
    public static CareTeamMember updateTeamMember(
        Id memberId,
        String role,
        String status,
        Boolean isPrimary,
        String notificationPref
    ) {
        try {
            return CareTeamService.updateTeamMember(
                memberId, role, status, isPrimary, notificationPref
            );
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Removes a care team member (sets to Inactive).
     * @param memberId The CareTeamMember record ID.
     */
    @AuraEnabled
    public static void removeTeamMember(Id memberId) {
        try {
            CareTeamService.removeTeamMember(memberId);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Searches provider accounts by name.
     * @param searchTerm Name search string (minimum 2 characters).
     * @return List of matching providers with active patient counts.
     */
    @AuraEnabled(cacheable=true)
    public static List<CareTeamService.ProviderSearchResult> searchProviders(String searchTerm) {
        try {
            return CareTeamService.searchProviders(searchTerm);
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
