import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTemplates from '@salesforce/apex/CarePlanTemplateController.getTemplates';

export default class CarePlanTemplateManager extends LightningElement {
    @track templates = [];
    @track selectedTemplateId = null;

    isLoading = true;
    errorMessage = '';
    showEditor = false;
    editorMode = 'view';

    wiredTemplatesResult;

    @wire(getTemplates)
    wiredTemplates(result) {
        this.wiredTemplatesResult = result;
        this.isLoading = false;
        if (result.data) {
            this.templates = result.data;
            this.errorMessage = '';
        } else if (result.error) {
            this.errorMessage = this.reduceErrors(result.error);
            this.templates = [];
        }
    }

    get hasTemplates() {
        return this.templates.length > 0;
    }

    get hasError() {
        return this.errorMessage !== '';
    }

    get templateCount() {
        return this.templates.length;
    }

    get formattedTemplates() {
        return this.templates.map(t => ({
            ...t,
            versionDisplay: 'v' + (t.version || 1),
            goalBadge: t.goalCount + ' goals',
            taskBadge: t.taskCount + ' tasks',
            lastModified: t.lastModifiedDate
                ? new Date(t.lastModifiedDate).toLocaleDateString('en-SG', {
                    year: 'numeric', month: 'short', day: 'numeric'
                })
                : '-',
            rowClass: t.id === this.selectedTemplateId
                ? 'templateManager__row templateManager__row--selected'
                : 'templateManager__row'
        }));
    }

    handleSelectTemplate(event) {
        const templateId = event.currentTarget.dataset.id;
        this.selectedTemplateId = templateId;
        this.editorMode = 'view';
        this.showEditor = true;
    }

    handleNewTemplate() {
        this.selectedTemplateId = null;
        this.editorMode = 'create';
        this.showEditor = true;
    }

    handleEditTemplate(event) {
        event.stopPropagation();
        const templateId = event.currentTarget.dataset.id;
        this.selectedTemplateId = templateId;
        this.editorMode = 'edit';
        this.showEditor = true;
    }

    handleEditorClose() {
        this.showEditor = false;
        this.selectedTemplateId = null;
        return refreshApex(this.wiredTemplatesResult);
    }

    handleEditorSaved() {
        this.showEditor = false;
        this.selectedTemplateId = null;
        return refreshApex(this.wiredTemplatesResult);
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
