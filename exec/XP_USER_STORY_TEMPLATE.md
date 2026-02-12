# XP-Aligned User Story Template

> **Self-Running Prompt for Creating/Reviewing User Stories in ClickUp**
>
> Use this as a prompt: "Create user stories following this XP-aligned template for [feature/requirement]. Follow the template structure and XP principles exactly."
>
> **Related Templates**: Use @exec/XP_BRD_TEMPLATE.md for overall project requirements documentation

## XP User Story Principles

**Kent Beck's XP approach to user stories:**
- Customer-authored or heavily customer-involved
- Focus on business value, not technical implementation
- Brief enough to estimate, detailed enough to implement
- Evolve through continuous feedback
- Serve as conversation starters, not comprehensive specs
- Prioritized by customer based on business value

## Core User Story Template

### Standard Format:
```
As a [specific user type/role]
I want [specific functionality]
So that [clear business benefit/value]
```

### Enhanced XP Format:
```
**User Type:** [Primary user who benefits]
**Business Value:** [Why this matters to business/user - be specific]
**Priority:** [High/Medium/Low] - [Customer rationale for priority]

**Story:**
As a [specific user type]
I want [specific functionality]
So that [measurable business benefit]

**Acceptance Criteria:**
- [ ] [Specific, testable condition]
- [ ] [Specific, testable condition]
- [ ] [Specific, testable condition]

**Definition of Done:**
- [ ] Passes all acceptance criteria
- [ ] Customer has reviewed and accepted
- [ ] Automated tests written and passing
- [ ] Integrated and deployed
- [ ] Success metrics verified (if applicable)

**Dependencies:**
- [Other user story or system dependency]

**Assumptions:**
- [Key assumption about user behavior or system state]

**Success Metrics (if measurable):**
- [How we'll know this delivers value]
```

## ClickUp Implementation Guide

### Creating User Stories in ClickUp:

**1. Task Creation:**
- **Task Name:** Use story format: "As [user] I want [feature] so that [benefit]"
- **Description:** Full user story template content
- **Assignee:** Development team member
- **Priority:** Map XP business priority to ClickUp priority

**2. Custom Fields Setup:**
- **User Type:** [Dropdown: Student, Faculty, Admin, etc.]
- **Business Value:** [Text field for value justification]
- **Story Points:** [Number field for estimation]
- **Customer Priority:** [High/Medium/Low based on customer input]
- **Success Metric:** [Text field if measurable outcome exists]

**3. ClickUp Status Workflow:**
- **Backlog:** Story defined, awaiting iteration planning
- **Ready:** Story estimated and ready for development
- **In Progress:** Currently being developed
- **Review:** Internal review (code, testing)
- **Customer Review:** Customer feedback and acceptance
- **Done:** Meets definition of done

**4. Linking and Organization:**
- **Link related stories:** Use ClickUp relationships
- **Epic/Feature grouping:** Parent tasks for larger features
- **Iteration tagging:** Use tags for iteration/cycle organization

## User Story Quality Checklist

### Before Creating in ClickUp:
- [ ] **Independent:** Can be developed without other stories
- [ ] **Negotiable:** Details can evolve through conversation
- [ ] **Valuable:** Delivers clear business value
- [ ] **Estimable:** Team can size the effort reasonably
- [ ] **Small:** Can be completed in one iteration
- [ ] **Testable:** Acceptance criteria are verifiable

### Customer Collaboration Requirements:
- [ ] Customer has reviewed and prioritized story
- [ ] Business value clearly articulated by customer
- [ ] Acceptance criteria agreed upon with customer
- [ ] Customer availability confirmed for feedback/review

## Story Variations by Context

### Simple Feature Story:
```
As a course instructor
I want to upload assignments with due dates
So that students receive clear assignment expectations

Acceptance Criteria:
- [ ] Can upload PDF/Word document
- [ ] Can set due date and time
- [ ] Students receive notification of new assignment
- [ ] Assignment appears in student dashboard
```

### Business Process Story:
```
As a program administrator
I want automated student progress tracking
So that I can identify at-risk students early

Business Value: Reduce student dropout by 15% through early intervention

Acceptance Criteria:
- [ ] System tracks assignment completion rates
- [ ] Flags students with <70% completion
- [ ] Sends weekly progress reports to administrators
- [ ] Provides intervention recommendation templates

Success Metrics:
- Student dropout rate decreases by 15%
- Time to identify at-risk students reduces from 4 weeks to 1 week
```

### Technical Debt/Infrastructure Story:
```
As a system administrator
I want automated database backups
So that student data is protected from loss

Business Value: Ensures continuity of educational services and compliance

Acceptance Criteria:
- [ ] Daily automated backups to secure cloud storage
- [ ] Backup verification process runs successfully
- [ ] Recovery procedure documented and tested
- [ ] Backup failure alerts sent to admin team

Dependencies:
- Cloud storage account setup
- Security compliance review
```

## XP Iteration Planning with ClickUp

### Planning Game Process:
1. **Customer prioritizes** stories in ClickUp by business value
2. **Team estimates** using story points or time
3. **Iteration capacity** determined by team velocity
4. **Customer selects** highest-value stories that fit iteration
5. **ClickUp iteration view** created for selected stories

### Continuous Feedback Loop:
- **Daily standups:** Update story progress in ClickUp
- **Customer check-ins:** Weekly review of completed stories
- **Story evolution:** Update acceptance criteria based on feedback
- **Iteration review:** Customer acceptance of delivered stories

## Anti-Patterns to Avoid

**❌ Technical Implementation Stories:**
```
Bad: "As a developer, I want to refactor the database schema..."
Better: "As an instructor, I want faster grade processing..."
```

**❌ Overly Complex Stories:**
```
Bad: "Complete student management system with all features"
Better: Individual stories for enrollment, grades, attendance, etc.
```

**❌ Missing Business Value:**
```
Bad: "I want a dashboard"
Better: "I want a dashboard so I can monitor student progress daily"
```

**❌ Non-Testable Criteria:**
```
Bad: "System should be user-friendly"
Better: "New users can complete enrollment in under 5 minutes"
```

---

## Usage Instructions

**When creating a new user story:**
1. Copy this template structure
2. Fill in specific details for your feature
3. Review with customer for priority and acceptance criteria
4. Create in ClickUp with appropriate fields and links
5. Estimate with development team
6. Add to iteration based on customer priority

**For story reviews:**
1. Check against XP quality checklist
2. Verify customer involvement in creation
3. Ensure business value is clear and specific
4. Confirm acceptance criteria are testable
5. Validate story size is appropriate for one iteration