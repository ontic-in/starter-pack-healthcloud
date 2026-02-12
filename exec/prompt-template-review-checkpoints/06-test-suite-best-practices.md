# Checkpoint: Test Suite Best Practices

## Priority
MEDIUM

## Objective
Evaluate automated test suite implementation quality following testing best practices: proper setup/teardown, test data management avoiding tight coupling, test independence, and clean resource handling.

## Scope
This checkpoint analyzes test implementation quality:
- Setup/teardown patterns (beforeEach, afterEach, beforeAll, afterAll)
- Test data management (pre-created vs. dynamic creation)
- Avoiding tight coupling to specific data
- Test independence and isolation
- Mock/stub usage
- Assertion quality
- Resource cleanup

**NOT in scope:**
- Test naming (covered in CP4)
- Behavior coverage (covered in CP5)
- Prompt quality (covered in CP1-3)

## Review Standards
**Reference**: Automated testing best practices (Jest, Vitest, industry standards)

### Test Data Management Principles:

**✅ BEST PRACTICE: Dynamic Data Creation**
```typescript
beforeEach(async () => {
  // Creates fresh data every test - tests against real Salesforce
  testLead = await createLead({
    email: 'test@example.com',
    qualification: 'Bachelor\'s Degree',
    year: '2024'
  });
});

afterEach(async () => {
  await deleteLead(testLead.id); // Cleanup ensures isolation
});
```

**Benefits**:
- Tests validate prompt behavior against real Salesforce data
- Each test has isolated, predictable data
- No dependencies on pre-existing records that might change
- Proper setup/teardown ensures test independence
- Tests are self-contained and portable across orgs

**❌ ANTI-PATTERN: Pre-Created Test Data**
```typescript
// Hardcoded IDs - fragile and environment-dependent
const TEST_LEADS = {
  QUALIFIED_BACHELOR_2024: '00Q8600000FkGdqEAF',
  QUALIFIED_MASTER_2023: '00Q8600000FkGdrXYZ',
  UNQUALIFIED_NO_DEGREE: '00Q8600000FkGdsABC'
};

it('should qualify lead with Bachelor 2024', async () => {
  const result = await qualifyLead(TEST_LEADS.QUALIFIED_BACHELOR_2024);
  expect(result.qualified).toBe(true);
});
```

**Problems**:
- Hardcoded IDs only work in specific Salesforce org
- Records might be deleted or modified, breaking tests
- Cannot run tests in different environments (dev, staging, prod)
- No control over record state - data might drift
- Tests fail when run in fresh orgs or by other developers

### Test Independence Principles:
- Each test runs in isolation
- No execution order dependencies
- Tests don't share mutable state
- Can run tests in parallel safely

### Setup/Teardown Best Practices:
- Use `beforeEach` for test-specific setup (minimal)
- Use `beforeAll` for expensive one-time setup
- Clean up in `afterEach` ONLY if necessary
- Avoid cleanup if using pre-created data

## Input Requirements
```json
{
  "test_suite_content": "[Full test file]",
  "test_scenarios": ["[From CP4]"]
}
```

## Task

### Step 1: Analyze Setup/Teardown Patterns
Scan for `beforeEach`, `afterEach`, `beforeAll`, `afterAll`:

**Check for**:
- Are they present?
- What do they do?
- Is setup minimal or complex?
- Is cleanup necessary or over-engineered?

**Flag violations**:
- HIGH: Hardcoded Salesforce IDs (environment-dependent)
- MEDIUM: Missing beforeEach/afterEach for data setup
- HIGH: No setup when tests need shared context

### Step 2: Detect Test Data Coupling
Scan for hardcoded ID patterns:

**Anti-patterns to detect**:
```typescript
// Hardcoded Salesforce IDs
const LEAD_ID = '00Q8600000FkGdqEAF';
const TEST_LEADS = {
  QUALIFIED: '00Q8600000FkGdqEAF',
  UNQUALIFIED: '00Q8600000FkGdrXYZ'
};

// Direct use without setup
it('test', async () => {
  const result = await qualifyLead('00Q8600000FkGdqEAF');
});
```

