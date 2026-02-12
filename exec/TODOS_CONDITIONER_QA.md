# Todos Conditioner - QA Testing

**Purpose:** Structure todos for systematic QA testing with evidence-based verification

**Context:** Testing Salesforce features against acceptance criteria with comprehensive documentation

**Related:**
- Persona: `@docs/personas/QA_TESTER.md`
- Methodology: `@exec/QA-Testing-Methodology.md` ← **Workflow steps defined here**
- Confidence scoring: `@docs/CONFIDENCE_SCORING_GUIDE_QA.md`
- Screenshot guide: `@exec/Screenshot-Renaming-Guide.md`

---

## Core Principles for QA Todos

1. **Critical Tests First**: Always test P1 scenarios before P2/P3
2. **Evidence-Based**: Every test case must have screenshots/videos + SF CLI verification
3. **Reproducible**: Anyone should be able to repeat your tests from documentation
4. **Organize Evidence**: Subfolder per ticket with all evidence together
5. **Progressive Documentation**: Update docs in real-time, not after testing
6. **Stakeholder Visibility**: Progress comments every 2-3 test cases
7. **Self-Verifying**: Each phase includes verification of completeness

---

## QA Todo Structure Pattern

**Reference:** See `@exec/QA-Testing-Methodology.md` for detailed 26-step workflow.

**When creating QA todos, follow this pattern:**

### Phase 1: Test Preparation (6 steps in methodology)
```
[📋] [@docs/personas/QA_TESTER.md] Load ticket from ClickUp
[🎯] [@docs/personas/QA_TESTER.md] Map acceptance criteria to P1/P2/P3
[📁] [@docs/personas/QA_TESTER.md] Create test subfolder structure
[📝] [@docs/personas/QA_TESTER.md] Create test documentation file
[💬] [@docs/personas/COMMUNICATOR.md] Post start comment
[⏱️] [@docs/personas/QA_TESTER.md] Start time tracking
```

**Key Pattern:** Setup before execution. Organization first.

---

### Phase 2: Test Execution (13 steps in methodology)
```
[📸] [@docs/personas/QA_TESTER.md] RENAME screenshots BEFORE documenting
[🧪] [@docs/personas/QA_TESTER.md] Execute P1 tests first
[📸] [@docs/personas/QA_TESTER.md] Capture evidence (screenshots/videos)
[🔍] [@docs/personas/QA_TESTER.md] Verify data with SF CLI
[📝] [@docs/personas/QA_TESTER.md] Document results in real-time
[💬] [@docs/personas/COMMUNICATOR.md] Post progress every 2-3 tests
[💾] [@docs/personas/QA_TESTER.md] Commit after each major phase
```

**Key Pattern:** Evidence → Verification → Documentation → Communication. Repeat for each test.

**Critical Anti-Pattern:** ❌ Don't test P2/P3 before completing ALL P1 tests

---

### Phase 3: Bug Management (6 steps in methodology) - If Applicable
```
[🔍] [@docs/personas/QA_TESTER.md] Identify: Bug vs Investigation
[📸] [@docs/personas/QA_TESTER.md] Capture comprehensive bug evidence
[🐛] [@docs/personas/QA_TESTER.md] Create BUG ticket with template
[🔬] [@docs/personas/QA_TESTER.md] OR create INVESTIGATION ticket
[🚨] [@docs/personas/QA_TESTER.md] Assess severity for status decision
[💾] [@docs/personas/QA_TESTER.md] Commit bug documentation
```

**Key Pattern:** Distinguish bug (not working) from investigation (unclear). Evidence is critical.

**Critical Decision:** CRITICAL bugs → Pause QA, return to "In QA" status

---

