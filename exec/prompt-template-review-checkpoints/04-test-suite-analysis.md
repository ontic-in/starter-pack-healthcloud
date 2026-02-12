# Checkpoint: Test Suite Analysis (Kent Beck TDD Principles)

## Priority
CRITICAL

## Objective
Evaluate test suite quality following Kent Beck's TDD principles: tests as executable specifications, test names tell stories, tests communicate intent, and tests are cheap to read.

## Scope
This checkpoint analyzes test suite quality:
- Test names tell stories vs. generic names
- Tests as specification (can you understand prompt from tests?)
- Communication quality and readability
- Behavioral focus (testing "what", not "how")
- Kent Beck test desiderata

**NOT in scope:**
- Prompt quality (covered in CP1-3)
- Test data management (covered in CP6)
- Behavior-to-test mapping (covered in CP5)

## Review Standards
**Reference**: Kent Beck TDD philosophy (2024)

### Kent Beck Principles:

**1. Test Names Tell Stories**
- ❌ Bad: `test1()`, `testPrompt()`, `basicTest()`
- ✅ Good: `should_return_found_false_when_search_results_are_empty()`

**2. Tests as Executable Specifications**
- Reading tests reveals what system does
- Tests document all prompt behaviors
- Tests are living documentation

**3. Tests Communicate Intent**
- Clear scenario descriptions
- Reveals purpose, not just verifies
- Written for human understanding

**4. Cheap to Read**
- Immediately understandable
- No deep diving required
- Clear structure and assertions

**5. Behavioral Focus**
- Tests validate outputs ("what")
- Not implementation details ("how")
- Sensitive to behavior changes, insensitive to structure changes

## Input Requirements
```json
{
  "test_suite_content": "[Full test file content]",
  "test_file_name": "[Name of test file]"
}
```

## Task

### Step 1: Parse Test Suite
Extract all test cases:
- Test function names
- Test descriptions (from `it()`, `test()`, `describe()` blocks)
- Test structure (setup, execution, assertions)
- Test count by category

### Step 2: Evaluate Test Names (Stories)
For each test, assess if name tells a story:

**Story-telling names** (✅):
```typescript
"should return Found=true when relevant SIM content exists"
"should detect assumption language and set Found=false"
"should handle empty search results gracefully"
```

**Generic names** (❌):
```typescript
"test1()"
"testPrompt()"
"basicValidation()"
"edgeCaseTest()"
```

**Count**:
- tests_with_story_names: [count]
- tests_with_generic_names: [count]

**Ratio**: story_names / total_tests

**Assessment**:
- "yes" if >= 90% tell stories
- "partial" if 50-89% tell stories
- "no" if < 50% tell stories

### Step 3: Tests as Specification Quality
Ask: "Can I understand what the prompt does by reading tests alone?"

**Excellent specification**:
- All major behaviors covered by named tests
- Test names describe scenarios completely
- Edge cases explicitly tested
- Reading test names = understanding prompt

**Poor specification**:
- Generic test names don't describe scenarios
- Major behaviors not tested
- Can't understand prompt from tests

**Assessment**: excellent | good | poor

### Step 4: Communication Quality
Evaluate how clearly tests reveal intent:

**Clear communication**:
- Descriptive test names
- Logical grouping (`describe` blocks)
- Clear assertions with messages
- Scenarios are obvious

**Unclear communication**:
- Vague test names
- No grouping or context
- Generic assertions
- Scenarios require code reading

**Assessment**: clear | moderate | unclear

### Step 5: Cheap to Read
Can you understand tests immediately?

**Cheap to read** (✅):
- Test name reveals scenario
- Setup is minimal and clear
- Assertions are specific
- No complex logic in tests

**Not cheap to read** (❌):
- Must read implementation to understand
- Complex setup obscures intent
- Vague assertions
- Logic-heavy tests

**Assessment**: yes | partial | no

### Step 6: Behavioral Focus
Do tests check "what" (output) vs "how" (implementation)?

**Behavioral** (✅):
```typescript
expect(result.found).toBe(false); // What: output value
expect(result.response).toContain("can only help with SIM");
```

**Structural** (❌):
```typescript
expect(prompt.hasRole Section).toBe(true); // How: implementation detail
expect(internalState.wasValidated).toBe(true); // How: internal logic
```

**Assessment**: yes | partial | no

### Step 7: Extract Test Scenarios
Create list of all test scenarios (for CP5 alignment):

Format:
```json
{
  "scenario": "[What this test validates]",
  "test_name": "[Actual test function name]",
  "tells_story": true|false,
  "behavior_focus": "behavioral|structural|mixed"
}
```

### Step 8: Identify Violations
Flag Kent Beck violations:

**CRITICAL**:
- All tests have generic names (fails specification principle)
- Tests don't reveal any prompt behaviors

**HIGH**:
- > 50% generic test names
- Tests as specification = "poor"
- Tests not cheap to read

**MEDIUM**:
- Some generic names
- Partial specification quality

## Output Format

