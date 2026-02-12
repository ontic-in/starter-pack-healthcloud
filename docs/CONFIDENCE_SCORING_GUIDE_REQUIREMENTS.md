# Requirements Confidence Scoring Guide

## Overview
This guide provides confidence scoring (0.0-1.0) specifically for **business requirements extracted from stakeholder conversations**. Confidence reflects the **validation level and implementation readiness** of requirements, not the quality of analysis work.

**Core Principle**: Confidence = **Stakeholder Validation + Implementation Readiness**, not how well-documented or thoroughly analyzed the requirement is.

## Quick Scoring Decision Tree

### For ANY Business Requirement:
START HERE → What level of stakeholder validation and implementation readiness do you have?

1. **Conversation-Level (0.1-0.3)**
   - Mentioned in discussion → 0.1
   - Detailed conversation occurred → 0.2
   - Business problem clearly articulated → 0.3

2. **Stakeholder-Validated (0.4-0.6)**
   - Key stakeholder confirmed need → 0.4
   - Decision-maker explicitly approved → 0.5
   - Customer prioritized against other needs → 0.6

3. **Implementation-Ready (0.7-0.9)**
   - Requirement scoped and feasible → 0.7
   - Acceptance criteria defined and agreed → 0.8
   - Ready for development with success metrics → 0.9

4. **Delivery-Proven (0.9-1.0)**
   - Successfully implemented in similar context → 0.95
   - Industry standard or proven pattern → 1.0

## Requirements-Specific Confidence Dimensions

### 1. Evidence Quality (Foundation Level)
- **0.1**: Single casual mention in transcript
- **0.2**: Multiple mentions or detailed discussion
- **0.3**: Quantitative data or specific examples provided
- **0.4**: Multiple stakeholders independently confirmed

### 2. Stakeholder Validation (Critical Dimension)
- **0.1**: Influencer opinion or suggestion
- **0.2**: Subject matter expert detailed input
- **0.3**: Department head or process owner confirmation
- **0.4**: Decision-maker explicit approval
- **0.5**: Customer prioritized as high/medium/low value
- **0.6**: Formal sign-off or documented agreement

### 3. Business Value Quantification
- **0.1**: Vague benefit claimed ("improves efficiency")
- **0.2**: General impact described ("saves time")
- **0.3**: Specific metrics mentioned ("reduces 30min to 5min")
- **0.4**: Quantified value calculated ("saves $50K annually")
- **0.5**: ROI analysis completed and validated

### 4. Implementation Feasibility
- **0.1**: May be technically impossible
- **0.2**: Requires custom development/research
- **0.3**: Standard platform capability confirmed
- **0.4**: Clear technical approach identified
- **0.5**: Ready for immediate user story creation

### 5. Constraint Compliance
- **0.1**: Likely out of scope or over budget
- **0.2**: Scope boundary unclear, needs validation
- **0.3**: Within contracted deliverables
- **0.4**: Fits timeline and resource allocation
- **0.5**: Aligns perfectly with project goals

## Confidence Levels for Requirements

### 0.1-0.3: Conversation-Level Requirements
- **0.1**: Mentioned once in passing, no detail
- **0.2**: Discussed in detail but not validated
- **0.3**: Clear business problem identified
- **Examples**:
  - "Someone mentioned mobile access would be nice" (0.1)
  - "Extended discussion about reporting needs but no specifics" (0.2)
  - "LE team spends 2 hours daily on manual data entry" (0.3)

### 0.4-0.6: Stakeholder-Validated Requirements
- **0.4**: Key stakeholder confirmed business need
- **0.5**: Decision-maker explicitly approved requirement
- **0.6**: Customer prioritized and committed resources
- **Examples**:
  - "Department head confirmed this solves critical workflow issue" (0.4)
  - "Project sponsor approved this as must-have feature" (0.5)
  - "Customer allocated budget and timeline for this specifically" (0.6)

### 0.7-0.8: Implementation-Ready Requirements
- **0.7**: Scoped, feasible, and constraint-compliant
- **0.8**: Detailed acceptance criteria defined and agreed
- **Examples**:
  - "Natural language chatbot to replace menu navigation - confirmed feasible with Agentforce" (0.7)
  - "Pre-chat form with Name/Email/Phone validation - customer approved exact fields and flow" (0.8)

### 0.9-1.0: Delivery-Proven Requirements
- **0.9**: Successfully implemented in similar context
- **1.0**: Industry standard or proven implementation pattern
- **Examples**:
  - "Lead qualification workflow - delivered successfully in 3 previous Agentforce projects" (0.9)
  - "Knowledge base integration - standard Salesforce capability" (1.0)

