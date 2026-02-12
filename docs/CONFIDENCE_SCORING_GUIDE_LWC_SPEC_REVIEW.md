# LWC Jest Spec Review Confidence Scoring Guide

## Overview
This guide provides confidence scoring (0.0-1.0) for **evaluating LWC Jest specification quality**. Confidence reflects how well a spec follows Kent Beck BDD principles adapted for JavaScript testing, not whether it passes (which should be 100% always).

**Core Principle**: Confidence = **Spec Quality Evidence**, not test pass rate or coverage percentage (coverage should be >80% for logic-heavy components).

## Quick Scoring for Spec Quality

### For ANY Jest Spec Evaluation:
START HERE → How well does this `it` block follow BDD principles?

1. **Excellent BDD Spec (0.8-1.0)**
   - One behavior tested → 0.8
   - Intent-revealing name (`it('should...')`) → +0.05
   - Kent Beck patterns (Given-When-Then, isolated) → +0.05
   - Proper LWC patterns (async, cleanup, Shadow DOM) → 0.9-1.0

2. **Good Functional Spec (0.6-0.7)**
   - Tests important behavior → 0.6
   - Name describes what, not how → +0.05
   - Mostly isolated, minor coupling → +0.05
   - Basic LWC patterns → 0.7

3. **Weak Spec (0.4-0.5)**
   - Tests multiple behaviors → 0.4
   - Generic name (`test button`) → 0.4
   - Tests implementation details (CSS classes) → 0.45
   - Missing cleanup or async handling → 0.5

4. **Poor Spec (0.1-0.3)**
   - No clear behavior → 0.1
   - Brittle/tightly coupled to internals → 0.2
   - Tests Salesforce framework, not component → 0.3

## Spec Quality Dimensions

### 1. Single Responsibility (Kent Beck Core Principle)
**Question**: Does `it` block test exactly ONE behavior?

- **1.0**: Single assertion, single behavior, single reason to fail
- **0.7**: Multiple related assertions, one behavior
- **0.4**: Tests 2-3 behaviors
- **0.1**: Tests many unrelated things

**Examples**:
```javascript
// 1.0: Single behavior
it('should return false for phone without + prefix', () => {
  const phone = new PhoneNumber("123456");
  expect(phone.isValid()).toBe(false);
});

// 0.4: Multiple behaviors
it('validates phone and shows error message', () => {
  expect(phone.isValid()).toBe(false);        // Behavior 1
  expect(phone.getErrorMessage()).toContain('+'); // Behavior 2
});
```

### 2. Intent-Revealing Names (Kent Beck)
**Question**: Does name express WHAT behavior, not HOW it's tested?

- **1.0**: Reads like specification: `it('should render avatar with 24px size')`
- **0.7**: Describes behavior: `it('renders avatar correctly')`
- **0.4**: Generic: `it('test avatar')`, `it('validates form')`
- **0.1**: Misleading or unclear

**Examples**:
```javascript
// 1.0: Intent-revealing
it('should disable submit button when required fields are empty')
it('should call onValid callback for valid phone format')

// 0.7: Functional but not specific
it('validates phone correctly')
it('renders form')

// 0.4: Generic
it('test button')
it('validates data')
```

### 3. Isolation (XP Principle for LWC)
**Question**: Can spec run independently without other specs?

- **1.0**: Fully isolated, own test data, proper DOM cleanup with `afterEach`
- **0.7**: Minor dependencies on test setup, has cleanup
- **0.4**: Missing DOM cleanup, potential test pollution
- **0.1**: Depends on execution order, breaks if other specs change

**LWC-Specific Isolation Requirements**:
- `afterEach` block removes all DOM elements: `while (document.body.firstChild) { document.body.removeChild(document.body.firstChild); }`
- Each test creates own component instance with `createElement`
- No shared component state between tests

**Examples**:
```javascript
// 1.0: Proper isolation
describe('PhoneNumber validation', () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it('should return false for invalid phone', () => {
    const phone = new PhoneNumber("123"); // Own test data
    expect(phone.isValid()).toBe(false);
  });
});

// 0.4: Missing cleanup (test pollution risk)
describe('Form tests', () => {
  // No afterEach cleanup!

  it('test 1', () => {
    const element = createElement('c-form', { is: Form });
    document.body.appendChild(element); // Never cleaned up
    // ...
  });
});
```

### 4. Behavior vs Implementation
**Question**: Does spec test WHAT component does, not HOW it does it?

- **1.0**: Tests public component behavior via `@api` properties, events, slots
- **0.7**: Tests behavior with minor implementation details
- **0.4**: Tightly coupled to CSS classes, internal DOM structure
- **0.1**: Tests private methods, internal state, framework behavior

