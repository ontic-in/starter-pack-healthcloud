/**
 * @description Reusable test data factory for Patient 360 Health Cloud tests.
 *              Centralizes creation of Person Account patients and related
 *              clinical/insurance records used across multiple test classes.
 */
@isTest
public class TestDataFactory {

    /**
     * @description Creates and inserts a Person Account patient with minimal fields.
     * @param firstName Patient first name.
     * @param lastName Patient last name.
     * @param nric NRIC value (must be unique).
     * @return The inserted Account record.
     */
    public static Account createPatient(String firstName, String lastName, String nric) {
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Person Account').getRecordTypeId();

        Account patient = new Account(
            RecordTypeId = personAccountRTId,
            FirstName = firstName,
            LastName = lastName,
            NRIC__c = nric
        );
        insert patient;
        return patient;
    }

    /**
     * @description Creates and inserts a Person Account patient with additional field overrides.
     *              Pass an Account with extra fields set; they will be merged onto the base patient.
     * @param firstName Patient first name.
     * @param lastName Patient last name.
     * @param nric NRIC value.
     * @param overrides An Account instance with additional fields to set (not inserted).
     * @return The inserted Account record.
     */
    public static Account createPatientWithDetails(
        String firstName,
        String lastName,
        String nric,
        Account overrides
    ) {
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Person Account').getRecordTypeId();

        Account patient = new Account(
            RecordTypeId = personAccountRTId,
            FirstName = firstName,
            LastName = lastName,
            NRIC__c = nric
        );

        // Apply overrides
        if (overrides.PersonBirthdate != null) { patient.PersonBirthdate = overrides.PersonBirthdate; }
        if (overrides.PersonEmail != null) { patient.PersonEmail = overrides.PersonEmail; }
        if (overrides.PersonMobilePhone != null) { patient.PersonMobilePhone = overrides.PersonMobilePhone; }
        if (overrides.Ethnicity__c != null) { patient.Ethnicity__c = overrides.Ethnicity__c; }
        if (overrides.Emergency_Contact_Name__c != null) { patient.Emergency_Contact_Name__c = overrides.Emergency_Contact_Name__c; }
        if (overrides.Emergency_Contact_Phone__c != null) { patient.Emergency_Contact_Phone__c = overrides.Emergency_Contact_Phone__c; }
        if (overrides.Emergency_Contact_Relationship__c != null) { patient.Emergency_Contact_Relationship__c = overrides.Emergency_Contact_Relationship__c; }

        insert patient;
        return patient;
    }

    /**
     * @description Creates and inserts a HealthCondition linked to a patient.
     * @param patientId The patient Account Id.
     * @param problemName Name of the condition.
     * @param status Condition status (e.g. Active).
     * @param severity Condition severity.
     * @param onsetDate When the condition started.
     * @return The inserted HealthCondition record.
     */
    public static HealthCondition createHealthCondition(
        Id patientId,
        String problemName,
        String status,
        String severity,
        DateTime onsetDate
    ) {
        HealthCondition condition = new HealthCondition(
            PatientId = patientId,
            ProblemName = problemName,
            ConditionStatus = status,
            Severity = severity,
            OnsetStartDateTime = onsetDate
        );
        insert condition;
        return condition;
    }

    /**
     * @description Creates and inserts a Medication and MedicationStatement linked to a patient.
     * @param patientId The patient Account Id.
     * @param medicationName Name of the medication.
     * @param status Statement status (e.g. Active).
     * @param startDate When the medication started.
     * @return The inserted MedicationStatement record.
     */
    public static MedicationStatement createMedicationStatement(
        Id patientId,
        String medicationName,
        String status,
        DateTime startDate
    ) {
        Medication med = new Medication(Name = medicationName);
        insert med;

        MedicationStatement statement = new MedicationStatement(
            PatientId = patientId,
            MedicationId = med.Id,
            Status = status,
            StartDateTime = startDate
        );
        insert statement;
        return statement;
    }

    /**
     * @description Creates and inserts an AllergyIntolerance linked to a patient.
     * @param patientId The patient Account Id.
     * @param allergyType Type value (e.g. Allergy).
     * @param severity Severity level.
     * @param status Allergy status (e.g. Active).
     * @return The inserted AllergyIntolerance record.
     */
    public static AllergyIntolerance createAllergyIntolerance(
        Id patientId,
        String allergyType,
        String severity,
        String status
    ) {
        AllergyIntolerance allergy = new AllergyIntolerance(
            PatientId = patientId,
            Type = allergyType,
            Severity = severity,
            Status = status
        );
        insert allergy;
        return allergy;
    }

