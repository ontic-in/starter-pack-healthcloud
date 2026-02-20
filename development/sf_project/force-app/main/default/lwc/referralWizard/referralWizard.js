import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPatientContext from '@salesforce/apex/ReferralController.getPatientContext';
import searchProviders from '@salesforce/apex/ReferralController.searchProviders';
import getSpecialtyOptions from '@salesforce/apex/ReferralController.getSpecialtyOptions';
import submitReferral from '@salesforce/apex/ReferralController.submitReferral';

// Step constants
const STEP_PATIENT = 1;
const STEP_PROVIDER = 2;
const STEP_DETAILS = 3;
const STEP_REVIEW = 4;

// Timing
const DEBOUNCE_DELAY = 300;

// Toast
const TOAST_TITLE_ERROR = 'Error';
const TOAST_TITLE_SUCCESS = 'Referral Created';
const TOAST_VARIANT_ERROR = 'error';
const TOAST_VARIANT_SUCCESS = 'success';

// Labels
const LABEL_NOT_SPECIFIED = 'Not specified';
const LABEL_NONE = 'None';
const LABEL_ACCEPTING = 'Accepting';
const LABEL_NOT_ACCEPTING = 'Not Accepting';
const LABEL_ALL_SPECIALTIES = 'All Specialties';
const MSG_UNKNOWN_ERROR = 'Unknown error';
const DEFAULT_PRIORITY = 'Routine';

// Priority options
const PRIORITY_OPTIONS = [
    { label: 'Routine', value: 'Routine' },
    { label: 'Urgent', value: 'Urgent' },
    { label: 'ASAP', value: 'ASAP' },
    { label: 'STAT', value: 'STAT' }
];

// CSS classes
const CSS_PROVIDER_CARD = 'referralWizard__providerCard slds-box slds-box_small';
const CSS_PROVIDER_CARD_SELECTED = 'referralWizard__providerCard referralWizard__providerCard--selected slds-box slds-box_small';
const CSS_BADGE_ACCEPTING = 'referralWizard__badge referralWizard__badge--accepting';
const CSS_BADGE_NOT_ACCEPTING = 'referralWizard__badge referralWizard__badge--notAccepting';

// Navigation
const NAV_TYPE_RECORD_PAGE = 'standard__recordPage';
const NAV_OBJECT_API_NAME = 'ClinicalServiceRequest';
const NAV_ACTION_VIEW = 'view';

export default class ReferralWizard extends NavigationMixin(LightningElement) {
    @api recordId;

    // Step tracking
    currentStep = STEP_PATIENT;

    // Step 1: Patient context
    patientContext;
    isLoadingPatient = true;
    patientError;

    // Step 2: Provider selection
    providerSearchTerm = '';
    selectedSpecialty = '';
    providers = [];
    selectedProviderId;
    selectedProvider;
    isLoadingProviders = false;
    _debounceTimer;

    // Step 3: Referral details
    priority = DEFAULT_PRIORITY;
    specialtyRequested = '';
    referralReason = '';
    referralNotes = '';

    // Step 4: Submission
    isSubmitting = false;

    // Specialty options
    specialtyOptions = [];

    get priorityOptions() {
        return PRIORITY_OPTIONS;
    }

    // ── Step getters ──

    get isStepPatient() {
        return this.currentStep === STEP_PATIENT;
    }

    get isStepProvider() {
        return this.currentStep === STEP_PROVIDER;
    }

    get isStepDetails() {
        return this.currentStep === STEP_DETAILS;
    }

    get isStepReview() {
        return this.currentStep === STEP_REVIEW;
    }

    get progressSteps() {
        return [
            { label: 'Patient Overview', value: String(STEP_PATIENT) },
            { label: 'Select Provider', value: String(STEP_PROVIDER) },
            { label: 'Referral Details', value: String(STEP_DETAILS) },
            { label: 'Review & Submit', value: String(STEP_REVIEW) }
        ];
    }

    get currentStepValue() {
        return String(this.currentStep);
    }

    // ── Navigation button visibility ──

