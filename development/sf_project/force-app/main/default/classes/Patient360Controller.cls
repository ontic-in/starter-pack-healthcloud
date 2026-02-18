/**
 * @description Controller for Patient 360 LWC component (US-1.1.2).
 *              Returns unified patient data including demographics, conditions,
 *              medications, allergies, and insurance in a single call.
 */
public with sharing class Patient360Controller {

    /**
     * @description Wrapper class containing all Patient 360 data sections.
     */
    public class Patient360Data {
        @AuraEnabled public Account demographics;
        @AuraEnabled public List<HealthCondition> conditions;
        @AuraEnabled public List<MedicationStatement> medications;
        @AuraEnabled public List<AllergyIntolerance> allergies;
        @AuraEnabled public List<MemberPlan> insurance;
    }

    /**
     * @description Retrieves all Patient 360 data for the given Account ID.
     * @param accountId The Account (Person Account) record ID
     * @return Patient360Data wrapper with all sections populated
     * @throws AuraHandledException if account not found or query fails
     */
    @AuraEnabled(cacheable=true)
    public static Patient360Data getPatient360Data(Id accountId) {
        Patient360Data result = new Patient360Data();

        List<Account> accounts = [
            SELECT Id, FirstName, LastName, PersonBirthdate, PersonEmail,
                   PersonMobilePhone, NRIC__c, Ethnicity__c,
                   Emergency_Contact_Name__c, Emergency_Contact_Phone__c,
                   Emergency_Contact_Relationship__c
            FROM Account
            WHERE Id = :accountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (accounts.isEmpty()) {
            throw new AuraHandledException('Patient record not found.');
        }

        result.demographics = accounts[0];

        result.conditions = [
            SELECT Id, ProblemName, ConditionStatus, Severity,
                   OnsetStartDateTime, DiagnosticStatus
            FROM HealthCondition
            WHERE PatientId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY OnsetStartDateTime DESC
            LIMIT 50
        ];

        result.medications = [
            SELECT Id, Name, Status, StartDateTime, EndDateTime,
                   MedicationId, Medication.Name
            FROM MedicationStatement
            WHERE PatientId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY StartDateTime DESC
            LIMIT 50
        ];

        result.allergies = [
            SELECT Id, Name, Type, Severity, Status, Category
            FROM AllergyIntolerance
            WHERE PatientId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];

        result.insurance = [
            SELECT Id, Name, MemberNumber, Status, Medisave_Balance__c,
                   EffectiveFrom, EffectiveTo
            FROM MemberPlan
            WHERE MemberId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];

        return result;
    }
}
