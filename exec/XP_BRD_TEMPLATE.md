# XP-Aligned Business Requirements Document (BRD) Template

> **Self-Running Prompt for Creating/Reviewing BRDs in ClickUp**
>
> Use this as a prompt: "Create a BRD following this XP-aligned template for [project/feature name]. Follow the template structure and XP principles exactly."
>
> **Requirements Analysis**: First use `@exec/TODOS_CONDITIONER_BRD_ANALYSIS.md` to extract validated requirements from call transcripts, then use this template to structure the BRD.

## XP Principles for Requirements

**Kent Beck's XP approach to requirements:**
- User stories over comprehensive documents
- Continuous customer collaboration
- Embrace change as core methodology
- Focus on business value and priority
- Keep it simple - implement only what's needed
- Sustainable pace with mutual benefit

## BRD Structure (Minimalist & XP-Aligned)

### 1. Business Problem & Value
**One clear sentence describing the problem and expected business value.**
```
Problem: [Specific business problem being solved]
Value: [Measurable business benefit expected]
```

### 2. User Stories Collection
**Core feature requirements as user stories, prioritized by customer/business value:**

*Use @exec/XP_USER_STORY_TEMPLATE.md for detailed user story creation*

```
As a [user type]
I want [functionality]
So that [business benefit]

Acceptance Criteria:
- [ ] [Specific testable condition]
- [ ] [Specific testable condition]
- [ ] [Specific testable condition]

Business Priority: [High/Medium/Low] - [Brief justification]
```

*Repeat for each major user story*

### 3. Iteration Plan
**XP uses iterations (1-3 weeks), not sprints. Plan flexible delivery:**

```
Iteration 1 (Week 1-2):
- [Highest value user story]
- [Next highest value story]

Iteration 2 (Week 3-4):
- [Next priority stories]
- [Customer feedback integration]

Customer Checkpoint: [When customer reviews and provides feedback]
```

### 4. Success Criteria
**Measurable outcomes that prove business value:**
- [Specific metric] will [increase/decrease] by [amount/percentage]
- [User behavior] will change from [current] to [desired]
- [Business process] will be [specific improvement]

### 5. Constraints & Assumptions
**Keep minimal - only critical constraints:**
- Technical: [If any critical technical limitations]
- Business: [Timeline, budget, or resource constraints]
- Regulatory: [If applicable]

**Assumptions:**
- Customer availability for feedback: [When/how often]
- [Key assumption about user behavior or system]

### 6. Definition of Done
**XP emphasizes working software and customer satisfaction:**
- [ ] User stories pass acceptance criteria
- [ ] Customer has reviewed and accepted functionality
- [ ] Automated tests written and passing
- [ ] Code reviewed and integrated
- [ ] Production deployment successful
- [ ] Success metrics measured and verified

---

## ClickUp Implementation Instructions

### Creating BRD in ClickUp:
1. **Create Epic/Project** with BRD name
2. **Add User Stories as Tasks** in ClickUp
3. **Use ClickUp Custom Fields** for:
   - Business Priority (High/Medium/Low)
   - Iteration Number
   - Success Metrics
4. **Link Related Tasks** to show dependencies
5. **Set up ClickUp Views** by iteration and priority

### ClickUp Status Workflow:
- **Backlog**: User stories awaiting iteration planning
- **In Progress**: Currently being developed
- **Review**: Customer/stakeholder review
- **Done**: Meets Definition of Done

### Customer Collaboration:
- **Schedule regular feedback sessions** (not just at iteration end)
- **Use ClickUp comments** for customer input and clarification
- **Track changes** to user stories with rationale
- **Document customer decisions** in ClickUp for transparency

---

## Template Usage Notes

**When to Use This BRD Template:**
- Project requires stakeholder alignment on scope
- Multiple user types or complex workflow
- Need to communicate business value to executives
- Regulatory or compliance requirements need documentation

**When NOT to Use (Pure XP):**
- Simple, single-user story features (use @exec/XP_USER_STORY_TEMPLATE.md directly)
- Internal tools with embedded customer
- Proof-of-concept or experimental work

**XP Adaptation:**
- This template serves as initial alignment tool
- Once development starts, live collaboration trumps document
- Update BRD only when major scope changes occur
- User stories evolve - document reflects current understanding, not fixed requirements