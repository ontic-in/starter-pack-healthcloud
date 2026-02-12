# ClickUp Planning

ClickUp project planning and ticket documentation.

## Purpose

Store ClickUp-related planning documents, epic definitions, and exported ticket structures.

## Content Types

- Epic definitions
- Sprint planning documents
- Ticket structure exports
- Milestone planning
- Project roadmaps
- Release planning

## Naming Convention

- `Epic_[NAME]_[DATE].md`
- `Sprint_[NUMBER]_Plan_[DATE].md`
- `Milestone_[NAME]_[DATE].md`
- `Roadmap_[QUARTER]_[DATE].md`

## Best Practices

1. **Link to ClickUp**: Include ClickUp ticket/epic URLs
2. **Export Structure**: Export ticket hierarchies for documentation
3. **Planning**: Document sprint/milestone planning decisions
4. **Roadmap**: Maintain up-to-date project roadmap
5. **Sync**: Keep this directory in sync with ClickUp
6. **Archive**: Archive completed sprint/milestone plans

## Epic Template

```markdown
# Epic: [Epic Name]

**ClickUp Epic**: https://app.clickup.com/t/[EPIC_ID]
**Status**: [Status]
**Owner**: [Name]
**Start Date**: YYYY-MM-DD
**Target Completion**: YYYY-MM-DD

## Description

[Epic description and business value]

## User Stories

1. **[Story 1]** - https://app.clickup.com/t/[TICKET_ID]
   - Acceptance Criteria: [...]
   - Story Points: [X]

2. **[Story 2]** - https://app.clickup.com/t/[TICKET_ID]
   - Acceptance Criteria: [...]
   - Story Points: [X]

## Dependencies

- Depends on: [Epic/Ticket]
- Blocks: [Epic/Ticket]

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2
```
