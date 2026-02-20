import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchProviders from '@salesforce/apex/ProviderDirectoryController.searchProviders';
import getSpecialtyOptions from '@salesforce/apex/ProviderDirectoryController.getSpecialtyOptions';
import getFacilityOptions from '@salesforce/apex/ProviderDirectoryController.getFacilityOptions';

const DEBOUNCE_DELAY = 300;
const LOAD_THRESHOLD_LOW = 20;
const LOAD_THRESHOLD_HIGH = 40;
const TOAST_TITLE_ERROR = 'Error';
const TOAST_VARIANT_ERROR = 'error';
const EMPTY_STATE_MESSAGE = 'No providers found matching your criteria.';
const LABEL_ACCEPTING = 'Accepting';
const LABEL_NOT_ACCEPTING = 'Not Accepting';
const LABEL_NOT_SET = 'Not set';
const LABEL_UNKNOWN_ERROR = 'Unknown error';
const VIEW_MODE_TABLE = 'table';
const VIEW_MODE_CARD = 'card';
const NAV_TYPE_RECORD_PAGE = 'standard__recordPage';
const NAV_OBJECT_API_NAME = 'HealthcareProvider';
const NAV_ACTION_VIEW = 'view';
const CSS_BADGE_ACCEPTING = 'providerDirectory__badge providerDirectory__badge--accepting';
const CSS_BADGE_NOT_ACCEPTING = 'providerDirectory__badge providerDirectory__badge--notAccepting';
const CSS_LOAD_LOW = 'providerDirectory__load providerDirectory__load--low';
const CSS_LOAD_MEDIUM = 'providerDirectory__load providerDirectory__load--medium';
const CSS_LOAD_HIGH = 'providerDirectory__load providerDirectory__load--high';
const CSS_BUTTON_SELECTED = 'slds-button slds-button_neutral slds-is-selected';
const CSS_BUTTON_NEUTRAL = 'slds-button slds-button_neutral';

export default class ProviderDirectory extends NavigationMixin(LightningElement) {
    searchTerm = '';
    selectedSpecialties = [];
    selectedFacilities = [];
    selectedLanguages = [];
    acceptingPatientsOnly = false;
    viewMode = VIEW_MODE_TABLE;

    providers = [];
    isLoading = true;
    errorMessage = '';

    specialtyOptions = [];
    facilityOptions = [];
    searchTimeout;

    languageOptions = [
        { label: 'English', value: 'English' },
        { label: 'Mandarin', value: 'Mandarin' },
        { label: 'Malay', value: 'Malay' },
        { label: 'Tamil', value: 'Tamil' },
        { label: 'Hindi', value: 'Hindi' },
        { label: 'Bengali', value: 'Bengali' },
        { label: 'Cantonese', value: 'Cantonese' },
        { label: 'Hokkien', value: 'Hokkien' },
        { label: 'Teochew', value: 'Teochew' },
        { label: 'Other', value: 'Other' }
    ];

    @wire(getSpecialtyOptions)
    wiredSpecialties({ data, error }) {
        if (data) {
            this.specialtyOptions = data.map((opt) => ({
                label: opt.label,
                value: opt.value
            }));
        } else if (error) {
            this.specialtyOptions = [];
        }
    }

    @wire(getFacilityOptions)
    wiredFacilities({ data, error }) {
        if (data) {
            this.facilityOptions = data.map((opt) => ({
                label: opt.label,
                value: opt.value
            }));
        } else if (error) {
            this.facilityOptions = [];
        }
    }

    connectedCallback() {
        this.performSearch();
    }

    // ──────────────────────────────────────────────
    // Search handlers
    // ──────────────────────────────────────────────

