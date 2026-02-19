import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTemplateDetail from '@salesforce/apex/CarePlanTemplateController.getTemplateDetail';
import saveTemplate from '@salesforce/apex/CarePlanTemplateController.saveTemplate';
import saveGoal from '@salesforce/apex/CarePlanTemplateController.saveGoal';
import saveTask from '@salesforce/apex/CarePlanTemplateController.saveTask';
import deleteGoal from '@salesforce/apex/CarePlanTemplateController.deleteGoal';
import deleteTask from '@salesforce/apex/CarePlanTemplateController.deleteTask';

const REVIEW_FREQUENCY_OPTIONS = [
    { label: 'Weekly', value: 'Weekly' },
    { label: 'Fortnightly', value: 'Fortnightly' },
    { label: 'Monthly', value: 'Monthly' },
    { label: 'Quarterly', value: 'Quarterly' },
    { label: '6-Monthly', value: '6-Monthly' },
    { label: 'Annually', value: 'Annually' },
    { label: 'Per Visit', value: 'Per Visit' },
    { label: 'Once', value: 'Once' }
];

const ROLE_OPTIONS = [
    { label: 'Primary Physician', value: 'Primary Physician' },
    { label: 'Specialist', value: 'Specialist' },
    { label: 'Care Coordinator', value: 'Care Coordinator' },
    { label: 'Nurse', value: 'Nurse' },
    { label: 'Allied Health', value: 'Allied Health' },
    { label: 'Pharmacist', value: 'Pharmacist' },
    { label: 'Admin Staff', value: 'Admin Staff' }
];

const FREQUENCY_OPTIONS = [
    { label: 'Every Visit', value: 'Every Visit' },
    { label: 'Weekly', value: 'Weekly' },
    { label: 'Fortnightly', value: 'Fortnightly' },
    { label: 'Monthly', value: 'Monthly' },
    { label: 'Quarterly', value: 'Quarterly' },
    { label: '6-Monthly', value: '6-Monthly' },
    { label: 'Annually', value: 'Annually' },
    { label: 'Once', value: 'Once' }
];

const PRIORITY_OPTIONS = [
    { label: 'High', value: 'High' },
    { label: 'Medium', value: 'Medium' },
    { label: 'Low', value: 'Low' }
];

export default class CarePlanTemplateEditor extends LightningElement {
    @api templateId;
    @api mode = 'view';

    @track detail = null;
    @track goals = [];
    @track tasks = [];

    templateName = '';
    templateDescription = '';
    icd10Code = '';
    mohGuidelineRef = '';

    isLoading = false;
    errorMessage = '';
    showAddGoal = false;
    showAddTask = false;

    newGoalName = '';
    newGoalTarget = '';
    newGoalMeasure = '';
    newGoalFrequency = '';

    newTaskSubject = '';
    newTaskRole = '';
    newTaskFrequency = '';
    newTaskPriority = 'Medium';

    get reviewFrequencyOptions() { return REVIEW_FREQUENCY_OPTIONS; }
    get roleOptions() { return ROLE_OPTIONS; }
    get frequencyOptions() { return FREQUENCY_OPTIONS; }
    get priorityOptions() { return PRIORITY_OPTIONS; }

    get isViewMode() { return this.mode === 'view'; }
    get isEditMode() { return this.mode === 'edit'; }
    get isCreateMode() { return this.mode === 'create'; }
    get isEditable() { return this.mode === 'edit' || this.mode === 'create'; }
    get hasError() { return this.errorMessage !== ''; }
    get hasGoals() { return this.goals.length > 0; }
    get hasTasks() { return this.tasks.length > 0; }
    get goalCount() { return this.goals.length; }
    get taskCount() { return this.tasks.length; }

    get modalTitle() {
        if (this.mode === 'create') return 'New Care Plan Template';
        if (this.mode === 'edit') return 'Edit Template';
        return this.templateName || 'Template Detail';
    }

    get versionDisplay() {
        if (!this.detail || !this.detail.template) return '';
        return 'v' + (this.detail.template.Version__c || 1);
    }

    connectedCallback() {
        if (this.templateId) {
            this.loadDetail();
        }
    }

