# Checkpoint: LWC Testing Standards

## Priority
MEDIUM

## Objective
Validate Jest test presence and quality for logic-heavy LWC components, ensuring proper test coverage and black-box testing approach.

## Scope
Analyze Jest test files for:
- Test presence for logic-heavy components
- Test quality (black-box approach, @api methods)
- Code coverage levels
- Test structure and cleanup
- Mock usage and test isolation

## Review Standards
- **Official Salesforce Testing**: Jest for LWC testing framework
- **Coverage**: Not mandatory (unlike Apex 75%), but recommended for logic-heavy components
- **Approach**: Black-box testing focusing on @api methods, templates, events
- **Cleanup**: afterEach() for DOM reset between tests

## Input Requirements
```json
{
  "files": ["array of .js file paths for components"],
  "file_contents": ["array of file content strings"],
  "test_files": ["array of __tests__/*.test.js file paths if they exist"]
}
```

## Task

**Step 1: Identify Logic-Heavy Components**

Classify components based on complexity:

**Logic-Heavy (Tests RECOMMENDED)**:
- Components with complex event handlers
- Components with validation logic
- Components with state management (@track properties)
- Components with conditional rendering logic
- Components making Apex calls
- Components with @api methods that accept parameters

**Presentational (Tests OPTIONAL)**:
- Simple display components
- Components with only @api properties (no methods)
- Pure templating components
- Wrapper components with minimal logic

**Example Logic-Heavy Component:**
```javascript
export default class UserTypeSelector extends LightningElement {
    @track selectedOption;
    @track showVerificationModal = false;

    @api options = [];

    // Complex logic - should be tested
    handleSelection(event) {
        const selectedValue = event.target.dataset.value;
        this.selectedOption = this.options.find(opt => opt.value === selectedValue);

        // Validation logic
        if (this.selectedOption.requiresVerification) {
            this.showVerificationModal = true;
        } else {
            this.dispatchSelectionEvent();
        }
    }

    dispatchSelectionEvent() {
        this.dispatchEvent(new CustomEvent('selection', {
            detail: { value: this.selectedOption }
        }));
    }
}
```

**Step 2: Check Test File Existence**

For each logic-heavy component, check for corresponding test file:

**Expected Structure:**
```
force-app/main/default/lwc/
  userTypeSelector/
    userTypeSelector.js
    userTypeSelector.html
    userTypeSelector.css
    __tests__/
      userTypeSelector.test.js  ← Should exist for logic-heavy components
```

**Step 3: Test Quality Analysis (if tests exist)**

Review test files for quality indicators:

**Good Test Structure:**
```javascript
import { createElement } from 'lwc';
import UserTypeSelector from 'c/userTypeSelector';

describe('c-user-type-selector', () => {
    // ✅ Good - Cleanup between tests
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    // ✅ Good - Testing @api method behavior
    it('dispatches selection event for non-verified options', () => {
        const element = createElement('c-user-type-selector', {
            is: UserTypeSelector
        });
        element.options = [{ value: 'student', requiresVerification: false }];
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('selection', handler);

        const button = element.shadowRoot.querySelector('[data-value="student"]');
        button.click();

        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.value).toEqual({ value: 'student', requiresVerification: false });
    });

    // ✅ Good - Testing conditional logic
    it('shows verification modal for verified options', () => {
        const element = createElement('c-user-type-selector', {
            is: UserTypeSelector
        });
        element.options = [{ value: 'alumni', requiresVerification: true }];
        document.body.appendChild(element);

        const button = element.shadowRoot.querySelector('[data-value="alumni"]');
        button.click();

        // Wait for async DOM updates
        return Promise.resolve().then(() => {
            const modal = element.shadowRoot.querySelector('.verification-modal');
            expect(modal).not.toBeNull();
        });
    });
});
```

**Test Quality Indicators**:
1. ✅ Uses `afterEach()` for DOM cleanup
2. ✅ Tests @api methods and properties
3. ✅ Tests event dispatching
4. ✅ Tests conditional rendering
5. ✅ Uses black-box approach (no internal method testing)
6. ✅ Proper async handling with Promise.resolve()
7. ✅ Uses `jest.fn()` for mocking
8. ✅ Clear test descriptions

