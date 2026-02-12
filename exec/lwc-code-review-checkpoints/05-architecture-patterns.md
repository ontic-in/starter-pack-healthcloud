# Checkpoint: LWC Architecture Patterns

## Priority
HIGH

## Objective
Validate component architecture, composition patterns, communication strategies, and reusability design following Salesforce LWC best practices.

## Scope
Analyze LWC component structure for:
- Component composition and hierarchy
- Communication patterns (events, LMS, @api)
- Single Responsibility Principle
- Reusability and modularity
- State management patterns
- Performance considerations

## Review Standards
- **Official Salesforce**: LWC Component Communication Guide
- **Architecture**: Component composition over inheritance
- **Communication**: Custom events for child-to-parent, @api for parent-to-child, LMS for cross-component
- **State**: @track for private reactive, @api for public properties
- **Performance**: Lazy loading, conditional rendering, wire efficiency

## Input Requirements
```json
{
  "files": ["array of .js/.html file paths"],
  "file_contents": ["array of file content strings"]
}
```

## Task

**Step 1: Component Composition Analysis**

Check for proper component hierarchy and responsibilities:

**Good Composition:**
```javascript
// ✅ Parent container component (orchestration only)
export default class PreChatContainer extends LightningElement {
    @track currentStep = 1;
    @track formData = {};

    handleStepComplete(event) {
        this.formData = { ...this.formData, ...event.detail };
        this.currentStep++;
    }
}

// ✅ Child step components (single responsibility)
export default class UserTypeStep extends LightningElement {
    @api options;
    selectedType;

    handleSelection(event) {
        this.selectedType = event.detail.value;
        this.dispatchEvent(new CustomEvent('stepcomplete', {
            detail: { userType: this.selectedType }
        }));
    }
}
```

**Poor Composition:**
```javascript
// ❌ God component (too many responsibilities)
export default class PreChatForm extends LightningElement {
    @track currentStep = 1;
    @track userType;
    @track name;
    @track email;
    @track phone;
    @track consent;
    @track errors = {};

    handleUserTypeChange() { /* ... */ }
    handleNameChange() { /* ... */ }
    handleEmailChange() { /* ... */ }
    handlePhoneChange() { /* ... */ }
    handleConsentChange() { /* ... */ }
    validateUserType() { /* ... */ }
    validateName() { /* ... */ }
    validateEmail() { /* ... */ }
    validatePhone() { /* ... */ }
    submitForm() { /* ... */ }
}
```

**Violation Criteria:**
- Component has > 300 lines of code
- Component manages > 5 different concerns
- Template has > 100 lines
- Component name doesn't reflect single responsibility

**Step 2: Communication Pattern Analysis**

Validate proper use of LWC communication methods:

**Child-to-Parent: Custom Events**
```javascript
// ✅ Good - Custom event with detail
this.dispatchEvent(new CustomEvent('selection', {
    detail: { value: this.selectedValue },
    bubbles: true,  // Optional: for multi-level propagation
    composed: true  // Optional: cross shadow DOM boundary
}));

// ❌ Bad - Trying to access parent directly
this.parent.handleSelection(this.selectedValue);  // Not possible in LWC
```

**Parent-to-Child: @api Properties/Methods**
```javascript
// ✅ Good - @api for parent communication
export default class ChildComponent extends LightningElement {
    @api
    set config(value) {
        this._config = value;
        this.processConfig();
    }
    get config() {
        return this._config;
    }

    @api
    reset() {
        this.selectedValue = null;
    }
}

// Parent usage:
this.template.querySelector('c-child-component').reset();

// ❌ Bad - No @api, not accessible from parent
export default class ChildComponent extends LightningElement {
    reset() {  // Not accessible without @api
        this.selectedValue = null;
    }
}
```

**Cross-Component: Lightning Message Service (LMS)**
```javascript
// ✅ Good - LMS for unrelated component communication
import { publish, MessageContext } from 'lightning/messageService';
import FORM_CHANNEL from '@salesforce/messageChannel/FormChannel__c';

export default class FormStep extends LightningElement {
    @wire(MessageContext)
    messageContext;

    publishUpdate() {
        publish(this.messageContext, FORM_CHANNEL, {
            stepComplete: true,
            data: this.formData
        });
    }
}

// ❌ Bad - Trying to use events across unrelated components
// Events don't work for sibling or cousin components
```

**Step 3: State Management Patterns**

Review state management approach:

**Proper State Decoration:**
```javascript
// ✅ Good - Clear state ownership
export default class FormComponent extends LightningElement {
    @api recordId;  // Public - parent controls
    @track formData = {};  // Private reactive - internal only
    errorMessage;  // Private non-reactive - no need for reactivity

    @wire(getRecord, { recordId: '$recordId' })
    wiredRecord({ error, data }) {
        if (data) {
            this.formData = this.processRecord(data);
        }
    }
}

// ❌ Bad - Unclear state ownership
export default class FormComponent extends LightningElement {
    @track recordId;  // Should be @api if parent controls
    formData = {};  // Should be @track if reactive
}
```

