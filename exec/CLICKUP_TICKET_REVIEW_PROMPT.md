# ClickUp Ticket Review Prompt

**Purpose**: Ensure all tickets meet quality standards before moving from "in-story-writing" or "backlog" to "Ready for dev"

**ClickUp Board**: https://app.clickup.com/9016365878/v/li/901610369300

---

## 🔑 Core Principle: When in Doubt, Ask the User

**CRITICAL**: Throughout the review process, if you are uncertain about any aspect of the ticket (business context, ticket type, priority, scope, acceptance criteria, etc.), **ASK THE USER for clarification BEFORE making assumptions or proceeding**. This applies to:

- Unclear business requirements or stakeholder intent
- Ambiguous ticket type (Research vs Spike vs Feature vs Bug)
- Conflicting information from different sources
- Missing or vague acceptance criteria
- Unclear scope boundaries
- Uncertain technical approach
- Any other area where you lack confidence in your assessment

**Always prefer asking clarifying questions over making assumptions.**

---

## Pre-Review Setup

Before reviewing any ticket, ensure you have access to:
- **Primary Business Requirements**: `/requirements/sow/`, `/requirements/client_call_transcripts/`, `/requirements/requirements_worksheets/`, `/requirements/emails/`
- **Secondary Documentation**: `/docs/brds/` (reference only - validate against requirements)
- **Project Templates**: `@exec/XP_USER_STORY_TEMPLATE.md`, `@exec/XP_BRD_TEMPLATE.md`
- **SOW Document**: Latest Scope of Work in `/requirements/sow/` for SIM Agentforce project

---

## Universal Quality Gates

**Every ticket MUST pass ALL of these checks to move to "Ready for dev":**

### ✅ 1. Business Requirement Grounding
- [ ] **Citation Required**: Ticket includes direct reference to business requirement source
- [ ] **Documentation Link**: Links to specific business document (SOW section, BRD epic, call transcript, worksheet)
- [ ] **Business Value Clear**: Explicit statement of why this work matters to the business
- [ ] **Stakeholder Validation**: Evidence of stakeholder input or approval

**Primary Sources (in order of trust):**
1. **Client Call Transcripts**: `/requirements/client_call_transcripts/` - Requirements sessions 1-3, project kickoff, standup notes (HIGHEST TRUST - direct stakeholder input)
2. **Requirements Worksheets**: `/requirements/requirements_worksheets/` - User analysis, deep dive sessions, omnichannel requirements (HIGHEST TRUST - processed stakeholder feedback)
3. **Epic BRDs**: `/docs/brds/` - Comprehensive business requirements with evidence and confidence scoring (HIGH TRUST - structured analysis)
4. **SOW Document**: `/requirements/sow/Latest Scope of Work.pdf` - sections 1.02 (Goals), 2.0 (Solution Design), 3.01 (Scope)
5. **Email Communications**: `/requirements/emails/` - Meeting summaries, stakeholder decisions

### ✅ 2. Clear Goals & Acceptance Criteria
- [ ] **Specific Goal**: What exactly will be delivered (not vague or theoretical)
- [ ] **Measurable Outcome**: Success can be verified objectively
- [ ] **Acceptance Criteria Listed**: Specific, testable conditions for completion
- [ ] **Definition of Done**: Clear completion criteria aligned with project standards

### ✅ 3. Implementation Readiness
- [ ] **Scope Clarity**: Boundaries of work are well-defined
- [ ] **Dependencies Identified**: Prerequisites or blockers noted
- [ ] **Estimate Feasible**: Work can be completed in reasonable timeframe
- [ ] **Technical Approach**: Implementation path is clear (not just requirements)

---

## Ticket Type-Specific Requirements

**Ticket Type Decision Tree:**
- **Unknown unknowns** (don't know what we don't know) → Research ticket
- **Known unknowns** (specific questions to answer) → Spike/Investigation ticket
- **Clear requirements** (ready to implement) → Feature/Enhancement/Bug ticket

### 🎯 Feature/Enhancement Tickets

**Required Elements:**
- [ ] **User Story Format**: Follows "As [user] I want [functionality] So that [benefit]" structure
- [ ] **User Type Specified**: Prospect, Applicant, Student, Alumni, or Staff member
- [ ] **Business Process Impact**: How this changes current workflows
- [ ] **Integration Points**: Connections to Salesforce, Agentforce, or other systems