**Poor Test Indicators**:
1. ❌ No afterEach() cleanup
2. ❌ Testing private methods directly
3. ❌ No event testing
4. ❌ No template query testing
5. ❌ Incomplete assertions

**Step 4: Coverage Analysis (if available)**

If coverage data available, check:
- Overall component coverage percentage
- Untested code branches
- Untested event handlers

**Coverage Command:**
```bash
sfdx-lwc-jest --coverage
```

**Step 5: Mock Usage Review**

Validate proper mocking of Apex calls:

```javascript
// ✅ Good - Mocking Apex with jest.mock()
import getUserTypeOptions from '@salesforce/apex/FormController.getUserTypeOptions';

jest.mock(
    '@salesforce/apex/FormController.getUserTypeOptions',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

describe('c-user-type-selector with Apex', () => {
    it('loads options from Apex on mount', () => {
        getUserTypeOptions.mockResolvedValue([
            { label: 'Student', value: 'student' }
        ]);

        const element = createElement('c-user-type-selector', {
            is: UserTypeSelector
        });
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const options = element.shadowRoot.querySelectorAll('.option');
            expect(options.length).toBe(1);
        });
    });
});
```

## Output Format
```json
{
  "checkpoint_name": "testing-standards",
  "checkpoint_priority": "MEDIUM",
  "status": "pass|warning",
  "violations": [
    {
      "severity": "medium|low",
      "category": "Testing Standards",
      "file": "[component path]",
      "issue": "[description of missing/poor tests]",
      "fix_guidance": "[how to add/improve tests]",
      "confidence": 0.6
    }
  ],
  "summary": {
    "logic_heavy_components": "[count]",
    "components_with_tests": "[count]",
    "components_without_tests": "[count]",
    "test_quality_score": "[0.0-1.0 if tests exist]",
    "coverage_percentage": "[percentage if available]",
    "production_blocker": false
  }
}
```

**Status Logic:**
- `status: "warning"` if logic-heavy components lack tests
- `status: "pass"` if all logic-heavy components have quality tests OR all components are presentational

## Confidence Scoring
- **Test file existence**: 0.9 (objective file system check)
- **Logic complexity assessment**: 0.6 (requires code understanding)
- **Test quality evaluation**: 0.6 (subjective assessment)
- **Coverage metrics**: 0.9 (objective if available)

## Success Criteria
- Logic-heavy components identified correctly
- Missing tests flagged with clear guidance
- Test quality assessed with specific improvement recommendations
- Coverage gaps highlighted if data available

## Fix Guidance Template

### Missing Tests
```javascript
// Component: userTypeSelector.js
// Missing: __tests__/userTypeSelector.test.js

// Create test file:
import { createElement } from 'lwc';
import UserTypeSelector from 'c/userTypeSelector';

describe('c-user-type-selector', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders with options', () => {
        const element = createElement('c-user-type-selector', {
            is: UserTypeSelector
        });
        element.options = [
            { label: 'Student', value: 'student' }
        ];
        document.body.appendChild(element);

        const options = element.shadowRoot.querySelectorAll('.option');
        expect(options.length).toBe(1);
    });

    it('dispatches selection event on click', () => {
        const element = createElement('c-user-type-selector', {
            is: UserTypeSelector
        });
        element.options = [{ label: 'Student', value: 'student' }];
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('selection', handler);

        const button = element.shadowRoot.querySelector('[data-value="student"]');
        button.click();

        expect(handler).toHaveBeenCalled();
    });
});

// Run tests:
npm run test:unit -- userTypeSelector
```

### Poor Test Quality
```javascript
// ❌ Bad - No cleanup, testing private methods
describe('c-user-type-selector', () => {
    it('calls internal method', () => {
        const element = createElement('c-user-type-selector', {
            is: UserTypeSelector
        });
        element._internalMethod();  // Testing private method
    });
});

// ✅ Good - Black-box testing with cleanup
describe('c-user-type-selector', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('shows verification modal when required', () => {
        const element = createElement('c-user-type-selector', {
            is: UserTypeSelector
        });
        element.options = [{ value: 'alumni', requiresVerification: true }];
        document.body.appendChild(element);

        const button = element.shadowRoot.querySelector('[data-value="alumni"]');
        button.click();

        return Promise.resolve().then(() => {
            const modal = element.shadowRoot.querySelector('.verification-modal');
            expect(modal).not.toBeNull();
        });
    });
});
```