    /**
     * @description Creates and inserts a MemberPlan (insurance) linked to a patient.
     * @param patientId The patient Account Id.
     * @param planName Name of the insurance plan.
     * @param memberNumber Member number.
     * @param status Plan status.
     * @param medisaveBalance Medisave balance amount.
     * @return The inserted MemberPlan record.
     */
    public static MemberPlan createMemberPlan(
        Id patientId,
        String planName,
        String memberNumber,
        String status,
        Decimal medisaveBalance
    ) {
        MemberPlan plan = new MemberPlan(
            MemberId = patientId,
            Name = planName,
            MemberNumber = memberNumber,
            Status = status,
            Medisave_Balance__c = medisaveBalance
        );
        insert plan;
        return plan;
    }

    /**
     * @description Creates and inserts a ClinicalEncounter linked to a patient.
     * @param patientId The patient Account Id.
     * @param status Encounter status (e.g. finished).
     * @param category Encounter category (e.g. encounter).
     * @param startDate When the encounter started.
     * @param endDate When the encounter ended.
     * @return The inserted ClinicalEncounter record.
     */
    public static ClinicalEncounter createClinicalEncounter(
        Id patientId,
        String status,
        String category,
        DateTime startDate,
        DateTime endDate
    ) {
        ClinicalEncounter encounter = new ClinicalEncounter(
            PatientId = patientId,
            Status = status,
            Category = category,
            StartDate = startDate,
            EndDate = endDate
        );
        insert encounter;
        return encounter;
    }

    /**
     * @description Creates and inserts a Task linked to a patient account.
     * @param accountId The patient Account Id (set as WhatId).
     * @param subject Task subject.
     * @param status Task status (e.g. Completed).
     * @param activityDate Task due date.
     * @return The inserted Task record.
     */
    public static Task createTask(
        Id accountId,
        String subject,
        String status,
        Date activityDate
    ) {
        Task t = new Task(
            WhatId = accountId,
            Subject = subject,
            Status = status,
            ActivityDate = activityDate
        );
        insert t;
        return t;
    }

    /**
     * @description Creates and inserts a Case linked to a patient account.
     * @param accountId The patient Account Id.
     * @param subject Case subject.
     * @param status Case status (e.g. Closed).
     * @return The inserted Case record.
     */
    public static Case createCase(
        Id accountId,
        String subject,
        String status
    ) {
        Case c = new Case(
            AccountId = accountId,
            Subject = subject,
            Status = status
        );
        insert c;
        return c;
    }

    // ── Care Plan Template factories (US-1.2.1) ──

    /**
     * @description Creates and inserts a CarePlanTemplate with custom fields.
     * @param name Template name.
     * @param icd10Code ICD-10 condition code.
     * @param version Template version number.
     * @return The inserted CarePlanTemplate record.
     */
    public static CarePlanTemplate createCarePlanTemplate(
        String name, String icd10Code, Integer version
    ) {
        CarePlanTemplate template = new CarePlanTemplate(
            Name = name,
            ICD10_Code__c = icd10Code,
            Version__c = version,
            IsActive = true
        );
        insert template;
        return template;
    }

    /**
     * @description Creates and inserts a CarePlanTemplateGoal with custom fields.
     * @param templateId Parent template ID.
     * @param goalName Goal name.
     * @param targetValue Target value string.
     * @param measure Measurement method.
     * @param reviewFrequency Review frequency picklist value.
     * @return The inserted CarePlanTemplateGoal record.
     */
    public static CarePlanTemplateGoal createCarePlanTemplateGoal(
        Id templateId, String goalName, String targetValue,
        String measure, String reviewFrequency
    ) {
        CarePlanTemplateGoal goal = new CarePlanTemplateGoal(
            CarePlanTemplateId = templateId,
            Name = goalName,
            Target_Value__c = targetValue,
            Measure__c = measure,
            Review_Frequency__c = reviewFrequency
        );
        insert goal;
        return goal;
    }