    async loadDetail() {
        this.isLoading = true;
        this.errorMessage = '';
        try {
            this.detail = await getTemplateDetail({ templateId: this.templateId });
            this.templateName = this.detail.template.Name || '';
            this.templateDescription = this.detail.template.Description || '';
            this.icd10Code = this.detail.template.ICD10_Code__c || '';
            this.mohGuidelineRef = this.detail.template.MOH_Guideline_Ref__c || '';
            this.goals = this.detail.goals || [];
            this.tasks = this.detail.tasks || [];
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;
        const value = event.target.value;
        if (field === 'name') this.templateName = value;
        else if (field === 'description') this.templateDescription = value;
        else if (field === 'icd10') this.icd10Code = value;
        else if (field === 'moh') this.mohGuidelineRef = value;
    }

    async handleSaveTemplate() {
        if (!this.templateName) {
            this.errorMessage = 'Template name is required.';
            return;
        }
        this.isLoading = true;
        this.errorMessage = '';
        try {
            const templateData = {
                Name: this.templateName,
                Description: this.templateDescription,
                ICD10_Code__c: this.icd10Code,
                MOH_Guideline_Ref__c: this.mohGuidelineRef
            };
            if (this.templateId) {
                templateData.Id = this.templateId;
            }
            await saveTemplate({
                templateJson: JSON.stringify(templateData),
                isNewVersion: false
            });
            this.showToast('Success', 'Template saved successfully.', 'success');
            this.dispatchEvent(new CustomEvent('saved'));
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleNewVersion() {
        this.isLoading = true;
        this.errorMessage = '';
        try {
            await saveTemplate({
                templateJson: JSON.stringify({ Id: this.templateId }),
                isNewVersion: true
            });
            this.showToast('Success', 'New template version created.', 'success');
            this.dispatchEvent(new CustomEvent('saved'));
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleToggleAddGoal() {
        this.showAddGoal = !this.showAddGoal;
        this.newGoalName = '';
        this.newGoalTarget = '';
        this.newGoalMeasure = '';
        this.newGoalFrequency = '';
    }

    handleNewGoalChange(event) {
        const field = event.target.dataset.field;
        if (field === 'name') this.newGoalName = event.target.value;
        else if (field === 'target') this.newGoalTarget = event.target.value;
        else if (field === 'measure') this.newGoalMeasure = event.target.value;
        else if (field === 'frequency') this.newGoalFrequency = event.detail.value;
    }

    async handleSaveNewGoal() {
        if (!this.newGoalName || !this.templateId) return;
        this.isLoading = true;
        try {
            await saveGoal({
                goalJson: JSON.stringify({
                    CarePlanTemplateId: this.templateId,
                    Name: this.newGoalName,
                    Target_Value__c: this.newGoalTarget,
                    Measure__c: this.newGoalMeasure,
                    Review_Frequency__c: this.newGoalFrequency
                })
            });
            this.showAddGoal = false;
            await this.loadDetail();
            this.showToast('Success', 'Goal added.', 'success');
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleDeleteGoal(event) {
        const goalId = event.currentTarget.dataset.id;
        this.isLoading = true;
        try {
            await deleteGoal({ goalId });
            await this.loadDetail();
            this.showToast('Success', 'Goal removed.', 'success');
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleToggleAddTask() {
        this.showAddTask = !this.showAddTask;
        this.newTaskSubject = '';
        this.newTaskRole = '';
        this.newTaskFrequency = '';
        this.newTaskPriority = 'Medium';
    }

    handleNewTaskChange(event) {
        const field = event.target.dataset.field;
        if (field === 'subject') this.newTaskSubject = event.target.value;
        else if (field === 'role') this.newTaskRole = event.detail.value;
        else if (field === 'frequency') this.newTaskFrequency = event.detail.value;
        else if (field === 'priority') this.newTaskPriority = event.detail.value;
    }

    async handleSaveNewTask() {
        if (!this.newTaskSubject || !this.templateId) return;
        this.isLoading = true;
        try {
            await saveTask({
                taskJson: JSON.stringify({
                    CarePlanTemplateId: this.templateId,
                    Subject: this.newTaskSubject,
                    Assigned_Role__c: this.newTaskRole,
                    Task_Frequency__c: this.newTaskFrequency,
                    Priority: this.newTaskPriority
                })
            });
            this.showAddTask = false;
            await this.loadDetail();
            this.showToast('Success', 'Task added.', 'success');
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleDeleteTask(event) {
        const taskId = event.currentTarget.dataset.id;
        this.isLoading = true;
        try {
            await deleteTask({ taskId });
            await this.loadDetail();
            this.showToast('Success', 'Task removed.', 'success');
        } catch (error) {
            this.errorMessage = this.reduceErrors(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleSwitchToEdit() {
        this.mode = 'edit';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
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
