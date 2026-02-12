# Start Development Work

Get ClickUp ticket ID from user, create branch, setup ticket directory, and create implementation plan using domain modeling, technical analysis, and research validation.

## Philosophy

**Channel @docs/personas/SALESFORCE_TECH_LEAD.md**:
- Spec-first, TDD mindset (RED-GREEN-REFACTOR)
- Domain modeling with state + behavior principle
- Evidence-based decisions, pragmatic trade-offs
- Integration risk mitigation upfront
- Research-validated assumptions (no guesswork)

## Complete Workflow

**Overview**: Setup → Domain Questions → Technical Analysis → Plan Creation → **Research Validation** → Tasks Generation

### STEP 1: Setup Branch and Directory

1. Ask user for ClickUp ticket ID
2. Fetch ticket details using `mcp__ClickUp__get_task`
3. Create branch: `<ticket-id>-<short-title>` (verify with user)
4. Create directory: `tickets/<ticket-id>/`
5. Post comment on ticket: "Work started - implementation planning in progress"

**Note**: This workflow generates `plan.md` and `tasks.md` following specification-driven development (SDD) best practices - a structured approach where requirements and planning come first, guiding systematic implementation.

### STEP 2: Domain Modeling (Interactive Discovery)

Ask user 3 simple questions using AskUserQuestion tool:

**Question 1: What business problem does this solve?**

Use AskUserQuestion:
```
Question: "What business problem does this ticket solve?"
Header: "Problem Type"
Options:
  - "Fix a bug in existing feature"
  - "Add new validation or business rule"
  - "Build new UI component or screen"
  - "Integrate with external system"
```

Document answer in plan.md

**Question 2: What business rules need to happen?**

Use AskUserQuestion (multiSelect: true):
```
Question: "What business rules or validations need to happen?"
Header: "Business Rules"
MultiSelect: true
Options:
  - "Check if something is allowed or valid"
  - "Calculate a value based on business rules"
  - "Enforce required fields or data formats"
  - "Update related records when something changes"
```

Document answers in plan.md

**Question 3: Where will the main logic be?**

Use AskUserQuestion:
```
Question: "Where will the main logic be implemented?"
Header: "Implementation Layer"
Options:
  - "LWC component (JavaScript)"
  - "Apex controller (@AuraEnabled methods)"
  - "Apex business class (domain logic)"
  - "Trigger"
```

Document answer in plan.md

**After Questions: Search Existing Code**

Automatically search for similar patterns:
- Use Grep to find similar field names, class names, validation patterns
- Document findings in plan.md under "Existing Code Analysis"

### STEP 3: Technical Analysis (Tech Lead Thinking)

**Use @docs/personas/SALESFORCE_TECH_LEAD.md principles**:

**A. Test Strategy (TDD First)**
"What are the test scenarios?"

For each scenario:
1. Write test name: `should_[expected_behavior]_when_[condition]`
2. Define expected vs actual
3. Identify boundary cases

Document:
```
Test Scenarios:
1. should_[behavior]_when_[condition]
   - Given: [setup]
   - When: [action]
   - Then: [expected outcome]
   - Confidence: [0.7-0.9] because [evidence]
```

**B. Integration Risk Assessment**
"What could go wrong between components?"

Check:
- Data type mismatches (String vs Id, Decimal vs Integer)
- Validation differences (client-side vs server-side)
- Error handling gaps
- Permission/security boundaries

Document:
```
Integration Risks:
1. [Risk description]
   - Severity: [Critical/High/Medium]
   - Mitigation: [Specific action]
   - Test: [How to verify fix]
```

**C. Security & Platform Compliance**
"Does this change affect security or platform limits?"

Check:
- CRUD/FLS requirements
- Governor limits (SOQL, DML, CPU)
- Sharing rules impact
- API limits

Document:
```
Security/Platform Checklist:
- [ ] CRUD/FLS enforced at [location]
- [ ] SOQL in loops avoided
- [ ] Bulk operations supported (200+ records)
- [ ] Error handling comprehensive
```

