import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTimelineEvents from '@salesforce/apex/PatientTimelineController.getTimelineEvents';

const FILTER_OPTIONS = [
    { label: 'All', value: 'all' },
    { label: 'Clinical', value: 'clinical' },
    { label: 'Administrative', value: 'administrative' },
    { label: 'Engagement', value: 'engagement' }
];

export default class PatientTimeline extends NavigationMixin(LightningElement) {
    @api recordId;

    events;
    error;
    isLoading = true;
    activeFilter = 'all';
    filterOptions = FILTER_OPTIONS;

    @wire(getTimelineEvents, { accountId: '$recordId', filterType: '$activeFilter' })
    wiredEvents({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.events = this.transformEvents(data);
            this.error = undefined;
        } else if (error) {
            this.error = this.reduceErrors(error);
            this.events = undefined;
        }
    }

    // --- Data transformation ---

    transformEvents(data) {
        return (data || []).map((evt) => ({
            ...evt,
            formattedDate: this.formatDate(evt.eventDate),
            formattedTime: this.formatTime(evt.eventDate),
            categoryClass: 'timeline__category timeline__category--' + evt.category,
            statusClass: this.getStatusClass(evt.status),
            isActiveFilter: this.activeFilter === evt.category || this.activeFilter === 'all'
        }));
    }

    // --- Computed properties ---

    get hasEvents() {
        return this.events && this.events.length > 0;
    }

    get eventCount() {
        return this.events ? this.events.length : 0;
    }

    get filterButtons() {
        return this.filterOptions.map((opt) => ({
            ...opt,
            variant: this.activeFilter === opt.value ? 'brand' : 'neutral',
            cssClass: 'timeline__filter-btn' +
                (this.activeFilter === opt.value ? ' timeline__filter-btn--active' : '')
        }));
    }

    // --- Event handlers ---

    handleFilterChange(event) {
        const newFilter = event.target.dataset.filter;
        if (newFilter && newFilter !== this.activeFilter) {
            this.activeFilter = newFilter;
            this.isLoading = true;
        }
    }

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

    // --- Formatting helpers ---

    formatDate(dateValue) {
        if (!dateValue) return '';
        return new Date(dateValue).toLocaleDateString('en-SG', {
            day: '2-digit',
            month: 'short',
            year: 'numeric'
        });
    }

    formatTime(dateValue) {
        if (!dateValue) return '';
        return new Date(dateValue).toLocaleTimeString('en-SG', {
            hour: '2-digit',
            minute: '2-digit',
            hour12: false
        });
    }

    getStatusClass(status) {
        const base = 'timeline__badge';
        if (!status) return base;
        switch (status.toLowerCase()) {
            case 'active':
            case 'in-progress':
            case 'in progress':
                return base + ' timeline__badge--active';
            case 'finished':
            case 'completed':
            case 'closed':
            case 'resolved':
                return base + ' timeline__badge--completed';
            case 'planned':
            case 'scheduled':
            case 'not started':
                return base + ' timeline__badge--planned';
            case 'cancelled':
            case 'entered-in-error':
                return base + ' timeline__badge--cancelled';
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