## Evidence-First Checklist for Requirements

When scoring requirements confidence, use this format:

```markdown
## Requirement Confidence Score: [X.X]

### Evidence Quality:
- Transcript sources: [List specific calls/sessions]
- Direct quotes: "[Exact stakeholder quotes with attribution]"
- Quantitative data: [Specific numbers, volumes, timelines]
- Multiple confirmation: [How many stakeholders mentioned this]

### Stakeholder Validation:
- Who confirmed: [Name, role, decision-making authority]
- Validation level: [Mentioned/Discussed/Approved/Prioritized]
- Customer priority: [High/Medium/Low with reasoning]
- Business owner: [Who will be accountable for success]

### Business Value Evidence:
- Current state cost: [Time/money/quality impact]
- Desired state benefit: [Specific improvement metrics]
- ROI calculation: [If available, dollar savings or revenue impact]
- Success metrics: [How we'll measure requirement completion]

### Implementation Readiness:
- Technical feasibility: [Platform capability assessment]
- Resource requirements: [Development effort estimate]
- Timeline fit: [How this fits project schedule]
- Acceptance criteria: [Specific, testable conditions]

### Constraint Compliance:
- Scope validation: [In contract vs. out of scope]
- Budget impact: [Within allocated resources]
- Timeline impact: [Fits development schedule]
- Risk assessment: [Implementation risks identified]

### What's NOT validated:
- [List specific unknowns or assumptions]

### Final Confidence Rationale:
[Evidence type] validation: [specific evidence]. [Testing level]: [what was validated]. [Limitation]: [what needs more validation].
```

## Requirements Confidence Anti-Patterns

❌ **Conversation Inflation**
- "Detailed discussion" (0.8) when no stakeholder confirmed → Should be 0.2-0.3

❌ **Stakeholder Confusion**
- "Executive mentioned" (0.7) when not the decision-maker → Should be 0.2-0.3

❌ **Implementation Assumption**
- "Clearly feasible" (0.8) without technical validation → Should be 0.3-0.4

❌ **Scope Optimism**
- "Obviously in scope" (0.7) without contract validation → Should be 0.2-0.3

❌ **Value Vagueness**
- "High business value" (0.8) without quantification → Should be 0.2-0.4

❌ **Validation Theater**
- Using 0.7+ without actual stakeholder confirmation

## Requirements Confidence Rationale Template

```
"[Evidence type]: [specific quotes and data]. [Stakeholder validation]: [who confirmed and how]. [Implementation readiness]: [technical feasibility status]. [Limitation]: [what still needs validation]."
```

**Examples**:
- "Transcript evidence: 'Menu navigation causes 40% dropoff' - Sean, LE Team Lead. Stakeholder validation: Project sponsor confirmed as #1 priority. Implementation readiness: Agentforce natural language confirmed feasible. Limitation: Exact conversation flow design needs customer approval." **Score: 0.7**

- "Transcript evidence: 'Reporting would be nice to have' mentioned once. Stakeholder validation: No decision-maker confirmation. Implementation readiness: Standard Salesforce capability. Limitation: Business value unquantified, priority unclear." **Score: 0.2**

## Requirements vs. Implementation Confidence

**Requirements Confidence** (This Guide):
- How validated is this business need?
- How ready is this for development?
- How likely is stakeholder acceptance?

**Implementation Confidence** (Use @learn/CONFIDENCE_SCORING_GUIDE.md):
- How confident are we in technical solution?
- How tested is our implementation approach?
- How proven is our development process?

## Decision Framework for Requirements

### High Confidence (0.7+): Proceed with Development
- Strong stakeholder validation
- Clear business value quantification
- Implementation feasibility confirmed
- Constraint compliance validated

### Medium Confidence (0.4-0.6): Validate Before Development
- Get explicit stakeholder confirmation
- Quantify business value impact
- Confirm technical feasibility
- Validate scope and timeline fit

### Low Confidence (0.1-0.3): Research Before Requirements
- Gather more stakeholder input
- Understand business problem better
- Assess implementation complexity
- Validate constraint boundaries

## Remember for Requirements Work

- Requirements confidence reflects **stakeholder validation**, not analysis quality
- Start with evidence from transcripts and build validation systematically
- XP principle: Customer collaboration over contract negotiation - but validate the collaboration
- High requirements confidence requires real stakeholders making real commitments
- Implementation can only be as confident as the underlying requirements