**D. Complexity Assessment**
"Is this change simple or complex?"

- Simple: Single component, no integration changes
- Medium: Multiple components, existing patterns
- Complex: New patterns, cross-tier integration

Document:
```
Complexity: [Simple/Medium/Complex]
Reasoning: [Why this assessment]
Approach: [Minimal viable implementation vs full architecture]
```

### STEP 4: Create Plan Document

Generate `tickets/<ticket-id>/plan.md` following SpecKit structure:

**Note**: This aligns with SpecKit's specification-driven development approach. The workflow is: Specify → Plan → Tasks.

```markdown
# Implementation Plan: [Ticket Title]

**Branch**: [branch-name] | **Date**: [DATE] | **ClickUp**: [ticket-url]
**Ticket ID**: [ticket-id]

## Summary

**Business Problem**: [From Question 1]
**Problem Statement**: [From ticket description]
**Success Criteria**: [From ticket acceptance criteria]

**Complexity**: [Simple/Medium/Complex]
**Confidence**: [0.7-0.9] based on [evidence]

---

## Technical Context

**Language/Version**: [e.g., Apex/LWC in Salesforce]
**Primary Dependencies**: [e.g., Salesforce Platform APIs, LWC framework]
**Storage**: [Salesforce Objects: Object__c fields]
**Testing**: [Apex Test Classes, LWC Jest tests, Manual verification if E2E blocked]
**Target Platform**: [Salesforce Lightning Experience]
**Performance Goals**: [Governor limits context: SOQL queries, DML operations]
**Constraints**: [Salesforce governor limits, sharing rules, CRUD/FLS requirements]
**Scale/Scope**: [Number of records, users, concurrent operations]

---

## Business Rules

**From User Input** (Question 2):
- [Selected rule 1: e.g., "Check if something is allowed or valid"]
- [Selected rule 2: e.g., "Calculate a value based on business rules"]
- [Additional rules from "Other"]

**Specific Implementation**:
- [Concrete rule: e.g., "Validate email format before saving"]
- [Concrete rule: e.g., "Calculate total as sum of line items"]

---

## Implementation Layer

**Primary Layer**: [From Question 3: LWC/Controller/Business Class/Trigger]

**Component Details**:
- **Files**: [Specific file names that will be created/modified]
- **Logic Location**: [Where business rules will be implemented]
- **Why This Layer**: [Brief justification]

---

## Data Flow

```
[User Action in UI]
  ↓
[LWC Component: component.js]
  ↓ [@wire or imperative call]
[Apex Controller: ControllerClass.method()]
  ↓ [Calls business logic]
[Apex Business Class: BusinessClass.method()]
  ↓ [DML operations]
[Salesforce Object: Object__c]
```

**Integration Risks**:
1. **[Risk Name]** - Severity: [Critical/High/Medium]
   - **Problem**: [What could go wrong]
   - **Mitigation**: [Specific action]
   - **Test**: [How to verify]

---

## Test Strategy (TDD)

### Test Scenarios

#### Scenario 1: [Test Name]
```apex
should_[expected_behavior]_when_[condition]
```
- **Given**: [Setup state]
- **When**: [Action performed]
- **Then**: [Expected outcome]
- **Confidence**: [0.7-0.9] because [evidence]

[Repeat for each scenario]

### Test Coverage Targets
- Unit tests: [Component/Class names]
- Integration tests: [Cross-component scenarios]
- Manual verification: [UI/UX scenarios if E2E blocked]

---

## Security & Platform Compliance

**Checklist**:
- [ ] CRUD/FLS enforced at: [specific location]
- [ ] SOQL queries bulkified
- [ ] DML operations bulkified
- [ ] Governor limits considered
- [ ] Error handling implemented
- [ ] Sharing rules validated

---

## Implementation Approach

**TDD Cycle**: RED → GREEN → REFACTOR

**Strategy**: [Describe whether MVP-first, incremental by user story, or full implementation]

**Risk Mitigation**: [How integration risks identified in Step 3 will be addressed]

---

## Complexity Justification

**Why [Simple/Medium/Complex]**:
[Reasoning based on analysis]

**Approach Chosen**:
[Minimal viable vs full architecture decision]

---

## Existing Code Analysis

**Similar Logic Found**:
- [File:line] - [Description]

**Reuse Decision**:
- [Reuse/Refactor/New] because [reasoning]

---

## Research Validation Results

**If research was conducted in STEP 5, document findings here. Otherwise, mark "No research needed - all requirements understood."**

### Research Item 1: [Technical unknown being validated]

**Research Question**: [Precise, testable question]

**Validation Result**: ✅ VALIDATED | ❌ INVALIDATED | ⚠️ UNCERTAIN

**Evidence Confidence**: [0.0-1.0]

**Key Findings**:
- [Finding 1 from query triangulation]
- [Finding 2 from documentation]

**Official Documentation**:
- Primary: [Salesforce doc link]
- API Reference: [Specific API/metadata link]

**Impact on Implementation**:
- [How this research affects the plan/approach]

[Repeat for each researched item]

---

## Notes

[Add implementation discoveries here]
```

