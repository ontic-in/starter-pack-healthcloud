Review the current Todos using TodoRead and think and break them down into **detailed, fine-grained, actionable todos that are self-verifying, correctly sequenced and persona-tagged; include reminders to reflect and learn-store after completing key tasks** following these principles:

**IMPORTANT**: Using @exec/TODOS_CONDITIONER_DOCS.md automatically enforces @exec/CONTENT_REVIEW_PROMPT.md for all documentation work. Every doc task MUST include a verification step using the review prompt to catch slop before it compounds.

## Core Principles for Documentation Work

1. **Investigate First**: Create discovery/analysis todos before planning implementation
2. **Outcome-Focused**: Each todo should deliver measurable value, not just activity; where relevant tag the todo with the appropriate persona to execute it
3. **Defer Details Until Investigation**: Don't create implementation todos until investigation is complete, instead create investigation todos
4. **Self-Verifying**: Each task should include verification using @exec/CONTENT_REVIEW_PROMPT.md to catch slop before it compounds
5. **Learning**: Include todos to capture and store few-shot examples using the `learn` tool - *be prescriptive about storing concrete examples of successful patterns that can be retrieved for similar future tasks*
6. **Logical Sequencing**: Each todo must depend on the completion of previous todos. Never place progress updates consecutively - they must follow the work they report on
7. **Include Links to Context**: Details of each type of task with relevant links to relevant context - files, urls, line numbers- into the Todos itself so that you are immune to compaction
8. **Pattern Alignment**: When storing new patterns, always search existing patterns first to align trigger phrases, creating cohesive sets of few-shot examples that can be retrieved together

## Todo Structure for Documentation

**MANDATORY PATTERN**: Every documentation todo MUST follow this sequence:

```
1. [🔍] Search first - grep/find for existing docs on this topic
2. [📚] **LEARN**: Retrieve similar documentation patterns from learn-store
3. [✍️] [@docs/personas/truth-teller.md] Draft content with specific, tested claims
4. [🧪] **REVIEW**: Think critically and review using @exec/CONTENT_REVIEW_PROMPT.md
   - Answer ALL review questions
   - Decide: Keep, Merge, or Kill
   - Use @learn/CONFIDENCE_SCORING_GUIDE.md to score confidence (0.7+ required to KEEP)
5. [🧪🧪] **REVIEW THE REVIEW**: Review the feedback from step 4 and think about it - what do you agree with, what do you disagree with? Incorporate the changes you agree with, and explain why you disagree with the changes you don't agree with. Update your confidence score if needed.
6. [✂️] [@docs/personas/truth-teller.md] Execute decision:
   - KILL: Delete draft, document why in PR/ticket
   - MERGE: Update existing doc, link PR
   - KEEP: Finalize with clear owner and purpose
7. [📚] **LEARN**: Store successful pattern with aligned trigger phrases
8. [💬] [@docs/personas/communicator.md] Post factual update with decision and rationale
```

**Non-negotiable**: Steps 1 (Search) and 4 (Verify) cannot be skipped. Default decision is KILL unless evidence proves otherwise.

## Persona Attribution Examples

**Investigation & Analysis:**
```
[🔍] Investigate redundancy in current process docs
```

**Content Creation:**
```
[✍️] [@docs/personas/truth-teller.md] Write guide section on prompt engineering
[✍️] [@docs/personas/value-architect.md] Document business value of new feature
```

**Review & Verification:**
```
[🧪] [@docs/personas/truth-teller.md] Review for unsupported claims
[🧪] [@docs/personas/value-architect.md] Verify business metrics are accurate
```

**Communication:**
```
[💬] [@docs/personas/communicator.md] Update ClickUp with completed work
[💬] [@docs/personas/communicator.md] Post PR ready notification to Slack
```

## Documentation-Specific Verification

Instead of running tests, verify documentation quality:
- **Redundancy**: Check against existing systems (ClickUp, git, Slack)
- **Maintenance**: Will this stay accurate without manual updates?
- **Evidence**: Are claims specific and proven, not theoretical?
- **Value**: Does this solve a real problem not already solved?

Example verification todo:
```
[🧪] VERIFY: Review HANDOFF.md with @exec/CONTENT_REVIEW_PROMPT.md
- Does ClickUp already provide this? (YES - ticket status)
- Does git already provide this? (YES - commit history)
- Conclusion: DELETE - redundant with existing systems
```

## Anti-Patterns to Avoid

- ❌ Overconfidence - always use ./learn/CONFIDENCE_SCORING_GUIDE.md to assess confidence levels
- ❌ Creating todos for todos ("Design todo structure") 
- ❌ Infrequent learning reflections - store patterns continuously
- ❌ Over-planning before understanding the problem
- ❌ Creating documentation that duplicates existing systems
- ❌ Adding process without evidence it helps
- ❌ Sequential progress updates without intervening work
- ❌ Writing "best practices" without proven examples

## The Documentation Workflow

1. **Question Need**: Could existing systems handle this?
2. **Draft Minimally**: Start with the smallest useful version
3. **Review Brutally**: Use CONTENT_REVIEW_PROMPT to cut slop
4. **Validate with Evidence**: Show specific examples where this helped
5. **Store Pattern**: Learn successful approaches for reuse

Remember: Every file you create is a maintenance burden. Only create what proves its value through use.