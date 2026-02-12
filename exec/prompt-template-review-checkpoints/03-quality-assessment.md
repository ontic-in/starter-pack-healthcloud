# Checkpoint: Prompt Quality Assessment

## Priority
HIGH

## Objective
Evaluate the prompt template against the "Good Prompt" criteria from the Prompt Engineering Guide: Consistency, Transparency, Grounded, and Maintainable.

## Scope
This checkpoint assesses qualitative aspects of the prompt:
- Consistency of reasoning paths
- Transparency of outputs (shows thinking)
- Grounding (validates own output)
- Maintainability (structure enables iteration)

**NOT in scope:**
- Structure completeness (covered in CP1)
- Specific decision logic (covered in CP2)
- Test quality (covered in CP4-6)

## Review Standards
**Reference**: development/prompt_development_and_testing/guide/prompt-guide.md

### The "Good" Prompt Criteria:

**1. Consistency**
- Reasoning path doesn't change randomly
- Same input → consistent reasoning method (not necessarily identical text)
- Predictable thought routine
- No conflicting instructions

**2. Transparency**
- Output shows reasoning/thinking process
- Includes `thinking` or `rationale` field in JSON
- Explainable decisions
- Not black-box outputs

**3. Grounded**
- Validates own output against source data
- Cross-references claims with provided context
- Doesn't need external validation LLM
- Self-checking mechanisms present

**4. Maintainable**
- Clear structure (from CP1)
- Easy to modify sections
- Logical organization
- Standard format followed

## Input Requirements
```json
{
  "prompt_template_content": "[Full prompt]",
  "structure_results": {
    "compliance_score": 0.0-1.0,
    "sections_present": ["..."]
  },
  "decision_logic_results": {
    "completeness": "complete|partial|minimal"
  }
}
```

## Task

### Step 1: Assess Consistency
Analyze prompt for consistency indicators:

**Look for**:
- Structured task steps (numbered, ordered)
- Clear decision tree or flowchart logic
- No conflicting instructions
- Predictable reasoning framework

**Red flags**:
- "Depending on context, may or may not..."
- Multiple contradictory guidelines
- Ambiguous conditional logic
- Random/unstructured task descriptions

**Rating**: excellent | good | poor

### Step 2: Assess Transparency
Check if output format includes reasoning:

**Transparent patterns**:
```json
{
  "response": "...",
  "thinking": "I analyzed X and determined Y because...",
  "rationale": "...",
  "reasoning_steps": ["step1", "step2"]
}
```

**Not transparent**:
```json
{
  "response": "..."
  // No thinking/rationale fields
}
```

**Rating**: excellent | good | poor

### Step 3: Assess Grounding
Look for self-validation instructions:

**Grounded patterns**:
- "Verify that response is based on provided context"
- "Cross-check claims against source data"
- "Ensure all facts are from search results"
- "Validate assumptions before stating"

**Not grounded**:
- No validation instructions
- "Use your knowledge to respond"
- No source-checking requirements

**Rating**: excellent | good | poor

### Step 4: Assess Maintainability
Evaluate structure quality (builds on CP1):

**Maintainable**:
- compliance_score >= 0.8
- Clear XML sections
- Easy to identify where to modify
- Logical flow

**Not maintainable**:
- compliance_score < 0.6
- Unstructured wall of text
- Mixed concerns in single section

**Rating**: excellent | good | poor

### Step 5: Identify Quality Violations
Flag issues per criterion:

**Example violations**:
- MEDIUM: "No transparency - output format lacks thinking/rationale field"
- MEDIUM: "Inconsistent logic - contradictory guidelines in sections 3 and 5"
- LOW: "Limited grounding - no validation instructions present"

## Output Format

```json
{
  "checkpoint_name": "quality-assessment",
  "checkpoint_priority": "HIGH",
  "status": "pass|warning|fail",
  "quality_criteria": {
    "consistency": {
      "rating": "excellent|good|poor",
      "assessment": "[Why this rating - evidence from prompt]",
      "reasoning_path_stability": "stable|mostly-stable|unstable",
      "has_structured_steps": true|false,
      "conflicting_instructions": 0
    },
    "transparency": {
      "rating": "excellent|good|poor",
      "assessment": "[Why this rating]",
      "output_shows_reasoning": true|false,
      "has_thinking_field": true|false,
      "has_rationale_field": true|false,
      "explainability_score": "high|medium|low"
    },
    "grounded": {
      "rating": "excellent|good|poor",
      "assessment": "[Why this rating]",
      "has_validation_instructions": true|false,
      "requires_source_checking": true|false,
      "self_checking_mechanisms": ["[list mechanisms if present]"]
    },
    "maintainable": {
      "rating": "excellent|good|poor",
      "assessment": "[Based on CP1 structure score and organization]",
      "structure_score_from_cp1": 0.0-1.0,
      "easy_to_modify": true|false,
      "logical_organization": true|false
    }
  },
  "violations": [
    {
      "severity": "critical|high|medium|low",
      "category": "Prompt Quality",
      "criterion": "consistency|transparency|grounded|maintainable",
      "issue": "[Specific quality issue]",
      "evidence": "[Quote or observation]",
      "impact": "[Why this hurts quality]",
      "fix_guidance": "[How to improve]",
      "example": "[Better pattern]",
      "confidence": 0.6
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "critical_count": 0,
    "high_count": "[number]",
    "medium_count": "[number]",
    "low_count": "[number]",
    "overall_quality_score": "[average of 4 criteria ratings]",
    "production_blocker": false
  }
}
```

**Status Logic:**
- `status: "pass"` if all 4 criteria >= "good" AND no high violations
- `status: "warning"` if 1-2 criteria = "poor" OR high violations > 0
- `status: "fail"` if 3+ criteria = "poor"

## Success Criteria
- All 4 quality criteria assessed with evidence
- Ratings justified with specific examples from prompt
- Quality violations identified with actionable guidance
- Overall quality score calculated

## Confidence Scoring
**Quality assessment: 0.6 confidence**

Rationale:
- Subjective interpretation of "good" vs "poor"
- Requires judgment on consistency and grounding
- Some criteria more objective (transparency - has field?) than others (consistency)
- Recommendations are opinions, not facts

## Examples

### Example: Excellent Quality
```markdown
<task>
1. Parse search results from context
2. Extract relevant SIM information
3. Validate facts against SIM knowledge base
4. If validation passes → construct response
5. If validation fails → deflect query
6. Return JSON with thinking field explaining reasoning
</task>

<output_format>
{
  "response": "...",
  "found": true|false,
  "thinking": "Analyzed results and found X. Validated against Y. Concluded Z."
}
</output_format>
```

**Ratings**:
- Consistency: excellent (structured 6-step process)
- Transparency: excellent (thinking field mandated)
- Grounded: excellent (explicit validation step)
- Maintainability: excellent (clear XML structure)

### Example: Poor Quality
```markdown
Respond to user queries about SIM. Use your knowledge to help them.
Return helpful information.
```

**Ratings**:
- Consistency: poor (no structure, unpredictable)
- Transparency: poor (no reasoning field)
- Grounded: poor (no source validation)
- Maintainability: poor (no XML structure)

## Shared Context for Subsequent Checkpoints

Provides quality metrics for final assessment:
```json
{
  "overall_quality_score": "excellent|good|poor",
  "quality_violations_count": number,
  "transparency_rating": "excellent|good|poor"
}
```
