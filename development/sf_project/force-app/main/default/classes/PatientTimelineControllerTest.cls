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

        // Clinical: ClinicalServiceRequest (Referral)
        Contact drTimeline = new Contact(FirstName = 'Timeline', LastName = 'Doctor', Email = 'timeline.doc@hospital.sg');
        insert drTimeline;
        HealthcareProvider timelineProvider = new HealthcareProvider(
            PractitionerId = drTimeline.Id,
            Name = 'Dr Timeline Doctor',
            Is_Accepting_Patients__c = true,
            IsActive = true
        );
        insert timelineProvider;

        ClinicalServiceRequest csr = new ClinicalServiceRequest(
            PatientId = patient.Id,
            Referred_To_Provider__c = timelineProvider.Id,
            Referral_Reason__c = 'Cardiology consult for chest pain',
            Priority = 'Urgent',
            Status = 'Active',
            Intent = 'order',
            AuthoredOn = DateTime.newInstance(2024, 12, 15, 9, 0, 0)
        );
        insert csr;
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
     * @description Null/blank filterType defaults to 'all' and returns events.
     */
    @isTest
    static void testGetTimelineEventsNullFilter() {
        Account patient = [SELECT Id FROM Account WHERE NRIC__c = 'S8800001T' LIMIT 1];

        Test.startTest();
        List<PatientTimelineController.TimelineEvent> events =
            PatientTimelineController.getTimelineEvents(patient.Id, null);
        Test.stopTest();

        Assert.isNotNull(events, 'Events list should not be null');
        Assert.isTrue(events.size() >= 4, 'Null filter should default to all and return all events');
    }

    /**
     * @description Blank string filterType defaults to 'all' and returns events.
     */
    @isTest
    static void testGetTimelineEventsBlankFilter() {
        Account patient = [SELECT Id FROM Account WHERE NRIC__c = 'S8800001T' LIMIT 1];

        Test.startTest();
        List<PatientTimelineController.TimelineEvent> events =
            PatientTimelineController.getTimelineEvents(patient.Id, '');
        Test.stopTest();

        Assert.isNotNull(events, 'Events list should not be null');
        Assert.isTrue(events.size() >= 4, 'Blank filter should default to all and return all events');
    }

    /**
     * @description Invalid Account ID returns empty list (no account validation query).
     */
    @isTest
    static void testGetTimelineEventsInvalidId() {
        Id fakeAccountId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
            .getKeyPrefix() + '000000000000';

        Test.startTest();
        List<PatientTimelineController.TimelineEvent> events =
            PatientTimelineController.getTimelineEvents(fakeAccountId, 'all');
        Test.stopTest();

        Assert.isNotNull(events, 'Events list should not be null');
        Assert.areEqual(0, events.size(), 'Invalid ID should return empty list');
    }

    /**
     * @description Verifies ClinicalServiceRequest referrals appear in the clinical timeline.
     */
    @isTest
    static void testGetTimelineEventsIncludesReferrals() {
        Account patient = [SELECT Id FROM Account WHERE NRIC__c = 'S8800001T' LIMIT 1];

        Test.startTest();
        List<PatientTimelineController.TimelineEvent> events =
            PatientTimelineController.getTimelineEvents(patient.Id, 'clinical');
        Test.stopTest();

        Boolean hasReferral = false;
        for (PatientTimelineController.TimelineEvent evt : events) {
            if (evt.objectType == 'ClinicalServiceRequest') {
                hasReferral = true;
                Assert.areEqual('clinical', evt.category, 'Referral should be clinical category');
                Assert.isTrue(evt.title.contains('Referral'), 'Title should contain Referral prefix');
                Assert.areEqual('standard:service_request', evt.iconName, 'Icon should be service_request');
                Assert.isNotNull(evt.eventDate, 'Event date should be populated from AuthoredOn');
            }
        }
        Assert.isTrue(hasReferral, 'Timeline should include ClinicalServiceRequest referral');
    }

    /**
     * @description Verifies referral timeline event has correct provider and description.
     */
    @isTest
    static void testGetTimelineEventsReferralDetails() {
        Account patient = [SELECT Id FROM Account WHERE NRIC__c = 'S8800001T' LIMIT 1];

        Test.startTest();
        List<PatientTimelineController.TimelineEvent> events =
            PatientTimelineController.getTimelineEvents(patient.Id, 'all');
        Test.stopTest();

        for (PatientTimelineController.TimelineEvent evt : events) {
            if (evt.objectType == 'ClinicalServiceRequest') {
                Assert.areEqual('Active', evt.status, 'Status should match');
                Assert.areEqual('Cardiology consult for chest pain', evt.description, 'Description should be referral reason');
                Assert.areEqual('Dr Timeline Doctor', evt.provider, 'Provider should be referred-to provider name');
            }
        }
    }
}