### STEP 5: Identify Research Needs

After creating plan.md, analyze for technical unknowns that need validation.

**Automatically identify unknowns from:**
- Technical Analysis (STEP 3): Integration risks, platform capabilities
- Existing Code Analysis: Uncertain reuse decisions
- Test scenarios: Unvalidated assumptions about behavior
- Business rules: Unclear platform support for requirements

**Compile research items:**
```
Technical Unknowns Identified:
1. [Unknown item 1: e.g., "Can LWC access custom metadata in @wire without Apex?"]
2. [Unknown item 2: e.g., "Does trigger context support async callouts?"]
3. [Unknown item 3: e.g., "What are governor limits for batch Apex with 10k records?"]
```

**Use AskUserQuestion (multiSelect: true):**
```
Question: "I've identified some technical unknowns that may need research. Which items should we validate before proceeding?"
Header: "Research Items"
MultiSelect: true
Options:
  - [Auto-generated from unknowns list]
  - "None - I know all required information"
  - "Other" (user can add custom research item)
```

**If user selects research items:**
- For EACH selected item, execute research using @exec/TODOS_CONDITIONER_RESEARCH.md
- Follow full triangulation methodology (3-5 queries per item)
- Document validation results in plan.md under new section: "Research Validation Results"
- Update confidence scores based on research findings

**If user selects "None":**
- Skip research, proceed to STEP 6

### STEP 6: Generate Tasks Document

**Always generate tasks.md after plan.md is finalized**

Create `tickets/<ticket-id>/tasks.md` following SpecKit task breakdown structure:

