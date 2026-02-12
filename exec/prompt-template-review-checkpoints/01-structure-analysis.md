# Checkpoint: Prompt Structure Analysis

## Priority
CRITICAL

## Objective
Validate prompt template XML structure and section completeness according to Prompt Engineering Guide standards. This checkpoint ensures the prompt follows the standardized structure that enables maintainability and iteration.

## Scope
This checkpoint analyzes the structural elements of the prompt template:
- Presence of required XML sections
- Section completeness and organization
- Prompt Engineering Guide compliance
- Structural maintainability assessment

**NOT in scope:**
- Content quality of each section (covered in CP3)
- Decision logic analysis (covered in CP2)
- Test suite validation (covered in CP4-6)

## Review Standards
**Reference**: development/prompt_development_and_testing/guide/prompt-guide.md

### Required Sections (from Prompt Engineering Guide):
1. **`<role>`**: Defines the LLM's role and organizational context
2. **`<task>`**: Specifies what the prompt should do
3. **`<output_format>`**: Exact schema for output structure
4. **`<guidelines>`**: Rules and constraints for behavior
5. **`<examples>`**: Demonstrations of desired patterns

### Compliance Scoring:
- Each section present = 0.2 points
- Maximum score = 1.0 (all 5 sections)
- Minimum acceptable = 0.6 (3 sections)

## Input Requirements
```json
{
  "prompt_template_content": "[Full prompt template markdown content]",
  "prompt_file_name": "[Name of prompt template file]"
}
```

## Task

Execute the following steps to analyze prompt structure:

### Step 1: Parse Prompt Template
- Read the full prompt template content
- Identify the prompt name/purpose from filename or content
- Extract overall structure

### Step 2: Detect XML Sections
For each required section, check presence:

**`<role>` Section Detection:**
- Look for `<role>` opening and `</role>` closing tags
- Verify content exists between tags
- Note: Content quality not assessed here

**`<task>` Section Detection:**
- Look for `<task>` opening and `</task>` closing tags
- Verify task description or steps present
- Check for bullet points or structured task breakdown

**`<output_format>` Section Detection:**
- Look for `<output_format>` tags
- Verify format specification (JSON schema, structure example)
- Check if format is explicitly defined

**`<guidelines>` Section Detection:**
- Look for `<guidelines>` tags
- Verify presence of rules, constraints, or behavioral guidance

**`<examples>` Section Detection:**
- Look for `<examples>` tags
- Verify presence of example scenarios (good/bad patterns)

### Step 3: Calculate Compliance Score
```
compliance_score = (sections_present / 5) * 1.0

Where sections_present = count of (<role>, <task>, <output_format>, <guidelines>, <examples>)
```

### Step 4: Assess XML Structure Quality
Evaluate overall XML organization:
- **Excellent**: All 5 sections present, properly nested, clear hierarchy
- **Good**: 4 sections present, mostly well-organized
- **Needs-improvement**: 2-3 sections present, or poorly organized

### Step 5: Identify Structural Violations
Flag CRITICAL violations:
- Missing `<role>` section (how does LLM know its context?)
- Missing `<task>` section (what should LLM do?)
- Missing `<output_format>` section (what structure to return?)

Flag HIGH violations:
- Missing `<guidelines>` section (no behavioral constraints)
- Missing `<examples>` section (no pattern demonstrations)
- Sections present but empty

### Step 6: Assess Maintainability
Based on Prompt Engineering Guide "Maintainable" principle:
- Clear structure enables easy iteration
- Sections are logically separated
- Easy to identify where to add/modify content

## Output Format