**Business Grounding Requirements:**
- [ ] **PRIMARY**: Cites specific call transcript or requirements worksheet with stakeholder quote/requirement
- [ ] **HIGH TRUST**: References relevant Epic BRD with evidence and confidence scoring
- [ ] **SECONDARY**: References SOW section or email communication
- [ ] Maps to core business problems identified in meeting transcripts and worksheets

**Example Good Ticket:**
```
Title: Implement email validation for prospect pre-chat form
Business Requirement: SOW Section 1.03 - "Poor data quality and validation"
User Story: As a prospect, I want my email validated during pre-chat so that counselors receive accurate contact information
Acceptance Criteria:
- Email validation using regex patterns
- Real-time validation feedback to user
- Invalid emails cannot proceed to chat
- Valid email formats stored in lead record
Primary Citation: "emails were invalid...we don't have the correct email" - 20250922_requirements_gathering_session_2_summary.md
High Trust Reference: EPIC_2_Lead_Data_Quality_Validation.md (Confidence: 0.42 - Highest)
Secondary Reference: SOW Section 1.03 - "Poor data quality and validation"
```

### 🐛 Bug Tickets

**Required Elements:**
- [ ] **Current Behavior**: What is happening now (with evidence)
- [ ] **Expected Behavior**: What should happen instead
- [ ] **Reproduction Steps**: Clear step-by-step process to reproduce
- [ ] **Impact Assessment**: How this affects users or business operations
- [ ] **Supporting Evidence**: Screenshots, videos, error messages, or logs

**Business Grounding Requirements:**
- [ ] **PRIMARY**: Connects to specific issue documented in call transcripts or worksheets
- [ ] **HIGH TRUST**: References relevant Epic BRD analysis and evidence
- [ ] **SECONDARY**: References functionality from SOW or email communications
- [ ] Impact on project success metrics identified in meeting transcripts and worksheets

**Example Bug Ticket:**
```
Title: Pre‑chat form allows invalid email submission
Type: Bug

Current Behavior: Invalid emails like "test@@example" pass validation and the user proceeds to chat.
Expected Behavior: Invalid emails are blocked and an inline validation error is shown.

Reproduction Steps:
1) Navigate to the pre‑chat form
2) Enter email "test@@example"
3) Click Submit
4) Observe that chat starts without any error

Impact Assessment: Invalid emails create uncontactable leads, lowering conversion and adding manual cleanup work for the LE team.

Supporting Evidence: Screenshot attached; console log shows no validation error thrown.

Business Reference:
- PRIMARY: Requirements Session 2 transcript - stakeholder identified email validation issues
- HIGH TRUST: EPIC_2_Lead_Data_Quality_Validation (docs/brds/EPIC_2_Lead_Data_Quality_Validation.md)
- SECONDARY: SOW Section 1.03 – "Poor data quality and validation"

Acceptance Criteria (Given/When/Then):
- Given the pre‑chat form, when the user enters an invalid email, then the submit action is prevented and an inline error message appears.
- Given a valid email, when the user submits, then the form proceeds and the email is stored in the lead record.
- Given client‑side validation, when the network is slow or JS fails, then server‑side validation still blocks invalid emails.
```

### 🔬 Research Tickets (Unknown Unknowns)

**Definition:** Research tickets address **unknown unknowns** - situations where we don't yet know what questions to ask or what the solution space looks like. Used when exploring entirely new domains, technologies, or problem spaces without clear boundaries.

**Required Elements:**
- [ ] **Research Scope**: Broad area or domain to explore
- [ ] **Research Questions**: Initial open-ended questions to guide exploration (will evolve)
- [ ] **Success Criteria**: What constitutes sufficient understanding to move forward
- [ ] **Business Context**: Why this research is needed now
- [ ] **Deliverable Format**: How findings will be structured and shared
- [ ] **Time Box**: Maximum time to spend on research (typically 1-3 days)
- [ ] **Follow-up Plan**: How research findings will inform next actions (spike, feature, or additional research)

**Business Grounding Requirements:**
- [ ] **PRIMARY**: Addresses strategic uncertainty identified in call transcripts or worksheets
- [ ] **HIGH TRUST**: References Epic BRD gaps or confidence scoring showing low confidence areas
- [ ] **SECONDARY**: References new business opportunities or risks from SOW or email communications
- [ ] Clear explanation of why this research is critical for business decision-making

