# ClickUp Ticket Auto-Fixer Prompt

**Purpose**: Automatically fix ClickUp tickets that fail quality review by gathering business requirements and updating ticket descriptions to meet development readiness standards.

**ClickUp Board**: https://app.clickup.com/9016365878/v/li/901610369300

**Usage**: When a ticket fails review using @exec/CLICKUP_TICKET_REVIEW_PROMPT.md, use this prompt to automatically gather requirements and fix the ticket.

---

## 🔑 Core Principle: When in Doubt, Ask the User

**CRITICAL**: Throughout the auto-fix process, if you are uncertain about any aspect of the ticket (business context, ticket type, requirements interpretation, scope, etc.), **ASK THE USER for clarification BEFORE making assumptions or updating the ticket**. This applies to:

- Unclear business requirements or unclear which source to prioritize
- Ambiguous ticket type (Research vs Spike vs Feature vs Bug)
- Conflicting information from different business documents
- Missing stakeholder context or validation
- Unclear scope or acceptance criteria expectations
- Uncertain about appropriate time estimates
- Any other area where you lack confidence in your assessment

**Always prefer asking clarifying questions over making assumptions. Document any assumptions made when user input is unavailable.**

---

## Process Overview

This prompt will systematically:
1. **Analyze current ticket** using ClickUp MCP commands
2. **Search business requirements** from `/requirements/` and `/docs/` directories
3. **Update ticket description** with comprehensive business grounding
4. **Verify ticket passes** @exec/CLICKUP_TICKET_REVIEW_PROMPT.md standards
5. **Mark as ready** for development

---

## Step-by-Step Execution

### Step 1: Get Current Ticket State
Use `mcp__ClickUp__get_task` to retrieve full ticket details and assess current quality gaps.

### Step 2: Identify Business Requirements
Search for relevant business context using these prioritized sources:

**Primary Sources (Highest Trust):**
- `/requirements/client_call_transcripts/` - Direct stakeholder input
- `/requirements/requirements_worksheets/` - Processed stakeholder feedback

**High Trust Sources:**
- `/docs/brds/` - Structured business analysis with confidence scoring

**Secondary Sources:**
- `/requirements/sow/` - Project scope and deliverables
- `/requirements/emails/` - Meeting summaries and decisions

**Search Strategy:**
1. Extract key terms from ticket title (e.g., "satisfaction survey", "handover", "routing")
2. Use Grep tool with relevant patterns across requirements directories
3. Use Read tool to examine specific documents with context
4. Prioritize sources based on trust hierarchy from review prompt

### Step 3: Structure Ticket Based on Type

**Determine Ticket Type:**
- **Unknown unknowns** (exploring new domain, unclear what questions to ask) → Research ticket
- **Known unknowns** (specific question with clear boundaries) → Spike/Investigation ticket
- **Clear requirements** (ready for implementation) → Feature/Enhancement/Bug ticket

#### For Research Tickets (Unknown Unknowns):
```markdown
## Research Scope
[Broad area or domain to explore]

## Initial Research Questions
- [Open-ended question 1 - will evolve during research]
- [Open-ended question 2]
- [Open-ended question 3]

## Business Requirement Context
**Primary Source**: [Transcript quote showing strategic uncertainty]
**High Trust Reference**: [BRD reference with low confidence areas]
**Secondary Reference**: [SOW or email reference]

## Success Criteria
- [ ] [Understanding deliverable 1]
- [ ] [Understanding deliverable 2]
- [ ] [Recommendation on next steps]

## Business Context
[Why this research is needed now and how it impacts project decisions]

## Deliverable Format
docs/research/<ticket-id>-[research-area].md with:
- [Required section 1]
- [Required section 2]
- Recommended next steps

## Time Box
**Maximum X days** research (typically 1-3 days)

## Follow-up Plan
Based on findings, create either:
- Spike ticket (if feasible but details unclear)
- Feature ticket (if straightforward)
- Additional research (if more exploration needed)
```

#### For Spike/Investigation Tickets (Known Unknowns):
```markdown
## Investigation Goal
[Specific technical question to be answered]

## Business Requirement Context
**Primary Source**: [Transcript quote with stakeholder validation]
**High Trust Reference**: [BRD reference with confidence scoring]
**Secondary Reference**: [SOW or email reference]

## Success Criteria
- [ ] [Specific deliverable 1]
- [ ] [Specific deliverable 2]
- [ ] [Specific deliverable 3]

## Deliverable Format
[Specific documentation path and content requirements]

## Time Box
**Maximum X days** investigation

## Business Unlock
[How this investigation enables other Epic work]
```

#### For Feature/Enhancement Tickets:
```markdown
## User Story
As a [user type] I want [functionality] So that [business benefit]

## Business Requirement Context
**Primary Source**: [Call transcript with stakeholder requirement]
**High Trust Reference**: [Epic BRD with evidence]
**Secondary Reference**: [SOW section reference]

## Acceptance Criteria
- [ ] [Testable condition 1]
- [ ] [Testable condition 2]
- [ ] [Testable condition 3]

## Definition of Done
[Clear completion criteria aligned with project standards]

## Business Value
[Explicit statement of business impact]
```

#### For Bug Tickets:
```markdown
## Current Behavior
[What is happening now with evidence]

## Expected Behavior
[What should happen instead]

## Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Business Impact
[How this affects users or business operations]

## Business Requirement Context
**Primary Source**: [Issue documentation from transcripts]
**High Trust Reference**: [Related BRD analysis]
**Secondary Reference**: [SOW functionality reference]
```

### Step 4: Update Ticket with Business Context
Use `mcp__ClickUp__update_task` with `markdown_description` parameter containing:

**Required Elements:**
1. **Business Requirement Grounding** with specific source citations
2. **Clear Goals & Acceptance Criteria** with measurable outcomes
3. **Implementation Readiness** with scope, dependencies, estimates

**Citation Format:**
- Primary sources: Direct quotes with document references
- High trust sources: BRD references with confidence scores
- Secondary sources: SOW sections or email summaries

### Step 5: Move Ticket Status
After updating description, move ticket from current status to appropriate development-ready status using `mcp__ClickUp__update_task`.

### Step 6: Add Confirmation Comment
Use `mcp__ClickUp__create_task_comment` to document the fixes applied and confirm readiness:

```markdown
✅ **TICKET AUTO-FIXED AND READY FOR DEVELOPMENT**

This ticket has been automatically updated with comprehensive business requirements:

**✅ Business Requirement Grounding - COMPLETE**
- **Primary Source**: [Source with quote]
- **High Trust Reference**: [BRD reference]
- **Secondary Reference**: [SOW/email reference]

**✅ Clear Goals & Acceptance Criteria - COMPLETE**
- [Key criteria met]

**✅ Implementation Readiness - COMPLETE**
- [Scope/time/dependencies defined]

All quality gates from @exec/CLICKUP_TICKET_REVIEW_PROMPT.md now pass.
```

---

## Search Patterns for Common Ticket Types

### Satisfaction/Survey Tickets:
```bash
grep -ri "satisfaction|survey|feedback|rating|experience" /requirements/
```

### Routing/Handover Tickets:
```bash
grep -ri "handover|transfer|routing|live agent|counselor|omnichannel" /requirements/
```

### Reporting/Analytics Tickets:
```bash
grep -ri "report|analytics|dashboard|metrics|tracking" /requirements/
```

### Business Hours/Capacity Tickets:
```bash
grep -ri "business hours|capacity|workload|availability" /requirements/
```

### Lead Management Tickets:
```bash
grep -ri "lead|prospect|qualification|validation|email" /requirements/
```

---

## Quality Verification

Before marking ticket as complete, verify it passes ALL these checks from @exec/CLICKUP_TICKET_REVIEW_PROMPT.md:

**Universal Quality Gates:**
- [ ] Business requirement citation with source link
- [ ] Business value statement
- [ ] Stakeholder validation evidence
- [ ] Specific, measurable goals
- [ ] Testable acceptance criteria
- [ ] Clear scope boundaries
- [ ] Dependencies identified
- [ ] Realistic effort estimation

**Type-Specific Requirements:**
- [ ] User story format (for features)
- [ ] Research scope & initial questions (for research tickets)
- [ ] Investigation goal & specific question (for spikes)
- [ ] Reproduction steps (for bugs)
- [ ] Time box (for research and spikes)
- [ ] Follow-up plan (for research tickets)
- [ ] Technical approach clarity

**Business Context Validation:**
- [ ] Aligns with SIM Agentforce project goals
- [ ] Connects to Epic BRD analysis
- [ ] References primary stakeholder requirements
- [ ] Within SOW scope boundaries

---

## Error Handling

**CRITICAL: When in doubt, ASK THE USER before making assumptions.**

**If business requirements not found:**
1. Search broader terms and synonyms
2. Check related Epic BRDs for context
3. Reference SOW sections for general scope
4. **ASK USER**: If still unclear, ask the user to clarify business context before proceeding
5. Note in ticket that specific validation needed from stakeholders

**If ticket type unclear:**
1. **ASK USER FIRST**: "Based on the ticket context, is this:
   - Unknown unknowns (exploring new domain, unclear what questions to ask) → Research ticket?
   - Known unknowns (specific question to answer) → Spike ticket?
   - Clear requirements (ready to implement) → Feature/Bug ticket?"
2. If user doesn't respond, assess knowledge level based on ticket content
3. Focus on defining what needs to be discovered
4. Set appropriate time box (1-3 days for research, 0.5-1 day for spike)
5. Define clear deliverable format
6. For research tickets, include follow-up plan

**If multiple conflicting requirements:**
1. **ASK USER**: Present the conflict and ask which source should take priority
2. If no user guidance, prioritize by source trust hierarchy
3. Note conflicts in ticket description
4. Reference most recent stakeholder input
5. Flag for clarification if needed

**If unclear scope or acceptance criteria:**
1. **ASK USER**: Request specific examples or clarification on expected outcomes
2. If user provides context, update ticket accordingly
3. If user unavailable, make best effort based on similar tickets and note assumptions

**General Principle:** Always prefer asking the user for clarification over making assumptions. Document any assumptions made when user input is not available.

---

## Success Criteria

This prompt succeeds when:
1. **Ticket passes review** - All quality gates from @exec/CLICKUP_TICKET_REVIEW_PROMPT.md are met
2. **Business grounding complete** - Primary, high trust, and secondary sources cited
3. **Development ready** - Clear scope, acceptance criteria, and implementation approach
4. **Status updated** - Ticket moved to appropriate development-ready status
5. **Documentation complete** - All fixes documented with source references

---

## Example Execution Flow

```
1. Get ticket: mcp__ClickUp__get_task(taskId="86d0example")
2. Search requirements: grep -ri "survey" /requirements/
3. Read relevant docs: Read("/requirements/client_call_transcripts/session_3.md")
4. Structure content based on ticket type (spike/feature/bug)
5. Update ticket: mcp__ClickUp__update_task(description=comprehensive_content)
6. Move status: mcp__ClickUp__update_task(status="ready for dev")
7. Add comment: mcp__ClickUp__create_task_comment(confirmation)
```

This systematic approach ensures every ticket that fails initial review can be automatically enhanced with proper business context and moved to development-ready status.