    get showBackButton() {
        return this.currentStep > STEP_PATIENT;
    }

    get showNextButton() {
        return this.currentStep < STEP_REVIEW;
    }

    get showSubmitButton() {
        return this.currentStep === STEP_REVIEW;
    }

    get isNextDisabled() {
        if (this.currentStep === STEP_PATIENT) {
            return !this.patientContext;
        }
        if (this.currentStep === STEP_PROVIDER) {
            return !this.selectedProviderId;
        }
        if (this.currentStep === STEP_DETAILS) {
            return !this.referralReason;
        }
        return false;
    }

    // ── Patient context display helpers ──

    get patientFullName() {
        return this.patientContext ? this.patientContext.fullName : '';
    }

    get patientDOB() {
        return this.patientContext ? this.patientContext.dateOfBirth : LABEL_NOT_SPECIFIED;
    }

    get patientNRIC() {
        return this.patientContext ? this.patientContext.nric : LABEL_NOT_SPECIFIED;
    }

    get patientEmail() {
        return this.patientContext && this.patientContext.email
            ? this.patientContext.email : LABEL_NOT_SPECIFIED;
    }

    get patientPhone() {
        return this.patientContext && this.patientContext.phone
            ? this.patientContext.phone : LABEL_NOT_SPECIFIED;
    }

    get hasConditions() {
        return this.patientContext && this.patientContext.conditions && this.patientContext.conditions.length > 0;
    }

    get hasMedications() {
        return this.patientContext && this.patientContext.medications && this.patientContext.medications.length > 0;
    }

    get hasAllergies() {
        return this.patientContext && this.patientContext.allergies && this.patientContext.allergies.length > 0;
    }

    get conditionsList() {
        return this.patientContext ? this.patientContext.conditions : [];
    }

    get medicationsList() {
        return this.patientContext ? this.patientContext.medications : [];
    }

    get allergiesList() {
        return this.patientContext ? this.patientContext.allergies : [];
    }

    // ── Provider display helpers ──

    get hasProviders() {
        return this.providers && this.providers.length > 0;
    }

    get transformedProviders() {
        return this.providers.map(p => ({
            ...p,
            isSelected: p.id === this.selectedProviderId,
            cardClass: p.id === this.selectedProviderId ? CSS_PROVIDER_CARD_SELECTED : CSS_PROVIDER_CARD,
            acceptingLabel: p.isAccepting ? LABEL_ACCEPTING : LABEL_NOT_ACCEPTING,
            acceptingClass: p.isAccepting ? CSS_BADGE_ACCEPTING : CSS_BADGE_NOT_ACCEPTING,
            specialtyDisplay: p.specialty || LABEL_NONE,
            facilityDisplay: p.facility || LABEL_NONE
        }));
    }

    // ── Review display helpers ──

    get reviewPatientName() {
        return this.patientContext ? this.patientContext.fullName : '';
    }

    get reviewProviderName() {
        return this.selectedProvider ? this.selectedProvider.practitionerName : '';
    }

    get reviewProviderSpecialty() {
        return this.selectedProvider ? this.selectedProvider.specialty : '';
    }

    get reviewPriority() {
        return this.priority;
    }

    get reviewSpecialty() {
        return this.specialtyRequested || LABEL_NOT_SPECIFIED;
    }

    get reviewReason() {
        return this.referralReason;
    }

    get reviewNotes() {
        return this.referralNotes || LABEL_NONE;
    }

    // ── Lifecycle ──

    connectedCallback() {
        this.loadPatientContext();
    }

    disconnectedCallback() {
        clearTimeout(this._debounceTimer);
    }

    // ── Wire: Specialty options ──

    @wire(getSpecialtyOptions)
    wiredSpecialtyOptions({ error, data }) {
        if (data) {
            this.specialtyOptions = [{ label: LABEL_ALL_SPECIALTIES, value: '' }, ...data];
        } else if (error) {
            this.specialtyOptions = [{ label: LABEL_ALL_SPECIALTIES, value: '' }];
        }
    }

    // ── Step 1: Patient Context ──

