# SIMU Weekly Status Report Template & Generator

## 📧 Email Template Format

```
Subject: SIMU Project - Weekly Status Update [Week Ending: DATE]

Hi All,

Hope you're doing well. Below is the summary of this past week's progress, key decisions, and upcoming activities, along with current risks, blockers, and action items.

**TL;DR:**
[2-3 sentence executive summary highlighting the most critical updates, changes, or decisions from the week]

**Key Decisions**
• [Decision 1 with rationale and impact]
• [Decision 2 with rationale and impact]
• [Any schedule or scope changes]

**Progress Since Last Update**
• [Completed deliverable/milestone 1]
• [Completed deliverable/milestone 2]
• [Key achievements or resolved issues]

**This Week's Plan**
• [Priority 1 for the upcoming week]
• [Priority 2 for the upcoming week]
• [Key milestones or deadlines]

**Risks**
• [Risk 1: Description and potential impact]
• [Risk 2: Description and potential impact]
• [Mitigation strategies if applicable]

**Action Items**

Realfast:
• [Action item 1 with owner if specific]
• [Action item 2 with owner if specific]
• [Action item 3 with owner if specific]

SIMU:
• [Action item 1 with owner if specific]
• [Action item 2 with owner if specific]

Please let us know if priorities need adjusting or if additional detail is needed.

Thanks,
[Your Name]
```

## 🤖 AI Prompt Generator for Weekly Reports

### Master Prompt Template
Copy this prompt and fill in the bracketed sections with current week's data:

```
Generate a professional weekly status report email for the SIMU project using the following format and information:

PROJECT CONTEXT:
- Client: SIMU
- Project: Knowledge Articles & Website Q&A Implementation
- Current Phase: [INSERT CURRENT PHASE/MILESTONE]
- Report Week Ending: [INSERT DATE]

REPORT SECTIONS REQUIRED:
1. TL;DR (2-3 sentences max)
2. Key Decisions (with rationale and impact)
3. Progress Since Last Update (completed items)
4. This Week's Plan (upcoming priorities)
5. Risks (with potential impacts)
6. Action Items (separated by team: Realfast and SIMU)

THIS WEEK'S DATA:

Completed Items:
- [LIST COMPLETED TASKS/DELIVERABLES]
- [INCLUDE DEMOS, DEPLOYMENTS, FIXES]
- [MENTION ANY DOCUMENTATION UPDATES]

Key Decisions Made:
- [LIST ANY SCHEDULE CHANGES]
- [SCOPE ADJUSTMENTS]
- [RESOURCE ALLOCATIONS]
- [TECHNICAL DECISIONS]

Upcoming Week Priorities:
- [LIST TOP 3-5 PRIORITIES]
- [INCLUDE ANY CRITICAL DEADLINES]
- [MENTION REQUIRED SIGN-OFFS]

Current Risks/Blockers:
- [LIST ACTIVE RISKS]
- [PENDING DEPENDENCIES]
- [POTENTIAL DELAYS]

Action Items Needing Completion:
Realfast Team:
- [LIST REALFAST RESPONSIBILITIES]

SIMU Team:
- [LIST SIMU RESPONSIBILITIES]

TONE REQUIREMENTS:
- Professional but friendly
- Concise and scannable
- Focus on impact and outcomes
- Include specific dates where relevant
- Start with "Hi All," and end with "Thanks, [Name]"

FORMAT REQUIREMENTS:
- Use bullet points for lists
- Bold the section headers
- Keep TL;DR to 2-3 sentences maximum
- Group action items by team
- Include a closing line asking if priorities need adjusting

Generate the complete email now.
```

### Quick-Fill Template (Simplified Version)
For faster weekly generation, use this condensed version:

```
Generate a SIMU project weekly status email for week ending [DATE].

COMPLETED THIS WEEK:
• 
• 
• 

KEY DECISIONS:
• 
• 

NEXT WEEK PRIORITIES:
• 
• 
• 

RISKS:
• 
• 

REALFAST ACTION ITEMS:
• 
• 

SIMU ACTION ITEMS:
• 
• 

Use professional tone, include TL;DR summary, format with bullets and bold headers.
```

## ✅ Data Collection Checklist

Before generating your weekly report, gather:

### From ClickUp/Project Management:
- [ ] Completed tasks this week
- [ ] In-progress items status
- [ ] Upcoming milestones
- [ ] Blocked items

### From Team Communications:
- [ ] Key decisions made
- [ ] Schedule changes
- [ ] UAT feedback received
- [ ] Demo outcomes

### From Risk Register:
- [ ] New risks identified
- [ ] Existing risk status updates
- [ ] Mitigation strategies needed

### From Stakeholders:
- [ ] Pending approvals needed
- [ ] Feedback on deliverables
- [ ] Priority changes
- [ ] Resource constraints

## 📝 Example Report (Your Provided Template)

```
Subject: SIMU Project - Weekly Status Update [Week Ending: June 23, 2024]

Hi All,

Hope you're doing well. Below is the summary of this past week's progress, key decisions, and upcoming activities, along with current risks, blockers, and action items.

**TL;DR:**
The TASC team provided UAT feedback on June 22 and realfast team estimated to need 1 business day to fix the issues. Based on this, the go-live for Milestone 2 has been shifted from June 23 to June 25 to allow time for required fixes. A combined demo for Milestones 1 and 2 was also conducted for Richard. The team is now working on completing final bug fixes, preparing for deployment, and updating training documentation.

**Key Decisions**
• Go-live date for Milestone 2 was pushed to June 25 due to feedback received on June 22. The realfast team required additional time to address the issues raised during UAT. This was due to the competing priority of providing a demo to the TASC team.

**Progress Since Last Update**
• Conducted a Milestone 1 & 2 demo for Richard.
• Received and began working on UAT feedback for both Milestones.

**This Week's Plan**
• Complete implementation of UAT feedback.
• Obtain UAT sign-off for Milestones 1 and 2.
• Execute production deployment of both milestones on June 25.
• Update training document as per feedback.

**Risks**
• If additional UAT feedback is submitted and determined to require critical changes, the go-live date may be delayed further to accommodate fixes and retesting.

**Action Items**

Realfast:
• Complete bug fixes and implement requested changes from UAT.
• Proceed with production deployment on June 25.
• Finalize updates to training documentation based on feedback.

TASC:
• Provide feedback on Training documentation.
• Provide UAT sign-off for both Milestone 1 and 2.

Please let us know if priorities need adjusting or if additional detail is needed.

Thanks,
Saurav
```

## 💡 Tips for Effective Reports

1. **Be Specific**: Use dates, numbers, and specific deliverables rather than vague statements
2. **Focus on Impact**: Explain WHY decisions were made and their implications
3. **Action-Oriented**: Ensure action items have clear owners and due dates where possible
4. **Balance Detail**: Provide enough context without overwhelming readers
5. **Consistent Timing**: Send reports on the same day each week (recommend Fridays)
6. **Track Metrics**: Consider including key metrics like tasks completed, velocity, or burn-down rates

## 🚀 Automation Ideas

For future automation, consider:
- Integrating with ClickUp API to pull completed tasks automatically
- Setting up email templates in your email client
- Creating a weekly reminder to gather data
- Using project management webhooks to collect status updates
- Building a simple form to collect weekly inputs from team members
- Creating a script to pre-populate the prompt with ClickUp data