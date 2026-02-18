import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPatient360Data from '@salesforce/apex/Patient360Controller.getPatient360Data';

export default class Patient360View extends NavigationMixin(LightningElement) {
    @api recordId;

    patientData;
    error;
    isLoading = true;

    @wire(getPatient360Data, { accountId: '$recordId' })
    wiredPatientData({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.patientData = this.transformData(data);
            this.error = undefined;
        } else if (error) {
            this.error = this.reduceErrors(error);
            this.patientData = undefined;
        }
    }

    // --- Data transformation ---

    transformData(data) {
        return {
            demographics: data.demographics,
            conditions: (data.conditions || []).map((c) => ({
                ...c,
                statusClass: this.getStatusClass(c.ConditionStatus),
                severityClass: this.getSeverityClass(c.Severity),
                formattedOnsetDate: this.formatDate(c.OnsetStartDateTime)
            })),
            medications: (data.medications || []).map((m) => ({
                ...m,
                medicationName: m.Medication ? m.Medication.Name : m.Name,
                statusClass: this.getStatusClass(m.Status),
                formattedStartDate: this.formatDate(m.StartDateTime)
            })),
            allergies: (data.allergies || []).map((a) => ({
                ...a,
                severityClass: this.getSeverityClass(a.Severity),
                statusClass: this.getStatusClass(a.Status)
            })),
            insurance: (data.insurance || []).map((p) => ({
                ...p,
                statusClass: this.getStatusClass(p.Status),
                formattedBalance: this.formatCurrency(p.Medisave_Balance__c)
            }))
        };
    }

    // --- Computed properties ---

    get demographics() {
        return this.patientData?.demographics;
    }

    get conditions() {
        return this.patientData?.conditions;
    }

    get medications() {
        return this.patientData?.medications;
    }

    get allergies() {
        return this.patientData?.allergies;
    }

    get insurance() {
        return this.patientData?.insurance;
    }

    get hasConditions() {
        return this.conditions && this.conditions.length > 0;
    }

    get hasMedications() {
        return this.medications && this.medications.length > 0;
    }

    get hasAllergies() {
        return this.allergies && this.allergies.length > 0;
    }

    get hasInsurance() {
        return this.insurance && this.insurance.length > 0;
    }

    get hasEmergencyContact() {
        return !!this.demographics?.Emergency_Contact_Name__c;
    }

    get emergencyContactDisplay() {
        const name = this.demographics?.Emergency_Contact_Name__c || '';
        const relationship = this.demographics?.Emergency_Contact_Relationship__c;
        return relationship ? `${name} (${relationship})` : name;
    }

    get formattedDob() {
        if (!this.demographics?.PersonBirthdate) return '';
        return this.formatDate(this.demographics.PersonBirthdate);
    }

    // --- Navigation handlers ---

    handleKeydown(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            event.currentTarget.click();
        }
    }

    navigateToRecord(event) {
        const recordId = event.currentTarget.dataset.recordId;
        if (!recordId) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    navigateToRelatedList(event) {
        const relatedList = event.currentTarget.dataset.relatedList;
        if (!relatedList) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                relationshipApiName: relatedList,
                actionName: 'view'
            }
        });
    }

    // --- Formatting helpers ---

    formatDate(dateValue) {
        if (!dateValue) return '';
        return new Date(dateValue).toLocaleDateString('en-SG', {
            day: '2-digit',
            month: 'short',
            year: 'numeric'
        });
    }

    formatCurrency(value) {
        if (value == null) return '';
        return new Intl.NumberFormat('en-SG', {
            style: 'currency',
            currency: 'SGD'
        }).format(value);
    }

    getSeverityClass(severity) {
        const base = 'patient360__badge';
        if (!severity) return base;
        switch (severity.toLowerCase()) {
            case 'severe':
            case 'high':
                return base + ' patient360__badge--danger';
            case 'moderate':
            case 'medium':
                return base + ' patient360__badge--warning';
            case 'mild':
            case 'low':
                return base + ' patient360__badge--success';
            default:
                return base;
        }
    }

    getStatusClass(status) {
        const base = 'patient360__badge';
        if (!status) return base;
        switch (status.toLowerCase()) {
            case 'active':
                return base + ' patient360__badge--active';
            case 'inactive':
            case 'resolved':
                return base + ' patient360__badge--inactive';
            default:
                return base;
        }
    }

    // --- Error handling ---

    reduceErrors(errors) {
        if (!Array.isArray(errors)) errors = [errors];
        return errors
            .filter((e) => !!e)
            .map((e) => {
                if (Array.isArray(e.body)) return e.body.map((b) => b.message);
                if (e.body && e.body.message) return e.body.message;
                if (typeof e.message === 'string') return e.message;
                return e.statusText || 'Unknown error';
            })
            .flat()
            .join(', ');
    }
}
