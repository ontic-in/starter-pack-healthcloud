# Checkpoint: Decision Logic & Validation Rules

## Priority
CRITICAL

## Objective
Analyze the prompt's decision logic, validation rules, and edge case handling. Extract all expected behaviors that the prompt should exhibit, which will be used for test alignment in Checkpoint 5.

## Scope
This checkpoint analyzes logical elements of the prompt:
- All validation rules and decision paths
- Edge cases explicitly mentioned
- Conditional logic (if/else/when)
- Expected behaviors catalog
- Decision logic completeness

**NOT in scope:**
- Prompt structure (covered in CP1)
- Output quality assessment (covered in CP3)
- Test coverage verification (covered in CP5)

## Review Standards
**Reference**: development/prompt_development_and_testing/guide/prompt-guide.md

### Decision Logic Requirements:
- **Completeness**: Every "if" needs "else", every edge case needs handling
- **Consistency**: Reasoning path should be predictable and stable
- **Explicit Rules**: Validation criteria clearly stated
- **Edge Cases**: Boundary conditions documented

## Input Requirements
```json
{
  "prompt_template_content": "[Full prompt template]",
  "structure_results": {
    "sections_present": ["role", "task", ...],
    "compliance_score": 0.0-1.0
  }
}
```

## Task

Execute the following steps:

### Step 1: Extract Validation Rules
Scan prompt for explicit validation statements:
- "If [condition] then [action]"
- "Must [requirement]"
- "Should [guideline]"
- "Never [prohibition]"
- "Always [requirement]"
- "Only when [condition]"

Example extraction:
```
"If search results are empty → return Found=false"
"Must validate content against knowledge base"
"Never assume information not in results"
```

**Count**: Total validation rules found

### Step 2: Identify Decision Paths
Map all conditional logic branches:
- Primary decision paths
- Alternative paths
- Fallback/default behavior
- Error handling paths

Assess completeness:
- Do all "if" statements have "else"?
- Are all branches documented?
- Is fallback behavior defined?

### Step 3: Document Edge Cases
Find explicitly mentioned edge cases:
- Empty inputs
- Missing data
- Boundary values
- Ambiguous scenarios
- Invalid inputs

Example:
```
"When search returns no results..."
"If query is competitor-related..."
"When content contains assumption language..."
```

### Step 4: Extract Expected Behaviors
Create comprehensive list of all behaviors prompt should exhibit.

**Format**: Action-oriented statements
```
"Should return Found=true when relevant content exists"
"Should return Found=false for empty search results"
"Should detect assumption language and set Found=false"
"Should validate content against SIM knowledge base"
"Should handle competitor content by setting Found=false"
```

**Critical**: This list will be used in CP5 to verify test coverage

### Step 5: Assess Decision Logic Completeness
Evaluate coverage:
- **Complete**: All paths documented, edge cases handled, behaviors clear
- **Partial**: Some paths documented, some edge cases missing
- **Minimal**: Basic logic only, many gaps

### Step 6: Identify Logic Violations
Flag issues:
- **CRITICAL**: Missing else branch for critical decision
- **HIGH**: Edge case mentioned but not handled
- **MEDIUM**: Validation rule stated ambiguously
- **LOW**: Minor logic clarity improvements needed

## Output Format

