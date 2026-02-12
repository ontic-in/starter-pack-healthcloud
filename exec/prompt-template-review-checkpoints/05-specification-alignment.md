# Checkpoint: Specification Alignment

## Priority
CRITICAL

## Objective
Cross-reference prompt behaviors (from CP2) with test coverage (from CP4) to ensure tests serve as complete executable specification. Identify untested behaviors (CRITICAL GAPS) and orphan tests.

## Scope
This checkpoint performs the critical alignment analysis:
- Map every prompt behavior to corresponding tests
- Identify behaviors WITHOUT tests (specification gaps)
- Identify tests WITHOUT matching behaviors (orphans)
- Assess specification completeness
- Answer: "Can I understand the prompt from tests alone?"

**NOT in scope:**
- Extracting behaviors (done in CP2)
- Evaluating test quality (done in CP4)
- Test data management (done in CP6)

## Review Standards
**Core Principle**: Tests are executable specifications (Kent Beck)

### Specification Completeness Criteria:
- **Every behavior MUST have tests** - untested behaviors = incomplete specification
- **Every test MUST map to behaviors** - orphan tests = unclear specification
- **Test names MUST reveal behaviors** - generic names = poor documentation

### Alignment Quality Levels:
- **Excellent** (0.9-1.0): All behaviors tested, all tests map to behaviors, names tell stories
- **Good** (0.7-0.89): Most behaviors tested, minor gaps, mostly good names
- **Poor** (< 0.7): Major behaviors untested OR many generic names OR many orphan tests

## Input Requirements
```json
{
  "expected_behaviors": ["[From CP2: list of all prompt behaviors]"],
  "test_scenarios": [
    {
      "scenario": "[From CP4]",
      "test_name": "[From CP4]",
      "tells_story": true|false
    }
  ],
  "tests_tell_stories_rating": "yes|partial|no",
  "tests_as_specification_rating": "excellent|good|poor"
}
```

## Task

### Step 1: Map Behaviors to Tests
For EACH behavior from CP2, find matching test(s):

**Process**:
1. Take behavior: "Should return Found=true when relevant content exists"
2. Search test scenarios for matches
3. Match by semantic similarity, not exact text
4. Document which test(s) cover this behavior

**Mapping Example**:
```json
{
  "behavior": "Should return Found=true when relevant SIM content exists",
  "matched_tests": [
    "should return Found=true when search contains SIM information"
  ],
  "coverage_quality": "comprehensive|partial|minimal",
  "test_names_communicate": true
}
```

**Coverage Quality**:
- **Comprehensive**: Multiple tests cover different aspects of behavior
- **Partial**: One test covers behavior but not all edge cases
- **Minimal**: Test exists but name doesn't reveal behavior

### Step 2: Identify Untested Behaviors (CRITICAL)
Behaviors from CP2 with NO matching tests:

**For each untested behavior**:
- Document the behavior
- Assess risk (CRITICAL if core functionality)
- Explain why gap matters
- Suggest test name that would cover it

**Example**:
```json
{
  "behavior": "Should detect assumption language and set Found=false",
  "risk": "CRITICAL",
  "impact": "Core deflection logic untested - assumption detection could fail in production",
  "recommended_test_name": "should_detect_assumption_phrases_like_however_might_possibly_and_return_found_false"
}
```

**CRITICAL**: behaviors_without_tests.length MUST be 0 for PASS

### Step 3: Identify Orphan Tests
Tests from CP4 that don't map to any CP2 behavior:

**Possible reasons**:
- Test validates implementation detail (not behavior)
- Behavior exists but not documented in prompt
- Test is redundant or unclear

**For each orphan**:
- Document test name
- Explain why it's orphaned
- Recommend: add_to_prompt | remove_test | clarify_behavior

### Step 4: Calculate Alignment Score
```
alignment_score = (behaviors_with_tests / total_behaviors) * 0.6
                + (test_story_quality_bonus) * 0.2
                + (no_orphans_bonus) * 0.2

Where:
- behaviors_with_tests = count of behaviors that have test coverage
- total_behaviors = count from CP2
- test_story_quality_bonus = 1.0 if tests_tell_stories="yes", 0.5 if "partial", 0.0 if "no"
- no_orphans_bonus = 1.0 if orphan_tests.length === 0, else 0.0
```

**Interpretation**:
- >= 0.9: Excellent alignment
- 0.7-0.89: Good alignment
- < 0.7: Poor alignment (FAIL threshold)

### Step 5: Assess Specification Completeness
Answer: "Can I understand what the prompt does by reading tests alone?"

**YES** if:
- All behaviors have tests
- Test names tell clear stories
- No orphan tests
- Test scenarios reveal prompt logic

**PARTIAL** if:
- Most behaviors tested (80-99%)
- Some generic test names
- Few orphan tests

**NO** if:
- Major behaviors untested (< 80%)
- Many generic test names
- Can't understand prompt from tests