### Phase 4: Test Completion (7 steps in methodology)
```
[📊] [@docs/personas/QA_TESTER.md] Update test summary statistics
[✅] [@docs/personas/QA_TESTER.md] Make final pass/fail decision
[🧪] [@docs/personas/QA_TESTER.md] Calculate confidence score
[💬] [@docs/personas/COMMUNICATOR.md] Post comprehensive final summary
[🎫] [@docs/personas/QA_TESTER.md] Update ticket status
[⏱️] [@docs/personas/QA_TESTER.md] Stop time tracking
[💾] [@docs/personas/QA_TESTER.md] Final git commit and push
```

**Key Pattern:** Statistics → Decision → Confidence → Communication → Status → Commit

---

## Persona Attribution Examples

### Test Preparation
```
[📋] [@docs/personas/QA_TESTER.md] Load ticket 86d0ffk2d from ClickUp
[🎯] [@docs/personas/QA_TESTER.md] Map 6 acceptance criteria to P1/P2/P3
[📁] [@docs/personas/QA_TESTER.md] Create qa/86d0ffk2d-persona-selection/
```

### Test Execution
```
[📸] [@docs/personas/QA_TESTER.md] Rename with glob: TC1-persona-dropdown.png
[🧪] [@docs/personas/QA_TESTER.md] Execute TC1: Persona Dropdown Display
[🔍] [@docs/personas/QA_TESTER.md] SF CLI: SELECT User__c FROM MessagingSession...
[📝] [@docs/personas/QA_TESTER.md] Document TC1 in QA-86d0ffk2d.md
```

### Progress Communication
```
[💬] [@docs/personas/COMMUNICATOR.md] "🧪 QA Progress: TC1-TC3 (50%) - 3/3 PASSED"
[💬] [@docs/personas/COMMUNICATOR.md] "✅ QA COMPLETE - 6/6 PASSED - 0 bugs"
```

### Bug Management
```
[🐛] [@docs/personas/QA_TESTER.md] Create "🐛 BUG: Email validation not working"
[🔬] [@docs/personas/QA_TESTER.md] Create "🔬 INVESTIGATION: Null User__c records"
```

---

## Verification Checklist Templates

**Use at end of each phase to ensure completeness:**

### Phase 1 Checklist
```
[🧪] VERIFY Phase 1:
- [ ] Ticket loaded and acceptance criteria understood
- [ ] Priority mapping (P1/P2/P3) documented
- [ ] Subfolder created: qa/{ticket-id}-{description}/
- [ ] Test doc created with template
- [ ] Start comment posted
- [ ] Time tracking started
```

### Phase 2 Checklist
```
[🧪] VERIFY Phase 2:
- [ ] All P1 tests executed before P2/P3
- [ ] Screenshots renamed (TC{number}- format)
- [ ] Every test has evidence (screenshots/videos)
- [ ] Data tests have SF CLI verification
- [ ] Results documented in real-time
- [ ] Progress comments posted every 2-3 tests
```

### Phase 4 Checklist
```
[🧪] VERIFY Phase 4:
- [ ] Test summary statistics complete
- [ ] Pass/fail decision documented
- [ ] Confidence score calculated (use CONFIDENCE_SCORING_GUIDE_QA.md)
- [ ] Final summary posted to ClickUp
- [ ] Ticket status updated appropriately
- [ ] Time tracking stopped
- [ ] All changes committed and pushed
```

---

## Anti-Patterns to Avoid

### ❌ Testing Anti-Patterns
- **Skipping critical tests**: Never test P2/P3 before completing ALL P1 tests
- **Testing without evidence**: Every test needs screenshot/video + SF CLI verification
- **Assuming data persisted**: Always verify with SF CLI queries, don't assume
- **Default screenshot names**: Rename BEFORE documenting (use Screenshot-Renaming-Guide.md)
- **Flat file structure**: Use subfolders per ticket for organization
- **Batched documentation**: Update test doc in real-time as each test completes

### ❌ Communication Anti-Patterns
- **Infrequent updates**: Post progress every 2-3 test cases, not at the end
- **Verbose comments**: Keep ultra-brief following @docs/personas/COMMUNICATOR.md
- **Missing metrics**: Always include pass/fail counts, bug counts, progress %

