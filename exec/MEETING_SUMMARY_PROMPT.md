# Meeting Summary Generation Prompt

## Purpose
Generate concise, actionable meeting summaries from transcripts and notes that capture key discussions without over-committing to decisions in requirements gathering phases.

## Instructions

You are tasked with creating a professional meeting summary email. Follow these guidelines:

### Input Required:
1. Meeting transcript or detailed notes
2. Meeting worksheet/agenda (if available)
3. Attendee list and roles
4. Meeting date and context

### Output Format:

Create an email-formatted summary with the following structure:

```markdown
# Meeting Summary: [Meeting Title]

**To:** [List all attendees]
**From:** [Meeting organizer]
**Date:** [Meeting date]
**Subject:** Meeting Summary - [Brief descriptive title]

Dear Team,

[Brief thank you and introduction - 1-2 sentences]

## **Meeting Overview**
[2-3 sentences describing what was discussed at a high level]

## **Key Topics Discussed**
[Bullet points of main discussion areas - use language like "explored", "discussed", "considered" rather than "decided" or "agreed" for requirements gathering sessions]

## **[Relevant Section Based on Meeting Type]**
[For requirements gathering: "Requirements Explored"]
[For decision meetings: "Decisions Made"]
[For planning sessions: "Plans Discussed"]

## **Action Items**
[Clear, concise list with owner and timeline]
**By [Date]:**
- **[Owner]:** [Action]

## **Next Meeting** (if applicable)
**When:** [Date and time]
**Where:** [Location/Virtual]
**Focus:** [Main topic]

## **Questions?**
[Standard closing for follow-up]

Best regards,
[Sender name]
[Team/Organization]
```

### Tone Guidelines:

1. **For Requirements Gathering Sessions:**
   - Use tentative language: "discussed", "explored", "considered"
   - Avoid committal phrases: "agreed", "decided", "confirmed"
   - Focus on what was learned rather than what was promised

2. **Keep it Concise:**
   - Aim for 1-page equivalent (300-400 words)
   - Focus on actionable information
   - Remove technical details unless critical

3. **Be Clear on Action Items:**
   - Always include owner and deadline
   - Make actions specific and measurable
   - Group by timeline (immediate, this week, next phase)
   - AVOID technical/development tasks (e.g., "configure system", "create separate business hours", "investigate feasibility")
   - Focus on business actions (e.g., "provide holiday list", "prepare message templates", "review and approve")

4. **Avoid:**
   - Over-detailed technical specifications
   - Internal discussions or debates
   - Premature commitments or promises
   - Excessive formatting or sections
   - References to ClickUp, internal task management, or project tracking systems

### Example Phrases:

**Good (Requirements Gathering):**
- "The team explored several priority areas including..."
- "We discussed the potential for..."
- "Several important capabilities were considered..."

**Avoid (Too Committal):**
- "The team agreed to implement..."
- "We confirmed that..."
- "It was decided that..."

### Processing Steps:

1. **Read through entire transcript/notes**
2. **Identify main discussion topics** (not every detail)
3. **Extract clear action items with owners** (business actions only, not technical tasks)
4. **Capture important questions raised** that need follow-up
5. **Summarize in business-friendly language**
6. **Keep summary under 400 words**
7. **Focus on what matters for follow-up**

### Output Location:
Save the generated summary as: `/emails/meeting_summary_[topic]_[YYYYMMDD].md`

---

## Usage Example:

```bash
# Input files:
- Transcript: client_call_transcripts/[date]_[meeting_type].md
- Worksheet: requirements_worksheets/[project]_[topic].md

# Output:
- Summary: emails/meeting_summary_[topic]_[date].md
```