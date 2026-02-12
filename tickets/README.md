# Tickets Directory

All ticket-related work, analysis, and artifacts.

## Naming Convention

```
tickets/{ticket-id}-brief-description/
```

Example: `tickets/86d0xjye7-delivery-template/`

## Contents

Each ticket folder should contain:
- Analysis and investigation notes
- Implementation notes
- Test evidence (screenshots, logs)
- RCA (Root Cause Analysis) if fixing bugs
- Any ticket-specific documentation

## Workflow

1. Create ClickUp ticket
2. Create branch: `clickup-{ticket-id}-description`
3. Create ticket folder: `tickets/{ticket-id}-description/`
4. Do work, document in ticket folder
5. Commit with ticket ID: `[{ticket-id}] description`

## Best Practices

- Keep ticket folders organized and focused
- Link back to ClickUp ticket in commits
- Document decisions and trade-offs
- Store test evidence for QA validation