**Example Research Ticket:**
```
Title: Research Salesforce Einstein Conversation Mining capabilities for chatbot analytics
Type: Research (unknown unknowns)

Research Scope: Explore Salesforce Einstein Conversation Mining to understand if it can meet our analytics requirements for conversation flow analysis and abandonment tracking (US-26, US-27).

Initial Research Questions:
- What conversation analytics capabilities does Einstein Conversation Mining provide?
- How does it integrate with Agentforce agents?
- What are the licensing requirements and costs?
- Does it support custom conversation flow tracking?
- What alternatives exist in the Salesforce ecosystem?

Success Criteria:
- Comprehensive understanding of Einstein Conversation Mining capabilities documented
- Comparison matrix with project analytics requirements (US-23 through US-32)
- Recommendation on feasibility and next steps (spike vs direct implementation vs alternative approach)
- Cost/benefit analysis for stakeholder decision-making

Business Context: Analytics & Reporting (EPIC_3) requires comprehensive conversation flow analytics. Current understanding of Salesforce capabilities is insufficient to determine implementation approach.

Deliverable Format: docs/research/<ticket-id>-einstein-conversation-mining-research.md with:
- Capability overview
- Integration requirements
- Licensing & cost analysis
- Fit analysis with project requirements
- Recommended next steps

Time Box: 2 days maximum

Follow-up Plan: Based on findings, create either:
- Spike ticket (if feasible but implementation details unclear)
- Feature ticket (if straightforward implementation)
- Alternative research (if Einstein CM not suitable)

Business Reference:
- PRIMARY: Requirements Session 2.1 - Analytics requirements and current capability gaps
- HIGH TRUST: EPIC_3_Analytics_Reporting (low confidence on conversation mining approach)
- SECONDARY: SOW Section 3.01 - Analytics & reporting deliverables
```

### 🔍 Spike/Investigation Tickets (Known Unknowns)

**Definition:** Spike tickets address **known unknowns** - specific questions with clear boundaries where we know what we don't know. Used when we understand the problem space but need to validate technical feasibility, performance, or specific implementation details.

**Required Elements:**
- [ ] **Investigation Goal**: Specific, well-defined question to be answered
- [ ] **Success Criteria**: What constitutes a complete investigation
- [ ] **Business Unlock**: What business requirement this investigation enables
- [ ] **Deliverable Format**: How findings will be documented and shared
- [ ] **Time Box**: Maximum time to spend on investigation (typically 0.5-1 day)

**Business Grounding Requirements:**
- [ ] **PRIMARY**: Addresses specific uncertainty or risk identified in call transcripts or worksheets
- [ ] **HIGH TRUST**: References Epic BRD analysis and confidence scoring
- [ ] **SECONDARY**: References business requirement from SOW or email communications
- [ ] Clear path from investigation outcome to business value documented in meeting transcripts

**Example Spike Ticket:**
```
Title: Assess Agentforce knowledge source sync latency
Type: Spike / Investigation (time‑boxed)

Investigation Goal: Determine the time between updating the knowledge base and the agent serving the updated answer.
Success Criteria: Documented procedure and measured latency; either latency < 15 minutes or recommended configuration to achieve it.
Business Unlock: Confirms feasibility of near‑real‑time content updates for student FAQs (supports EPIC_0 Knowledge Base Foundation).

Deliverable Format: docs/findings/<ticket‑id>-agentforce-sync-latency.md attached in ticket with summary comment.
Time Box: 0.5 day (4 hours)

Business Reference:
- PRIMARY: Requirements Session 3 transcript - stakeholder concerns about content freshness
- HIGH TRUST: EPIC_0_Knowledge_Base_Foundation (docs/brds/EPIC_0_Knowledge_Base_Foundation.md)
- SECONDARY: SOW Section 2.0 – Solution design assumptions around KB freshness

Acceptance Criteria (Given/When/Then):
- Given the documented test steps, when executed twice at different times of day, then observed sync latency is measured and recorded.
- Given the measured latency, when it exceeds the target, then proposed configuration or process adjustments are documented.
- Given the findings, when shared with stakeholders, then open risks and next actions are clearly listed.
```

---

## Business Context Validation

### 📋 SIM Agentforce Project Context
Every ticket must align with project fundamentals:

**Core Business Problems Being Solved:**
- [ ] LE team time relief from routine queries
- [ ] Improved lead data quality and validation
- [ ] Natural language interaction without menu navigation
- [ ] Comprehensive reporting and analytics
- [ ] Business hours and capacity management

**Project Scope Boundaries (SOW Section 3.01):**
- [ ] Within scope: Agentforce Q&A agent, Lead conversion, Dashboards, Routing configuration
- [ ] Out of scope: Data migration, Custom UI/UX, Website content format changes
- [ ] Clear understanding of LE Team vs Student Success Team deliverables

