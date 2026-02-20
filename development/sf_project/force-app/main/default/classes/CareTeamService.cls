/**
 * @description Service layer for Care Team operations (US-1.2.3).
 *              Handles CRUD on CareTeam/CareTeamMember, primary physician
 *              validation, provider search, and assignment notifications.
 */
public with sharing class CareTeamService {

    private static final Integer QUERY_LIMIT = 50;
    private static final Integer SEARCH_LIMIT = 20;
    private static final Integer MIN_SEARCH_LENGTH = 2;
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_INACTIVE = 'Inactive';
    private static final String DEFAULT_NOTIFICATION_PREF = 'All';
    private static final String DEFAULT_CARE_TEAM_NAME = 'Care Team';
    private static final String NOTIF_TYPE_CARE_TEAM = 'Care_Team_Assignment';
    private static final String NOTIF_ACTION_ADDED = 'ADDED';
    private static final String NOTIF_ACTION_REMOVED = 'REMOVED';
    private static final String ERR_MEMBER_NOT_FOUND = 'Care team member not found.';
    private static final String ERR_PRIMARY_EXISTS =
        'This care team already has a primary physician. ' +
        'Please remove the existing primary before assigning a new one.';

    // ── Wrapper classes ──

    public class CareTeamDetail {
        @AuraEnabled public CareTeam careTeam;
        @AuraEnabled public List<CareTeamMemberDetail> members;
        @AuraEnabled public Boolean hasPrimaryPhysician;
    }

    public class CareTeamMemberDetail {
        @AuraEnabled public Id memberId;
        @AuraEnabled public Id providerAccountId;
        @AuraEnabled public String providerName;
        @AuraEnabled public String providerPhone;
        @AuraEnabled public String role;
        @AuraEnabled public String status;
        @AuraEnabled public Boolean isPrimary;
        @AuraEnabled public String notificationPref;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
    }

    public class ProviderSearchResult {
        @AuraEnabled public Id accountId;
        @AuraEnabled public String name;
        @AuraEnabled public String phone;
        @AuraEnabled public Integer activePatientCount;
    }

    // ── Public methods ──

    /**
     * @description Gets or creates a CareTeam for the patient and returns all active members.
     * @param patientAccountId The patient Account ID.
     * @return CareTeamDetail wrapper with team and member list.
     */
    public static CareTeamDetail getCareTeamForPatient(Id patientAccountId) {
        CareTeamDetail detail = new CareTeamDetail();
        detail.members = new List<CareTeamMemberDetail>();
        detail.hasPrimaryPhysician = false;

        List<CareTeam> teams = [
            SELECT Id, Name, Status
            FROM CareTeam
            WHERE PatientId = :patientAccountId
            AND Status = :STATUS_ACTIVE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (teams.isEmpty()) {
            detail.careTeam = null;
            return detail;
        }

        detail.careTeam = teams[0];

        List<CareTeamMember> members = [
            SELECT Id, AccountId, Account.Name, Account.Phone,
                   Role, Status, Is_Primary__c, Notification_Pref__c,
                   PeriodStartDate, PeriodEndDate
            FROM CareTeamMember
            WHERE CareTeamId = :detail.careTeam.Id
            AND Status = :STATUS_ACTIVE
            WITH SECURITY_ENFORCED
            ORDER BY Is_Primary__c DESC, Role ASC
            LIMIT :QUERY_LIMIT
        ];

        for (CareTeamMember m : members) {
            CareTeamMemberDetail md = new CareTeamMemberDetail();
            md.memberId = m.Id;
            md.providerAccountId = m.AccountId;
            md.providerName = m.Account != null ? m.Account.Name : '';
            md.providerPhone = m.Account != null ? m.Account.Phone : '';
            md.role = m.Role;
            md.status = m.Status;
            md.isPrimary = m.Is_Primary__c;
            md.notificationPref = m.Notification_Pref__c;
            md.startDate = m.PeriodStartDate;
            md.endDate = m.PeriodEndDate;
            if (m.Is_Primary__c) {
                detail.hasPrimaryPhysician = true;
            }
            detail.members.add(md);
        }

        return detail;
    }

    /**
     * @description Adds a new member to the patient's care team.
     *              Creates the CareTeam if it does not exist.
     * @param patientAccountId The patient Account ID.
     * @param providerAccountId The provider Account ID.
     * @param role Care team role (e.g. Primary_Physician).
     * @param isPrimary Whether this is the primary physician.
     * @param notificationPref Notification preference value.
     * @return The inserted CareTeamMember record.
     */
    public static CareTeamMember addTeamMember(
        Id patientAccountId,
        Id providerAccountId,
        String role,
        Boolean isPrimary,
        String notificationPref
    ) {
        CareTeam team = getOrCreateCareTeam(patientAccountId);

        if (isPrimary) {
            validatePrimaryPhysicianRule(team.Id, null);
        }

        CareTeamMember member = new CareTeamMember(
            CareTeamId = team.Id,
            AccountId = providerAccountId,
            Role = role,
            Status = STATUS_ACTIVE,
            Is_Primary__c = isPrimary,
            Notification_Pref__c = notificationPref != null ? notificationPref : DEFAULT_NOTIFICATION_PREF,
            PeriodStartDate = Date.today()
        );

        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.CREATABLE, new List<CareTeamMember>{ member }
        );
        insert decision.getRecords();
        CareTeamMember inserted = (CareTeamMember) decision.getRecords()[0];

        sendAssignmentNotification(providerAccountId, patientAccountId, role, NOTIF_ACTION_ADDED);

        return inserted;
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
    public static CareTeamMember updateTeamMember(
        Id memberId,
        String role,
        String status,
        Boolean isPrimary,
        String notificationPref
    ) {
        List<CareTeamMember> existing = [
            SELECT Id, CareTeamId, AccountId, Role, Status,
                   Is_Primary__c, Notification_Pref__c
            FROM CareTeamMember
            WHERE Id = :memberId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (existing.isEmpty()) {
            AuraHandledException ex = new AuraHandledException(ERR_MEMBER_NOT_FOUND);
            ex.setMessage(ERR_MEMBER_NOT_FOUND);
            throw ex;
        }

        CareTeamMember member = existing[0];

        if (isPrimary && !member.Is_Primary__c) {
            validatePrimaryPhysicianRule(member.CareTeamId, member.Id);
        }

        member.Role = role;
        member.Status = status;
        member.Is_Primary__c = isPrimary;
        member.Notification_Pref__c = notificationPref;

        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.UPDATABLE, new List<CareTeamMember>{ member }
        );
        update decision.getRecords();
        return (CareTeamMember) decision.getRecords()[0];
    }

    /**
     * @description Soft-removes a care team member by setting status to Inactive.
     * @param memberId The CareTeamMember record ID.
     */
    public static void removeTeamMember(Id memberId) {
        List<CareTeamMember> existing = [
            SELECT Id, AccountId, CareTeamId, Role
            FROM CareTeamMember
            WHERE Id = :memberId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (existing.isEmpty()) {
            AuraHandledException ex = new AuraHandledException(ERR_MEMBER_NOT_FOUND);
            ex.setMessage(ERR_MEMBER_NOT_FOUND);
            throw ex;
        }

        CareTeamMember member = existing[0];
        Id providerAccountId = member.AccountId;
        String role = member.Role;

        member.Status = STATUS_INACTIVE;
        member.PeriodEndDate = Date.today();

        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.UPDATABLE, new List<CareTeamMember>{ member }
        );
        update decision.getRecords();

        // Look up patient from CareTeam
        List<CareTeam> teams = [
            SELECT PatientId FROM CareTeam
            WHERE Id = :existing[0].CareTeamId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!teams.isEmpty()) {
            sendAssignmentNotification(providerAccountId, teams[0].PatientId, role, NOTIF_ACTION_REMOVED);
        }
    }

    /**
     * @description Searches provider accounts by name.
     * @param searchTerm Name search string.
     * @return List of matching providers with active patient counts.
     */
    public static List<ProviderSearchResult> searchProviders(String searchTerm) {
        List<ProviderSearchResult> results = new List<ProviderSearchResult>();

        if (String.isBlank(searchTerm) || searchTerm.length() < MIN_SEARCH_LENGTH) {
            return results;
        }

        String likePattern = '%' + String.escapeSingleQuotes(searchTerm) + '%';

        List<Account> providers = [
            SELECT Id, Name, Phone
            FROM Account
            WHERE Name LIKE :likePattern
            AND IsPersonAccount = false
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC
            LIMIT :SEARCH_LIMIT
        ];

        if (providers.isEmpty()) {
            return results;
        }

        Set<Id> providerIds = new Set<Id>();
        for (Account a : providers) {
            providerIds.add(a.Id);
        }

        Map<Id, Integer> patientCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT AccountId, COUNT(Id) cnt
            FROM CareTeamMember
            WHERE AccountId IN :providerIds
            AND Status = :STATUS_ACTIVE
            WITH SECURITY_ENFORCED
            GROUP BY AccountId
        ]) {
            patientCounts.put((Id) ar.get('AccountId'), (Integer) ar.get('cnt'));
        }

        for (Account a : providers) {
            ProviderSearchResult r = new ProviderSearchResult();
            r.accountId = a.Id;
            r.name = a.Name;
            r.phone = a.Phone;
            r.activePatientCount = patientCounts.containsKey(a.Id)
                ? patientCounts.get(a.Id) : 0;
            results.add(r);
        }

        return results;
    }

    // ── Private helpers ──

    private static CareTeam getOrCreateCareTeam(Id patientAccountId) {
        List<CareTeam> existing = [
            SELECT Id, Name, Status
            FROM CareTeam
            WHERE PatientId = :patientAccountId
            AND Status = :STATUS_ACTIVE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (!existing.isEmpty()) {
            return existing[0];
        }

        CareTeam team = new CareTeam(
            PatientId = patientAccountId,
            Name = DEFAULT_CARE_TEAM_NAME,
            Status = STATUS_ACTIVE
        );

        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.CREATABLE, new List<CareTeam>{ team }
        );
        insert decision.getRecords();
        return (CareTeam) decision.getRecords()[0];
    }

    @TestVisible
    private static void validatePrimaryPhysicianRule(Id careTeamId, Id excludeMemberId) {
        Integer existingCount;
        if (excludeMemberId != null) {
            existingCount = [
                SELECT COUNT()
                FROM CareTeamMember
                WHERE CareTeamId = :careTeamId
                AND Is_Primary__c = true
                AND Status = :STATUS_ACTIVE
                AND Id != :excludeMemberId
            ];
        } else {
            existingCount = [
                SELECT COUNT()
                FROM CareTeamMember
                WHERE CareTeamId = :careTeamId
                AND Is_Primary__c = true
                AND Status = :STATUS_ACTIVE
            ];
        }

        if (existingCount > 0) {
            AuraHandledException ex = new AuraHandledException(ERR_PRIMARY_EXISTS);
            ex.setMessage(ERR_PRIMARY_EXISTS);
            throw ex;
        }
    }

    @TestVisible
    private static void sendAssignmentNotification(
        Id providerAccountId, Id patientAccountId, String role, String notificationType
    ) {
        try {
            List<Account> patients = [
                SELECT Name FROM Account
                WHERE Id = :patientAccountId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (patients.isEmpty()) {
                return;
            }

            String patientName = patients[0].Name;
            String title;
            String body;

            if (notificationType == NOTIF_ACTION_ADDED) {
                title = 'New Care Team Assignment';
                body = 'You have been added to the care team for '
                    + patientName + ' as ' + role.replace('_', ' ') + '.';
            } else {
                title = 'Removed from Care Team';
                body = 'You have been removed from the care team for '
                    + patientName + '.';
            }

            List<CustomNotificationType> notifTypes = [
                SELECT Id FROM CustomNotificationType
                WHERE DeveloperName = :NOTIF_TYPE_CARE_TEAM
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if (notifTypes.isEmpty()) {
                return;
            }

            // Find User linked to provider Account
            List<User> users = [
                SELECT Id FROM User
                WHERE AccountId = :providerAccountId
                AND IsActive = true
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            if (users.isEmpty()) {
                return;
            }

            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notifTypes[0].Id);
            notification.setTargetId(patientAccountId);
            notification.send(new Set<String>{ users[0].Id });
        } catch (Exception e) {
            // Best-effort notification - log but don't fail the operation
            System.debug(LoggingLevel.WARN, 'Care team notification failed: ' + e.getMessage());
        }
    }
}
