/**
 * @description Tests for CareTeamController (US-1.2.3).
 */
@isTest
private class CareTeamControllerTest {

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @TestSetup
    static void setupTestData() {
        Account patient = TestDataFactory.createPatient('Ctrl', 'Patient', 'S2345678B');
        Account provider = TestDataFactory.createProvider('Dr. Controller Test');

        CareTeam team = TestDataFactory.createCareTeam(patient.Id, 'Active');
        TestDataFactory.createCareTeamMember(team.Id, provider.Id, 'Nurse', false);
    }

    @isTest
    static void testGetCareTeamForPatient() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE LastName = 'Patient' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            CareTeamService.CareTeamDetail detail =
                CareTeamController.getCareTeamForPatient(patient.Id);
            Test.stopTest();

            Assert.isNotNull(detail, 'Detail should not be null');
            Assert.areEqual(1, detail.members.size(), 'Should have 1 member');
        }
    }

    @isTest
    static void testAddTeamMember() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE LastName = 'Patient' LIMIT 1];
        Account newProvider = TestDataFactory.createProvider('Dr. New Provider');

        System.runAs(testUser) {
            Test.startTest();
            CareTeamMember member = CareTeamController.addTeamMember(
                patient.Id, newProvider.Id, 'Specialist', false, 'All'
            );
            Test.stopTest();

            Assert.isNotNull(member.Id, 'Member should be created');
        }
    }

    @isTest
    static void testUpdateTeamMember() {
        User testUser = getTestUser();
        CareTeamMember existing = [SELECT Id FROM CareTeamMember WHERE Role = 'Nurse' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            CareTeamMember updated = CareTeamController.updateTeamMember(
                existing.Id, 'Care_Coordinator', 'Active', false, 'Critical Only'
            );
            Test.stopTest();

            Assert.isNotNull(updated, 'Updated member should not be null');
        }
    }

    @isTest
    static void testRemoveTeamMember() {
        User testUser = getTestUser();
        CareTeamMember existing = [SELECT Id FROM CareTeamMember WHERE Role = 'Nurse' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            CareTeamController.removeTeamMember(existing.Id);
            Test.stopTest();

            CareTeamMember removed = [
                SELECT Status FROM CareTeamMember WHERE Id = :existing.Id
            ];
            Assert.areEqual('Inactive', removed.Status, 'Should be inactive');
        }
    }

    @isTest
    static void testSearchProviders() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<CareTeamService.ProviderSearchResult> results =
                CareTeamController.searchProviders('Controller');
            Test.stopTest();

            Assert.isTrue(results.size() >= 1, 'Should find at least 1 provider');
        }
    }

    @isTest
    static void testAddTeamMember_ErrorHandling() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE LastName = 'Patient' LIMIT 1];
        Account provider = [SELECT Id FROM Account WHERE Name = 'Dr. Controller Test' LIMIT 1];

        // First add a primary physician
        CareTeamController.addTeamMember(
            patient.Id, provider.Id, 'Primary_Physician', true, 'All'
        );

        Account newProvider = TestDataFactory.createProvider('Dr. Duplicate Primary');

        System.runAs(testUser) {
            Test.startTest();
            try {
                CareTeamController.addTeamMember(
                    patient.Id, newProvider.Id, 'Primary_Physician', true, 'All'
                );
                Assert.fail('Should throw AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(
                    e.getMessage().contains('primary physician'),
                    'Should contain primary physician error'
                );
            }
            Test.stopTest();
        }
    }
}