**Step 4: Reusability Assessment**

Check for reusable component design:

**Reusable Component Patterns:**
```javascript
// ✅ Good - Configurable, reusable
export default class DataSelector extends LightningElement {
    @api label;
    @api options;
    @api required = false;
    @api variant = 'standard';

    handleChange(event) {
        this.dispatchEvent(new CustomEvent('change', {
            detail: { value: event.target.value }
        }));
    }
}

// Usage in different contexts:
// <c-data-selector label="User Type" options={userTypes} required></c-data-selector>
// <c-data-selector label="Department" options={departments}></c-data-selector>

// ❌ Bad - Hardcoded, not reusable
export default class UserTypeSelector extends LightningElement {
    options = [
        { label: 'Student', value: 'student' },  // Hardcoded
        { label: 'Alumni', value: 'alumni' }
    ];

    // Can only be used for user types, not reusable for other selections
}
```

**Step 5: Performance Considerations**

Flag performance anti-patterns:

**Lazy Loading:**
```javascript
// ✅ Good - Lazy load heavy components
<template if:true={showAdvancedOptions}>
    <c-advanced-options-panel></c-advanced-options-panel>
</template>

// ❌ Bad - Always loaded even if not used
<div class={advancedPanelClass}>
    <c-advanced-options-panel></c-advanced-options-panel>
</div>
```

**Conditional Rendering:**
```javascript
// ✅ Good - if:true/if:false for boolean conditions
<template if:true={hasData}>
    <c-data-display data={records}></c-data-display>
</template>
<template if:false={hasData}>
    <p>No data available</p>
</template>

// ❌ Bad - Using CSS display:none (component still renders)
<div class={dataContainerClass}>
    <c-data-display data={records}></c-data-display>
</div>
```

**Wire Efficiency:**
```javascript
// ✅ Good - Wire caching enabled
@wire(getRecords, { recordId: '$recordId' })
wiredRecords;

// ❌ Suboptimal - Imperative call on every render
renderedCallback() {
    getRecords({ recordId: this.recordId })
        .then(data => this.records = data);
}
```

## Output Format
```json
{
  "checkpoint_name": "architecture-patterns",
  "checkpoint_priority": "HIGH",
  "status": "pass|fail|warning",
  "violations": [
    {
      "severity": "high|medium|low",
      "category": "Architecture: [subcategory]",
      "file": "[path]",
      "issue": "[description]",
      "evidence": "[code snippet]",
      "fix_guidance": "[refactoring recommendation]",
      "confidence": 0.7
    }
  ],
  "summary": {
    "god_components": "[count]",
    "communication_violations": "[count]",
    "state_management_issues": "[count]",
    "reusability_opportunities": "[count]",
    "performance_concerns": "[count]",
    "production_blocker": false
  }
}
```

**Status Logic:**
- `status: "fail"` if god components exist OR critical communication violations
- `status: "warning"` if reusability/performance improvements needed
- `status: "pass"` if architecture is solid

## Confidence Scoring
- **God component detection**: 0.8 (LOC + responsibility count)
- **Communication patterns**: 0.7 (pattern matching)
- **State management**: 0.7 (decorator analysis)
- **Reusability**: 0.6 (subjective assessment)
- **Performance**: 0.7 (pattern detection)

## Success Criteria
- God components identified with refactoring guidance
- Communication patterns validated against Salesforce best practices
- State management improvements recommended
- Reusability opportunities highlighted
- Performance optimizations suggested

## Fix Guidance Examples

### God Component Refactoring
```javascript
// ❌ Before - God component (300+ lines)
export default class PreChatForm extends LightningElement {
    // All form logic, validation, submission in one component
}

// ✅ After - Composed architecture
// preChatContainer.js (orchestration)
export default class PreChatContainer extends LightningElement {
    @track currentStep = 1;
    @track formData = {};
}

// userTypeStep.js (single responsibility)
export default class UserTypeStep extends LightningElement {
    @api options;
    // Only handles user type selection
}

// contactInfoStep.js (single responsibility)
export default class ContactInfoStep extends LightningElement {
    // Only handles contact information
}
```

### Communication Pattern Fix
```javascript
// ❌ Bad - Wrong communication method
export default class ChildComponent extends LightningElement {
    handleClick() {
        this.parentComponent.updateData();  // Can't access parent
    }
}

// ✅ Good - Custom event
export default class ChildComponent extends LightningElement {
    handleClick() {
        this.dispatchEvent(new CustomEvent('dataupdate', {
            detail: { data: this.data }
        }));
    }
}

// Parent handles event:
<c-child-component ondataupdate={handleDataUpdate}></c-child-component>
```

### State Management Fix
```javascript
// ❌ Bad - Unclear ownership
export default class FormComponent extends LightningElement {
    formData = {};  // Should be @track for reactivity
    @track recordId;  // Should be @api if parent-controlled
}

// ✅ Good - Clear state ownership
export default class FormComponent extends LightningElement {
    @api recordId;  // Public API - parent sets
    @track formData = {};  // Private reactive state
}
```
