import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import searchPatients from '@salesforce/apex/PatientSearchController.searchPatients';
import checkDuplicates from '@salesforce/apex/PatientSearchController.checkDuplicates';

const SEARCH_TYPE_OPTIONS = [
    { label: 'NRIC', value: 'NRIC' },
    { label: 'Name', value: 'Name' },
    { label: 'Phone', value: 'Phone' }
];

const NRIC_MASK_REGEX = /^(.)(.{5})(...)$/;

export default class PatientSearchDuplicates extends NavigationMixin(LightningElement) {
    searchTerm = '';
    searchType = 'NRIC';
    searchTypeOptions = SEARCH_TYPE_OPTIONS;

    @track searchResults = [];
    @track duplicateResults = [];

    isLoading = false;
    hasSearched = false;
    errorMessage = '';
    showMergeWizard = false;
    mergeRecordIds = {};

    get hasResults() {
        return this.searchResults.length > 0;
    }

    get hasNoResults() {
        return this.hasSearched && this.searchResults.length === 0;
    }

    get hasDuplicates() {
        return this.duplicateResults.length > 0;
    }

    get hasError() {
        return this.errorMessage !== '';
    }

    get searchPlaceholder() {
        const placeholders = {
            NRIC: 'Enter NRIC (e.g., S1234567A)',
            Name: 'Enter patient name',
            Phone: 'Enter phone number (e.g., +6591234567)'
        };
        return placeholders[this.searchType] || 'Enter search term';
    }

    handleSearchTypeChange(event) {
        this.searchType = event.detail.value;
        this.clearResults();
    }

    handleSearchTermChange(event) {
        this.searchTerm = event.detail.value;
    }

    handleKeyPress(event) {
        if (event.key === 'Enter') {
            this.handleSearch();
        }
    }

    async handleSearch() {
        if (!this.searchTerm || !this.searchTerm.trim()) {
            this.errorMessage = 'Please enter a search term.';
            return;
        }

        this.isLoading = true;
        this.errorMessage = '';
        this.duplicateResults = [];
        this.hasSearched = true;

        try {
            const results = await searchPatients({
                searchTerm: this.searchTerm.trim(),
                searchType: this.searchType
            });

            this.searchResults = results.map(r => this.transformResult(r));
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
            this.searchResults = [];
        } finally {
            this.isLoading = false;
        }
    }

    async handleCheckDuplicates(event) {
        const recordId = event.currentTarget.dataset.recordId;
        const result = this.searchResults.find(r => r.patient.Id === recordId);

        if (!result) return;

        this.isLoading = true;
        this.errorMessage = '';

        try {
            const duplicates = await checkDuplicates({
                nric: result.patient.NRIC__c || '',
                firstName: result.patient.FirstName || '',
                lastName: result.patient.LastName || '',
                dob: result.patient.PersonBirthdate || null
            });

            this.duplicateResults = duplicates
                .filter(d => d.patient.Id !== recordId)
                .map(d => this.transformResult(d));
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleNavigateToRecord(event) {
        const recordId = event.currentTarget.dataset.recordId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    handleMerge(event) {
        const masterId = event.currentTarget.dataset.masterId;
        const duplicateId = event.currentTarget.dataset.duplicateId;
        this.mergeRecordIds = { masterId, duplicateId };
        this.showMergeWizard = true;
    }

    handleMergeComplete() {
        this.showMergeWizard = false;
        this.mergeRecordIds = {};
        this.duplicateResults = [];
        this.handleSearch();
    }

    handleMergeCancel() {
        this.showMergeWizard = false;
        this.mergeRecordIds = {};
    }

    clearResults() {
        this.searchResults = [];
        this.duplicateResults = [];
        this.hasSearched = false;
        this.errorMessage = '';
    }

    transformResult(result) {
        return {
            ...result,
            maskedNRIC: this.maskNRIC(result.patient.NRIC__c),
            formattedDOB: this.formatDate(result.patient.PersonBirthdate),
            confidenceClass: this.getConfidenceClass(result.matchConfidence)
        };
    }

    maskNRIC(nric) {
        if (!nric || nric.length < 9) return nric || '-';
        return nric.replace(NRIC_MASK_REGEX, '$1****$3');
    }

    formatDate(dateValue) {
        if (!dateValue) return '-';
        return new Intl.DateTimeFormat('en-SG', {
            day: '2-digit',
            month: 'short',
            year: 'numeric'
        }).format(new Date(dateValue));
    }

    getConfidenceClass(confidence) {
        if (confidence >= 90) return 'patientSearch__badge patientSearch__badge--danger';
        if (confidence >= 75) return 'patientSearch__badge patientSearch__badge--warning';
        return 'patientSearch__badge patientSearch__badge--info';
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
