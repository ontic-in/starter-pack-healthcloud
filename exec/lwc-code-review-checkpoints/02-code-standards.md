# Checkpoint: LWC Code Standards

## Priority
CRITICAL

## Objective
Validate LWC components follow Salesforce official coding standards, naming conventions, best practices, and architectural patterns.

## Scope
Manual code review focusing on:
- Naming conventions (camelCase, kebab-case, PascalCase)
- @wire vs imperative Apex calls
- Base lightning-* component usage
- ES6+ modern JavaScript patterns
- No hardcoded business values
- No DOM manipulation anti-patterns

## Review Standards
- Official Salesforce LWC Developer Guide
- ES6+ JavaScript standards
- Backend as source of truth principle
- Salesforce platform best practices

## Input Requirements
```json
{
  "files": ["array of .js/.html/.css file paths"],
  "file_contents": ["array of file content strings matching files array"],
  "eslint_context": ["Previous ESLint findings for cross-reference"]
}
```

## Task

**Step 1: Read All LWC Files**
- Parse JavaScript, HTML, and CSS files
- Identify component structure, properties, methods
- Map component dependencies and imports

**Step 2: Naming Convention Analysis**
Check for violations of official Salesforce naming standards:

**JavaScript (camelCase for properties/methods, PascalCase for classes)**:
```javascript
// ✅ Good
export default class MyComponent extends LightningElement {
    @track selectedOption;  // camelCase

    handleClick() {  // camelCase
        // logic
    }
}

// ❌ Bad
export default class my_component extends LightningElement {
    @track SelectedOption;  // Should be camelCase

    HandleClick() {  // Should be camelCase
        // logic
    }
}
```

**HTML (kebab-case for custom components)**:
```html
<!-- ✅ Good -->
<c-my-component></c-my-component>

<!-- ❌ Bad -->
<c-MyComponent></c-MyComponent>
<c-my_component></c-my_component>
```

**Step 3: @wire vs Imperative Analysis**
Flag imperative Apex calls when @wire could be used:

```javascript
// ❌ Suboptimal - Imperative when @wire would work
import getRecords from '@salesforce/apex/Controller.getRecords';

export default class MyComponent extends LightningElement {
    connectedCallback() {
        getRecords()
            .then(data => {
                this.records = data;
            });
    }
}

// ✅ Better - Use @wire for reactive architecture
import getRecords from '@salesforce/apex/Controller.getRecords';

export default class MyComponent extends LightningElement {
    @wire(getRecords)
    wiredRecords({ error, data }) {
        if (data) {
            this.records = data;
        }
    }
}
```

**When @wire is preferred**:
- Data doesn't change based on user interaction
- Read-only data fetching
- Need automatic refresh on parameter changes
- Want Lightning Data Service caching benefits

**When imperative is acceptable**:
- User-triggered actions (button clicks)
- Create/update/delete operations
- Complex conditional logic before calling Apex

**Step 4: Base Component Usage**
Flag custom implementations when base `lightning-*` components exist:

```javascript
// ❌ Bad - Reinventing the wheel
<input type="text" onchange={handleChange} />

// ✅ Good - Use base component
<lightning-input label="Name" value={name} onchange={handleChange}></lightning-input>
```

Common base components to check:
- `lightning-input` (text, number, email, etc.)
- `lightning-button`
- `lightning-combobox`
- `lightning-datatable`
- `lightning-record-form`
- `lightning-record-edit-form`

**Step 5: Hardcoded Business Values Detection**
Flag ANY hardcoded business logic, picklist values, configurations:

```javascript
// ❌ CRITICAL VIOLATION - Hardcoded business values
export default class UserTypeSelector extends LightningElement {
    options = [
        { label: 'Student', value: 'student' },
        { label: 'Alumni', value: 'alumni' },
        { label: 'Faculty', value: 'faculty' }
    ];
}

// ✅ Good - Retrieve from Apex
import getUserTypeOptions from '@salesforce/apex/FormController.getUserTypeOptions';

export default class UserTypeSelector extends LightningElement {
    @track options = [];

    @wire(getUserTypeOptions)
    wiredOptions({ error, data }) {
        if (data) {
            this.options = data;
        }
    }
}
```

**Hardcoded values to flag**:
- Picklist options
- Labels (use Custom Labels instead)
- Configuration values (use Custom Metadata/Settings)
- Status values
- Record type IDs
- User IDs
- Any business logic constants

**Step 6: DOM Manipulation Anti-Patterns**
Flag jQuery, Bootstrap, or direct DOM manipulation:

```javascript
// ❌ CRITICAL - DOM manipulation library
import $ from 'jquery';
$(this.template.querySelector('.element')).fadeIn();

// ❌ CRITICAL - Direct DOM manipulation
this.template.querySelector('.element').style.display = 'block';

// ✅ Good - LWC reactive rendering
@track isVisible = true;
// In HTML: class={elementClasses}
// In CSS: .element--visible { display: block; }
```

**Step 7: ES6+ Modern Patterns**
Flag old JavaScript patterns:

```javascript
// ❌ Bad - Old patterns
var self = this;
promise.then(function(data) {
    self.records = data;
});

// ✅ Good - ES6+ patterns
promise.then(data => {
    this.records = data;
});

// Or even better - async/await
async connectedCallback() {
    try {
        this.records = await getRecords();
    } catch (error) {
        // Handle error
    }
}
```

## Output Format
```json
{
  "checkpoint_name": "code-standards",
  "checkpoint_priority": "CRITICAL",
  "status": "pass|fail|warning",
  "violations": [
    {
      "severity": "critical|high|medium",
      "category": "Code Standards: [subcategory]",
      "file": "[path]",
      "line": "[number]",
      "issue": "[description]",
      "evidence": "[code snippet]",
      "fix_guidance": "[specific fix with code example]",
      "confidence": 0.7,
      "salesforce_reference": "[Official Salesforce doc link]"
    }
  ],
  "summary": {
    "naming_violations": "[count]",
    "wire_opportunities": "[count]",
    "base_component_opportunities": "[count]",
    "hardcoded_values": "[count]",
    "dom_anti_patterns": "[count]",
    "es6_improvements": "[count]",
    "production_blocker": "[true if hardcoded values or DOM anti-patterns exist]"
  }
}
```

**Status Logic:**
- `status: "fail"` if hardcoded values OR DOM anti-patterns exist
- `status: "warning"` if naming violations OR missed @wire opportunities
- `status: "pass"` if no violations

## Confidence Scoring
- **Hardcoded values**: 0.8 (clear code inspection)
- **DOM anti-patterns**: 0.9 (objective detection)
- **Naming conventions**: 0.7 (pattern matching)
- **@wire opportunities**: 0.6 (requires context understanding)
- **Base component usage**: 0.7 (known alternatives)

## Success Criteria
- All hardcoded business values flagged as CRITICAL
- DOM manipulation libraries flagged as CRITICAL
- Naming convention violations identified
- @wire opportunities suggested with rationale
- Base component alternatives provided
- ES6+ improvements recommended
