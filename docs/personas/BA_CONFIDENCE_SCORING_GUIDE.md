# BA Confidence Scoring Guide for Requirements & Documentation

## Overview
This guide provides confidence scoring (0.0-1.0) specifically for Business Analyst work on requirements gathering, documentation quality, and Salesforce implementation planning. Confidence reflects the **validation level with actual users and stakeholders**, not documentation polish.

## Core Principle for BA Work
**Confidence = User/Stakeholder Validation Level**, not how comprehensive or well-written the documentation is.

## BA-Specific Decision Tree

### For ANY Requirements/Documentation:
START HERE → What level of user/stakeholder validation do you have?

1. **Theoretical/Assumed** (0.1-0.3)
   - Requirement assumed from similar projects → 0.1
   - Stakeholder mentioned it casually → 0.2
   - Draft user story written, not validated → 0.3

2. **Initial Stakeholder Validation** (0.4-0.6)
   - Requirement confirmed with 1-2 stakeholders → 0.4
   - User story reviewed and approved by product owner → 0.5
   - Acceptance criteria agreed upon with end users → 0.6

3. **Multi-Stakeholder Validated** (0.7-0.9)
   - Requirement validated across user groups (< 10 users) → 0.7
   - Piloted with real data/workflows (10-50 users) → 0.8
   - Validated in production-like environment (50+ users) → 0.9

4. **Production-Proven** (0.9-1.0)
   - Successfully implemented and adopted → 0.95
   - Proven pattern across multiple projects → 1.0

## BA Deliverable Specific Scoring

### User Stories
- Story idea documented → 0.1
- Basic format (As a/I want/So that) → 0.2
- Acceptance criteria drafted → 0.3
- Stakeholder reviewed and approved → 0.5
- User validated with real scenarios → 0.7
- Successfully implemented and adopted → 0.9

### Business Requirements Documents (BRDs)
- Problem statement drafted → 0.1
- Solution approach researched → 0.2
- Requirements documented and structured → 0.3
- Executive/sponsor approval → 0.4
- Technical feasibility confirmed → 0.5
- User workflow validation completed → 0.7
- Pilot implementation successful → 0.8
- Full production deployment successful → 0.9

### Process Documentation
- Process observed and documented → 0.2
- Stakeholders reviewed draft → 0.3
- Current state validated with users → 0.5
- Future state tested with pilot users → 0.7
- Process change successfully adopted → 0.8
- Sustained adoption over multiple cycles → 0.9

### Salesforce Solution Design
- Platform capability researched → 0.2
- Solution design documented → 0.3
- Technical feasibility confirmed → 0.4
- Configured in sandbox and tested → 0.5
- User acceptance testing completed → 0.7
- Production deployment successful → 0.8
- User adoption targets met → 0.9

## Evidence-First Checklist for BA Work

When scoring requirements/documentation, use this format:

```markdown
## Confidence Score: [X.X]

### User/Stakeholder Validation Evidence:
- Users interviewed: ___ (specific count)
- Stakeholder approval: ___ (who and when)
- Pilot testing period: ___ (duration and user count)
- Adoption metrics: ___% (if measurable)

### BA-Specific Evidence:

#### For Requirements:
- Stakeholder interviews: ___
- User workflow observations: ___
- Current state validation: [completed/partial/none]
- Future state testing: [completed/partial/none]
- Business value quantified: $___ or ___% improvement

#### For User Stories:
- [ ] Story format complete (As a/I want/So that)
- [ ] Acceptance criteria defined
- [ ] Business value articulated
- [ ] User validated scenarios
- [ ] Technical feasibility confirmed
- [ ] Priority agreed with product owner

#### For Process Documentation:
- Process steps observed: ___
- Current state validated by: ___ (role/name)
- Pain points confirmed: ___ (specific issues)
- Solution tested with: ___ users
- Training completed: ___% of affected users

### What's NOT validated:
- [List specific unknowns or assumptions]

### Final Justification:
[One sentence with NUMBERS, e.g., "0.6 because 5/7 user groups validated acceptance criteria but 2 technical constraints not yet tested"]
```

## Requirements Quality Confidence Levels

### 0.1-0.3: Assumption & Basic Documentation
- **0.1**: Requirement assumed from similar projects
- **0.2**: Stakeholder mentioned need in passing conversation
- **0.3**: User story drafted with basic acceptance criteria
- Examples:
  - "Students need better grade tracking" (0.1) - general assumption
  - "Faculty want mobile access to gradebooks" (0.2) - mentioned in meeting
  - "Staff require automated report generation" (0.3) - documented but not validated

