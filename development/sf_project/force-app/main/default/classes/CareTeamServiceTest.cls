/**
 * @description Tests for CareTeamService (US-1.2.3).
 */
@isTest
private class CareTeamServiceTest {

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @TestSetup
    static void setupTestData() {
        Account patient = TestDataFactory.createPatient('Care', 'TeamPatient', 'S1234567A');
        Account provider1 = TestDataFactory.createProvider('Dr. Primary Clinic');
        Account provider2 = TestDataFactory.createProvider('Dr. Specialist Clinic');
        Account provider3 = TestDataFactory.createProvider('Nurse Station Alpha');

        CareTeam team = TestDataFactory.createCareTeam(patient.Id, 'Active');
        TestDataFactory.createCareTeamMember(team.Id, provider1.Id, 'Primary_Physician', true);
    }

    // ── getCareTeamForPatient tests ──

    @isTest
    static void testGetCareTeamForPatient_WithExistingTeam() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE LastName = 'TeamPatient' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            CareTeamService.CareTeamDetail detail =
                CareTeamService.getCareTeamForPatient(patient.Id);
            Test.stopTest();

            Assert.isNotNull(detail.careTeam, 'CareTeam should exist');
            Assert.areEqual(1, detail.members.size(), 'Should have 1 active member');
            Assert.isTrue(detail.hasPrimaryPhysician, 'Should have a primary physician');
            Assert.areEqual('Dr. Primary Clinic', detail.members[0].providerName,
                'Provider name should match');
        }
    }

    @isTest
    static void testGetCareTeamForPatient_NoTeamExists() {
        User testUser = getTestUser();
        Account newPatient = TestDataFactory.createPatient('No', 'Team', 'S9999999Z');

        System.runAs(testUser) {
            Test.startTest();
            CareTeamService.CareTeamDetail detail =
                CareTeamService.getCareTeamForPatient(newPatient.Id);
            Test.stopTest();

            Assert.isNull(detail.careTeam, 'CareTeam should be null');
            Assert.areEqual(0, detail.members.size(), 'Members should be empty');
            Assert.isFalse(detail.hasPrimaryPhysician, 'No primary physician');
        }
    }

    // ── addTeamMember tests ──

    @isTest
    static void testAddTeamMember_Success() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE LastName = 'TeamPatient' LIMIT 1];
        Account provider2 = [SELECT Id FROM Account WHERE Name = 'Dr. Specialist Clinic' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            CareTeamMember member = CareTeamService.addTeamMember(
                patient.Id, provider2.Id, 'Specialist', false, 'All'
            );
            Test.stopTest();

            Assert.isNotNull(member.Id, 'Member should be inserted');
            Assert.areEqual('Specialist', member.Role, 'Role should be Specialist');
        }
    }

    @isTest
    static void testAddTeamMember_CreatesTeamIfNone() {
        User testUser = getTestUser();
        Account newPatient = TestDataFactory.createPatient('New', 'Patient', 'S8888888Y');
        Account provider = [SELECT Id FROM Account WHERE Name = 'Dr. Specialist Clinic' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            CareTeamMember member = CareTeamService.addTeamMember(
                newPatient.Id, provider.Id, 'Care_Coordinator', false, 'Critical Only'
            );
            Test.stopTest();

            Assert.isNotNull(member.Id, 'Member should be inserted');

            List<CareTeam> teams = [
                SELECT Id FROM CareTeam WHERE PatientId = :newPatient.Id AND Status = 'Active'
            ];
            Assert.areEqual(1, teams.size(), 'CareTeam should be auto-created');
        }
    }

    @isTest
    static void testAddTeamMember_PrimaryViolation() {
        User testUser = getTestUser();
        Account patient = [SELECT Id FROM Account WHERE LastName = 'TeamPatient' LIMIT 1];
        Account provider2 = [SELECT Id FROM Account WHERE Name = 'Dr. Specialist Clinic' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            try {
                CareTeamService.addTeamMember(
                    patient.Id, provider2.Id, 'Primary_Physician', true, 'All'
                );
                Assert.fail('Should have thrown exception for duplicate primary');
            } catch (AuraHandledException e) {
                Assert.isTrue(
                    e.getMessage().contains('primary physician'),
                    'Error should mention primary physician'
                );
            }
            Test.stopTest();
        }
    }

    // ── updateTeamMember tests ──

    @isTest
    static void testUpdateTeamMember_ChangeRole() {
        User testUser = getTestUser();
        CareTeamMember existing = [
            SELECT Id, Role FROM CareTeamMember
            WHERE Role = 'Primary_Physician' LIMIT 1
        ];

        System.runAs(testUser) {
            Test.startTest();
            CareTeamMember updated = CareTeamService.updateTeamMember(
                existing.Id, 'Specialist', 'Active', false, 'All'
            );
            Test.stopTest();

            CareTeamMember requeried = [SELECT Role FROM CareTeamMember WHERE Id = :existing.Id];
            Assert.areEqual('Specialist', requeried.Role, 'Role should be updated');
        }
    }

    @isTest
    static void testUpdateTeamMember_NotFound() {
        User testUser = getTestUser();
        // Use a fake ID that doesn't exist
        Id fakeId = CareTeamMember.SObjectType.getDescribe().getKeyPrefix() + '000000000000';

        System.runAs(testUser) {
            Test.startTest();
            try {
                CareTeamService.updateTeamMember(fakeId, 'Nurse', 'Active', false, 'All');
                Assert.fail('Should throw exception for missing member');
            } catch (AuraHandledException e) {
                Assert.isTrue(
                    e.getMessage().contains('not found'),
                    'Error should indicate member not found'
                );
            }
            Test.stopTest();
        }
    }

    // ── removeTeamMember tests ──

    @isTest
    static void testRemoveTeamMember_SoftDelete() {
        User testUser = getTestUser();
        CareTeamMember existing = [
            SELECT Id FROM CareTeamMember
            WHERE Role = 'Primary_Physician' LIMIT 1
        ];

        System.runAs(testUser) {
            Test.startTest();
            CareTeamService.removeTeamMember(existing.Id);
            Test.stopTest();

            CareTeamMember removed = [
                SELECT Status, PeriodEndDate FROM CareTeamMember WHERE Id = :existing.Id
            ];
            Assert.areEqual('Inactive', removed.Status, 'Status should be Inactive');
            Assert.areEqual(Date.today(), removed.PeriodEndDate, 'End date should be today');
        }
    }

    @isTest
    static void testRemoveTeamMember_NotFound() {
        User testUser = getTestUser();
        Id fakeId = CareTeamMember.SObjectType.getDescribe().getKeyPrefix() + '000000000000';

        System.runAs(testUser) {
            Test.startTest();
            try {
                CareTeamService.removeTeamMember(fakeId);
                Assert.fail('Should throw exception for missing member');
            } catch (AuraHandledException e) {
                Assert.isTrue(
                    e.getMessage().contains('not found'),
                    'Error should indicate member not found'
                );
            }
            Test.stopTest();
        }
    }

    // ── searchProviders tests ──

    @isTest
    static void testSearchProviders_ByName() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<CareTeamService.ProviderSearchResult> results =
                CareTeamService.searchProviders('Specialist');
            Test.stopTest();

            Assert.isTrue(results.size() >= 1, 'Should find at least 1 provider');
            Assert.areEqual('Dr. Specialist Clinic', results[0].name,
                'Should match specialist provider');
        }
    }

    @isTest
    static void testSearchProviders_ShortTerm() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<CareTeamService.ProviderSearchResult> results =
                CareTeamService.searchProviders('D');
            Test.stopTest();

            Assert.areEqual(0, results.size(),
                'Should return empty for search term less than 2 chars');
        }
    }

    @isTest
    static void testSearchProviders_WithPatientCount() {
        User testUser = getTestUser();

        System.runAs(testUser) {
            Test.startTest();
            List<CareTeamService.ProviderSearchResult> results =
                CareTeamService.searchProviders('Primary');
            Test.stopTest();

            Assert.isTrue(results.size() >= 1, 'Should find primary provider');
            Assert.areEqual(1, results[0].activePatientCount,
                'Primary provider should have 1 active patient');
        }
    }

    // ── validatePrimaryPhysicianRule tests ──

    @isTest
    static void testValidatePrimaryRule_NoExistingPrimary() {
        User testUser = getTestUser();
        Account newPatient = TestDataFactory.createPatient('Rule', 'Test', 'S7777777X');
        CareTeam team = TestDataFactory.createCareTeam(newPatient.Id, 'Active');

        System.runAs(testUser) {
            Test.startTest();
            // Should not throw
            CareTeamService.validatePrimaryPhysicianRule(team.Id, null);
            Test.stopTest();
        }
    }
}
