/**
 * @description Controller for Patient Merge workflow LWC (US-1.1.4).
 *              Provides merge preview with related record counts and
 *              merge execution with audit logging for compliance.
 */
public with sharing class PatientMergeController {

    /**
     * @description Wrapper for merge preview data showing both records
     *              and their related record counts.
     */
    public class MergePreview {
        @AuraEnabled public Account masterRecord;
        @AuraEnabled public Account duplicateRecord;
        @AuraEnabled public Integer masterConditionCount;
        @AuraEnabled public Integer masterMedicationCount;
        @AuraEnabled public Integer masterAllergyCount;
        @AuraEnabled public Integer masterInsuranceCount;
        @AuraEnabled public Integer duplicateConditionCount;
        @AuraEnabled public Integer duplicateMedicationCount;
        @AuraEnabled public Integer duplicateAllergyCount;
        @AuraEnabled public Integer duplicateInsuranceCount;
    }

    /**
     * @description Wrapper for merge operation result.
     */
    public class MergeResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public Id masterRecordId;
        @AuraEnabled public String auditLogId;
    }

    /**
     * @description Retrieves preview data for a potential merge operation.
     * @param masterAccountId The Id of the intended master (surviving) record.
     * @param duplicateAccountId The Id of the duplicate record to be merged.
     * @return MergePreview with both records and related record counts.
     * @throws AuraHandledException if either record is not found.
     */
    @AuraEnabled(cacheable=true)
    public static MergePreview getMergePreview(Id masterAccountId, Id duplicateAccountId) {
        List<Account> masters = [
            SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate,
                   PersonMobilePhone, PersonEmail, Ethnicity__c,
                   Emergency_Contact_Name__c, Emergency_Contact_Phone__c,
                   Emergency_Contact_Relationship__c
            FROM Account
            WHERE Id = :masterAccountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        List<Account> duplicates = [
            SELECT Id, FirstName, LastName, NRIC__c, PersonBirthdate,
                   PersonMobilePhone, PersonEmail, Ethnicity__c,
                   Emergency_Contact_Name__c, Emergency_Contact_Phone__c,
                   Emergency_Contact_Relationship__c
            FROM Account
            WHERE Id = :duplicateAccountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (masters.isEmpty() || duplicates.isEmpty()) {
            throw new AuraHandledException('One or both patient records not found.');
        }

        MergePreview preview = new MergePreview();
        preview.masterRecord = masters[0];
        preview.duplicateRecord = duplicates[0];

        preview.masterConditionCount = [
            SELECT COUNT() FROM HealthCondition
            WHERE PatientId = :masterAccountId WITH SECURITY_ENFORCED
        ];
        preview.masterMedicationCount = [
            SELECT COUNT() FROM MedicationStatement
            WHERE PatientId = :masterAccountId WITH SECURITY_ENFORCED
        ];
        preview.masterAllergyCount = [
            SELECT COUNT() FROM AllergyIntolerance
            WHERE PatientId = :masterAccountId WITH SECURITY_ENFORCED
        ];
        preview.masterInsuranceCount = [
            SELECT COUNT() FROM MemberPlan
            WHERE MemberId = :masterAccountId WITH SECURITY_ENFORCED
        ];

        preview.duplicateConditionCount = [
            SELECT COUNT() FROM HealthCondition
            WHERE PatientId = :duplicateAccountId WITH SECURITY_ENFORCED
        ];
        preview.duplicateMedicationCount = [
            SELECT COUNT() FROM MedicationStatement
            WHERE PatientId = :duplicateAccountId WITH SECURITY_ENFORCED
        ];
        preview.duplicateAllergyCount = [
            SELECT COUNT() FROM AllergyIntolerance
            WHERE PatientId = :duplicateAccountId WITH SECURITY_ENFORCED
        ];
        preview.duplicateInsuranceCount = [
            SELECT COUNT() FROM MemberPlan
            WHERE MemberId = :duplicateAccountId WITH SECURITY_ENFORCED
        ];

        return preview;
    }

    /**
     * @description Executes the merge of two patient records and creates an audit log.
     * @param masterAccountId The Id of the master (surviving) record.
     * @param duplicateAccountId The Id of the duplicate record to merge into master.
     * @param fieldsChanged JSON string describing which field values were changed.
     * @return MergeResult with success status and audit log reference.
     * @throws AuraHandledException for invalid inputs or merge failures.
     */
    @AuraEnabled
    public static MergeResult mergePatients(
        Id masterAccountId,
        Id duplicateAccountId,
        String fieldsChanged
    ) {
        if (masterAccountId == duplicateAccountId) {
            throw new AuraHandledException('Cannot merge a record with itself.');
        }

        List<Account> masters = [
            SELECT Id, FirstName, LastName, NRIC__c
            FROM Account
            WHERE Id = :masterAccountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        List<Account> duplicates = [
            SELECT Id, FirstName, LastName, NRIC__c
            FROM Account
            WHERE Id = :duplicateAccountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (masters.isEmpty() || duplicates.isEmpty()) {
            throw new AuraHandledException('One or both patient records not found.');
        }

        String duplicateIdStr = String.valueOf(duplicateAccountId);

        try {
            Database.merge(masters[0], duplicates[0]);
        } catch (DmlException e) {
            throw new AuraHandledException('Merge failed: ' + e.getMessage());
        }

        MergeAuditLog__c auditLog = new MergeAuditLog__c(
            Master_Record__c = masterAccountId,
            Merged_Record_Id__c = duplicateIdStr,
            Merged_By__c = UserInfo.getUserId(),
            Fields_Changed__c = fieldsChanged
        );
        insert auditLog;

        MergeResult result = new MergeResult();
        result.success = true;
        result.masterRecordId = masterAccountId;
        result.auditLogId = auditLog.Id;
        return result;
    }
}