```markdown
# Tasks: [Ticket Title]

**Input**: plan.md, ClickUp ticket details
**Prerequisites**: plan.md (required), business rules (from Step 2), test scenarios (from Step 3), research validation (from Step 5 if applicable)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story/phase this task belongs to (e.g., US1, RED, GREEN, REFACTOR)
- Include exact file paths in descriptions

## Phase 1: Setup & Tests (RED) 🔴

**Purpose**: Write failing tests that define expected behavior

- [ ] T001 [P] [RED] Create failing unit test for [scenario 1] in [TestClass.cls]
- [ ] T002 [P] [RED] Create failing unit test for [scenario 2] in [TestClass.cls]
- [ ] T003 [RED] Verify all tests fail for the right reason (expected failure messages)

**Checkpoint**: All tests RED (failing as expected)

---

## Phase 2: Core Implementation (GREEN) 🟢

**Purpose**: Implement minimum code to make tests pass

- [ ] T004 [GREEN] Implement [CoreType] with state + behavior in [ClassName.cls]
- [ ] T005 [GREEN] Implement [RelatedType] if needed in [RelatedClass.cls]
- [ ] T006 [GREEN] Verify all tests now pass (GREEN)

**Checkpoint**: All tests GREEN (passing)

---

## Phase 3: Integration (GREEN) 🟢

**Purpose**: Connect components across tiers (LWC ↔ Apex ↔ Database)

- [ ] T007 [GREEN] Implement [SourceComponent] integration in [component.js]
- [ ] T008 [GREEN] Implement [ApexController] methods in [Controller.cls]
- [ ] T009 [GREEN] Wire LWC to Apex in [component.js]
- [ ] T010 [GREEN] Verify integration tests pass

**Checkpoint**: Integration complete

---

## Phase 4: Refactor (REFACTOR) 🔧

**Purpose**: Improve code quality without changing behavior

- [ ] T011 [REFACTOR] Extract duplicated logic into helper methods
- [ ] T012 [REFACTOR] Improve naming for clarity (Tell Don't Ask principle)
- [ ] T013 [REFACTOR] Add inline documentation for complex logic
- [ ] T014 [GREEN] Verify all tests STILL pass after refactoring

**Checkpoint**: Code quality improved + All tests still GREEN

---

## Phase 5: Manual Verification (if E2E blocked) 📸

**Purpose**: Human-verified testing when automated E2E unavailable

- [ ] T015 [MANUAL] Open [specific Salesforce URL]
- [ ] T016 [MANUAL] Perform [specific user actions]
- [ ] T017 [EVIDENCE] Capture screenshot of [expected state]
- [ ] T018 [VERIFY] Confirm [specific behavior visible]

**Checkpoint**: Manual evidence captured + Documented

---

## Dependencies & Execution Order

### Phase Dependencies
- **Phase 1 (RED)**: No dependencies - start immediately
- **Phase 2 (GREEN)**: Depends on Phase 1 complete (all tests RED)
- **Phase 3 (Integration)**: Depends on Phase 2 complete (all tests GREEN)
- **Phase 4 (REFACTOR)**: Depends on Phase 3 complete (integration working)
- **Phase 5 (Manual)**: Can run after Phase 3 or 4

### TDD Rule
**CRITICAL**: Never move to next phase until current phase checkpoint passed

---

## Implementation Strategy

**RED-GREEN-REFACTOR Cycle**:
1. Complete Phase 1 (RED) → Write failing tests
2. Complete Phase 2 (GREEN) → Implement minimum code to pass tests
3. Complete Phase 3 (Integration) → Connect components across tiers
4. Complete Phase 4 (REFACTOR) → Improve code quality
5. Complete Phase 5 (Manual) → Human verification if E2E blocked

**Parallel Opportunities**:
- Tests within Phase 1 marked [P] can run in parallel
- Implementation tasks within phases marked [P] can run in parallel

**When Ready to Save Work**:
- Use `@exec/COMMIT.md` workflow for committing changes
- The commit workflow handles: file selection, CI validation, proper formatting, push, and ClickUp updates

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to TDD phase for traceability
- Each phase has clear checkpoint for validation
- Verify tests fail/pass before moving phases
- When ready to commit, use `@exec/COMMIT.md` workflow
```

---

## Example Session

