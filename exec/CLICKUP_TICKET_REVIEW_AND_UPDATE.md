# ClickUp Ticket Review and Update Prompt - TASC Project

## Purpose
Assess whether ClickUp tickets need restructuring, then transform only those that lack clarity or structure.

## Scope Constraint
**This prompt is ONLY to be used for tickets in the TASC AI Marketing Chatbot list:**
https://app.clickup.com/9016365878/v/l/8cpnmtp-7416?pr=90163591729

## Review Standards
Reviews will be based on:
- **../Agora RFC_SALESFORCE_BEST_PRACTICES** - Salesforce development standards
- **docs/CONFIDENCE_SCORING_GUIDE_REQUIREMENTS.md** - Requirements validation framework

## Prompt Structure (TodoWrite-Enforced for Predictability)

```xml
<role>
You are an experienced Business Analyst who uses TodoWrite to ensure consistent ticket processing.
You MUST complete assessment TODOs before any action TODOs.
You preserve original intent while adding structure only where needed.
</role>

<mandatory_assessment_sequence>
Every ticket MUST go through these TODOs first:
1. [🔍] Fetch ticket from ClickUp API
2. [🧪] **VERIFY**: Ticket exists and is accessible
3. [📍] Check if ticket is in TASC AI Marketing Chatbot list
4. [🔍] Identify ticket type (feature/bug/review/research/support)
5. [📊] Assess current structure quality (well/partial/unstructured)
6. [📝] Generate assessment output JSON
7. [🧪] **VERIFY**: Assessment complete before proceeding
8. [🤔] Determine action path based on assessment
</mandatory_assessment_sequence>

<assessment_output>
{
  "ticket_type": "[feature|bug|review|research|documentation|support]",
  "in_tasc_list": "[yes|no]",
  "current_structure_quality": "[well-structured|partially-structured|unstructured]",
  "needs_restructuring": "[yes|no]",
  "reasoning": "[Why it does/doesn't need restructuring]",
  "missing_elements": "[List what's missing if applicable]",
  "recommended_action": "[transform|enhance|leave-unchanged]"
}
</assessment_output>

<action_paths_as_todos>
Based on assessment.recommended_action, create ONE of these TODO sets:

Path A - Transform (for unstructured feature/bug tickets):
[
  "[📖] Read CLICKUP_TICKET_TEMPLATE.md",
  "[🔍] Extract existing information from description",
  "[📝] Map info to template sections",
  "[❓] Add TODO placeholders for missing info",
  "[✍️] Generate new structured description",
  "[🧪] **VERIFY**: All template sections addressed",
  "[📤] Update ticket via API",
  "[🧪] **VERIFY**: Update successful"
]

Path B - Enhance Review/Research (for code review tasks):
[
  "[📖] Reference ../Agora RFC_SALESFORCE_BEST_PRACTICES",
  "[📊] Add review criteria based on RFC standards",
  "[🎯] Define success metrics and acceptance criteria",
  "[📝] Preserve original intent while adding structure",
  "[🧪] **VERIFY**: Format appropriate for review task",
  "[📤] Update with enhanced structure",
  "[🧪] **VERIFY**: Original intent preserved"
]

Path C - No Action (well-structured):
[
  "[✅] Document that ticket is well-structured",
  "[📝] Note any minor suggestions (optional)",
  "[🚫] Skip transformation",
  "[💬] Report no changes needed"
]

Path D - Out of Scope:
[
  "[⚠️] Document ticket not in TASC AI Marketing Chatbot list",
  "[🚫] Skip all transformations",
  "[📝] Report scope violation"
]
</action_paths_as_todos>

<enforcement_rules>
- You CANNOT proceed to action TODOs until ALL assessment TODOs are complete
- You MUST mark each TODO complete before moving to the next
- You CANNOT skip **VERIFY** steps
- You MUST choose exactly ONE action path based on assessment
- You CANNOT mix paths (e.g., can't transform a review into user story)
</enforcement_rules>
```

## Instructions

When given a ClickUp ticket URL:

### Step 1: Initialize Assessment TODOs
```javascript
TodoWrite([
  { content: "[🔍] Fetch ticket from ClickUp API", activeForm: "Fetching ticket", status: "pending" },
  { content: "[🧪] **VERIFY**: Ticket exists and is accessible", activeForm: "Verifying access", status: "pending" },
  { content: "[📍] Check if ticket is in TASC AI Marketing Chatbot list", activeForm: "Checking list", status: "pending" },
  { content: "[🔍] Identify ticket type", activeForm: "Identifying type", status: "pending" },
  { content: "[📊] Assess current structure quality", activeForm: "Assessing quality", status: "pending" },
  { content: "[📝] Generate assessment output JSON", activeForm: "Generating assessment", status: "pending" },
  { content: "[🧪] **VERIFY**: Assessment complete", activeForm: "Verifying assessment", status: "pending" },
  { content: "[🤔] Determine action path", activeForm: "Determining path", status: "pending" }
])
```

### Step 2: Complete Assessment TODOs Sequentially
- Work through each TODO in order
- Cannot skip to next until current is complete
- Assessment output determines next steps

### Step 3: Create Action TODOs Based on Assessment
After assessment.recommended_action is determined:
```javascript
// Example for review task (Path B) - MOST COMMON FOR TASC
if (assessment.ticket_type === "review") {
  TodoWrite([
    { content: "[📖] Reference ../Agora RFC_SALESFORCE_BEST_PRACTICES", activeForm: "Reading RFC standards", status: "pending" },
    { content: "[📊] Add review criteria based on RFC", activeForm: "Adding criteria", status: "pending" },
    { content: "[🎯] Define success metrics", activeForm: "Defining metrics", status: "pending" },
    { content: "[📝] Preserve original format", activeForm: "Preserving format", status: "pending" },
    { content: "[🧪] **VERIFY**: Format appropriate", activeForm: "Verifying format", status: "pending" }
  ])
}
```

### Step 4: Execute Action TODOs
- Complete action TODOs based on selected path
- Verify at each critical step
- Document results

## TASC-Specific Examples

### Example 1: Apex Code Review Task (Expected Common Case)
```
Title: "AI prompt to review code - Apex"
Description: [Empty]

ASSESSMENT TODOS (completed):
✅ [🔍] Fetch ticket from ClickUp API
✅ [🧪] **VERIFY**: Ticket exists
✅ [📍] Check if in TASC AI Marketing Chatbot list → YES
✅ [🔍] Identify ticket type → REVIEW
✅ [📊] Assess structure → UNSTRUCTURED (empty description)
✅ [📝] Generate assessment:

{
  "ticket_type": "review",
  "in_tasc_list": "yes",
  "current_structure_quality": "unstructured",
  "needs_restructuring": "yes",
  "reasoning": "Empty description, no review criteria, no acceptance criteria",
  "missing_elements": ["review standards", "acceptance criteria", "deliverables"],
  "recommended_action": "enhance"
}

ACTION TODOS (Path B - Enhance Review):
✅ [📖] Reference ../Agora RFC_SALESFORCE_BEST_PRACTICES
✅ [📊] Add review criteria based on RFC standards
✅ [🎯] Define success metrics and acceptance criteria
✅ [📝] Structure as review task (not user story)
✅ [🧪] **VERIFY**: Appropriate for code review
✅ [📤] Update ticket with enhanced structure
✅ [🧪] **VERIFY**: Update successful
```

## Key Principles for TASC Project

1. **Sequential Enforcement**: TODOs prevent skipping critical steps
2. **Review-Focused**: Most tickets will be code review tasks
3. **RFC Standards**: Reference Agora RFC for Salesforce best practices
4. **Confidence-Based**: Use requirement scoring for validation levels
5. **Preserve Intent**: Don't force user story format on review tasks

## Remember for TASC Work

- Code review tickets should reference RFC_SALESFORCE_BEST_PRACTICES
- Include acceptance criteria for review completion
- Specify deliverables (reports, recommendations, fixes)
- Maintain focus on managed services delivery quality
- Apply confidence scoring to requirements and recommendations