```json
{
  "checkpoint_name": "structure-analysis",
  "checkpoint_priority": "CRITICAL",
  "status": "pass|warning|fail",
  "prompt_analyzed": {
    "prompt_name": "[Name extracted from file or content]",
    "purpose": "[Brief description of what prompt does]"
  },
  "structure_compliance": {
    "has_role_section": "yes|no",
    "has_task_section": "yes|no",
    "has_output_format": "yes|no",
    "has_guidelines": "yes|no",
    "has_examples": "yes|no",
    "compliance_score": "[0.0-1.0]",
    "xml_structure_quality": "excellent|good|needs-improvement"
  },
  "sections_detail": {
    "role_section": {
      "present": true|false,
      "content_length": "[approximate character count or 'empty']",
      "quality_note": "[Brief note on section quality]"
    },
    "task_section": {
      "present": true|false,
      "content_length": "[approximate character count or 'empty']",
      "has_structured_steps": true|false,
      "quality_note": "[Brief note]"
    },
    "output_format_section": {
      "present": true|false,
      "format_type": "JSON|CSV|TEXT|CUSTOM|unknown",
      "schema_defined": "yes|no|partial",
      "quality_note": "[Brief note]"
    },
    "guidelines_section": {
      "present": true|false,
      "rule_count": "[approximate number of rules/guidelines]",
      "quality_note": "[Brief note]"
    },
    "examples_section": {
      "present": true|false,
      "example_count": "[number of examples found]",
      "has_good_bad_patterns": true|false,
      "quality_note": "[Brief note]"
    }
  },
  "violations": [
    {
      "severity": "critical|high|medium|low",
      "category": "Prompt Structure",
      "issue": "[Specific structural issue]",
      "impact": "[Why this matters for maintainability/quality]",
      "fix_guidance": "[How to add missing section]",
      "example": "[Example of proper section structure]",
      "confidence": 0.9
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "critical_count": "[number]",
    "high_count": "[number]",
    "medium_count": "[number]",
    "low_count": "[number]",
    "sections_present": "[number out of 5]",
    "sections_missing": ["[list of missing section names]"],
    "production_blocker": "[true if compliance_score < 0.6 or missing role/task/output_format]"
  }
}
```

**Status Logic:**
- `status: "pass"` if compliance_score >= 0.8 (4+ sections) AND no critical violations
- `status: "fail"` if compliance_score < 0.6 OR missing role/task/output_format
- `status: "warning"` if 0.6 <= compliance_score < 0.8

## Success Criteria
- All 5 required sections identified and documented
- Compliance score calculated accurately
- Structural violations properly categorized by severity
- Clear guidance provided for missing sections

## Failure Handling
**CANNOT FAIL EXECUTION** - This checkpoint always completes with findings.

If prompt template cannot be parsed:
- Set status: "fail"
- Set compliance_score: 0.0
- Document parsing error in violations

Structure analysis must complete to enable subsequent checkpoints.

## Confidence Scoring
**All structure detection: 0.9 confidence**

Rationale:
- XML tag detection is automated and reliable
- Section presence/absence is objective
- Minimal interpretation required
- Clear true/false determination for each section

Lower to 0.7 only if:
- Prompt uses non-standard XML structure
- Sections present but with variant naming
- Ambiguous section boundaries

## Examples

### Example 1: Excellent Structure (compliance_score = 1.0)
```markdown
<role>
You are an intelligent search assistant for SIM...
</role>

<task>
- Analyze search results for relevance
- Validate content against SIM knowledge
- Set Found flag based on validation
</task>

<output_format>
{
  "response": "...",
  "found": true|false,
  "thinking": "..."
}
</output_format>

<guidelines>
- Never assume information not in results
- Flag competitor content as Found=false
- Detect assumption language
</guidelines>

<examples>
## Good Example
Query: "What is student care?"
Found: true

## Bad Example
Query: "Weather today"
Found: false
</examples>
```

**Result**:
- compliance_score: 1.0
- status: "pass"
- No violations

### Example 2: Missing Sections (compliance_score = 0.4)
```markdown
You are a helpful assistant.

Analyze the user query and provide relevant information from the knowledge base.

Return JSON with response and found flag.
```

**Result**:
- compliance_score: 0.4 (2/5 sections - minimal role, minimal task)
- status: "fail"
- Violations:
  - CRITICAL: Missing `<output_format>` section
  - HIGH: Missing `<guidelines>` section
  - HIGH: Missing `<examples>` section
  - HIGH: `<role>` section not properly tagged
  - HIGH: `<task>` section not properly tagged

### Example 3: Empty Sections (compliance_score = 1.0 but violations)
```markdown
<role>
</role>

<task>
Analyze queries
</task>

<output_format>
{
  "response": "string"
}
</output_format>

<guidelines>
</guidelines>

<examples>
</examples>
```

**Result**:
- compliance_score: 1.0 (all tags present)
- status: "warning"
- Violations:
  - HIGH: `<role>` section is empty
  - MEDIUM: `<task>` section lacks detail
  - HIGH: `<guidelines>` section is empty
  - HIGH: `<examples>` section is empty

## Shared Context for Subsequent Checkpoints

This checkpoint provides foundation for:
- **Checkpoint 2 (Decision Logic)**: Knows which sections to analyze for validation rules
- **Checkpoint 3 (Quality)**: Uses structure score as input for maintainability assessment
- **Checkpoint 5 (Alignment)**: Validates that prompt behaviors can be extracted from structured sections

**Context passed forward:**
```json
{
  "structure_compliance_score": 0.0-1.0,
  "sections_present": ["role", "task", "output_format", ...],
  "sections_missing": ["guidelines", "examples"],
  "structural_violations_count": number
}
```
