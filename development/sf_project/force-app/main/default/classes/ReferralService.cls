/**
 * @description Service class for Internal Referral business logic (US-1.3.2).
 *              Handles patient context retrieval, provider search, referral
 *              creation, and notification dispatch.
 */
public with sharing class ReferralService {

    private static final String ERROR_MISSING_PATIENT = 'Patient ID is required.';
    private static final String ERROR_MISSING_PROVIDER = 'Referred-to provider is required.';
    private static final String ERROR_MISSING_REASON = 'Referral reason is required.';
    private static final String ERROR_PATIENT_NOT_FOUND = 'Patient not found.';
    private static final String ERROR_PROVIDER_NOT_FOUND = 'Provider not found.';
    private static final String REFERRAL_INTENT = 'order';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_DRAFT = 'Draft';
    private static final String DISPLAY_SEPARATOR = ', ';
    private static final Integer CONDITION_LIMIT = 5;
    private static final Integer MEDICATION_LIMIT = 5;
    private static final Integer ALLERGY_LIMIT = 3;
    private static final Integer PROVIDER_SEARCH_LIMIT = 50;
    private static final Integer SPECIALTY_LIMIT = 200;
    private static final String NOTIFICATION_TITLE = 'New Referral Received';
    private static final String NOTIFICATION_BODY = 'A new patient referral has been assigned to you.';
    private static final String NOTIFICATION_TYPE_NAME = 'Referral_Notification';
    private static final String SUCCESS_MESSAGE = 'Referral created successfully.';
    private static final String PRIORITY_DEFAULT = 'Routine';
    private static final String LABEL_UNKNOWN = 'Unknown';

    // ── Inner Wrapper Classes ──

    /**
     * @description Input wrapper for referral creation from LWC.
     */
    public class ReferralRequest {
        @AuraEnabled public Id patientId;
        @AuraEnabled public Id referredToProviderId;
        @AuraEnabled public Id referringProviderId;
        @AuraEnabled public String reason;
        @AuraEnabled public String notes;
        @AuraEnabled public String priority;
        @AuraEnabled public String specialtyRequested;
    }

    /**
     * @description Auto-populated patient context for the referral wizard.
     */
    public class PatientContext {
        @AuraEnabled public Id patientId;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String fullName;
        @AuraEnabled public Date dateOfBirth;
        @AuraEnabled public String nric;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public List<ConditionSummary> conditions;
        @AuraEnabled public List<MedicationSummary> medications;
        @AuraEnabled public List<AllergySummary> allergies;
    }

    /**
     * @description Lightweight condition summary for patient context.
     */
    public class ConditionSummary {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String status;
        @AuraEnabled public String severity;
    }

    /**
     * @description Lightweight medication summary for patient context.
     */
    public class MedicationSummary {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String status;
    }

    /**
     * @description Lightweight allergy summary for patient context.
     */
    public class AllergySummary {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String severity;
    }

    /**
     * @description Provider option for the selection step.
     */
    public class ProviderOption {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String practitionerName;
        @AuraEnabled public String specialty;
        @AuraEnabled public String facility;
        @AuraEnabled public Boolean isAccepting;
    }

    /**
     * @description Picklist option wrapper for specialty dropdown.
     */
    public class PicklistOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

    /**
     * @description Result wrapper after referral creation.
     */
    public class ReferralResult {
        @AuraEnabled public Id referralId;
        @AuraEnabled public String status;
        @AuraEnabled public String message;
    }

    // ── Public Methods ──

    /**
     * @description Retrieves patient context for the referral wizard.
     * @param accountId The patient Person Account ID.
     * @return PatientContext with demographics, conditions, medications, allergies.
     */
    public static PatientContext getPatientContext(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException(ERROR_MISSING_PATIENT);
        }

        List<Account> patients = [
            SELECT Id, FirstName, LastName, PersonBirthdate, NRIC__c,
                   PersonEmail, PersonMobilePhone
            FROM Account
            WHERE Id = :accountId AND IsPersonAccount = true
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (patients.isEmpty()) {
            throw new AuraHandledException(ERROR_PATIENT_NOT_FOUND);
        }

        Account patient = patients[0];
        PatientContext ctx = new PatientContext();
        ctx.patientId = patient.Id;
        ctx.firstName = patient.FirstName;
        ctx.lastName = patient.LastName;
        ctx.fullName = patient.FirstName + ' ' + patient.LastName;
        ctx.dateOfBirth = patient.PersonBirthdate;
        ctx.nric = patient.NRIC__c;
        ctx.email = patient.PersonEmail;
        ctx.phone = patient.PersonMobilePhone;

        ctx.conditions = getActiveConditions(accountId);
        ctx.medications = getActiveMedications(accountId);
        ctx.allergies = getActiveAllergies(accountId);

        return ctx;
    }

    /**
     * @description Searches for providers by name and/or specialty.
     * @param searchTerm Optional name search term.
     * @param specialty Optional specialty filter.
     * @return List of matching ProviderOption records.
     */
    public static List<ProviderOption> searchProviders(String searchTerm, String specialty) {
        Set<Id> providerIdsBySpecialty = new Set<Id>();
        Boolean filterBySpecialty = String.isNotBlank(specialty);

        if (filterBySpecialty) {
            for (HealthcareProviderTaxonomy hpt : [
                SELECT HealthcareProviderId
                FROM HealthcareProviderTaxonomy
                WHERE Taxonomy.Name = :specialty
                WITH SECURITY_ENFORCED
            ]) {
                providerIdsBySpecialty.add(hpt.HealthcareProviderId);
            }
            if (providerIdsBySpecialty.isEmpty()) {
                return new List<ProviderOption>();
            }
        }

        String query = 'SELECT Id, Name, Practitioner.Name, Is_Accepting_Patients__c'
            + ' FROM HealthcareProvider'
            + ' WHERE IsActive = true';

        String searchPattern;
        if (String.isNotBlank(searchTerm)) {
            searchPattern = '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';
            query += ' AND (Name LIKE :searchPattern OR Practitioner.Name LIKE :searchPattern)';
        }

        if (filterBySpecialty) {
            query += ' AND Id IN :providerIdsBySpecialty';
        }

        query += ' WITH SECURITY_ENFORCED ORDER BY Name ASC LIMIT ' + PROVIDER_SEARCH_LIMIT;

        List<HealthcareProvider> providers = Database.query(query);

        Map<Id, List<String>> specialtiesByProvider = getSpecialtiesByProvider(providers);
        Map<Id, String> facilitiesByPractitioner = getFacilitiesByPractitioner(providers);

        List<ProviderOption> options = new List<ProviderOption>();
        for (HealthcareProvider hp : providers) {
            ProviderOption opt = new ProviderOption();
            opt.id = hp.Id;
            opt.name = hp.Name;
            opt.practitionerName = hp.Practitioner != null ? hp.Practitioner.Name : hp.Name;
            opt.isAccepting = hp.Is_Accepting_Patients__c;

            List<String> specs = specialtiesByProvider.get(hp.Id);
            opt.specialty = specs != null ? String.join(specs, DISPLAY_SEPARATOR) : '';

            String fac = facilitiesByPractitioner.get(hp.PractitionerId);
            opt.facility = fac != null ? fac : '';

            options.add(opt);
        }
        return options;
    }

    /**
     * @description Returns distinct specialty values for the filter dropdown.
     * @return List of PicklistOption records.
     */
    public static List<PicklistOption> getSpecialtyOptions() {
        List<PicklistOption> options = new List<PicklistOption>();
        for (CareTaxonomy ct : [
            SELECT Id, Name
            FROM CareTaxonomy
            WITH SECURITY_ENFORCED
            ORDER BY Name ASC
            LIMIT :SPECIALTY_LIMIT
        ]) {
            PicklistOption opt = new PicklistOption();
            opt.label = ct.Name;
            opt.value = ct.Name;
            options.add(opt);
        }
        return options;
    }

    /**
     * @description Creates a ClinicalServiceRequest referral record and sends notification.
     * @param requestJson JSON string of ReferralRequest fields.
     * @return ReferralResult with the created referral ID and status.
     */
    public static ReferralResult createReferral(String requestJson) {
        ReferralRequest request = (ReferralRequest) JSON.deserialize(
            requestJson, ReferralRequest.class
        );

        validateReferralRequest(request);

        ClinicalServiceRequest csr = new ClinicalServiceRequest();
        csr.PatientId = request.patientId;
        csr.Referred_To_Provider__c = request.referredToProviderId;
        csr.Referral_Reason__c = request.reason;
        csr.Referral_Notes__c = request.notes;
        csr.Priority = String.isNotBlank(request.priority) ? request.priority : PRIORITY_DEFAULT;
        csr.Specialty_Requested__c = request.specialtyRequested;
        csr.Status = STATUS_ACTIVE;
        csr.Intent = REFERRAL_INTENT;
        csr.AuthoredOn = DateTime.now();

        if (request.referringProviderId != null) {
            csr.RequesterId = request.referringProviderId;
        }

        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.CREATABLE, new List<ClinicalServiceRequest>{ csr }
        );
        insert decision.getRecords();
        ClinicalServiceRequest inserted = (ClinicalServiceRequest) decision.getRecords()[0];

        sendReferralNotification(inserted.Id, request.referredToProviderId);

        ReferralResult result = new ReferralResult();
        result.referralId = inserted.Id;
        result.status = STATUS_ACTIVE;
        result.message = SUCCESS_MESSAGE;
        return result;
    }

    // ── Private Helper Methods ──

    private static void validateReferralRequest(ReferralRequest request) {
        if (request.patientId == null) {
            throw new AuraHandledException(ERROR_MISSING_PATIENT);
        }
        if (request.referredToProviderId == null) {
            throw new AuraHandledException(ERROR_MISSING_PROVIDER);
        }
        if (String.isBlank(request.reason)) {
            throw new AuraHandledException(ERROR_MISSING_REASON);
        }
    }

    private static List<ConditionSummary> getActiveConditions(Id accountId) {
        List<ConditionSummary> summaries = new List<ConditionSummary>();
        for (HealthCondition hc : [
            SELECT Id, ProblemName, ConditionStatus, Severity
            FROM HealthCondition
            WHERE PatientId = :accountId AND ConditionStatus = :STATUS_ACTIVE
            WITH SECURITY_ENFORCED
            ORDER BY OnsetStartDateTime DESC
            LIMIT :CONDITION_LIMIT
        ]) {
            ConditionSummary cs = new ConditionSummary();
            cs.id = hc.Id;
            cs.name = hc.ProblemName;
            cs.status = hc.ConditionStatus;
            cs.severity = hc.Severity;
            summaries.add(cs);
        }
        return summaries;
    }

    private static List<MedicationSummary> getActiveMedications(Id accountId) {
        List<MedicationSummary> summaries = new List<MedicationSummary>();
        for (MedicationStatement ms : [
            SELECT Id, Medication.Name, Status
            FROM MedicationStatement
            WHERE PatientId = :accountId AND Status = :STATUS_ACTIVE
            WITH SECURITY_ENFORCED
            ORDER BY StartDateTime DESC
            LIMIT :MEDICATION_LIMIT
        ]) {
            MedicationSummary summary = new MedicationSummary();
            summary.id = ms.Id;
            summary.name = ms.Medication != null ? ms.Medication.Name : LABEL_UNKNOWN;
            summary.status = ms.Status;
            summaries.add(summary);
        }
        return summaries;
    }

    private static List<AllergySummary> getActiveAllergies(Id accountId) {
        List<AllergySummary> summaries = new List<AllergySummary>();
        for (AllergyIntolerance ai : [
            SELECT Id, Name, Severity
            FROM AllergyIntolerance
            WHERE PatientId = :accountId AND Status = :STATUS_ACTIVE
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT :ALLERGY_LIMIT
        ]) {
            AllergySummary as2 = new AllergySummary();
            as2.id = ai.Id;
            as2.name = ai.Name;
            as2.severity = ai.Severity;
            summaries.add(as2);
        }
        return summaries;
    }

    private static Map<Id, List<String>> getSpecialtiesByProvider(List<HealthcareProvider> providers) {
        Set<Id> providerIds = new Set<Id>();
        for (HealthcareProvider hp : providers) {
            providerIds.add(hp.Id);
        }

        Map<Id, List<String>> result = new Map<Id, List<String>>();
        for (HealthcareProviderTaxonomy hpt : [
            SELECT HealthcareProviderId, Taxonomy.Name
            FROM HealthcareProviderTaxonomy
            WHERE HealthcareProviderId IN :providerIds
            WITH SECURITY_ENFORCED
        ]) {
            if (!result.containsKey(hpt.HealthcareProviderId)) {
                result.put(hpt.HealthcareProviderId, new List<String>());
            }
            result.get(hpt.HealthcareProviderId).add(hpt.Taxonomy.Name);
        }
        return result;
    }

    private static Map<Id, String> getFacilitiesByPractitioner(List<HealthcareProvider> providers) {
        Set<Id> practitionerIds = new Set<Id>();
        for (HealthcareProvider hp : providers) {
            if (hp.PractitionerId != null) {
                practitionerIds.add(hp.PractitionerId);
            }
        }

        Map<Id, String> result = new Map<Id, String>();
        for (HealthcarePractitionerFacility hpf : [
            SELECT PractitionerId, Account.Name
            FROM HealthcarePractitionerFacility
            WHERE PractitionerId IN :practitionerIds AND IsActive = true
            WITH SECURITY_ENFORCED
        ]) {
            if (!result.containsKey(hpf.PractitionerId)) {
                result.put(hpf.PractitionerId, hpf.Account.Name);
            }
        }
        return result;
    }

    /**
     * @description Sends a custom notification to the receiving provider's user.
     *              Notification failure does not fail the referral creation.
     * @param referralId The ClinicalServiceRequest record ID.
     * @param providerId The receiving HealthcareProvider ID.
     */
    private static void sendReferralNotification(Id referralId, Id providerId) {
        try {
            List<HealthcareProvider> providers = [
                SELECT PractitionerId
                FROM HealthcareProvider
                WHERE Id = :providerId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if (providers.isEmpty() || providers[0].PractitionerId == null) {
                return;
            }

            Id contactId = providers[0].PractitionerId;
            List<User> users = [
                SELECT Id FROM User
                WHERE ContactId = :contactId AND IsActive = true
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            if (users.isEmpty()) {
                return;
            }

            CustomNotificationType notifType = [
                SELECT Id FROM CustomNotificationType
                WHERE DeveloperName = :NOTIFICATION_TYPE_NAME
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(NOTIFICATION_TITLE);
            notification.setBody(NOTIFICATION_BODY);
            notification.setNotificationTypeId(notifType.Id);
            notification.setTargetId(referralId);
            notification.send(new Set<String>{ users[0].Id });
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Referral notification failed: ' + e.getMessage());
        }
    }
}