### ❌ Evidence Anti-Patterns
- **Missing screenshots**: Every test case needs visual evidence
- **No SF CLI verification**: Data persistence tests require query verification
- **Lost evidence**: Store all evidence in ticket subfolder, not scattered
- **No video for UX**: Complex UI/UX behavior needs video recording

### ❌ Workflow Anti-Patterns
- **No priority mapping**: Must map acceptance criteria to P1/P2/P3 before testing
- **Wrong bug type**: Distinguish between bugs (not working) vs investigations (unclear)
- **Wrong status**: Critical bugs = "In QA" not "Ready for UAT"
- **Uncommitted evidence**: Git commit after each major phase, not just at end

---

## Decision Framework for Todo Breakdown

**When a user assigns a QA ticket:**

1. **Read ticket** → Understand acceptance criteria and business value
2. **Apply this conditioner** → Break work into 26-step todos (see methodology)
3. **Adjust for context:**
   - Simple feature? May skip some P3 tests
   - Complex feature? May need more test cases per phase
   - Bugs found? Add Phase 3 todos dynamically
4. **Add verification steps** → Use checklist templates above
5. **Execute systematically** → Following @docs/personas/QA_TESTER.md

---

## Integration with QA Workflow

**How documents work together:**

```
User assigns QA ticket
    ↓
Apply TODOS_CONDITIONER_QA.md → Generate 26-step todo list
    ↓
Execute todos following @docs/personas/QA_TESTER.md
    ↓
Reference @exec/QA-Testing-Methodology.md for step details
    ↓
Use @exec/Screenshot-Renaming-Guide.md for evidence
    ↓
Calculate confidence using @docs/CONFIDENCE_SCORING_GUIDE_QA.md
    ↓
Update ClickUp following @docs/personas/COMMUNICATOR.md
```

**Separation of Concerns:**
- **This document (TODOS_CONDITIONER):** Patterns, principles, anti-patterns
- **QA-Testing-Methodology.md:** Detailed 26-step workflow, templates, examples
- **QA_TESTER.md:** Persona behavior, decision framework, responsibilities
- **CONFIDENCE_SCORING_GUIDE_QA.md:** Evidence-based confidence calculation

---

## Success Metrics

A well-conditioned QA todo list ensures:

1. ✅ **Systematic Coverage**: All acceptance criteria mapped and tested in priority order
2. ✅ **Comprehensive Evidence**: Every test case has reproducible evidence
3. ✅ **Clear Attribution**: Each todo has persona tag and emoji indicator
4. ✅ **Self-Verifying**: Verification checkpoints at each phase
5. ✅ **Stakeholder Visibility**: Regular progress updates throughout testing
6. ✅ **Organized Assets**: All evidence in subfolder, easy to find and share
7. ✅ **Confident Decisions**: Pass/fail backed by evidence and confidence score

---

## Quick Reference

**When to use this conditioner:**
- At the start of any QA ticket to structure the work
- When QA work feels overwhelming or unclear
- To ensure no steps are missed in systematic testing

**Key Pattern Reminders:**
- 📋 **Phase 1:** Setup (6 steps) - Preparation before execution
- 🧪 **Phase 2:** Execute (13 steps) - P1 first, evidence always, document real-time
- 🐛 **Phase 3:** Bugs (6 steps) - Only if issues found
- ✅ **Phase 4:** Complete (7 steps) - Statistics → Decision → Confidence → Status

**Critical Success Factor:** Follow the phases sequentially. Don't skip to Phase 4 without completing Phase 2.

---

**Version:** 2.0
**Created:** 2025-10-28
**Updated:** 2025-10-28
**Owner:** QA Team
**Pattern:** Matches SALESFORCE_TECH_LEAD TODO Conditioner structure
**Related:** @docs/personas/QA_TESTER.md, @exec/QA-Testing-Methodology.md, @docs/CONFIDENCE_SCORING_GUIDE_QA.md
