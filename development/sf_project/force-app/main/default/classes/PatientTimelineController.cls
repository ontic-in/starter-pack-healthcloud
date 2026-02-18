/**
 * @description Controller for Patient Timeline LWC (US-1.1.3).
 *              Queries multiple Health Cloud and standard objects to build
 *              a unified chronological timeline of patient events.
 *              Supports filtering by category: clinical, administrative, engagement.
 */
public with sharing class PatientTimelineController {

    private static final String CATEGORY_CLINICAL = 'clinical';
    private static final String CATEGORY_ADMINISTRATIVE = 'administrative';
    private static final String CATEGORY_ENGAGEMENT = 'engagement';
    private static final String FILTER_ALL = 'all';
    private static final Integer QUERY_LIMIT = 50;

    /**
     * @description Unified wrapper for timeline events from multiple source objects.
     */
    public class TimelineEvent implements Comparable {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String objectType;
        @AuraEnabled public String category;
        @AuraEnabled public String title;
        @AuraEnabled public String description;
        @AuraEnabled public DateTime eventDate;
        @AuraEnabled public String provider;
        @AuraEnabled public String facility;
        @AuraEnabled public String status;
        @AuraEnabled public String iconName;

        public Integer compareTo(Object other) {
            TimelineEvent otherEvent = (TimelineEvent) other;
            if (this.eventDate == null && otherEvent.eventDate == null) { return 0; }
            if (this.eventDate == null) { return 1; }
            if (otherEvent.eventDate == null) { return -1; }
            if (this.eventDate > otherEvent.eventDate) { return -1; }
            if (this.eventDate < otherEvent.eventDate) { return 1; }
            return 0;
        }
    }

    /**
     * @description Retrieves timeline events for a patient, optionally filtered by category.
     * @param accountId The patient's Account (Person Account) ID
     * @param filterType Filter category: 'all', 'clinical', 'administrative', 'engagement'
     * @return List of TimelineEvent sorted by date descending
     */
    @AuraEnabled(cacheable=true)
    public static List<TimelineEvent> getTimelineEvents(Id accountId, String filterType) {
        // Validate account exists
        List<Account> accounts = [
            SELECT Id FROM Account
            WHERE Id = :accountId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (accounts.isEmpty()) {
            throw new AuraHandledException('Patient record not found.');
        }

        String filter = String.isBlank(filterType) ? FILTER_ALL : filterType.toLowerCase();
        List<TimelineEvent> events = new List<TimelineEvent>();

        if (filter == FILTER_ALL || filter == CATEGORY_CLINICAL) {
            events.addAll(getClinicalEncounters(accountId));
            events.addAll(getHealthConditions(accountId));
            events.addAll(getMedicationStatements(accountId));
            events.addAll(getAllergyIntolerances(accountId));
            events.addAll(getCareObservations(accountId));
            events.addAll(getCarePlans(accountId));
        }

        if (filter == FILTER_ALL || filter == CATEGORY_ADMINISTRATIVE) {
            events.addAll(getTasks(accountId));
            events.addAll(getEvents(accountId));
        }

        if (filter == FILTER_ALL || filter == CATEGORY_ENGAGEMENT) {
            events.addAll(getCases(accountId));
        }

        events.sort();
        return events;
    }

    private static List<TimelineEvent> getClinicalEncounters(Id accountId) {
        List<TimelineEvent> events = new List<TimelineEvent>();
        for (ClinicalEncounter ce : [
            SELECT Id, Name, Status, Category, StartDate, EndDate
            FROM ClinicalEncounter
            WHERE PatientId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY StartDate DESC
            LIMIT :QUERY_LIMIT
        ]) {
            TimelineEvent te = new TimelineEvent();
            te.recordId = ce.Id;
            te.objectType = 'ClinicalEncounter';
            te.category = CATEGORY_CLINICAL;
            te.title = 'Encounter: ' + ce.Name;
            te.description = ce.Category != null ? 'Category: ' + ce.Category : '';
            te.eventDate = ce.StartDate;
            te.status = ce.Status;
            te.iconName = 'standard:visit_templates';
            events.add(te);
        }
        return events;
    }

    private static List<TimelineEvent> getHealthConditions(Id accountId) {
        List<TimelineEvent> events = new List<TimelineEvent>();
        for (HealthCondition hc : [
            SELECT Id, ProblemName, ConditionStatus, Severity, OnsetStartDateTime
            FROM HealthCondition
            WHERE PatientId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY OnsetStartDateTime DESC
            LIMIT :QUERY_LIMIT
        ]) {
            TimelineEvent te = new TimelineEvent();
            te.recordId = hc.Id;
            te.objectType = 'HealthCondition';
            te.category = CATEGORY_CLINICAL;
            te.title = hc.ProblemName != null ? hc.ProblemName : 'Health Condition';
            te.description = hc.Severity != null ? 'Severity: ' + hc.Severity : '';
            te.eventDate = hc.OnsetStartDateTime;
            te.status = hc.ConditionStatus;
            te.iconName = 'standard:condition';
            events.add(te);
        }
        return events;
    }

    private static List<TimelineEvent> getMedicationStatements(Id accountId) {
        List<TimelineEvent> events = new List<TimelineEvent>();
        for (MedicationStatement ms : [
            SELECT Id, Name, Status, StartDateTime, Medication.Name
            FROM MedicationStatement
            WHERE PatientId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY StartDateTime DESC
            LIMIT :QUERY_LIMIT
        ]) {
            TimelineEvent te = new TimelineEvent();
            te.recordId = ms.Id;
            te.objectType = 'MedicationStatement';
            te.category = CATEGORY_CLINICAL;
            te.title = ms.Medication != null && ms.Medication.Name != null
                ? ms.Medication.Name : 'Medication';
            te.eventDate = ms.StartDateTime;
            te.status = ms.Status;
            te.iconName = 'standard:medication_ingredient';
            events.add(te);
        }
        return events;
    }

    private static List<TimelineEvent> getAllergyIntolerances(Id accountId) {
        List<TimelineEvent> events = new List<TimelineEvent>();
        for (AllergyIntolerance ai : [
            SELECT Id, Name, Type, Severity, Status, CreatedDate
            FROM AllergyIntolerance
            WHERE PatientId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT :QUERY_LIMIT
        ]) {
            TimelineEvent te = new TimelineEvent();
            te.recordId = ai.Id;
            te.objectType = 'AllergyIntolerance';
            te.category = CATEGORY_CLINICAL;
            te.title = ai.Name != null ? 'Allergy: ' + ai.Name : 'Allergy';
            te.description = ai.Severity != null ? 'Severity: ' + ai.Severity : '';
            te.eventDate = ai.CreatedDate;
            te.status = ai.Status;
            te.iconName = 'standard:record_lookup';
            events.add(te);
        }
        return events;
    }

    private static List<TimelineEvent> getCareObservations(Id accountId) {
        List<TimelineEvent> events = new List<TimelineEvent>();
        for (CareObservation co : [
            SELECT Id, Name, ObservationStatus, Category, EffectiveDateTime
            FROM CareObservation
            WHERE ObservedSubjectId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY EffectiveDateTime DESC
            LIMIT :QUERY_LIMIT
        ]) {
            TimelineEvent te = new TimelineEvent();
            te.recordId = co.Id;
            te.objectType = 'CareObservation';
            te.category = CATEGORY_CLINICAL;
            te.title = co.Name != null ? co.Name : 'Observation';
            te.description = co.Category != null ? 'Category: ' + co.Category : '';
            te.eventDate = co.EffectiveDateTime;
            te.status = co.ObservationStatus;
            te.iconName = 'standard:observation_component';
            events.add(te);
        }
        return events;
    }

    private static List<TimelineEvent> getCarePlans(Id accountId) {
        List<TimelineEvent> events = new List<TimelineEvent>();
        for (CarePlan cp : [
            SELECT Id, Name, Status, Description, StartDate
            FROM CarePlan
            WHERE ParticipantId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY StartDate DESC
            LIMIT :QUERY_LIMIT
        ]) {
            TimelineEvent te = new TimelineEvent();
            te.recordId = cp.Id;
            te.objectType = 'CarePlan';
            te.category = CATEGORY_CLINICAL;
            te.title = cp.Name != null ? cp.Name : 'Care Plan';
            te.description = cp.Description;
            te.eventDate = cp.StartDate;
            te.status = cp.Status;
            te.iconName = 'standard:care_plan';
            events.add(te);
        }
        return events;
    }

    private static List<TimelineEvent> getTasks(Id accountId) {
        List<TimelineEvent> events = new List<TimelineEvent>();
        for (Task t : [
            SELECT Id, Subject, Status, ActivityDate, Description
            FROM Task
            WHERE WhatId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY ActivityDate DESC NULLS LAST
            LIMIT :QUERY_LIMIT
        ]) {
            TimelineEvent te = new TimelineEvent();
            te.recordId = t.Id;
            te.objectType = 'Task';
            te.category = CATEGORY_ADMINISTRATIVE;
            te.title = t.Subject != null ? t.Subject : 'Task';
            te.description = t.Description;
            te.eventDate = t.ActivityDate != null
                ? DateTime.newInstance(t.ActivityDate, Time.newInstance(0, 0, 0, 0))
                : null;
            te.status = t.Status;
            te.iconName = 'standard:task';
            events.add(te);
        }
        return events;
    }

    private static List<TimelineEvent> getEvents(Id accountId) {
        List<TimelineEvent> events = new List<TimelineEvent>();
        for (Event e : [
            SELECT Id, Subject, StartDateTime, Description
            FROM Event
            WHERE WhatId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY StartDateTime DESC
            LIMIT :QUERY_LIMIT
        ]) {
            TimelineEvent te = new TimelineEvent();
            te.recordId = e.Id;
            te.objectType = 'Event';
            te.category = CATEGORY_ADMINISTRATIVE;
            te.title = e.Subject != null ? e.Subject : 'Event';
            te.description = e.Description;
            te.eventDate = e.StartDateTime;
            te.status = 'Scheduled';
            te.iconName = 'standard:event';
            events.add(te);
        }
        return events;
    }

    private static List<TimelineEvent> getCases(Id accountId) {
        List<TimelineEvent> events = new List<TimelineEvent>();
        for (Case c : [
            SELECT Id, Subject, Status, Description, CreatedDate
            FROM Case
            WHERE AccountId = :accountId
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
            LIMIT :QUERY_LIMIT
        ]) {
            TimelineEvent te = new TimelineEvent();
            te.recordId = c.Id;
            te.objectType = 'Case';
            te.category = CATEGORY_ENGAGEMENT;
            te.title = c.Subject != null ? c.Subject : 'Case';
            te.description = c.Description;
            te.eventDate = c.CreatedDate;
            te.status = c.Status;
            te.iconName = 'standard:case';
            events.add(te);
        }
        return events;
    }
}