    /**
     * @description Creates and inserts a CarePlanTemplateTask with custom fields.
     * @param templateId Parent template ID.
     * @param taskName Task subject.
     * @param assignedRole Role picklist value.
     * @param taskFrequency Frequency picklist value.
     * @param priority Task priority.
     * @return The inserted CarePlanTemplateTask record.
     */
    public static CarePlanTemplateTask createCarePlanTemplateTask(
        Id templateId, String taskName, String assignedRole,
        String taskFrequency, String priority
    ) {
        CarePlanTemplateTask task = new CarePlanTemplateTask(
            CarePlanTemplateId = templateId,
            Subject = taskName,
            Assigned_Role__c = assignedRole,
            Task_Frequency__c = taskFrequency,
            Priority = priority
        );
        insert task;
        return task;
    }

    // ── Provider Directory factories (US-1.3.1) ──

    /**
     * @description Creates and inserts a HealthcareProvider linked to a practitioner Contact.
     * @param practitionerId The Contact Id for the practitioner.
     * @param name Provider name.
     * @param mcrNumber MCR registration number.
     * @param languages Multi-select picklist value (semicolon-separated).
     * @param patientLoad Current patient load count.
     * @param accepting Whether the provider is accepting new patients.
     * @return The inserted HealthcareProvider record.
     */
    public static HealthcareProvider createHealthcareProvider(
        Id practitionerId, String name, String mcrNumber,
        String languages, Integer patientLoad, Boolean accepting
    ) {
        HealthcareProvider provider = new HealthcareProvider(
            PractitionerId = practitionerId,
            Name = name,
            MCR_Number__c = mcrNumber,
            Languages__c = languages,
            Current_Patient_Load__c = patientLoad,
            Is_Accepting_Patients__c = accepting,
            Next_Available_Slot__c = DateTime.now().addDays(3),
            IsActive = true
        );
        insert provider;
        return provider;
    }

    /**
     * @description Creates and inserts a CareSpecialty record.
     * @param name Specialty name.
     * @param specialtyCode Specialty code value.
     * @return The inserted CareSpecialty record.
     */
    public static CareSpecialty createCareSpecialty(String name, String specialtyCode) {
        CareSpecialty specialty = new CareSpecialty(
            Name = name,
            SpecialtyCode = specialtyCode,
            IsActive = true
        );
        insert specialty;
        return specialty;
    }

    /**
     * @description Creates and inserts a CareTaxonomy record.
     * @param name Taxonomy name.
     * @return The inserted CareTaxonomy record.
     */
    public static CareTaxonomy createCareTaxonomy(String name) {
        CareTaxonomy taxonomy = new CareTaxonomy(
            Name = name
        );
        insert taxonomy;
        return taxonomy;
    }

    /**
     * @description Creates and inserts a HealthcareProviderTaxonomy junction record.
     * @param healthcareProviderId The HealthcareProvider Id.
     * @param taxonomyId The CareTaxonomy Id.
     * @return The inserted HealthcareProviderTaxonomy record.
     */
    public static HealthcareProviderTaxonomy createProviderTaxonomy(
        Id healthcareProviderId, Id taxonomyId
    ) {
        HealthcareProviderTaxonomy provTaxonomy = new HealthcareProviderTaxonomy(
            HealthcareProviderId = healthcareProviderId,
            TaxonomyId = taxonomyId
        );
        insert provTaxonomy;
        return provTaxonomy;
    }

    /**
     * @description Creates and inserts a basic Account for use as a facility.
     * @param name Facility name.
     * @return The inserted Account record.
     */
    public static Account createFacilityAccount(String name) {
        Account facility = new Account(
            Name = name
        );
        insert facility;
        return facility;
    }

    /**
     * @description Creates and inserts a HealthcarePractitionerFacility junction record.
     * @param practitionerId The practitioner Contact Id.
     * @param accountId The facility Account Id.
     * @return The inserted HealthcarePractitionerFacility record.
     */
    public static HealthcarePractitionerFacility createPractitionerFacility(
        Id practitionerId, Id accountId
    ) {
        HealthcarePractitionerFacility pracFacility = new HealthcarePractitionerFacility(
            PractitionerId = practitionerId,
            AccountId = accountId,
            IsActive = true
        );
        insert pracFacility;
        return pracFacility;
    }
}
