# Emails

Important email communications with client.

## Purpose

Archive critical email threads that contain requirements, clarifications, approvals, or scope changes.

## Content Types

- Requirement clarifications
- Scope change requests
- Client approvals and sign-offs
- Technical discussions via email
- Contract amendments
- Timeline adjustments

## Naming Convention

`YYYYMMDD_[SUBJECT_SUMMARY].md`

Examples:
- `20250923_scope_clarification_reporting.md`
- `20250925_approval_phase1_requirements.md`
- `20251001_technical_question_authentication.md`

## Best Practices

1. **Convert to Markdown**: Convert email threads to readable Markdown format
2. **Preserve Headers**: Include From, To, Cc, Date, Subject
3. **Thread Structure**: Maintain email thread hierarchy (latest first or chronological)
4. **Attachments**: Reference attachments and store in `../client_docs/` if needed
5. **Action Items**: Extract action items and create ClickUp tickets
6. **Link**: Cross-reference with related transcripts or worksheets

## Template Structure

```markdown
# Email: [Subject]

**Date**: YYYY-MM-DD
**From**: Sender Name <email@example.com>
**To**: Recipient Name <email@example.com>
**Cc**: CC Recipients
**Subject**: Original Subject Line

---

## Email Content

[Email body content]

---

## Follow-up Actions

- [ ] Action 1 - @Owner - Due: DATE
- [ ] Action 2 - @Owner - Due: DATE

## Related Documents

- Link to transcript: `../client_call_transcripts/YYYYMMDD_meeting.md`
- Link to worksheet: `../requirements_worksheets/Feature_Requirements.md`
```
