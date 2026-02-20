import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getCareTeamForPatient from '@salesforce/apex/CareTeamController.getCareTeamForPatient';
import addTeamMember from '@salesforce/apex/CareTeamController.addTeamMember';
import updateTeamMember from '@salesforce/apex/CareTeamController.updateTeamMember';
import removeTeamMember from '@salesforce/apex/CareTeamController.removeTeamMember';
import searchProviders from '@salesforce/apex/CareTeamController.searchProviders';

const ROLE_OPTIONS = [
    { label: 'Primary Physician', value: 'Primary_Physician' },
    { label: 'Specialist', value: 'Specialist' },
    { label: 'Care Coordinator', value: 'Care_Coordinator' },
    { label: 'Nurse', value: 'Nurse' },
    { label: 'Allied Health', value: 'Allied_Health' },
    { label: 'Pharmacist', value: 'Pharmacist' }
];

const NOTIFICATION_OPTIONS = [
    { label: 'All Notifications', value: 'All' },
    { label: 'Critical Only', value: 'Critical Only' },
    { label: 'None', value: 'None' }
];

const ROLE_ICONS = {
    Primary_Physician: 'standard:user',
    Specialist: 'standard:calibration',
    Care_Coordinator: 'standard:case_wrap_up',
    Nurse: 'standard:people',
    Allied_Health: 'standard:partner_marketing_budget',
    Pharmacist: 'standard:medicine'
};

export default class CareTeamPanel extends LightningElement {
    @api recordId;

    // Wire result reference for refresh
    wiredCareTeamResult;

    // Data
    careTeamDetail;
    error;
    isLoading = true;

    // Modal state
    showAddModal = false;
    showEditModal = false;
    showRemoveConfirm = false;

    // Add member form
    providerSearchTerm = '';
    providerSearchResults = [];
    isSearching = false;
    selectedProvider = null;
    newMemberRole = '';
    newMemberIsPrimary = false;
    newMemberNotifPref = 'All';
    isSaving = false;

    // Edit member form
    editMemberId = null;
    editMemberRole = '';
    editMemberIsPrimary = false;
    editMemberNotifPref = 'All';
    editMemberProviderName = '';

    // Remove member
    removeMemberId = null;
    removeMemberName = '';

    // Options
    roleOptions = ROLE_OPTIONS;
    notificationOptions = NOTIFICATION_OPTIONS;

    @wire(getCareTeamForPatient, { patientAccountId: '$recordId' })
    wiredCareTeam(result) {
        this.wiredCareTeamResult = result;
        this.isLoading = false;
        if (result.data) {
            this.careTeamDetail = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = this.reduceErrors(result.error);
            this.careTeamDetail = undefined;
        }
    }

    // ── Computed properties ──

    get hasMembers() {
        return this.careTeamDetail &&
            this.careTeamDetail.members &&
            this.careTeamDetail.members.length > 0;
    }

    get memberCount() {
        return this.careTeamDetail && this.careTeamDetail.members
            ? this.careTeamDetail.members.length
            : 0;
    }

    get formattedMembers() {
        if (!this.careTeamDetail || !this.careTeamDetail.members) {
            return [];
        }
        return this.careTeamDetail.members.map((m) => ({
            ...m,
            roleLabel: this.getRoleLabel(m.role),
            roleIcon: ROLE_ICONS[m.role] || 'standard:user',
            roleBadgeClass: 'careTeam__role-badge careTeam__role-badge--' +
                (m.role || '').toLowerCase(),
            primaryBadge: m.isPrimary,
            formattedStartDate: m.startDate
                ? new Date(m.startDate).toLocaleDateString('en-SG', {
                    year: 'numeric', month: 'short', day: 'numeric'
                })
                : '',
            notifLabel: this.getNotifLabel(m.notificationPref)
        }));
    }

    get showEmptyState() {
        return !this.isLoading && !this.error && !this.hasMembers;
    }

    get hasSelectedProvider() {
        return this.selectedProvider !== null;
    }

    get selectedProviderName() {
        return this.selectedProvider ? this.selectedProvider.name : '';
    }

    get hasProviderResults() {
        return this.providerSearchResults.length > 0;
    }

    get canSaveNewMember() {
        return this.selectedProvider && this.newMemberRole && !this.isSaving;
    }

    get canSaveEdit() {
        return this.editMemberRole && !this.isSaving;
    }

    get hasPrimaryPhysician() {
        return this.careTeamDetail && this.careTeamDetail.hasPrimaryPhysician;
    }

    get showPrimaryWarning() {
        return this.showAddModal && this.newMemberIsPrimary && this.hasPrimaryPhysician;
    }

    get showEditPrimaryWarning() {
        return this.showEditModal && this.editMemberIsPrimary && this.hasPrimaryPhysician;
    }

    // ── Event handlers ──

    handleAddMember() {
        this.resetAddForm();
        this.showAddModal = true;
    }

    handleCloseAddModal() {
        this.showAddModal = false;
        this.resetAddForm();
    }

    handleEditMember(event) {
        const memberId = event.currentTarget.dataset.memberId;
        const member = this.careTeamDetail.members.find(
            (m) => m.memberId === memberId
        );
        if (!member) return;

        this.editMemberId = member.memberId;
        this.editMemberRole = member.role;
        this.editMemberIsPrimary = member.isPrimary;
        this.editMemberNotifPref = member.notificationPref || 'All';
        this.editMemberProviderName = member.providerName;
        this.showEditModal = true;
    }

