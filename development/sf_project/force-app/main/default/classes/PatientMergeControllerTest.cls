/**
 * @description Test class for PatientMergeController (US-1.1.4).
 *              Tests merge preview, execution, audit logging, and error handling
 *              for patient record deduplication.
 */
@isTest
private class PatientMergeControllerTest {

    @TestSetup
    static void setupTestData() {
        List<Account> patients = TestDataFactory.createPatientsForSearchTests();

        Account masterPatient = patients[0];
        TestDataFactory.createHealthCondition(
            masterPatient.Id, 'Hypertension', 'Active', 'Moderate',
            DateTime.newInstance(2023, 1, 15, 0, 0, 0)
        );
    }

    @isTest
    static void testGetMergePreview() {
        List<Account> patients = [
            SELECT Id FROM Account WHERE IsPersonAccount = true ORDER BY NRIC__c LIMIT 2
        ];
        Id masterId = patients[0].Id;
        Id duplicateId = patients[1].Id;

        Test.startTest();
        PatientMergeController.MergePreview preview =
            PatientMergeController.getMergePreview(masterId, duplicateId);
        Test.stopTest();

        Assert.isNotNull(preview.masterRecord, 'Master record should be populated');
        Assert.isNotNull(preview.duplicateRecord, 'Duplicate record should be populated');
        Assert.isNotNull(preview.masterConditionCount, 'Condition count should be set');
    }

    @isTest
    static void testMergePatients_Success() {
        List<Account> patients = [
            SELECT Id, NRIC__c FROM Account WHERE IsPersonAccount = true ORDER BY NRIC__c LIMIT 2
        ];
        Id masterId = patients[0].Id;
        Id duplicateId = patients[1].Id;
        String duplicateIdStr = String.valueOf(duplicateId);

        Test.startTest();
        PatientMergeController.MergeResult result =
            PatientMergeController.mergePatients(masterId, duplicateId, '{"NRIC__c": "kept master value"}');
        Test.stopTest();

        Assert.isTrue(result.success, 'Merge should succeed');
        Assert.areEqual(masterId, result.masterRecordId, 'Should return master record Id');

        List<Account> remaining = [
            SELECT Id FROM Account WHERE Id = :duplicateId
        ];
        Assert.isTrue(remaining.isEmpty(), 'Duplicate record should no longer exist');
    }

    @isTest
    static void testMergePatients_AuditLogCreated() {
        List<Account> patients = [
            SELECT Id FROM Account WHERE IsPersonAccount = true ORDER BY NRIC__c LIMIT 2
        ];
        Id masterId = patients[0].Id;
        Id duplicateId = patients[1].Id;

        Test.startTest();
        PatientMergeController.MergeResult result =
            PatientMergeController.mergePatients(masterId, duplicateId, '{"test": "data"}');
        Test.stopTest();

        Assert.isNotNull(result.auditLogId, 'Audit log Id should be returned');

        List<MergeAuditLog__c> logs = [
            SELECT Id, Master_Record__c, Merged_Record_Id__c, Merged_By__c, Fields_Changed__c
            FROM MergeAuditLog__c
            WHERE Id = :result.auditLogId
        ];
        Assert.areEqual(1, logs.size(), 'One audit log should be created');
        Assert.areEqual(masterId, logs[0].Master_Record__c, 'Audit should reference master');
    }

    @isTest
    static void testMergePatients_SameRecord() {
        List<Account> patients = [
            SELECT Id FROM Account WHERE IsPersonAccount = true LIMIT 1
        ];
        Id sameId = patients[0].Id;

        Test.startTest();
        try {
            PatientMergeController.mergePatients(sameId, sameId, '{}');
            Assert.fail('Should throw exception for same record merge');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Cannot merge'),
                'Error should indicate merge not possible');
        }
        Test.stopTest();
    }

    @isTest
    static void testMergePatients_InvalidId() {
        String fakeId = Account.SObjectType.getDescribe().getKeyPrefix() + '000000000000';

        Test.startTest();
        try {
            PatientMergeController.mergePatients(fakeId, fakeId, '{}');
            Assert.fail('Should throw exception for invalid Id');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'Should have error message');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetMergePreview_InvalidId() {
        String fakeId = Account.SObjectType.getDescribe().getKeyPrefix() + '000000000000';

        Test.startTest();
        try {
            PatientMergeController.getMergePreview(fakeId, fakeId);
            Assert.fail('Should throw exception for invalid Id');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('not found'),
                'Error should indicate record not found');
        }
        Test.stopTest();
    }
}