**For each occurrence**:
- Flag as environment-dependent test data violation
- Recommend using dynamic data creation in beforeEach
- Suggest proper setup/teardown pattern

**Good patterns (no violation)**:
```typescript
beforeEach(async () => {
  testLead = await createLead({ /* fields */ });
});

afterEach(async () => {
  await deleteLead(testLead.id);
});
```

### Step 3: Assess Test Independence
Check if tests can run in any order:

**Independence violations**:
- Tests share mutable global state
- Test A creates data for Test B
- Tests numbered test1, test2 implying order
- Tests modify shared resources

**Independent patterns**:
- Each test has own data
- No side effects between tests
- Can run in parallel

**Assessment**: independent | mostly-independent | dependent

### Step 4: Evaluate Mock/Stub Usage
Check if external dependencies are mocked:

**Good mocking**:
```typescript
jest.mock('@salesforce/apex/LeadController.getLeadData');
// Mock specific function, not entire module
```

**Poor mocking**:
```typescript
jest.mock('entire-module'); // Too broad
// OR no mocking when external calls present
```

**Assessment**: proper | partial | none

### Step 5: Check Assertion Quality
Evaluate assertion specificity:

**Specific assertions** (✅):
```typescript
expect(result.qualified).toBe(true);
expect(result.reason).toContain('Bachelor degree');
expect(result.errors).toHaveLength(0);
```

**Vague assertions** (❌):
```typescript
expect(result).toBeTruthy(); // Too generic
expect(data).toBeDefined(); // Doesn't validate content
```

**Assessment**: specific | mostly-specific | vague

### Step 6: Identify Best Practice Violations
Categorize violations:

**HIGH Priority**:
- Hardcoded Salesforce IDs (environment-dependent tests)
- No test independence (tests affect each other)
- Missing mocks for external API calls

**MEDIUM Priority**:
- Missing setup/teardown methods
- Complex setup that could be simplified
- Incomplete mocking

**LOW Priority**:
- Minor assertion improvements
- Missing descriptive comments in setup
- Organization improvements

## Output Format

```json
{
  "checkpoint_name": "test-suite-best-practices",
  "checkpoint_priority": "MEDIUM",
  "status": "pass|warning|fail",
  "setup_teardown_analysis": {
    "has_beforeEach": true|false,
    "has_afterEach": true|false,
    "has_beforeAll": true|false,
    "has_afterAll": true|false,
    "setup_complexity": "minimal|moderate|complex",
    "setup_pattern_quality": "excellent|good|needs-improvement",
    "setup_notes": "[What setup does, is it appropriate?]"
  },
  "test_data_management": {
    "uses_precreated_data": true|false,
    "uses_dynamic_creation": true|false,
    "data_coupling_violations": [
      {
        "location": "[Line number or test name]",
        "pattern": "[What anti-pattern detected]",
        "evidence": "[Code snippet showing violation]",
        "recommended_fix": "[Use pre-created data constant]",
        "example": "[Show better pattern]"
      }
    ],
    "coupling_assessment": "well-decoupled|some-coupling|tightly-coupled",
    "coupling_notes": "[Analysis of test data approach]"
  },
  "test_independence": {
    "assessment": "independent|mostly-independent|dependent",
    "can_run_in_parallel": true|false,
    "shared_state_issues": [
      "[Issue 1: Tests modify global variable]",
      "[Issue 2: Test order dependencies]"
    ],
    "independence_notes": "[Do tests affect each other?]"
  },
  "mock_stub_usage": {
    "assessment": "proper|partial|none",
    "external_calls_mocked": true|false,
    "mocking_patterns": ["[List mocking approaches used]"],
    "mocking_notes": "[Quality of mock usage]"
  },
  "assertion_quality": {
    "assessment": "specific|mostly-specific|vague",
    "vague_assertions_count": "[count]",
    "specific_assertions_count": "[count]",
    "assertion_examples_good": ["[Good assertion examples]"],
    "assertion_examples_bad": ["[Vague assertion examples]"],
    "assertion_notes": "[Analysis of assertion specificity]"
  },
  "violations": [
    {
      "severity": "critical|high|medium|low",
      "category": "Test Best Practices",
      "subcategory": "data-coupling|test-independence|mocking|assertions|setup-teardown",
      "issue": "[Specific practice violation]",
      "evidence": "[Code showing violation]",
      "impact": "[Why this hurts test quality]",
      "fix_guidance": "[How to fix]",
      "example_before": "[Current bad pattern]",
      "example_after": "[Improved pattern]",
      "confidence": 0.8
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "critical_count": 0,
    "high_count": "[number]",
    "medium_count": "[number]",
    "low_count": "[number]",
    "data_coupling_violations_count": "[number]",
    "test_independence_score": "excellent|good|poor",
    "overall_best_practices_score": "excellent|good|poor",
    "production_blocker": false
  }
}
```