```json
{
  "checkpoint_name": "test-suite-analysis",
  "checkpoint_priority": "CRITICAL",
  "status": "pass|warning|fail",
  "test_file_analyzed": "[test file name]",
  "total_test_count": "[number]",
  "kent_beck_assessment": {
    "tests_tell_stories": "yes|partial|no",
    "story_telling_evidence": {
      "tests_with_story_names": "[count]",
      "tests_with_generic_names": "[count]",
      "story_ratio": "[percentage]",
      "example_good_names": ["[test names that tell stories]"],
      "example_bad_names": ["[generic test names to fix]"]
    },
    "tests_as_specification": "excellent|good|poor",
    "specification_rationale": "[Can you understand prompt from tests alone? Why/why not?]",
    "communication_quality": "clear|moderate|unclear",
    "communication_assessment": "[Do tests reveal intent clearly?]",
    "cheap_to_read": "yes|partial|no",
    "readability_notes": "[Are tests immediately understandable?]",
    "behavioral_focus": "yes|partial|no",
    "behavior_assessment": "[Do tests check 'what' not 'how'?]"
  },
  "test_scenarios_identified": [
    {
      "scenario": "[Description of what test validates]",
      "test_name": "[Actual test name]",
      "tells_story": true|false,
      "cheap_to_read": true|false,
      "behavioral_focus": "behavioral|structural|mixed"
    }
  ],
  "test_categorization": {
    "success_scenarios": {
      "count": "[number]",
      "assessment": "[Quality of success coverage]"
    },
    "failure_scenarios": {
      "count": "[number]",
      "assessment": "[Quality of failure coverage]"
    },
    "edge_cases": {
      "count": "[number]",
      "assessment": "[Quality of edge case coverage]"
    }
  },
  "violations": [
    {
      "severity": "critical|high|medium|low",
      "category": "Test Suite Quality",
      "kent_beck_principle": "[Which principle violated]",
      "issue": "[Specific issue]",
      "evidence": "[Test names or patterns]",
      "impact": "[Why this hurts specification quality]",
      "fix_guidance": "[How to improve]",
      "example_before": "[Current bad pattern]",
      "example_after": "[Improved pattern following Kent Beck]",
      "confidence": 0.7
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "critical_count": "[number]",
    "high_count": "[number]",
    "medium_count": "[number]",
    "low_count": "[number]",
    "overall_kent_beck_quality": "excellent|good|poor",
    "specification_completeness": "complete|partial|minimal",
    "production_blocker": "[true if tests don't serve as specification]"
  }
}
```

**Status Logic:**
- `status: "pass"` if tests_tell_stories = "yes" AND tests_as_specification >= "good"
- `status: "fail"` if tests_tell_stories = "no" OR tests_as_specification = "poor"
- `status: "warning"` if tests_tell_stories = "partial" OR tests_as_specification = "good"

## Success Criteria
- All test names evaluated for story-telling quality
- Kent Beck principles assessed with evidence
- Test scenarios extracted (for CP5 alignment)
- Violations identified with specific examples
- Clear guidance on improving test names

## Confidence Scoring
**Test suite analysis: 0.7 confidence**

Rationale:
- Kent Beck principles are established but subjective to apply
- "Story-telling" quality requires judgment
- "Cheap to read" is subjective
- Specification quality has clear criteria but nuanced assessment

## Examples

### Example: Excellent Kent Beck Quality
```typescript
describe('Lead Qualification Prompt', () => {
  it('should return qualified=true when lead has Bachelor degree and year 2024', async () => {
    const result = await qualifyLead({ degree: 'Bachelor', year: '2024' });
    expect(result.qualified).toBe(true);
  });

  it('should return qualified=false when lead has no degree', async () => {
    const result = await qualifyLead({ degree: null });
    expect(result.qualified).toBe(false);
  });

  it('should detect invalid year format and return validation error', async () => {
    const result = await qualifyLead({ year: 'invalid' });
    expect(result.error).toContain('year format');
  });
});
```

**Assessment**:
- tests_tell_stories: "yes" (100% descriptive names)
- tests_as_specification: "excellent" (understand prompt from tests)
- cheap_to_read: "yes"
- behavioral_focus: "yes"

### Example: Poor Kent Beck Quality
```typescript
test('test1', () => { expect(result).toBeTruthy(); });
test('test2', () => { expect(prompt.validate()).toBe(true); });
test('edgeCase', () => { /* ... */ });
```

**Assessment**:
- tests_tell_stories: "no" (all generic names)
- tests_as_specification: "poor" (can't understand from names)
- Violations: CRITICAL - all generic names

## Shared Context for Subsequent Checkpoints

Provides test scenarios for CP5 alignment:
```json
{
  "test_scenarios": [
    {
      "scenario": "Returns qualified=true for Bachelor 2024",
      "test_name": "should return qualified=true...",
      "tells_story": true
    },
    "..."
  ],
  "tests_tell_stories_rating": "yes|partial|no",
  "tests_as_specification_rating": "excellent|good|poor"
}
```
