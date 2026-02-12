# Design Documentation

Architecture designs, technical specifications, and system design documents.

## Purpose

This directory contains design documentation for the project including:
- System architecture documents
- Technical design specifications
- Data models and schemas
- Integration designs
- UI/UX mockups and wireframes
- Architecture diagrams

## Directory Structure

```
designs/
├── README.md                       # This file - Design guidelines
├── architecture/                   # Architecture design documents
│   ├── [TICKET_ID]-[NAME].md      # Architecture document
│   ├── [NAME]-diagram.png         # Architecture diagrams
│   └── [NAME]-diagram.mmd         # Mermaid diagram source
└── [PROJECT_NAME]-design.md       # Main design document (optional)
```

## Document Types

### Architecture Documents

Location: `architecture/`

Purpose: System architecture, component design, and technical specifications

Format: `[TICKET_ID]-[ARCHITECTURE_NAME].md`

Examples:
- `86d0abc12-agentforce-architecture.md`
- `86d0def34-integration-architecture.md`
- `86d0ghi56-data-architecture.md`

### Main Design Document

Location: Root of `designs/`

Purpose: High-level project design overview and summary

Format: `[PROJECT_NAME]-design.md`

Example:
- `SalesforceAgent-design.md`
- `ChatbotPlatform-design.md`

## Architecture Document Template

See `architecture/ARCHITECTURE-TEMPLATE.md` for the standard template.

### Required Sections

1. **Header Information** - Ticket ID, creation date, status
2. **Executive Summary** - High-level overview and key decisions
3. **System Architecture** - Components, integrations, data flow
4. **Design Decisions** - Architectural choices and rationale
5. **Data Model** - Object definitions and relationships
6. **Security & Compliance** - Auth, privacy, compliance
7. **Implementation Plan** - Phases, dependencies, timeline
8. **Risks & Mitigation** - Technical risks and strategies

## Creating Architecture Diagrams

### Using Mermaid

Mermaid is the recommended tool for creating diagrams:
- Create `.mmd` file with Mermaid syntax
- Generate PNG using mermaid-cli or online tools
- Commit both `.mmd` source and `.png` output
- Reference PNG in markdown docs

### Diagram Types

- Component Diagrams
- Data Flow Diagrams
- Sequence Diagrams
- Entity Relationship Diagrams
- Deployment Diagrams

## Naming Conventions

### Architecture Documents

Format: `[TICKET_ID]-[ARCHITECTURE_NAME].md`

Examples:
- `86d0abc12-salesforce-integration.md`
- `86d0def34-data-model-design.md`

### Diagrams

Format: `[ARCHITECTURE_NAME]-[DIAGRAM_TYPE].png` and `.mmd`

Examples:
- `salesforce-integration-components.png`
- `data-model-erd.png`

## Design Workflow

1. **Initial Design**: Create document from template
2. **Design Review**: Share and gather feedback
3. **Design Approval**: Get stakeholder sign-off
4. **Implementation Tracking**: Link to tickets
5. **Maintenance**: Keep updated with implementation

## Best Practices

### Documentation

- Be comprehensive - cover all major decisions
- Use diagrams - visualize complex concepts
- Explain rationale - document why decisions were made
- Consider alternatives - show what was rejected
- Keep updated - reflect actual implementation

### Collaboration

- Review early - get feedback before deep investment
- Involve stakeholders - include all relevant parties
- Document decisions - record design meeting outcomes
- Share knowledge - use designs for team education

## Design Review Checklist

Before approving:
- ✅ All required sections completed
- ✅ Diagrams included and clear
- ✅ Key decisions documented with rationale
- ✅ Security and compliance addressed
- ✅ Risks identified with mitigation plans
- ✅ Stakeholders reviewed and approved

## References

- **ClickUp Project**: [CLICKUP_PROJECT_URL]
- **Requirements**: `requirements/` directory
- **Example Template**: `architecture/ARCHITECTURE-TEMPLATE.md`