**Status Logic:**
- `status: "pass"` if overall_score = "excellent" AND no high violations
- `status: "warning"` if overall_score = "good" OR high violations > 0
- `status: "fail"` if overall_score = "poor" (would indicate severe issues)

## Success Criteria
- Setup/teardown patterns documented
- Test data coupling violations identified
- Test independence assessed
- Mock usage evaluated
- Assertion quality checked
- Actionable recommendations provided

## Confidence Scoring
**Best practices analysis: 0.8 confidence**

Rationale:
- Data coupling detection is pattern-based (0.9)
- Test independence requires understanding test logic (0.7)
- Mock usage assessment is objective (0.9)
- Assertion quality is mostly objective (0.8)
- Overall: high confidence in detecting patterns

## Examples

### Example 1: Excellent Best Practices
```typescript
let testLead;

// ✅ Dynamic data creation - tests against real Salesforce
beforeEach(async () => {
  testLead = await createLead({
    email: 'test@example.com',
    qualification: 'Bachelor\'s Degree',
    year: '2024'
  });
});

afterEach(async () => {
  await deleteLead(testLead.id);
});

// Mock external dependencies
jest.mock('@salesforce/apex/LeadController.getLeadData');

describe('Lead Qualification', () => {
  it('should qualify Bachelor 2024 lead', async () => {
    const result = await qualifyLead(testLead.id);
    expect(result.qualified).toBe(true);
    expect(result.reason).toContain('Bachelor');
  });

  it('should qualify Master 2023 lead independently', async () => {
    // Each test gets fresh data from beforeEach
    const result = await qualifyLead(testLead.id);
    expect(result.qualified).toBe(true);
  });
});
```

**Assessment**:
- data_coupling: "well-decoupled" (no hardcoded IDs)
- test_independence: "independent" (fresh data each test)
- mock_usage: "proper"
- assertion_quality: "specific"
- overall: "excellent"

### Example 2: Poor Practices (Environment-Dependent)
```typescript
// ❌ Hardcoded IDs - only work in specific org
const TEST_LEADS = {
  QUALIFIED_BACHELOR_2024: '00Q8600000FkGdqEAF',
  QUALIFIED_MASTER_2023: '00Q8600000FkGdrXYZ'
};

it('test1', async () => {
  // ❌ Will fail in different orgs
  const result = await qualifyLead(TEST_LEADS.QUALIFIED_BACHELOR_2024);
  expect(result).toBeTruthy(); // ❌ Vague assertion
});

it('test2', async () => {
  // ❌ Breaks if record is deleted from org
  const result = await qualifyLead(TEST_LEADS.QUALIFIED_MASTER_2023);
  // ❌ No control over record state
});
```

**Violations**:
- HIGH: Hardcoded Salesforce IDs (environment-dependent)
- HIGH: Tests will fail in different orgs or if records are deleted
- MEDIUM: Generic test names
- MEDIUM: Vague assertions
- Assessment: "poor"

## Shared Context for Final Report

This checkpoint contributes to overall test quality assessment:
```json
{
  "test_data_coupling_violations": number,
  "test_independence_score": "excellent|good|poor",
  "best_practices_violations": number
}
```
