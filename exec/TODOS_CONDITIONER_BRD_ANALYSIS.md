# TODOS Conditioner for BRD Requirements Analysis from Call Transcripts

Use this prompt to analyze call transcripts and extract **validated, implementable business requirements** following these evidence-based principles:

Use @docs/CONFIDENCE_SCORING_GUIDE_REQUIREMENTS.md to assess confidence in requirement validity.
Use @exec/TODOS_CONDITIONER_DOCS.md if the work shifts to documentation creation.

## Core Principles for Requirements Analysis

**Requirements Analysis is NOT Documentation or Development Work**:
- **Evidence Base**: Transcripts contain conversations, not final decisions
- **Validation Critical**: Stakeholder statements ≠ confirmed requirements
- **Constraint Reality**: Timeline/budget/scope determine feasibility
- **Business Value Focus**: Quantify impact, not just document features
- **Implementation Readiness**: Requirements must be actionable for developers

## Requirements Analysis Methodology

### 1. **Evidence Collection First**
Extract specific quotes, data points, and context from transcripts:
- Direct quotes with speaker attribution
- Quantitative data (volumes, timelines, metrics)
- Pain point descriptions with business impact
- Current state vs. desired state comparisons

### 2. **Business Problem Identification**
Transform conversation points into business problems:
- What business process is broken/inefficient?
- What cost/time/quality impact exists?
- Who is affected and how often?
- What's the measurable business value of solving this?

### 3. **Constraint Validation**
Reality-check each potential requirement:
- **Timeline**: Does this fit the project timeline?
- **Scope**: Is this in contracted deliverables?
- **Budget**: Are resources available for this complexity?
- **Technical**: Is this feasible with chosen platform/technology?

### 4. **Stakeholder Confirmation Assessment**
Distinguish conversation levels:
- **Mentioned**: Brought up in discussion
- **Discussed**: Detailed conversation occurred
- **Confirmed**: Stakeholder explicitly validated
- **Prioritized**: Customer ranked as high/medium/low value

### 5. **Value Quantification**
Where possible, quantify business impact:
- Time savings (hours per day/week/month)
- Cost reduction (dollar amounts)
- Quality improvements (error reduction %)
- Volume capacity (transactions, users, conversations)
- Risk mitigation (compliance, security, business continuity)

### 6. **Implementation Readiness Check**
Ensure requirement can become user stories:
- Clear user type identification
- Specific functionality needed
- Measurable acceptance criteria
- Business benefit articulation

## BRD Analysis Todo Structure

```
1. [📖] **EVIDENCE**: Extract specific quotes and data from [transcript source]
   - Include speaker, timestamp, exact quote
   - Note quantitative data (volumes, timelines, pain frequencies)

2. [🎯] **PROBLEM**: Identify core business problem being solved
   - What process is broken/inefficient?
   - Who is impacted and how often?
   - What's the current cost/time/quality impact?

3. [⚖️] **CONSTRAINTS**: Validate against project realities
   - Timeline feasibility check
   - Scope/contract boundary validation
   - Technical platform capability check
   - Resource availability assessment

4. [🏢] **STAKEHOLDER**: Assess confirmation level
   - Who mentioned this and in what context?
   - Was this discussed in detail or passing mention?
   - Did customer prioritize this requirement?
   - Is stakeholder decision-maker for this area?

5. [💰] **VALUE**: Quantify business impact where possible
   - Time savings: X hours per [period]
   - Cost reduction: $X per [period]
   - Quality improvement: X% error reduction
   - Capacity increase: X more [transactions/users/etc.]

6. [📚] **LEARN**: Search existing requirement patterns first, then store this analysis approach with aligned trigger phrases

7. [📋] **REQUIREMENT**: Create implementation-ready BRD requirement
   - Clear business problem statement
   - Measurable success criteria
   - User story outline ready for development
   - Priority level with justification

8. [🎯] **CONFIDENCE**: Score requirement confidence using @docs/CONFIDENCE_SCORING_GUIDE_REQUIREMENTS.md
```

## Requirements Analysis Anti-Patterns

❌ **Feature Shopping**: Listing everything mentioned vs. validated business needs
❌ **Assumption Inflation**: Treating conversation points as confirmed requirements
❌ **Scope Creep Enablement**: Including every "nice to have" without constraint validation
❌ **Implementation Ignorance**: Requirements that can't be turned into user stories
❌ **Value Vagueness**: "Improves efficiency" without quantification
❌ **Stakeholder Confusion**: Confusing influencer opinions with decision-maker validation
❌ **Transcript Literalism**: Copying conversation flow vs. extracting business needs
❌ **Constraint Blindness**: Ignoring timeline, budget, or technical limitations

## Evidence-Based Decision Framework

**For Each Potential Requirement, Ask**:

### **Is This a Real Business Need?**
- Is there a quantifiable current-state problem?
- Who specifically is impacted and how often?
- What's the business cost of not solving this?

### **Is This Validated by Decision-Makers?**
- Did the right stakeholder confirm this need?
- Was this discussed in detail or mentioned in passing?
- Did customer prioritize this against other needs?

### **Is This Implementable Given Constraints?**
- Does this fit the project timeline?
- Is this in contracted scope?
- Do we have technical capability and resources?
- Can this be broken into user stories immediately?

### **Can We Measure Success?**
- What metrics will prove this solved the business problem?
- How will we know when this requirement is complete?
- What's the expected business impact (time, cost, quality)?

## BRD Requirement Quality Criteria

**High-Quality Requirements Must Have**:
- [ ] Specific transcript evidence with quotes and context
- [ ] Clear business problem statement with impact quantification
- [ ] Stakeholder validation level clearly documented
- [ ] Constraint feasibility assessment completed
- [ ] Implementation-ready user story outline
- [ ] Measurable success criteria defined
- [ ] Priority level with business value justification
- [ ] Confidence score with evidence-based rationale

## Pattern Storage Focus

**When storing successful requirement analysis patterns, include**:
- Problem identification approach that worked
- Effective constraint validation methods
- Stakeholder confirmation techniques
- Value quantification strategies
- Implementation readiness frameworks
- Specific transcript analysis methods that revealed business value

## Remember: Requirements ≠ Features

Focus on **business problems to solve**, not features to build. The goal is validated, implementable requirements that deliver measurable business value within project constraints.

Every requirement should answer: **"What business problem does this solve, for whom, and how do we measure success?"**