### Step 6: Identify Alignment Violations
**CRITICAL violations**:
- Core behaviors untested (e.g., main validation logic)
- > 30% behaviors without tests
- All tests have generic names

**HIGH violations**:
- Important behaviors untested (e.g., edge cases)
- 10-30% behaviors without tests
- > 50% tests with generic names

**MEDIUM violations**:
- Nice-to-have behaviors untested
- < 10% behaviors without tests
- Some orphan tests

## Output Format

```json
{
  "checkpoint_name": "specification-alignment",
  "checkpoint_priority": "CRITICAL",
  "status": "pass|warning|fail",
  "alignment_score": "[0.0-1.0]",
  "alignment_quality": "excellent|good|poor",
  "behaviors_with_tests": [
    {
      "behavior": "[From CP2]",
      "matched_tests": ["[test names]"],
      "coverage_quality": "comprehensive|partial|minimal",
      "test_names_communicate_behavior": true|false
    }
  ],
  "behaviors_without_tests": [
    {
      "behavior": "[Untested behavior from CP2]",
      "risk": "CRITICAL|HIGH|MEDIUM|LOW",
      "impact": "[Why this gap matters]",
      "recommended_test_name": "[Story-telling test name]",
      "example_test_structure": "[How test should be written]"
    }
  ],
  "orphan_tests": [
    {
      "test_name": "[Test with no matching behavior]",
      "issue": "[Why orphaned]",
      "resolution": "add_to_prompt|remove_test|clarify_behavior",
      "recommendation": "[What to do]"
    }
  ],
  "specification_completeness": {
    "can_understand_from_tests": "yes|partial|no",
    "rationale": "[Detailed: Can reading tests reveal prompt logic?]",
    "missing_specification_areas": ["[What's not documented in tests]"],
    "specification_quality_score": "[0.0-1.0]"
  },
  "violations": [
    {
      "severity": "critical|high|medium|low",
      "category": "Specification Alignment",
      "issue": "[Specific gap]",
      "evidence": "[Untested behaviors or orphan tests]",
      "impact": "[Why incomplete specification matters]",
      "fix_guidance": "[Add test with story-telling name]",
      "example_test_name": "[Suggested name]",
      "confidence": 0.8
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "critical_count": "[number]",
    "high_count": "[number]",
    "medium_count": "[number]",
    "low_count": "[number]",
    "total_behaviors": "[from CP2]",
    "behaviors_with_tests_count": "[count]",
    "behaviors_without_tests_count": "[count]",
    "orphan_tests_count": "[count]",
    "coverage_percentage": "[behaviors_with_tests / total_behaviors * 100]",
    "production_blocker": "[true if critical gaps OR alignment_score < 0.7]"
  }
}
```

**Status Logic:**
- `status: "pass"` if alignment_score >= 0.9 AND behaviors_without_tests.length === 0
- `status: "fail"` if alignment_score < 0.7 OR critical untested behaviors
- `status: "warning"` if 0.7 <= alignment_score < 0.9

## Success Criteria
- Every behavior from CP2 mapped to tests (or flagged as gap)
- Untested behaviors identified with risk assessment
- Orphan tests identified with recommendations
- Alignment score calculated accurately
- Specification completeness honestly assessed

## Confidence Scoring
**Alignment mapping: 0.8 confidence**

Rationale:
- Behavior-to-test matching is mostly objective
- Some interpretation needed for semantic similarity
- Risk assessment is subjective (0.6)
- Mapping accuracy high (0.9) but interpretation moderate (0.7)

## Examples

### Example 1: Excellent Alignment (score = 0.95)
**Behaviors (CP2)**:
1. "Should return Found=true for relevant SIM content"
2. "Should return Found=false for empty results"
3. "Should detect assumption language"

**Tests (CP4)**:
1. "should_return_found_true_when_search_contains_SIM_information"
2. "should_return_found_false_when_search_results_are_empty"
3. "should_detect_assumption_phrases_and_return_found_false"

**Result**:
- behaviors_without_tests: [] (all covered)
- orphan_tests: []
- alignment_score: 0.95
- status: "pass"

### Example 2: Poor Alignment (score = 0.4)
**Behaviors (CP2)**:
1. "Should validate SIM content"
2. "Should deflect competitor queries"
3. "Should handle assumption language"
4. "Should process empty results"
5. "Should check knowledge base"

**Tests (CP4)**:
1. "test1()"
2. "test2()"

**Result**:
- behaviors_without_tests: [3, 4, 5] (60% untested)
- tests with generic names: 100%
- alignment_score: 0.4
- status: "fail"
- Violations:
  - CRITICAL: 60% of behaviors untested
  - CRITICAL: All test names generic (can't understand from tests)

## Shared Context for Final Report

This checkpoint provides critical data for overall PASS/FAIL:
```json
{
  "all_behaviors_tested": behaviors_without_tests.length === 0,
  "alignment_score_acceptable": alignment_score >= 0.7,
  "behaviors_without_tests_count": number,
  "specification_completeness": "yes|partial|no"
}
```