    async loadPatientContext() {
        this.isLoadingPatient = true;
        this.patientError = undefined;
        try {
            this.patientContext = await getPatientContext({ accountId: this.recordId });
        } catch (error) {
            this.patientError = this.reduceErrors(error);
        } finally {
            this.isLoadingPatient = false;
        }
    }

    // ── Step 2: Provider Search ──

    handleProviderSearch(event) {
        this.providerSearchTerm = event.target.value;
        this.debounceProviderSearch();
    }

    handleSpecialtyFilter(event) {
        this.selectedSpecialty = event.detail.value;
        this.performProviderSearch();
    }

    debounceProviderSearch() {
        clearTimeout(this._debounceTimer);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._debounceTimer = setTimeout(() => {
            this.performProviderSearch();
        }, DEBOUNCE_DELAY);
    }

    async performProviderSearch() {
        this.isLoadingProviders = true;
        try {
            this.providers = await searchProviders({
                searchTerm: this.providerSearchTerm,
                specialty: this.selectedSpecialty
            });
        } catch (error) {
            this.showToast(TOAST_TITLE_ERROR, this.reduceErrors(error), TOAST_VARIANT_ERROR);
            this.providers = [];
        } finally {
            this.isLoadingProviders = false;
        }
    }

    handleProviderSelect(event) {
        const providerId = event.currentTarget.dataset.id;
        this.selectedProviderId = providerId;
        this.selectedProvider = this.providers.find(p => p.id === providerId);
        if (this.selectedProvider && this.selectedProvider.specialty) {
            this.specialtyRequested = this.selectedProvider.specialty;
        }
    }

    handleProviderKeydown(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            this.handleProviderSelect(event);
        }
    }

    // ── Step 3: Referral Details ──

    handlePriorityChange(event) {
        this.priority = event.detail.value;
    }

    handleSpecialtyRequestedChange(event) {
        this.specialtyRequested = event.target.value;
    }

    handleReasonChange(event) {
        this.referralReason = event.target.value;
    }

    handleNotesChange(event) {
        this.referralNotes = event.target.value;
    }

    // ── Navigation ──

    handleBack() {
        if (this.currentStep > STEP_PATIENT) {
            this.currentStep--;
        }
    }

    handleNext() {
        if (this.currentStep === STEP_PROVIDER && !this.hasProviders && this.providers.length === 0) {
            this.performProviderSearch();
        }
        if (this.currentStep < STEP_REVIEW) {
            this.currentStep++;
            if (this.currentStep === STEP_PROVIDER && this.providers.length === 0) {
                this.performProviderSearch();
            }
        }
    }

    // ── Step 4: Submit ──

    async handleSubmit() {
        this.isSubmitting = true;
        try {
            const request = {
                patientId: this.recordId,
                referredToProviderId: this.selectedProviderId,
                reason: this.referralReason,
                notes: this.referralNotes,
                priority: this.priority,
                specialtyRequested: this.specialtyRequested
            };

            const result = await submitReferral({
                requestJson: JSON.stringify(request)
            });

            this.showToast(
                TOAST_TITLE_SUCCESS,
                result.message,
                TOAST_VARIANT_SUCCESS
            );

            this[NavigationMixin.Navigate]({
                type: NAV_TYPE_RECORD_PAGE,
                attributes: {
                    recordId: result.referralId,
                    objectApiName: NAV_OBJECT_API_NAME,
                    actionName: NAV_ACTION_VIEW
                }
            });
        } catch (error) {
            this.showToast(TOAST_TITLE_ERROR, this.reduceErrors(error), TOAST_VARIANT_ERROR);
        } finally {
            this.isSubmitting = false;
        }
    }

    // ── Utility ──

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    reduceErrors(error) {
        if (!error) {
            return MSG_UNKNOWN_ERROR;
        }
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        }
        if (error.body && typeof error.body.message === 'string') {
            return error.body.message;
        }
        if (typeof error.message === 'string') {
            return error.message;
        }
        return error.statusText || MSG_UNKNOWN_ERROR;
    }
}