    handleSearchInput(event) {
        this.searchTerm = event.target.value;
        clearTimeout(this.searchTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchTimeout = setTimeout(() => {
            this.performSearch();
        }, DEBOUNCE_DELAY);
    }

    handleSpecialtyChange(event) {
        this.selectedSpecialties = event.detail.value;
        this.performSearch();
    }

    handleFacilityChange(event) {
        this.selectedFacilities = event.detail.value;
        this.performSearch();
    }

    handleLanguageChange(event) {
        this.selectedLanguages = event.detail.value;
        this.performSearch();
    }

    handleAcceptingChange(event) {
        this.acceptingPatientsOnly = event.target.checked;
        this.performSearch();
    }

    handleClearFilters() {
        this.searchTerm = '';
        this.selectedSpecialties = [];
        this.selectedFacilities = [];
        this.selectedLanguages = [];
        this.acceptingPatientsOnly = false;
        this.performSearch();
    }

    handleViewToggle(event) {
        this.viewMode = event.target.dataset.view;
    }

    async performSearch() {
        this.isLoading = true;
        this.errorMessage = '';
        try {
            const criteria = {
                searchTerm: this.searchTerm,
                specialtyNames: this.selectedSpecialties,
                facilityNames: this.selectedFacilities,
                languages: this.selectedLanguages,
                acceptingPatientsOnly: this.acceptingPatientsOnly
            };
            const results = await searchProviders({
                criteriaJson: JSON.stringify(criteria)
            });
            this.providers = this.transformProviderData(results);
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
            this.providers = [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: TOAST_TITLE_ERROR,
                    message: this.errorMessage,
                    variant: TOAST_VARIANT_ERROR
                })
            );
        } finally {
            this.isLoading = false;
        }
    }

    // ──────────────────────────────────────────────
    // Data transformation
    // ──────────────────────────────────────────────

    transformProviderData(data) {
        return (data || []).map((p) => ({
            ...p,
            acceptingClass: p.acceptingPatients
                ? CSS_BADGE_ACCEPTING
                : CSS_BADGE_NOT_ACCEPTING,
            acceptingLabel: p.acceptingPatients ? LABEL_ACCEPTING : LABEL_NOT_ACCEPTING,
            patientLoadClass: this.getPatientLoadClass(p.patientLoad),
            formattedNextAvailable: this.formatDateTime(p.nextAvailableSlot)
        }));
    }

    getPatientLoadClass(load) {
        if (load < LOAD_THRESHOLD_LOW) {
            return CSS_LOAD_LOW;
        }
        if (load < LOAD_THRESHOLD_HIGH) {
            return CSS_LOAD_MEDIUM;
        }
        return CSS_LOAD_HIGH;
    }

    formatDateTime(dateTimeValue) {
        if (!dateTimeValue) {
            return LABEL_NOT_SET;
        }
        const dt = new Date(dateTimeValue);
        return dt.toLocaleDateString(undefined, {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
    }

    // ──────────────────────────────────────────────
    // Navigation
    // ──────────────────────────────────────────────

    navigateToProvider(event) {
        const providerId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: NAV_TYPE_RECORD_PAGE,
            attributes: {
                recordId: providerId,
                objectApiName: NAV_OBJECT_API_NAME,
                actionName: NAV_ACTION_VIEW
            }
        });
    }

    // ──────────────────────────────────────────────
    // Computed properties
    // ──────────────────────────────────────────────

    get hasProviders() {
        return this.providers && this.providers.length > 0;
    }

    get showEmptyState() {
        return !this.isLoading && !this.hasProviders && !this.errorMessage;
    }

    get emptyStateMessage() {
        return EMPTY_STATE_MESSAGE;
    }

    get resultCount() {
        const count = this.providers ? this.providers.length : 0;
        return count === 1 ? '1 provider found' : `${count} providers found`;
    }

    get isTableView() {
        return this.viewMode === VIEW_MODE_TABLE;
    }

    get isCardView() {
        return this.viewMode === VIEW_MODE_CARD;
    }

    get tableViewClass() {
        return this.isTableView ? CSS_BUTTON_SELECTED : CSS_BUTTON_NEUTRAL;
    }

    get cardViewClass() {
        return this.isCardView ? CSS_BUTTON_SELECTED : CSS_BUTTON_NEUTRAL;
    }

    get hasActiveFilters() {
        return (
            this.searchTerm ||
            this.selectedSpecialties.length > 0 ||
            this.selectedFacilities.length > 0 ||
            this.selectedLanguages.length > 0 ||
            this.acceptingPatientsOnly
        );
    }

    // ──────────────────────────────────────────────
    // Error handling
    // ──────────────────────────────────────────────

    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }
        return errors
            .filter((e) => !!e)
            .map((e) => {
                if (Array.isArray(e.body)) {
                    return e.body.map((b) => b.message);
                }
                if (e.body && e.body.message) {
                    return e.body.message;
                }
                if (typeof e.message === 'string') {
                    return e.message;
                }
                return e.statusText || LABEL_UNKNOWN_ERROR;
            })
            .flat()
            .join(', ');
    }
}