```
User: "Start work on ticket 86d10j1v8"

AI: "Let me fetch that ticket...

✓ Found: 'Fix messaging session layout bug'

I'll create the branch and start domain modeling.

[Uses AskUserQuestion tool]

Question 1: "What business problem does this ticket solve?"
User selects: "Fix a bug in existing feature"

Question 2: "What business rules or validations need to happen?"
User selects: "Check if something is allowed or valid" + "Enforce required fields or data formats"

Question 3: "Where will the main logic be implemented?"
User selects: "LWC component (JavaScript)"

[AI searches for similar code patterns]

AI: "I've created tickets/86d10j1v8/plan.md with:
- Business Problem: Fix a bug in existing feature
- Business Rules: Validation + required field enforcement
- Implementation Layer: LWC component
- Similar Code Found: ChatMessage.js (deprecated), MessageValidator.cls
- Test strategy: 5 test scenarios
- Security checklist: CRUD/FLS on MessagingSession__c

I've identified 2 technical unknowns that may need research:
1. Can LWC access MessagingSession__c without Apex controller?
2. What are validation limits for message content length?

Which items should we validate before proceeding?"

[Uses AskUserQuestion with multiSelect]

User selects: "1. Can LWC access MessagingSession__c without Apex controller?" + "None - I know item 2"

[AI executes research using TODOS_CONDITIONER_RESEARCH.md for item 1]

AI: "Research completed for item 1:
✅ VALIDATED (confidence: 0.9)
- LWC can access custom objects via @wire with Lightning Data Service
- No Apex needed for simple CRUD operations
- Documentation: https://developer.salesforce.com/docs/...

Updated plan.md with research validation results.

Now generating tasks.md..."

[AI generates tasks.md]

AI: "I've created tickets/86d10j1v8/tasks.md with:
- Phase 1 (RED): 3 test tasks
- Phase 2 (GREEN): 3 implementation tasks
- Phase 3 (Integration): 4 integration tasks
- Phase 4 (REFACTOR): 4 cleanup tasks
- Phase 5 (Manual): 5 verification tasks

✅ Planning complete! You can now:
1. Start implementing tasks from tasks.md
2. Use @exec/COMMIT.md when ready to save your work

Ready to start Phase 1 (write failing tests)?"
```

---

## Tools

- `AskUserQuestion`: Interactive domain discovery and research selection
- `mcp__ClickUp__get_task`: Fetch ticket details
- `Bash`: Create and checkout branch, create directory
- `Grep`: Search for existing similar code
- `Read`: Analyze existing code patterns
- `Write`: Create plan.md and tasks.md
- `mcp__perplexity-ask__perplexity_ask`: Execute research validation queries
- `mcp__ClickUp__create_task_comment`: Post start comment

---

## Success Criteria

### plan.md is complete when:
1. ✅ Business problem type identified (from Question 1)
2. ✅ Business rules documented (from Question 2)
3. ✅ Implementation layer decided (from Question 3)
4. ✅ Integration risks identified and mitigated
5. ✅ Test scenarios defined (TDD-ready)
6. ✅ Security/platform checklist completed
7. ✅ Technical context documented (Salesforce-specific)
8. ✅ Research validation completed (if unknowns identified)
9. ✅ Confidence score assigned with evidence

### tasks.md is complete when:
1. ✅ Tasks organized by TDD phase (RED/GREEN/REFACTOR)
2. ✅ Dependencies clearly marked
3. ✅ Parallel opportunities identified with [P] marker
4. ✅ Exact file paths specified for each task
5. ✅ Checkpoints defined between phases
6. ✅ Manual verification tasks included if E2E blocked
7. ✅ Implementation strategy documented

---

## Specification-Driven Development (SDD) Approach

This workflow follows specification-driven development best practices:

**Standard SDD Workflow**: Specify → Plan → Tasks → Implement

**Our Implementation**:
- **Specify**: ClickUp ticket provides initial specification and requirements
- **Plan** (STEP 4): Interactive discovery generates `plan.md` with business rules + tech analysis
- **Research** (STEP 5): Validate technical unknowns using query triangulation
- **Tasks** (STEP 6): Generate `tasks.md` with detailed task breakdown (always generated)
- **Implement**: Developer proceeds with systematic implementation using structured docs

**Salesforce-Specific Adaptations**:
- **Platform Focus**: Apex/LWC components, Salesforce Objects, Lightning Experience
- **TDD Emphasis**: RED-GREEN-REFACTOR cycle enforcement with phase checkpoints
- **Integration Risk**: Cross-tier validation (LWC ↔ Apex ↔ Database) upfront
- **Security-First**: CRUD/FLS requirements, governor limits, sharing rules analysis
- **Evidence-Based**: Manual verification with screenshots when E2E tests blocked by shadow DOM
- **Research-Validated**: Query triangulation for technical unknowns before implementation

**Document Structure** (inspired by tools like SpecKit, but adapted for our context):
```
tickets/<ticket-id>/
├── plan.md              # Technical implementation plan
├── tasks.md             # Actionable task breakdown
├── spec.md              # Optional: Detailed specification
└── [implementation docs] # Created during development
```
