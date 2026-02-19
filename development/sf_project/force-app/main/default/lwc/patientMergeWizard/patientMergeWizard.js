import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMergePreview from '@salesforce/apex/PatientMergeController.getMergePreview';
import mergePatients from '@salesforce/apex/PatientMergeController.mergePatients';

const COMPARE_FIELDS = [
    { label: 'First Name', field: 'FirstName' },
    { label: 'Last Name', field: 'LastName' },
    { label: 'NRIC', field: 'NRIC__c' },
    { label: 'Date of Birth', field: 'PersonBirthdate' },
    { label: 'Phone', field: 'PersonMobilePhone' },
    { label: 'Email', field: 'PersonEmail' },
    { label: 'Ethnicity', field: 'Ethnicity__c' },
    { label: 'Emergency Contact', field: 'Emergency_Contact_Name__c' },
    { label: 'Emergency Phone', field: 'Emergency_Contact_Phone__c' },
    { label: 'Emergency Relationship', field: 'Emergency_Contact_Relationship__c' }
];

export default class PatientMergeWizard extends NavigationMixin(LightningElement) {
    @api masterAccountId;
    @api duplicateAccountId;

    @track preview = null;
    @track fieldComparisons = [];
    @track mergeResult = null;

    currentStep = 1;
    isLoading = false;
    errorMessage = '';

    get isStep1() { return this.currentStep === 1; }
    get isStep2() { return this.currentStep === 2; }
    get isStep3() { return this.currentStep === 3; }
    get isStep4() { return this.currentStep === 4; }

    get hasError() { return this.errorMessage !== ''; }

    get totalRelatedRecords() {
        if (!this.preview) return 0;
        return (this.preview.duplicateConditionCount || 0) +
               (this.preview.duplicateMedicationCount || 0) +
               (this.preview.duplicateAllergyCount || 0) +
               (this.preview.duplicateInsuranceCount || 0);
    }

    get masterName() {
        if (!this.preview || !this.preview.masterRecord) return '';
        return this.preview.masterRecord.FirstName + ' ' + this.preview.masterRecord.LastName;
    }

    get duplicateName() {
        if (!this.preview || !this.preview.duplicateRecord) return '';
        return this.preview.duplicateRecord.FirstName + ' ' + this.preview.duplicateRecord.LastName;
    }

    connectedCallback() {
        this.loadPreview();
    }

    async loadPreview() {
        this.isLoading = true;
        this.errorMessage = '';

        try {
            this.preview = await getMergePreview({
                masterAccountId: this.masterAccountId,
                duplicateAccountId: this.duplicateAccountId
            });

            this.buildFieldComparisons();
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
        } finally {
            this.isLoading = false;
        }
    }

    buildFieldComparisons() {
        if (!this.preview) return;

        this.fieldComparisons = COMPARE_FIELDS.map(cf => {
            const masterVal = this.preview.masterRecord[cf.field] || '';
            const dupVal = this.preview.duplicateRecord[cf.field] || '';
            const isDifferent = String(masterVal) !== String(dupVal);

            return {
                label: cf.label,
                field: cf.field,
                masterValue: this.formatFieldValue(masterVal),
                duplicateValue: this.formatFieldValue(dupVal),
                masterRawValue: masterVal,
                duplicateRawValue: dupVal,
                isDifferent: isDifferent,
                selectedValue: 'master',
                rowClass: isDifferent
                    ? 'mergeWizard__row mergeWizard__row--different'
                    : 'mergeWizard__row'
            };
        });
    }

    formatFieldValue(value) {
        if (value === null || value === undefined || value === '') return '-';
        return String(value);
    }

    handleFieldSelection(event) {
        const field = event.currentTarget.dataset.field;
        const source = event.currentTarget.dataset.source;

        this.fieldComparisons = this.fieldComparisons.map(fc => {
            if (fc.field === field) {
                return { ...fc, selectedValue: source };
            }
            return fc;
        });
    }

    handleNext() {
        if (this.currentStep < 3) {
            this.currentStep++;
        }
    }

    handleBack() {
        if (this.currentStep > 1) {
            this.currentStep--;
        }
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('mergecancel'));
    }

    async handleConfirmMerge() {
        this.isLoading = true;
        this.errorMessage = '';

        const fieldsChanged = {};
        this.fieldComparisons.forEach(fc => {
            if (fc.isDifferent && fc.selectedValue === 'duplicate') {
                fieldsChanged[fc.field] = fc.duplicateRawValue;
            }
        });

        try {
            this.mergeResult = await mergePatients({
                masterAccountId: this.masterAccountId,
                duplicateAccountId: this.duplicateAccountId,
                fieldsChanged: JSON.stringify(fieldsChanged)
            });

            this.currentStep = 4;
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleViewMasterRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.mergeResult.masterRecordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    handleDone() {
        this.dispatchEvent(new CustomEvent('mergecomplete'));
    }

    reduceErrors(error) {
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        }
        if (error.body && error.body.message) {
            return error.body.message;
        }
        if (typeof error.message === 'string') {
            return error.message;
        }
        return 'An unexpected error occurred.';
    }
}