### 0.4-0.6: Stakeholder Validation
- **0.4**: Key stakeholder confirms requirement
- **0.5**: Product owner approves user story priority
- **0.6**: End users validate acceptance criteria
- Examples:
  - "Dean confirms need for enrollment dashboard" (0.4) - executive validation
  - "Registrar approves student information system changes" (0.5) - process owner agreement
  - "Faculty test gradebook workflow and approve design" (0.6) - end user validation

### 0.7-0.8: Multi-User Validation
- **0.7**: Requirement validated with multiple user groups (<10 users)
- **0.8**: Pilot tested with real data and workflows (10-50 users)
- Examples:
  - "Course scheduling requirements validated with 5 department heads" (0.7) - cross-functional validation
  - "Student portal tested with 25 students using real course data" (0.8) - pilot validation

### 0.9-1.0: Production Validation
- **0.9**: Successfully implemented and meeting adoption targets
- **1.0**: Proven pattern from multiple successful implementations
- Examples:
  - "New admissions process deployed, 90% staff adoption in 30 days" (0.9) - successful implementation
  - "Student lifecycle management pattern proven across 3 universities" (1.0) - industry pattern

## BA Anti-Patterns to Avoid

❌ **Documentation Quality = Confidence**
- "Comprehensive BRD with 50 pages" (0.8) without user validation → Should be 0.3

❌ **Stakeholder Approval = User Validation**
- "Executive signed off" (0.7) without end user input → Should be 0.4

❌ **Feature Completeness = Requirements Quality**
- "All features documented" (0.9) without business value validation → Should be 0.5

❌ **Technical Feasibility = Business Value**
- "Salesforce can do this" (0.8) without user workflow validation → Should be 0.4

❌ **Assumption Inflation**
- "Based on industry best practices" (0.7) without local validation → Should be 0.2

## XP Integration for BA Confidence

### User Story Evolution Scoring:
- Initial conversation captured → 0.1
- Story card written → 0.2
- Acceptance criteria added → 0.3
- Customer prioritized → 0.4
- Estimated by dev team → 0.5
- Customer acceptance test defined → 0.6
- Iteration delivered and accepted → 0.7
- User adoption measured → 0.8
- Pattern reused in next iteration → 0.9

### Customer Collaboration Confidence:
- Customer identified and available → 0.2
- Regular feedback sessions scheduled → 0.4
- Customer actively participates in planning → 0.6
- Customer provides timely acceptance feedback → 0.7
- Customer requests inform iteration changes → 0.8
- Customer satisfaction measured and high → 0.9

## Salesforce BA Specific Patterns

### Data Model Requirements:
- Objects/fields identified from interviews → 0.3
- Current system data mapped → 0.5
- Validation rules tested with real data → 0.7
- User adoption of new data model → 0.9

### Integration Requirements:
- System touchpoints documented → 0.2
- Data flow validated with system owners → 0.5
- Integration tested in sandbox → 0.7
- Production integration successful → 0.9

### Security & Access Requirements:
- Roles identified from org chart → 0.2
- Permissions validated with security team → 0.5
- Access tested with pilot users → 0.7
- Security audit passed in production → 0.9

## Educational Institution Specific Scoring

### Student Lifecycle Requirements:
- Process documented from catalog → 0.2
- Current state validated with registrar → 0.4
- Future state tested with sample students → 0.7
- Full semester cycle completed successfully → 0.9

### Faculty Workflow Requirements:
- Academic process documented → 0.3
- Department heads validate requirements → 0.5
- Faculty pilot test with real courses → 0.8
- Semester-end adoption metrics positive → 0.9

### Administrative Process Requirements:
- Policy requirements documented → 0.2
- Compliance team validates approach → 0.4
- Staff test new process → 0.6
- Audit cycle completed successfully → 0.9

## BA Confidence Rationale Template

```
"[Validation type]: [specific evidence]. [Testing level]: [what was validated]. [Limitation]: [what needs more validation]."
```

Examples:
- "Stakeholder validation: 3/4 department heads approve user stories. User testing: 8 faculty completed workflow pilot. Limitation: Student-facing features not yet tested."
- "Requirements validation: All acceptance criteria reviewed with product owner. Technical validation: Salesforce sandbox configured and tested. Limitation: Integration with student system pending."

## Remember for BA Work
- Confidence reflects **user validation**, not documentation quality
- Start with stakeholder assumptions (low confidence) and build through user validation
- XP emphasizes customer collaboration - use this for confidence building
- Educational institutions have complex stakeholder groups - validate across all affected roles
- Salesforce capabilities don't guarantee user adoption - validate workflows, not just features
- High confidence requires real users doing real work with real data