**User Personas Addressed:**
- [ ] Prospects (lead generation focus)
- [ ] Applicants (existing application context)
- [ ] Students (knowledge base access)
- [ ] Alumni (career progression vs general support)

---

## Review Checklist

### Before Moving to "Ready for Dev"

**1. Content Quality Review**
- [ ] Title is clear and actionable
- [ ] Description provides sufficient context
- [ ] All required fields completed
- [ ] Proper labeling and categorization

**2. Business Alignment Check**
- [ ] Supports one of the 5 main project EPICs
- [ ] References specific business requirement
- [ ] Includes stakeholder evidence or validation
- [ ] Aligns with SOW deliverables and timeline

**3. Technical Readiness Assessment**
- [ ] Implementation approach is clear
- [ ] Dependencies are identified and available
- [ ] Acceptance criteria are testable
- [ ] Definition of done is achievable

**4. Resource Planning Validation**
- [ ] Appropriate assignee identified
- [ ] Realistic effort estimation
- [ ] Required expertise available
- [ ] Timeline aligns with project schedule

---

## Quick Reference: Business Requirements Sources

### Primary Sources (Must Reference - In Trust Order)
- **Call Transcripts**: Requirements sessions 1-3 with direct stakeholder input (HIGHEST TRUST)
- **Requirements Worksheets**: Detailed analysis and processed user feedback (HIGHEST TRUST)
- **Epic BRDs**: 5 main EPICs with confidence scoring and structured evidence analysis (HIGH TRUST)
- **SOW Document**: Latest Scope of Work - USD 27K project scope
- **Email Communications**: Meeting summaries and stakeholder decisions

### Key Business Requirements
1. **Knowledge Base Foundation** (EPIC_0): Prerequisite for all agent functionality
2. **Natural Language Agent** (EPIC_1): Core Q&A capabilities
3. **Lead Data Quality** (EPIC_2): Email validation and complete lead capture
4. **Analytics & Reporting** (EPIC_3): Comprehensive dashboards and metrics
5. **Routing & Business Hours** (EPIC_4A/4B): Availability and workload management

### Success Metrics Reference
- Data quality: Elimination of incomplete lead records
- User engagement: Improved interaction metrics
- Operational efficiency: Reduced manual intervention in lead processing
- Staff utilization: Time savings for LE team follow-up activities

---

## Common Failure Modes

**❌ Tickets That Should NOT Move to Ready for Dev:**

1. **No Business Grounding**
   - "Implement nice-to-have feature" without business requirement
   - Technical improvements without business value statement
   - "Best practices" without specific project context

2. **Vague Requirements**
   - "Make chatbot better" without specific acceptance criteria
   - "Fix performance issues" without reproduction steps
   - "Add reporting" without specific metrics identified

3. **Missing Context**
   - No reference to project documentation
   - No stakeholder validation evidence
   - No connection to user personas or workflows

4. **Scope Creep Indicators**
   - Requirements outside SOW boundaries
   - Features not validated by business stakeholders
   - Technical complexity beyond project timeline

---

## Reviewer Actions

### ✅ PASS: Move to "Ready for Dev"
Ticket meets all quality gates and business requirements. Development team can proceed with confidence.

### 🔄 RETURN: Back to "In-Story-Writing"
Ticket needs refinement. **REQUIRED ACTIONS**:
1. Move ticket status back to "in-story-writing" using `mcp__ClickUp__update_task`
2. Ask clarifying questions and update the ticket directly

### ❌ REJECT: Remove from Current Sprint
Ticket doesn't align with business requirements or project scope. Requires stakeholder consultation.

---

## Active Ticket Improvement Process

**When a ticket fails quality criteria, DO NOT just reject it. Instead:**

**CRITICAL FIRST STEP: Move ticket back to "in-story-writing" status immediately using `mcp__ClickUp__update_task`**

**IMPORTANT: When in doubt about any aspect of the ticket, ASK THE USER for clarification before making assumptions or proceeding with updates.**

### Step 1: Identify Gaps
Document specific missing elements from this checklist.

### Step 2: Ask Clarifying Questions (ASK USER FIRST)
**When uncertain, always ask the user before making assumptions.** Use these question templates based on what's missing:

**Missing Business Grounding:**
- "Which specific call transcript, worksheet, or business document supports this requirement?"
- "Can you provide a stakeholder quote or business problem statement that validates this need?"
- "How does this ticket connect to the core project goals in the SOW?"