**Examples**:
```javascript
// 1.0: Tests behavior (public API)
it('should disable submit button when form is invalid', () => {
  const element = createElement('c-form', { is: Form });
  document.body.appendChild(element);

  element.persona = ''; // Public API

  expect(element.isSubmitDisabled).toBe(true); // Public API
});

// 0.4: Tests implementation (CSS classes)
it('has submit-button--disabled class', () => {
  const element = createElement('c-form', { is: Form });
  document.body.appendChild(element);

  const button = element.shadowRoot.querySelector('.submit-button');
  expect(button.classList.contains('submit-button--disabled')).toBe(true); // Internal CSS
});
```

### 5. LWC Async Handling
**Question**: Does spec properly handle LWC's asynchronous DOM updates?

- **1.0**: Uses `await Promise.resolve()` after state changes before assertions
- **0.7**: Handles some async cases, may miss edge cases
- **0.4**: No async handling, tests may be flaky
- **0.1**: Incorrect async patterns causing false positives/negatives

**Examples**:
```javascript
// 1.0: Proper async handling
it('should show loading spinner during submission', async () => {
  const element = createElement('c-form', { is: Form });
  document.body.appendChild(element);

  const submitPromise = element.handleSubmit();

  await Promise.resolve(); // Wait for DOM update

  const spinner = element.shadowRoot.querySelector('.spinner');
  expect(spinner).not.toBeNull();

  await submitPromise; // Clean up async operation
});

// 0.4: Missing async handling (flaky test)
it('shows spinner', () => {
  const element = createElement('c-form', { is: Form });
  document.body.appendChild(element);

  element.handleSubmit();
  // No await! May query before DOM updates

  const spinner = element.shadowRoot.querySelector('.spinner');
  expect(spinner).not.toBeNull(); // May fail intermittently
});
```

### 6. Shadow DOM Awareness
**Question**: Does spec use proper Shadow DOM queries?

