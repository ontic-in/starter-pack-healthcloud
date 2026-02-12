# Content Review Prompt

Use this prompt to catch hallucinated, redundant, or unnecessary content before it becomes technical debt.

Use @learn/CONFIDENCE_SCORING_GUIDE.md to assess confidence in your judgments.
Use @exec/TODOS_CONDITIONER_DOCS.md to plan any resulting work.

## The Review Questions

Ask these questions about any new documentation, process, or abstraction:

### 0. Search First
- Did you search for existing docs on this topic? (grep, find, ClickUp)
- What similar content exists?
- Could you update that instead of creating new?

### 1. Redundancy Check
- Does this duplicate something the system already provides?
- Is there an existing mechanism that serves this purpose?
- Example: HANDOFF.md duplicates what ClickUp + git history already provides

### 2. Synchronization Risk  
- Will this get out of sync with reality?
- Who specifically will maintain this? (Name them)
- What happens when people forget to update it?

### 3. Value Test
- What specific problem does this solve that isn't already solved?
- Can you point to a real incident where this would have helped? (Link the ticket)
- Is the cost (maintenance, confusion) worth the benefit?

### 4. Simplicity Check
- Is there a simpler way to achieve the same outcome?
- Could this be code, automation, or a comment instead of docs?
- Would removing this make things clearer?

### 5. Evidence Test
- Is every claim specific and verifiable?
- Are there concrete examples, not theoretical benefits?
- Can someone act on this information today?

### 6. Sensitivity Check (for Company-Wide Documents)
- Does this maintain professional respect for all individuals mentioned?
- Are quotes used constructively rather than embarrassingly?
- Does the tone focus on learning and improvement rather than blame?
- Is it honest and direct without being harsh or corpo-speak?

## Decision: Keep, Merge, or Kill

After reviewing, choose ONE:

### KILL (Default)
- Duplicates existing content
- No clear owner
- Theoretical benefits only
- Action: Delete, don't create

### MERGE
- Valuable content but wrong place
- Update existing doc instead
- Action: Update canonical source, link PR

### KEEP
- Clear gap filled
- Specific owner assigned
- Proven value with evidence
- Action: Create with clear purpose

## The Review Command

```
Review this content critically using @exec/CONTENT_REVIEW_PROMPT.md:
1. Search for existing docs first
2. Answer all review questions
3. Decide: Keep, Merge, or Kill
4. Be specific about what to cut
```

## Examples of Slop Caught

**HANDOFF.md**: Redundant with ClickUp ticket status + git history
- ClickUp already tracks "what's done" and "what's next"
- Git commits show exactly what changed
- This file would constantly be out of date

**Complex Todo Hierarchies**: Over-planning before understanding
- Creating todos for creating todos
- Pre-planning milestones before doing work
- Solution: Just start with investigation

**Vague Process Docs**: "Best practices" without evidence
- "Always do X for better Y"
- No specific examples of success/failure
- Solution: Document what actually worked, with proof

## The Anti-Slop Formula

Before adding any new documentation or process:
1. Try working without it for a week
2. If you genuinely miss it, document why
3. If not, you saved yourself maintenance burden

Trust = Proven Value - Maintenance Cost

Every unnecessary abstraction damages velocity. Every proven pattern accelerates it.