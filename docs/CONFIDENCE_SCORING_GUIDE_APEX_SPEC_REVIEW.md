# Apex Spec Review Confidence Scoring Guide

## Overview
This guide provides confidence scoring (0.0-1.0) for **evaluating specification quality** in Apex test classes. Confidence reflects how well a spec follows Kent Beck BDD principles, not whether it passes.

**Core Principle**: Confidence = **Spec Quality Evidence**, not merely test pass rate (which should be 100% always) or coverage percentage (should be >95% always).

## Quick Scoring for Spec Quality

### For ANY Spec Evaluation:
START HERE → How well does this spec follow BDD principles?

1. **Excellent BDD Spec (0.8-1.0)**
   - One behavior tested → 0.8
   - Intent-revealing name → +0.1
   - Kent Beck patterns (Given-When-Then, isolated) → 0.9-1.0

2. **Good Functional Spec (0.6-0.7)**
   - Tests important behavior → 0.6
   - Name describes what, not how → 0.65
   - Mostly isolated, minor coupling → 0.7

3. **Weak Spec (0.4-0.5)**
   - Tests multiple behaviors → 0.4
   - Generic name (testMethod1) → 0.4
   - Tests implementation details → 0.5

4. **Poor Spec (0.1-0.3)**
   - No clear behavior → 0.1
   - Brittle/tightly coupled → 0.2
   - Tests framework, not code → 0.3

## Spec Quality Dimensions

### 1. Single Responsibility (Kent Beck Core Principle)
**Question**: Does spec test exactly ONE behavior?

- **1.0**: Single assertion, single behavior, single reason to fail
- **0.7**: Multiple related assertions, one behavior
- **0.4**: Tests 2-3 behaviors
- **0.1**: Tests many unrelated things

**Examples**:
```apex
// 1.0: Single behavior
specMalformedJSONReturnsUserFriendlyError() {
    // ONLY tests error message for invalid JSON
}

// 0.4: Multiple behaviors
testUpdateLeadWithInvalidJSON() {
    // Tests error response AND error logging AND ...
}
```

### 2. Intent-Revealing Names (Kent Beck)
**Question**: Does name express WHAT behavior, not HOW it's tested?

- **1.0**: Reads like specification: "spec<Behavior>When<Condition>"
- **0.7**: Describes behavior: "testCreateLeadSuccess"
- **0.4**: Generic: "testMethod1", "testUpdateLead"
- **0.1**: Misleading or unclear

**Examples**:
```apex
// 1.0: Intent-revealing
specReturnsErrorMessageWhenJSONIsMalformed()
specInsertsRecordWithPopulatedID()

// 0.7: Functional but not BDD
testCreateLeadWithValidData()

// 0.4: Generic
testUpdateLead()
testMethod1()
```

### 3. Isolation (XP Principle)
**Question**: Can spec run independently without other specs?

- **1.0**: Fully isolated, own test data, no shared state
- **0.7**: Minor dependencies on test data setup
- **0.4**: Depends on order of execution
- **0.1**: Breaks if other specs change

### 4. Behavior vs Implementation
**Question**: Does spec test WHAT system does, not HOW it does it?

- **1.0**: Tests public behavior only
- **0.7**: Tests behavior with minor implementation details
- **0.4**: Tightly coupled to implementation
- **0.1**: Tests private methods, internal state

**Examples**:
```apex
// 1.0: Tests behavior
System.assertEquals(ERROR_USER_FRIENDLY, response.message);

// 0.4: Tests implementation
System.assertEquals('LeadFromExtractedPromptData.updateLead()', errorLog.Endpoint__c);
```

### 5. Given-When-Then Structure
**Question**: Is spec organized with clear Given-When-Then?

- **1.0**: Explicit Given-When-Then comments
- **0.7**: Implicit but clear structure
- **0.4**: Mixed setup and assertions
- **0.1**: No clear structure

## Common Spec Smells (Anti-Patterns)

### Multi-Behavior Spec
```apex
// 0.3: Tests TWO behaviors
testInvalidJSON() {
    // Asserts error response
    System.assertEquals(1, responses.size());
    // AND asserts error logging
    System.assertEquals(1, errorLogs.size());
}
```
**Fix**: Split into `specReturnsErrorResponse()` and `specLogsErrors()`

### Testing Infrastructure, Not Behavior
```apex
// 0.2: Tests Salesforce permission system
specCRUDSecurityViolation() {
    System.runAs(restrictedUser) {
        // Assumes Standard User lacks permissions - testing platform, not our code
    }
}
```
**Fix**: Test our security abstraction (SecureDataAccess), not Salesforce infrastructure

### Hardcoded Strings
```apex
// 0.5: Brittle to message changes
System.assertEquals('Sorry, there was an error', response.message);
```
**Fix**: Use named constants
```apex
System.assertEquals(MyClass.ERROR_MESSAGE, response.message);
```

## Spec Review Decision Framework

### Excellent Spec (0.8+): Keep As-Is
- Single behavior clearly specified
- Intent-revealing name
- Isolated and maintainable
- Tests behavior, not implementation

### Good Spec (0.6-0.7): Minor Improvements
- Consider splitting if testing 2 behaviors
- Improve name if generic
- Extract test data setup if coupled

### Weak Spec (0.4-0.5): Refactor Needed
- Split multi-behavior specs
- Rename to express intent
- Decouple from implementation details
- Add Given-When-Then structure

### Poor Spec (0.1-0.3): Rewrite from Scratch
- Identify actual behavior to specify
- Write new spec following Kent Beck principles
- Delete old spec after new one passes

## Spec Quality Checklist

**Before Accepting a Spec**:
- [ ] Tests exactly one behavior
- [ ] Name completes "It should..."
- [ ] Has clear Given-When-Then structure
- [ ] Can run independently
- [ ] Tests public behavior, not internals
- [ ] Uses named constants, not hardcoded strings
- [ ] Fails for exactly one reason
- [ ] Passes when behavior is correct

## Remember for Spec Review

- Specs are executable documentation - they define behavior
- Good specs survive refactoring - bad specs break with implementation changes
- Kent Beck: "Test what, not how"
- One behavior = one reason to fail = one spec
- Intent-revealing names make specs self-documenting
- Specs drive design, they don't just verify it