- **1.0**: Uses `element.shadowRoot.querySelector()` for component internals
- **0.7**: Mostly correct, minor query issues
- **0.4**: Uses `document.querySelector()` incorrectly (won't find Shadow DOM elements)
- **0.1**: Tests ignore Shadow DOM encapsulation

**Examples**:
```javascript
// 1.0: Correct Shadow DOM query
it('should render avatar element', () => {
  const element = createElement('c-form', { is: Form });
  document.body.appendChild(element);

  const avatar = element.shadowRoot.querySelector('.avatar'); // Correct
  expect(avatar).not.toBeNull();
});

// 0.4: Incorrect query (won't work)
it('renders avatar', () => {
  const element = createElement('c-form', { is: Form });
  document.body.appendChild(element);

  const avatar = document.querySelector('.avatar'); // Wrong! Shadow DOM hidden
  expect(avatar).not.toBeNull(); // Will fail
});
```

### 7. Describe Block Organization
**Question**: Are specs organized in logical describe blocks?

- **1.0**: Nested describe blocks group related behaviors by feature/method
- **0.7**: Basic describe organization, could be more granular
- **0.4**: Flat structure, all specs in one describe block
- **0.1**: No describe blocks or poor naming

**Examples**:
```javascript
// 1.0: Excellent organization
describe('PhoneNumber domain object', () => {
  describe('isValid() method', () => {
    it('should return false for phone without + prefix', () => { /* ... */ });
    it('should return false for < 6 digits', () => { /* ... */ });
  });

  describe('validate() callbacks', () => {
    it('should call onInvalid for invalid phone', () => { /* ... */ });
    it('should call onValid for valid phone', () => { /* ... */ });
  });
});

// 0.4: Flat organization
describe('PhoneNumber tests', () => {
  it('validates phone 1', () => { /* ... */ });
  it('validates phone 2', () => { /* ... */ });
  it('calls callback 1', () => { /* ... */ });
  it('calls callback 2', () => { /* ... */ });
  // 20 more tests without grouping...
});
```

## Common Spec Smells (Anti-Patterns)

### Multi-Behavior Spec
```javascript
// 0.3: Tests TWO behaviors
it('validates phone and returns error message', () => {
  const phone = new PhoneNumber("123");

  expect(phone.isValid()).toBe(false);        // Behavior 1: validation
  expect(phone.getErrorMessage()).toBeDefined(); // Behavior 2: error message
});
```
**Fix**: Split into `it('should return false for invalid format')` and `it('should return error message when invalid')`

### Testing Implementation Details
```javascript
// 0.4: Tests CSS class (implementation)
it('button has disabled class', () => {
  const element = createElement('c-form', { is: Form });
  document.body.appendChild(element);

  const button = element.shadowRoot.querySelector('button');
  expect(button.classList.contains('button--disabled')).toBe(true); // Brittle
});
```
**Fix**: Test behavior via public API: `expect(element.isSubmitDisabled).toBe(true)`

### Missing DOM Cleanup
```javascript
// 0.5: No cleanup - test pollution risk
describe('Form tests', () => {
  it('test 1', () => {
    const element = createElement('c-form', { is: Form });
    document.body.appendChild(element); // Never removed!
    // ...
  });

  it('test 2', () => {
    // May be affected by element from test 1
  });
});
```
**Fix**: Add `afterEach(() => { while (document.body.firstChild) { document.body.removeChild(document.body.firstChild); } })`

### Testing Framework, Not Component
```javascript
// 0.2: Tests Jest mocking, not component behavior
it('mock returns expected value', () => {
  const mockFn = jest.fn().mockReturnValue(true);
  expect(mockFn()).toBe(true); // Testing Jest, not our code
});
```
**Fix**: Test how component uses the mock, not the mock itself

### Incorrect Shadow DOM Query
```javascript
// 0.3: Won't find element in Shadow DOM
it('renders input', () => {
  const element = createElement('c-form', { is: Form });
  document.body.appendChild(element);

  const input = document.querySelector('input'); // Won't work
  expect(input).not.toBeNull(); // Will fail
});
```
**Fix**: Use `element.shadowRoot.querySelector('input')`

### No Async Handling
```javascript
// 0.5: Flaky test - may fail intermittently
it('updates display after data change', () => {
  const element = createElement('c-form', { is: Form });
  document.body.appendChild(element);

  element.data = { name: 'Test' };
  // No await! DOM may not have updated yet

  const display = element.shadowRoot.querySelector('.display');
  expect(display.textContent).toBe('Test'); // May fail
});
```
**Fix**: Add `await Promise.resolve()` after state change

## Spec Review Decision Framework

### Excellent Spec (0.8+): Keep As-Is
- Single behavior clearly specified
- Intent-revealing name (`it('should...')`)
- Isolated with proper DOM cleanup
- Tests behavior via public API
- Handles async properly
- Uses Shadow DOM queries correctly

### Good Spec (0.6-0.7): Minor Improvements
- Consider splitting if testing 2 behaviors
- Improve name to be more specific
- Add missing `afterEach` cleanup
- Fix async handling if missing

### Weak Spec (0.4-0.5): Refactor Needed
- Split multi-behavior specs into focused tests
- Rename to express specific intent
- Decouple from CSS classes/internal DOM
- Add proper cleanup and async handling
- Use Shadow DOM queries

### Poor Spec (0.1-0.3): Rewrite from Scratch
- Identify actual component behavior to specify
- Write new spec following Kent Beck + LWC patterns
- Delete old spec after new one passes

## LWC Jest Spec Quality Checklist

**Before Accepting a Spec**:
- [ ] Tests exactly one behavior per `it` block
- [ ] Name completes "it should..." with specific behavior
- [ ] Has clear Given-When-Then structure (explicit or implicit)
- [ ] Can run independently in any order
- [ ] Tests public component behavior (@api properties, events)
- [ ] Uses `element.shadowRoot.querySelector()` for Shadow DOM queries
- [ ] Handles async DOM updates with `await Promise.resolve()`
- [ ] Has `afterEach` DOM cleanup removing all test elements
- [ ] Mocks external dependencies (Apex, wire adapters)
- [ ] Organized in logical describe blocks by feature
- [ ] Fails for exactly one reason
- [ ] Passes when behavior is correct

## Weighted Confidence Calculation

When multiple dimensions apply, calculate weighted average:

### Formula
```
Overall Confidence = (Dimension1_Score * Weight1 + Dimension2_Score * Weight2) / Total_Weight
```

### Example 1: Good Spec with Minor Issues
**Spec**: Tests phone validation with proper structure but generic name

```
Single Responsibility: 1.0 (one behavior)
Naming: 0.7 (functional but not ideal)
Isolation: 1.0 (proper cleanup)
LWC Patterns: 1.0 (correct async/Shadow DOM)

Calculation:
(1.0 * 1.0 + 0.7 * 0.8 + 1.0 * 1.0 + 1.0 * 1.0) / 3.8 = 0.89

Overall Confidence: 0.9 (rounded)
```

### Example 2: Multi-Behavior with Implementation Coupling
**Spec**: Tests validation AND error message, uses CSS class assertions

```
Single Responsibility: 0.4 (two behaviors)
Naming: 0.6 (describes behaviors but not split)
Behavior vs Implementation: 0.4 (tests CSS classes)
Isolation: 1.0 (has cleanup)

Calculation:
(0.4 * 1.0 + 0.6 * 0.8 + 0.4 * 1.0 + 1.0 * 0.5) / 3.3 = 0.52

Overall Confidence: 0.5 (needs refactoring)
```

## Remember for LWC Spec Review

- Specs are executable documentation of component behavior
- Good specs survive CSS refactoring - bad specs break with class name changes
- Kent Beck: "Test what, not how" - test observable behavior, not internals
- One behavior = one reason to fail = one `it` block
- Intent-revealing names make specs self-documenting
- LWC DOM updates asynchronously - always use `await Promise.resolve()`
- Shadow DOM requires `element.shadowRoot` queries
- Proper cleanup prevents test pollution
- Organize specs in describe blocks by feature/method
- Test public component API, not internal implementation