    handleCloseEditModal() {
        this.showEditModal = false;
        this.resetEditForm();
    }

    handleRemoveMember(event) {
        const memberId = event.currentTarget.dataset.memberId;
        const member = this.careTeamDetail.members.find(
            (m) => m.memberId === memberId
        );
        if (!member) return;

        this.removeMemberId = memberId;
        this.removeMemberName = member.providerName;
        this.showRemoveConfirm = true;
    }

    handleCloseRemoveConfirm() {
        this.showRemoveConfirm = false;
        this.removeMemberId = null;
        this.removeMemberName = '';
    }

    // ── Provider search ──

    handleProviderSearch(event) {
        const term = event.target.value;
        this.providerSearchTerm = term;
        this.selectedProvider = null;

        if (!term || term.length < 2) {
            this.providerSearchResults = [];
            return;
        }

        this.executeSearch(term);
    }

    async executeSearch(term) {
        this.isSearching = true;
        try {
            const results = await searchProviders({ searchTerm: term });
            this.providerSearchResults = (results || []).map((r) => ({
                ...r,
                patientCountLabel: r.activePatientCount + ' active patients'
            }));
        } catch (err) {
            this.providerSearchResults = [];
        } finally {
            this.isSearching = false;
        }
    }

    handleSelectProvider(event) {
        const accountId = event.currentTarget.dataset.accountId;
        const provider = this.providerSearchResults.find(
            (r) => r.accountId === accountId
        );
        if (provider) {
            this.selectedProvider = provider;
            this.providerSearchResults = [];
            this.providerSearchTerm = provider.name;
        }
    }

    handleClearProvider() {
        this.selectedProvider = null;
        this.providerSearchTerm = '';
        this.providerSearchResults = [];
    }

    // ── Form fields ──

    handleNewRoleChange(event) {
        this.newMemberRole = event.detail.value;
        this.newMemberIsPrimary = event.detail.value === 'Primary_Physician';
    }

    handleNewPrimaryChange(event) {
        this.newMemberIsPrimary = event.target.checked;
    }

    handleNewNotifChange(event) {
        this.newMemberNotifPref = event.detail.value;
    }

    handleEditRoleChange(event) {
        this.editMemberRole = event.detail.value;
        this.editMemberIsPrimary = event.detail.value === 'Primary_Physician';
    }

    handleEditPrimaryChange(event) {
        this.editMemberIsPrimary = event.target.checked;
    }

    handleEditNotifChange(event) {
        this.editMemberNotifPref = event.detail.value;
    }

    // ── Save operations ──

    async handleSaveNewMember() {
        if (!this.canSaveNewMember) return;
        this.isSaving = true;

        try {
            await addTeamMember({
                patientAccountId: this.recordId,
                providerAccountId: this.selectedProvider.accountId,
                role: this.newMemberRole,
                isPrimary: this.newMemberIsPrimary,
                notificationPref: this.newMemberNotifPref
            });
            this.showAddModal = false;
            this.resetAddForm();
            await refreshApex(this.wiredCareTeamResult);
        } catch (err) {
            this.showToast('Error', this.reduceErrors(err), 'error');
        } finally {
            this.isSaving = false;
        }
    }

    async handleSaveEdit() {
        if (!this.canSaveEdit) return;
        this.isSaving = true;

        try {
            await updateTeamMember({
                memberId: this.editMemberId,
                role: this.editMemberRole,
                status: 'Active',
                isPrimary: this.editMemberIsPrimary,
                notificationPref: this.editMemberNotifPref
            });
            this.showEditModal = false;
            this.resetEditForm();
            await refreshApex(this.wiredCareTeamResult);
        } catch (err) {
            this.showToast('Error', this.reduceErrors(err), 'error');
        } finally {
            this.isSaving = false;
        }
    }

    async handleConfirmRemove() {
        if (!this.removeMemberId) return;
        this.isSaving = true;

        try {
            await removeTeamMember({ memberId: this.removeMemberId });
            this.showRemoveConfirm = false;
            this.removeMemberId = null;
            this.removeMemberName = '';
            await refreshApex(this.wiredCareTeamResult);
        } catch (err) {
            this.showToast('Error', this.reduceErrors(err), 'error');
        } finally {
            this.isSaving = false;
        }
    }

    // ── Helpers ──

    getRoleLabel(role) {
        const option = ROLE_OPTIONS.find((o) => o.value === role);
        return option ? option.label : (role || '').replace(/_/g, ' ');
    }

    getNotifLabel(pref) {
        const option = NOTIFICATION_OPTIONS.find((o) => o.value === pref);
        return option ? option.label : pref || 'All';
    }

    resetAddForm() {
        this.providerSearchTerm = '';
        this.providerSearchResults = [];
        this.selectedProvider = null;
        this.newMemberRole = '';
        this.newMemberIsPrimary = false;
        this.newMemberNotifPref = 'All';
        this.isSearching = false;
    }

    resetEditForm() {
        this.editMemberId = null;
        this.editMemberRole = '';
        this.editMemberIsPrimary = false;
        this.editMemberNotifPref = 'All';
        this.editMemberProviderName = '';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new CustomEvent('showtoast', {
            detail: { title, message, variant },
            bubbles: true,
            composed: true
        }));
    }

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