**Unclear Acceptance Criteria:**
- "What specific conditions must be met for this to be considered complete?"
- "How will we test and verify this functionality works as expected?"
- "What does 'done' look like from a user perspective?"

**Vague Requirements:**
- "Can you provide a concrete example of this functionality in action?"
- "What specific user actions should trigger this behavior?"
- "What error conditions or edge cases should be handled?"

**Unclear Ticket Type:**
- **ASK USER**: "Based on the ticket context, is this:
  - Unknown unknowns (exploring new domain, unclear what questions to ask) → Research ticket?
  - Known unknowns (specific question to answer) → Spike/Investigation ticket?
  - Clear requirements (ready to implement) → Feature/Enhancement/Bug ticket?"

**Conflicting Information:**
- **ASK USER**: "I found conflicting information in [source A] and [source B]. Which should take priority for this ticket?"

**Unclear Business Value:**
- **ASK USER**: "What specific business problem does this solve, or which Epic/requirement does it support?"

### Step 3: Update Ticket Directly
**You have full ClickUp MCP access - use these commands:**

#### For Updating Ticket Content:
- `mcp__ClickUp__update_task` - Update title, description, status, priority
- `mcp__ClickUp__create_task_comment` - Add clarifying questions as comments

#### For Ticket Information:
- `mcp__ClickUp__get_task` - Get current ticket details for context
- `mcp__ClickUp__get_task_comments` - Review existing discussion

#### For Status Management:
- **MANDATORY**: Move ticket back to "in-story-writing" status using `mcp__ClickUp__update_task`
- Add comments explaining what needs to be addressed

### Step 4: Document Requirements
When updating the ticket, include:
- **Gap Analysis**: What specific criteria failed
- **Required Information**: What business sources need to be provided
- **Next Actions**: Specific steps to address the gaps
- **Review Checklist**: Reference sections of this prompt that need attention

### Example Ticket Update:
```
Title: [NEEDS REFINEMENT] Original ticket title

Comments Added:
"This ticket needs additional information before moving to Ready for Dev:

MISSING BUSINESS GROUNDING:
- No reference to call transcripts, worksheets, or business requirements
- Required: Cite specific stakeholder input from requirements documentation

UNCLEAR ACCEPTANCE CRITERIA:
- Current criteria too vague: 'improve user experience'
- Required: Specific, testable conditions for completion

NEXT ACTIONS:
1. Reference specific business requirement from /requirements/ folder
2. Provide measurable acceptance criteria
3. Include stakeholder quote supporting this need

Review against: @exec/CLICKUP_TICKET_REVIEW_PROMPT.md sections 1-2"

Status: Moved to "in-story-writing"
```

### Available ClickUp Commands Summary:

**Core Ticket Management:**
- `mcp__ClickUp__get_task` - Retrieve ticket details
- `mcp__ClickUp__update_task` - Update any ticket field
- `mcp__ClickUp__create_task_comment` - Add comments with feedback
- `mcp__ClickUp__get_task_comments` - Review existing comments

**When to Use Each:**
- **get_task**: Always start here to understand current state
- **update_task**: Change status, add requirements, update description
- **create_task_comment**: Ask clarifying questions, provide feedback
- **get_task_comments**: Check if questions already asked/answered

**Pro Tip**: Use comments for questions and discussions, update_task for actual requirement changes.

---

## Usage Instructions

### For Ticket Review:
1. **Get ticket details**: Use `mcp__ClickUp__get_task` with ticket ID
2. **Work through checklist** systematically for each quality gate
3. **Check existing comments**: Use `mcp__ClickUp__get_task_comments` to avoid duplicate questions
4. **Reference business sources** when identifying gaps or confirming alignment

### For Failed Tickets (Active Improvement):
1. **FIRST ACTION**: Move ticket status back to "in-story-writing" using `mcp__ClickUp__update_task`
2. **Identify specific gaps** using this checklist
3. **Add clarifying questions** using `mcp__ClickUp__create_task_comment`
4. **Modify title if needed** to indicate refinement required (e.g., "[NEEDS REFINEMENT]")
5. **Follow up** until all quality criteria are met

### For Passing Tickets:
1. **Confirm status** is ready for "Ready for dev"
2. **Add approval comment** summarizing what criteria were met
3. **Reference business sources** that validate the requirements

**Remember**: Don't just reject tickets - actively improve them by asking the right questions and updating them directly using ClickUp MCP commands. The goal is ensuring every ticket that reaches development is actionable, valuable, and aligned with the SIM Agentforce project's business objectives.