```json
{
  "checkpoint_name": "decision-logic-validation",
  "checkpoint_priority": "CRITICAL",
  "status": "pass|warning|fail",
  "validation_rules": [
    {
      "rule_id": "[unique identifier]",
      "rule_statement": "[Exact rule from prompt]",
      "rule_type": "requirement|prohibition|guideline|validation",
      "condition": "[If/when condition, or 'always']",
      "action": "[Then/must/should action]",
      "has_else_branch": true|false,
      "completeness": "complete|partial|unclear"
    }
  ],
  "decision_paths": {
    "primary_paths": ["[Path 1: condition → action]", "[Path 2: ...]"],
    "alternative_paths": ["[Alt path 1]", "[Alt path 2]"],
    "fallback_behavior": "[Default behavior when no conditions met]",
    "error_handling": "[How errors are handled]",
    "paths_documented": "all|most|some|few",
    "completeness_assessment": "complete|partial|minimal"
  },
  "edge_cases": [
    {
      "edge_case": "[Description of edge case]",
      "mentioned_in_prompt": true|false,
      "handling_defined": "yes|no|partial",
      "location": "[Section where mentioned]"
    }
  ],
  "expected_behaviors": [
    "[Behavior 1: Should return Found=true when relevant content exists]",
    "[Behavior 2: Should return Found=false for empty search results]",
    "[Behavior 3: Should detect assumption language and set Found=false]",
    "[... list ALL behaviors the prompt should exhibit]"
  ],
  "violations": [
    {
      "severity": "critical|high|medium|low",
      "category": "Decision Logic",
      "issue": "[Specific logic gap]",
      "evidence": "[Quote from prompt or absence]",
      "impact": "[Why this matters]",
      "fix_guidance": "[How to complete the logic]",
      "example": "[Example of proper decision path]",
      "confidence": 0.7
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "critical_count": "[number]",
    "high_count": "[number]",
    "medium_count": "[number]",
    "low_count": "[number]",
    "validation_rules_count": "[number found]",
    "edge_cases_count": "[number found]",
    "edge_cases_handled": "[number with handling defined]",
    "expected_behaviors_count": "[number extracted]",
    "decision_logic_completeness": "complete|partial|minimal",
    "production_blocker": "[true if critical violations exist]"
  }
}
```

**Status Logic:**
- `status: "pass"` if completeness = "complete" AND no critical violations
- `status: "fail"` if completeness = "minimal" OR critical violations > 0
- `status: "warning"` if completeness = "partial" OR high violations > 0

## Success Criteria
- All validation rules extracted and cataloged
- Decision paths mapped with completeness assessment
- Edge cases identified and handling documented
- Expected behaviors list is comprehensive (will enable CP5 alignment check)
- Logic gaps identified with severity

## Confidence Scoring
**Decision logic analysis: 0.7 confidence**

Rationale:
- Requires interpretation of natural language rules
- Some ambiguity in identifying implicit behaviors
- Edge case detection may miss subtle scenarios
- Higher confidence for explicit rules (0.8)
- Lower confidence for inferred behaviors (0.6)

## Examples

### Example 1: Complete Decision Logic
```markdown
<task>
1. Analyze search results for SIM-related content
2. If results contain relevant SIM information:
   - Validate against knowledge base
   - Return Found=true with response
3. Else if results are empty:
   - Return Found=false with deflection message
4. Else if content mentions competitors:
   - Return Found=false (deflect competitor queries)
5. Else if content contains assumption language ("however", "might", "possibly"):
   - Return Found=false (uncertain information)
6. Else:
   - Return Found=false with generic deflection
</task>
```

**Analysis**:
- validation_rules_count: 5
- decision_paths: all branches covered
- completeness: "complete"
- expected_behaviors: 6 extracted
- status: "pass"

### Example 2: Incomplete Decision Logic
```markdown
<task>
Analyze the query and provide relevant information.
If content is relevant, return it.
</task>
```

**Analysis**:
- validation_rules_count: 1 (implicit)
- Violations:
  - CRITICAL: Missing "else" branch - what if content not relevant?
  - HIGH: "Relevant" not defined - what makes content relevant?
  - HIGH: No edge case handling (empty results, errors, etc.)
- completeness: "minimal"
- status: "fail"

## Shared Context for Subsequent Checkpoints

This checkpoint provides critical input for:
- **Checkpoint 3 (Quality)**: Decision logic completeness feeds into consistency assessment
- **Checkpoint 5 (Alignment)**: expected_behaviors array is THE source for test mapping

**Context passed forward:**
```json
{
  "expected_behaviors": [
    "Should return Found=true when relevant content exists",
    "Should return Found=false for empty search results",
    "Should detect assumption language...",
    "..."
  ],
  "validation_rules_count": number,
  "edge_cases_count": number,
  "decision_logic_completeness": "complete|partial|minimal"
}
```
