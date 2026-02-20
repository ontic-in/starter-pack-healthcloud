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
    @AuraEnabled
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

        Set<Id> bothIds = new Set<Id>{ masterAccountId, duplicateAccountId };

        Map<Id, Integer> conditionCounts = new Map<Id, Integer>();
        Map<Id, Integer> medicationCounts = new Map<Id, Integer>();
        Map<Id, Integer> allergyCounts = new Map<Id, Integer>();
        Map<Id, Integer> insuranceCounts = new Map<Id, Integer>();

        for (AggregateResult ar : [
            SELECT PatientId, COUNT(Id) cnt FROM HealthCondition
            WHERE PatientId IN :bothIds WITH SECURITY_ENFORCED GROUP BY PatientId
        ]) {
            conditionCounts.put((Id) ar.get('PatientId'), (Integer) ar.get('cnt'));
        }
        for (AggregateResult ar : [
            SELECT PatientId, COUNT(Id) cnt FROM MedicationStatement
            WHERE PatientId IN :bothIds WITH SECURITY_ENFORCED GROUP BY PatientId
        ]) {
            medicationCounts.put((Id) ar.get('PatientId'), (Integer) ar.get('cnt'));
        }
        for (AggregateResult ar : [
            SELECT PatientId, COUNT(Id) cnt FROM AllergyIntolerance
            WHERE PatientId IN :bothIds WITH SECURITY_ENFORCED GROUP BY PatientId
        ]) {
            allergyCounts.put((Id) ar.get('PatientId'), (Integer) ar.get('cnt'));
        }
        for (AggregateResult ar : [
            SELECT MemberId, COUNT(Id) cnt FROM MemberPlan
            WHERE MemberId IN :bothIds WITH SECURITY_ENFORCED GROUP BY MemberId
        ]) {
            insuranceCounts.put((Id) ar.get('MemberId'), (Integer) ar.get('cnt'));
        }

        preview.masterConditionCount = conditionCounts.containsKey(masterAccountId) ? conditionCounts.get(masterAccountId) : 0;
        preview.masterMedicationCount = medicationCounts.containsKey(masterAccountId) ? medicationCounts.get(masterAccountId) : 0;
        preview.masterAllergyCount = allergyCounts.containsKey(masterAccountId) ? allergyCounts.get(masterAccountId) : 0;
        preview.masterInsuranceCount = insuranceCounts.containsKey(masterAccountId) ? insuranceCounts.get(masterAccountId) : 0;

        preview.duplicateConditionCount = conditionCounts.containsKey(duplicateAccountId) ? conditionCounts.get(duplicateAccountId) : 0;
        preview.duplicateMedicationCount = medicationCounts.containsKey(duplicateAccountId) ? medicationCounts.get(duplicateAccountId) : 0;
        preview.duplicateAllergyCount = allergyCounts.containsKey(duplicateAccountId) ? allergyCounts.get(duplicateAccountId) : 0;
        preview.duplicateInsuranceCount = insuranceCounts.containsKey(duplicateAccountId) ? insuranceCounts.get(duplicateAccountId) : 0;

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
            SELECT Id, FirstName, LastName, NRIC__c
            FROM Account
            WHERE Id = :duplicateAccountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (masters.isEmpty() || duplicates.isEmpty()) {
            throw new AuraHandledException('One or both patient records not found.');
        }

        Account masterRecord = masters[0];
        String duplicateIdStr = String.valueOf(duplicateAccountId);

        // Apply selected field values from the compare step to the master record
        if (String.isNotBlank(fieldsChanged) && fieldsChanged != '{}') {
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(fieldsChanged);
            Map<String, Schema.SObjectField> fieldDescribeMap = Schema.SObjectType.Account.fields.getMap();

            for (String fieldName : fieldMap.keySet()) {
                Object fieldValue = fieldMap.get(fieldName);
                if (fieldValue == null) {
                    continue;
                }
                String strValue = String.valueOf(fieldValue);
                if (strValue == '-') {
                    continue;
                }

                Schema.SObjectField sField = fieldDescribeMap.get(fieldName);
                if (sField != null) {
                    Schema.DisplayType fieldType = sField.getDescribe().getType();
                    if (fieldType == Schema.DisplayType.DATE) {
                        masterRecord.put(fieldName, Date.valueOf(strValue));
                    } else if (fieldType == Schema.DisplayType.DATETIME) {
                        masterRecord.put(fieldName, DateTime.valueOf(strValue));
                    } else if (fieldType == Schema.DisplayType.DOUBLE
                            || fieldType == Schema.DisplayType.CURRENCY
                            || fieldType == Schema.DisplayType.PERCENT) {
                        masterRecord.put(fieldName, Decimal.valueOf(strValue));
                    } else if (fieldType == Schema.DisplayType.INTEGER) {
                        masterRecord.put(fieldName, Integer.valueOf(strValue));
                    } else if (fieldType == Schema.DisplayType.BOOLEAN) {
                        masterRecord.put(fieldName, Boolean.valueOf(strValue));
                    } else {
                        masterRecord.put(fieldName, strValue);
                    }
                } else {
                    masterRecord.put(fieldName, strValue);
                }
            }
            update masterRecord;
        }

        Savepoint sp = Database.setSavepoint();
        try {
            Database.merge(masterRecord, duplicates[0]);

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
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException('Merge failed: ' + e.getMessage());
        }
    }
}
