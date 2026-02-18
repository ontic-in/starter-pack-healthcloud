/**
 * @description Test class for PatientTimelineController (US-1.1.3).
 *              Validates timeline event retrieval, category filtering,
 *              date sorting, and error handling across multiple source objects.
 */
@isTest
private class PatientTimelineControllerTest {

    @TestSetup
    static void setupTestData() {
        Account patient = TestDataFactory.createPatient('Timeline', 'Patient', 'S8800001T');

        // Clinical: ClinicalEncounter
        TestDataFactory.createClinicalEncounter(
            patient.Id, 'finished', 'encounter',
            DateTime.newInstance(2024, 12, 1, 10, 0, 0),
            DateTime.newInstance(2024, 12, 1, 11, 0, 0)
        );

        // Clinical: HealthCondition
        TestDataFactory.createHealthCondition(
            patient.Id, 'Hypertension', 'Active', 'Moderate',
            DateTime.newInstance(2024, 11, 15, 0, 0, 0)
        );

        // Administrative: Task
        TestDataFactory.createTask(
            patient.Id, 'Follow-up appointment scheduling', 'Completed',
            Date.newInstance(2024, 12, 5)
        );

        // Administrative: Event
        Event evt = new Event(
            WhatId = patient.Id,
            Subject = 'Specialist Consultation',
            StartDateTime = DateTime.newInstance(2024, 12, 10, 14, 0, 0),
            DurationInMinutes = 60
        );
        insert evt;
    }

    /**
     * @description Happy path: returns events from all categories, sorted by date desc,
     *              with all required wrapper fields populated.
     */
    @isTest
    static void testGetTimelineEventsAll() {
        Account patient = [SELECT Id FROM Account WHERE NRIC__c = 'S8800001T' LIMIT 1];

        Test.startTest();
        List<PatientTimelineController.TimelineEvent> events =
            PatientTimelineController.getTimelineEvents(patient.Id, 'all');
        Test.stopTest();

        Assert.isNotNull(events, 'Events list should not be null');
        Assert.isTrue(events.size() >= 4, 'Should have at least 4 events from setup data');

        // Verify sorted by date descending
        for (Integer i = 0; i < events.size() - 1; i++) {
            Assert.isTrue(
                events[i].eventDate >= events[i + 1].eventDate,
                'Events should be sorted by date descending'
            );
        }

        // Verify all required fields populated on each event
        for (PatientTimelineController.TimelineEvent evt : events) {
            Assert.isNotNull(evt.recordId, 'Record ID should not be null');
            Assert.isNotNull(evt.objectType, 'Object type should not be null');
            Assert.isNotNull(evt.category, 'Category should not be null');
            Assert.isNotNull(evt.title, 'Title should not be null');
            Assert.isNotNull(evt.eventDate, 'Event date should not be null');
            Assert.isNotNull(evt.status, 'Status should not be null');
            Assert.isNotNull(evt.iconName, 'Icon name should not be null');
        }

        // Verify both categories present (engagement skipped due to SDO Case flow)
        Set<String> categories = new Set<String>();
        for (PatientTimelineController.TimelineEvent evt : events) {
            categories.add(evt.category);
        }
        Assert.isTrue(categories.contains('clinical'), 'Should contain clinical events');
        Assert.isTrue(categories.contains('administrative'), 'Should contain administrative events');
    }

    /**
     * @description Filter by clinical returns only clinical category events.
     */
    @isTest
    static void testGetTimelineEventsClinicalFilter() {
        Account patient = [SELECT Id FROM Account WHERE NRIC__c = 'S8800001T' LIMIT 1];

        Test.startTest();
        List<PatientTimelineController.TimelineEvent> events =
            PatientTimelineController.getTimelineEvents(patient.Id, 'clinical');
        Test.stopTest();

        Assert.isNotNull(events, 'Events list should not be null');
        Assert.isTrue(events.size() >= 2, 'Should have at least 2 clinical events');

        for (PatientTimelineController.TimelineEvent evt : events) {
            Assert.areEqual('clinical', evt.category, 'All events should be clinical');
        }
    }

    /**
     * @description Filter by administrative returns only administrative category events.
     */
    @isTest
    static void testGetTimelineEventsAdministrativeFilter() {
        Account patient = [SELECT Id FROM Account WHERE NRIC__c = 'S8800001T' LIMIT 1];

        Test.startTest();
        List<PatientTimelineController.TimelineEvent> events =
            PatientTimelineController.getTimelineEvents(patient.Id, 'administrative');
        Test.stopTest();

        Assert.isNotNull(events, 'Events list should not be null');
        Assert.isTrue(events.size() >= 2, 'Should have at least 2 administrative events');

        for (PatientTimelineController.TimelineEvent evt : events) {
            Assert.areEqual('administrative', evt.category, 'All events should be administrative');
        }
    }

    /**
     * @description Filter by engagement returns empty list when no Cases exist.
     *              Case creation blocked in test context by SDO Service flow.
     */
    @isTest
    static void testGetTimelineEventsEngagementFilter() {
        Account patient = [SELECT Id FROM Account WHERE NRIC__c = 'S8800001T' LIMIT 1];

        Test.startTest();
        List<PatientTimelineController.TimelineEvent> events =
            PatientTimelineController.getTimelineEvents(patient.Id, 'engagement');
        Test.stopTest();

        Assert.isNotNull(events, 'Events list should not be null');
        Assert.areEqual(0, events.size(), 'Should have 0 engagement events (Case blocked by SDO flow)');
    }

    /**
     * @description Patient with no related records returns empty list, not null.
     */
    @isTest
    static void testGetTimelineEventsEmptyPatient() {
        Account emptyPatient = TestDataFactory.createPatient('Empty', 'Timeline', 'S9900002T');

        Test.startTest();
        List<PatientTimelineController.TimelineEvent> events =
            PatientTimelineController.getTimelineEvents(emptyPatient.Id, 'all');
        Test.stopTest();

        Assert.isNotNull(events, 'Events list should not be null');
        Assert.areEqual(0, events.size(), 'Should have 0 events');
    }

    /**
     * @description Invalid Account ID throws AuraHandledException.
     */
    @isTest
    static void testGetTimelineEventsInvalidId() {
        Id fakeAccountId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
            .getKeyPrefix() + '000000000000';

        Test.startTest();
        try {
            PatientTimelineController.getTimelineEvents(fakeAccountId, 'all');
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().length() > 0, 'Exception should have a message');
        }
        Test.stopTest();
    }
}
