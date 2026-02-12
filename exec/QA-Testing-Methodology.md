# QA Testing Methodology & Process

**Project:** SIMU SOW 1
**Created:** 2025-10-28
**Last Updated:** 2025-10-28
**Version:** 1.3
**Purpose:** Standard QA testing process for all tickets in QA status
**Persona Reference:** @docs/personas/QA_TESTER.md
**Supporting Documents:**
- TODO Conditioner: @exec/TODOS_CONDITIONER_QA.md
- Confidence Scoring: @docs/CONFIDENCE_SCORING_GUIDE_QA.md
- Screenshot Guide: @exec/Screenshot-Renaming-Guide.md
- Commit Guide: @exec/COMMIT.md

---

## 🎯 QA Testing Goals

1. **Comprehensive Coverage** - Test all acceptance criteria thoroughly
2. **Edge Case Discovery** - Push features to their limits to find breaking points
3. **Documentation** - Create clear, reproducible test cases with organized evidence
4. **Bug Tracking** - Document issues with detailed reproduction steps
5. **Regression Prevention** - Ensure fixes don't break existing functionality
6. **Stakeholder Visibility** - Regular progress updates using @docs/personas/COMMUNICATOR.md

---

## 📋 QA Workflow Process

### Phase 1: Test Preparation

**Goal:** Load ticket context, prioritize test cases, create organized documentation structure

```
1. [📋] [@docs/personas/QA_TESTER.md] Load ticket details from ClickUp using ticket ID
   - Review user story, acceptance criteria, technical specifications
   - Understand business value and user impact
   - Identify all testable scenarios

2. [🎯] [@docs/personas/QA_TESTER.md] Map acceptance criteria to priority levels
   - CRITICAL (P1): Data persistence, required validation, core flows
   - HIGH (P2): Edge cases, error handling, integrations
   - MEDIUM (P3): Special characters, UI/UX polish
   - LOW (P4): Advanced edge cases, nice-to-haves
   - Document priority mapping in test plan

3. [📁] [@docs/personas/QA_TESTER.md] Create test documentation subfolder
   - Location: `qa/{ticket-id}-{short-description}/`
   - Example: `qa/86d0ffk2d-persona-selection/`
   - Benefits: All evidence for ticket in one place, easy navigation

4. [📝] [@docs/personas/QA_TESTER.md] Create main test documentation file
   - Location: `qa/{ticket-id}-{description}/QA-{ticket-id}-{description}.md`
   - Example: `qa/86d0ffk2d-persona-selection/QA-86d0ffk2d-persona-selection.md`
   - Use template from "Test Documentation Template" section below

5. [💬] [@docs/personas/COMMUNICATOR.md] Post start comment to ClickUp ticket
   - Template: "🧪 QA testing started - [focus areas]"
   - Keep brief and factual (see @docs/personas/COMMUNICATOR.md)
   - Notify stakeholders of testing approach

6. [⏱️] [@docs/personas/QA_TESTER.md] Start time tracking
   - Can span multiple sessions across days
   - Use meaningful description: "QA testing for [feature]"
   - Continue tracking in subsequent sessions, stop when complete
```

---

### Phase 2: Test Execution

**Goal:** Execute tests systematically with priority-based approach, capture comprehensive evidence

```
7. [📸] [@docs/personas/QA_TESTER.md] RENAME SCREENSHOTS FIRST (before documenting)
   - Use glob patterns for special characters (see @exec/Screenshot-Renaming-Guide.md)
   - Naming: `TC{number}-{test-area}-{description}.{ext}`
   - Example: `TC1-persona-dropdown-display.png`
   - Store in same subfolder: `qa/{ticket-id}-{description}/`
   - Benefits: Clean organization, easy reference in documentation

8. [🧪] [@docs/personas/QA_TESTER.md] Execute CRITICAL tests first (P1 priority)
   - Test all P1 scenarios before moving to P2/P3
   - Focus on data persistence, core functionality, required validation
   - This ensures critical features validated early
   - DO NOT skip to lower priority tests

9. [📸] [@docs/personas/QA_TESTER.md] Capture test evidence systematically
   - Screenshots: Every test case gets visual evidence
   - Videos: UI/UX behavior, complex workflows, bug reproduction (.mov format)
   - SF CLI queries: Verify data persistence (see examples below)
   - Store all evidence in ticket subfolder

10. [🔍] [@docs/personas/QA_TESTER.md] Verify data persistence with SF CLI
    - ALWAYS verify using `sf data query --target-org sim-dev`
    - Example MessagingSession query:
      ```bash
      sf data query \
        --query "SELECT Id, FirstName__c, User__c, CreatedDate FROM MessagingSession WHERE FirstName__c = 'TestApplicant' ORDER BY CreatedDate DESC LIMIT 1" \
        --target-org sim-dev \
        --json
      ```
    - Document query results in test case
    - Compare actual vs expected data

11. [📝] [@docs/personas/QA_TESTER.md] Document test results in real-time
    - Update test doc as each test completes
    - Record: Test steps, expected result, actual result, pass/fail
    - Reference screenshots: `TC1-persona-dropdown-display.png`
    - Include SF CLI verification results

12. [💬] [@docs/personas/COMMUNICATOR.md] Post progress update every 2-3 test cases
    - Template: "🧪 QA Progress: TC1-TC3 completed (50%) - 3/3 PASSED, 0 bugs"
    - Keep ultra-brief, factual only
    - Include pass/fail counts and bug count
    - See @docs/personas/COMMUNICATOR.md for format

13. [💾] [@docs/personas/QA_TESTER.md] Commit progress after major test sections
    - Follow @exec/COMMIT.md instructions
    - Message format: `[ticket-id] QA: {what was tested}`
    - Example: `[86d0ffk2d] QA: Persona routing tests complete`
    - Include test documentation and screenshots
```

---

### Phase 3: Bug and Investigation Management

**Goal:** Distinguish between bugs vs investigations, create appropriate tickets with evidence

```
14. [🔍] [@docs/personas/QA_TESTER.md] Identify issue type when problem discovered
    - BUG: Feature not working as specified in acceptance criteria
    - INVESTIGATION: Anomaly that needs analysis (unclear root cause)
    - Example BUG: Email validation not working → Bug ticket
    - Example INVESTIGATION: Unexpected null values in DB → Investigation ticket

15. [📸] [@docs/personas/QA_TESTER.md] Capture comprehensive bug evidence
    - Screenshots showing the issue
    - SF CLI queries showing incorrect data
    - Video reproduction if UI/UX related
    - Store evidence in ticket subfolder

16. [🐛] [@docs/personas/QA_TESTER.md] Create BUG ticket for acceptance criteria violations
    - Use bug ticket template (see "Bug Ticket Template" section)
    - Include: Title, severity, reproduction steps, expected vs actual, screenshots
    - Link to parent user story
    - Assess production impact

17. [🔬] [@docs/personas/QA_TESTER.md] Create INVESTIGATION ticket for anomalies
    - Title: "🔬 INVESTIGATION: [brief description]"
    - Describe what was observed vs what was expected
    - Include evidence (screenshots, queries)
    - Link to parent ticket
    - Example: "🔬 INVESTIGATION: Null User__c in MessagingSession records"

18. [🚨] [@docs/personas/QA_TESTER.md] Assess bug severity for status decision
    - CRITICAL bugs: Security, data loss, feature non-functional → PAUSE QA
    - HIGH bugs: Errors but functional, validation issues → CONTINUE with notes
    - MEDIUM bugs: UI/UX issues, edge cases with workarounds → PASS with notes
    - Decision impacts final ticket status (see Phase 4)

19. [💾] [@docs/personas/QA_TESTER.md] Commit bug/investigation documentation
    - Follow @exec/COMMIT.md instructions
    - Message: `[ticket-id] QA: Document [bug-id] - [brief description]`
    - Include all evidence files
```

---

### Phase 4: Test Completion

**Goal:** Finalize documentation, make pass/fail decision, update ticket status appropriately

```
20. [📊] [@docs/personas/QA_TESTER.md] Update test summary statistics
    - Total test cases executed
    - Pass/fail counts by priority
    - Bugs found (count and links)
    - Enhanced implementations discovered (beyond requirements)
    - Overall pass rate

21. [✅] [@docs/personas/QA_TESTER.md] Make final pass/fail decision
    - ALL P1 tests passed + NO CRITICAL bugs = PASS
    - ANY P1 test failed OR CRITICAL bugs = FAIL
    - PASS with HIGH bugs = CONDITIONAL PASS (document in notes)
    - Use decision template (see "Pass/Fail Decision Template" section)

22. [🧪] [@docs/personas/QA_TESTER.md] Calculate QA confidence score
    - Use @docs/CONFIDENCE_SCORING_GUIDE_QA.md
    - Score based on documentation completeness and reproducibility
    - NOT based on whether tests passed (user approves that)
    - Include confidence score and justification in final summary

23. [💬] [@docs/personas/COMMUNICATOR.md] Post comprehensive final summary to ClickUp
    - Template: "✅ QA COMPLETE - [X/Y tests PASSED] - [Z bugs] - [Status]"
    - Include test statistics, bug links, confidence score, recommendation
    - See @docs/personas/COMMUNICATOR.md for format
    - Keep factual and brief

24. [🎫] [@docs/personas/QA_TESTER.md] Update ticket status based on results
    - IF ALL P1 passed + NO CRITICAL bugs → Status: "Ready for UAT"
    - IF CRITICAL bugs found → Status: "In QA" (leave for dev to fix)
    - IF BLOCKED → Status: "Blocked" (document blocker)
    - Always explain status decision in final comment

25. [⏱️] [@docs/personas/QA_TESTER.md] Stop time tracking with summary
    - Add final time entry summary
    - Note total time spent across all sessions
    - Can resume in future sessions if needed

26. [💾] [@docs/personas/QA_TESTER.md] Final git commit
    - Follow @exec/COMMIT.md instructions
    - Message: `[ticket-id] QA Complete: [Pass/Fail] - [test count]`
    - Example: `[86d0ffk2d] QA Complete: PASSED - 6/6 tests`
    - Push all test documentation and evidence
```

---

## 🧪 Test Data Templates

**Purpose:** Consistent, reproducible test data makes debugging and reproduction easier.

### Standard Test Data Patterns

**Personal Information:**
- **First Name:** TestApplicant (or Test + Role, e.g., TestEmployee, TestVisitor)
- **Last Name:** QATest (or QA + Descriptor, e.g., QAValidation, QAEdgeCase)
- **Email:** testapplicant.qa@example.com (pattern: firstname.lastname@example.com)
- **Phone:** +6591234567 (valid format with country code)
- **Country:** Singapore (or appropriate for context)

**Variations for Edge Cases:**
- **Special Characters:** "Test'Applicant", "Test-Applicant"
- **Very Long Name:** "TestApplicantWithVeryLongFirstNameThatExceedsNormalLength"
- **Minimum Length:** "A", "B"
- **Unicode:** "Test日本語", "TestÜmlaut"

**Invalid Data (for negative testing):**
- **Invalid Email:** "notanemail", "test@", "@example.com"
- **Invalid Phone:** "123", "+999999999999999"
- **Missing Required:** Leave blank or null

### Naming Conventions by Test Case Type

| Test Case Type | First Name | Last Name | Email |
|---------------|-----------|-----------|-------|
| Happy Path | TestApplicant | QATest | testapplicant.qa@example.com |
| Email Validation | TestEmail | QAValidation | testemail.qavalidation@example.com |
| Edge Case | TestEdge | QACase | testedge.qa@example.com |
| Special Chars | Test'Special | QA-Chars | testspecial.qa@example.com |
| Data Persistence | TestData | QAPersist | testdata.qapersist@example.com |

**Benefit:** When viewing screenshots or Salesforce records, you can immediately identify which test case created the data.

---

## 🧪 Testing Categories

### 1. Functional Testing
- Does the feature work as described in acceptance criteria?
- All happy path scenarios work correctly?
- Feature integrates properly with existing functionality?

### 2. Validation Testing
- Required field validation
- Data type validation (email, phone, etc.)
- Format validation
- Range/limit validation

### 3. Data Integrity Testing
- Data persists correctly to Salesforce
- No data loss or corruption
- Correct field mappings
- Proper data types stored

### 4. Negative Testing
- What happens with invalid inputs?
- What happens when required fields missing?
- What happens with edge case values?
- What happens with special characters, very long strings, etc.?

### 5. Integration Testing
- Does it work with dependent features?
- Are references to other tickets/features working?
- Cross-feature functionality maintained?

### 6. UI/UX Testing
- Matches design specifications
- Responsive on different screen sizes
- Accessible (keyboard navigation, screen readers)
- Error messages clear and helpful

### 7. Performance Testing (when applicable)
- Load times acceptable
- No performance degradation
- Handles expected user volume

---

## 📝 Test Documentation Template

Each ticket's QA document should include:

### Header Section
```markdown
# QA Test Documentation: [Ticket ID] - [Feature Name]

**Ticket:** [ClickUp URL]
**QA Tester:** [Name]
**QA Start Date:** [Date]
**QA End Date:** [Date]
**Status:** [PASSED / FAILED / CONDITIONAL PASS / BLOCKED]

## 📊 Test Summary
**Total Test Cases:** [Number]
**Passed:** [Number]
**Failed:** [Number]
**Pass Rate:** [Percentage]

**Critical Tests (P1):** [X/Y completed]
**High Tests (P2):** [X/Y completed]
**Medium Tests (P3):** [X/Y completed]
```

### Acceptance Criteria Priority Mapping

**CRITICAL:** Map each acceptance criterion to a priority level before starting testing.

**Example Mapping:**
```markdown
## 🎯 Acceptance Criteria Priority Mapping

### ⚠️ CRITICAL (Priority 1) - MUST PASS
1. Data persists to MessagingSession object → TC3
2. NO Lead created for applicant persona → TC3
3. Form captures all required fields → TC1
4. Required field validation works → TC4

### 🔴 HIGH (Priority 2) - SHOULD PASS
5. Email field validates format → TC2
6. Phone supports international formats → TC5

### 🟡 MEDIUM (Priority 3) - NICE TO PASS
7. Country dropdown includes all countries → TC6
8. Special character handling → TC7

### 🟢 LOW (Priority 4) - OPTIONAL
9. Very long input handling → TC8
```

### Test Cases Section

**For each test case:**
```markdown
### TC1: [Test Case Title]

**Priority:** CRITICAL / HIGH / MEDIUM / LOW
**Status:** ✅ PASSED / ❌ FAILED / ⏸️ BLOCKED

**Test Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result:**
[What should happen]

**Actual Result:**
[What actually happened]

**Data Verification (SF CLI):**
```bash
sf data query --query "..." --target-org sim-dev
```

**Result:** [Query output or summary]

**Screenshots:**
- `TC1-screenshot-description.png`
- `TC1-video-recording.mov` (if applicable)

**Pass/Fail:** ✅ PASSED
**Notes:** [Any observations or enhanced implementations discovered]
```

### Bugs Section
```markdown
## 🐛 Bugs Discovered

### Bug #1: [Bug Title]
- **Ticket:** [ClickUp link to bug ticket]
- **Severity:** CRITICAL / HIGH / MEDIUM / LOW
- **Status:** [Current status]
- **Description:** [Brief description]

### Investigation #1: [Investigation Title]
- **Ticket:** [ClickUp link to investigation ticket]
- **Description:** [What anomaly was found]
- **Status:** [Current status]
```

### Summary Statistics
```markdown
## 📊 Final Test Results

**Total Tests:** 6
**Pass Rate:** 100% (6/6)
- Critical (P1): 4/4 ✅
- High (P2): 2/2 ✅
- Medium (P3): 0/0 N/A

**Bugs Found:** 0
**Investigations Created:** 1 (link)
**Enhanced Implementations:** 2 documented

**Final Status:** ✅ READY FOR UAT
**Recommendation:** Deploy after UAT approval
**Confidence:** High - all critical functionality verified with evidence
```

---

## 🐛 Bug Ticket Template

**When to use:** Acceptance criteria violated, feature not working as specified

**Title Format:** `🐛 BUG: {Component} - {Brief Description}`
**Example:** `🐛 BUG: Applicant Form - Email validation not working`

**Required Fields:**
- **Severity:** Critical / High / Medium / Low
- **Priority:** Urgent / High / Normal / Low
- **Component:** Which feature/area affected
- **Parent Ticket:** Link to original user story
- **Assignee:** Developer responsible

**Description Template:**
```markdown
## Bug Description
[Clear description of the issue]

## Steps to Reproduce
1. [Exact step 1]
2. [Exact step 2]
3. [Exact step 3]

## Expected Result
[What should happen per acceptance criteria]

## Actual Result
[What actually happens]

## Evidence
- Screenshot: `BUG-{ticket-id}-{description}.png`
- SF CLI Query showing issue:
  ```bash
  sf data query --query "..." --target-org sim-dev
  ```
- Video: `BUG-{ticket-id}-reproduction.mov` (if applicable)

## Environment
- Org: sim-dev
- Browser: Chrome / Firefox / Safari
- User Role: [if relevant]

## Impact
**Production Risk:** [High/Medium/Low]
**User Impact:** [Description of how this affects users]
**Blocker:** [Yes/No - does this block UAT or production deployment?]

## Related Tickets
- Parent Story: [Link]
- Related Bugs: [Links if applicable]
```

---

## 🔬 Investigation Ticket Template

**When to use:** Anomaly discovered but unclear if bug or expected behavior, needs analysis

**Title Format:** `🔬 INVESTIGATION: {Brief Description}`
**Example:** `🔬 INVESTIGATION: Null User__c in MessagingSession records`

**Description Template:**
```markdown
## Observation
[What was observed that seems unexpected]

## Context
[When/where this was discovered during QA]

## Evidence
- Screenshot: `INV-{ticket-id}-{description}.png`
- SF CLI Query:
  ```bash
  sf data query --query "..." --target-org sim-dev
  ```
- Results: [Query output showing anomaly]

## Expected Behavior (Best Guess)
[What QA tester expected based on understanding of feature]

## Questions to Investigate
1. Is this expected behavior?
2. What is the root cause?
3. Does this need fixing or is it by design?

## Related Tickets
- Parent Story: [Link to ticket where discovered]
- Related Features: [Links to related functionality]
```

---

## 📂 Directory Structure

```
SIM/
├── exec/
│   ├── COMMIT.md                           ← Follow these commit instructions!
│   ├── QA-Testing-Methodology.md           ← This document
│   └── Screenshot-Renaming-Guide.md        ← Screenshot renaming workflows
├── docs/
│   └── personas/
│       ├── QA_TESTER.md                    ← QA persona reference
│       └── COMMUNICATOR.md                 ← Progress update patterns
└── qa/
    ├── {ticket-id}-{short-description}/    ← Subfolder per ticket
    │   ├── QA-{ticket-id}-{description}.md ← Main test documentation
    │   ├── TC1-{description}.png           ← Test case 1 screenshot
    │   ├── TC2-{description}.png           ← Test case 2 screenshot
    │   ├── TC3-{description}.mov           ← Test case 3 video
    │   ├── BUG-{id}-{description}.png      ← Bug evidence (if any)
    │   └── ...                             ← All test evidence
    │
    └── 86d0ffk2d-persona-selection/        ← Example structure
        ├── QA-86d0ffk2d-persona-selection.md
        ├── TC1-persona-dropdown-display.png
        ├── TC2-persona-prospect-form.png
        ├── TC2-persona-applicant-form.png
        ├── TC2-persona-student-form.png
        ├── TC4-required-field-no-button.png
        └── TC6-ui-ux-behavior.mov
```

**Benefits of Subfolder Structure:**
- All evidence for a ticket in one organized location
- Easy to find and reference screenshots/videos
- Clean git history (one folder per ticket)
- Simple to share entire test package with stakeholders
- Future QA can easily locate and review previous tests

---

## 📸 Screenshot and Video Evidence Standards

### Screenshot Naming Convention

**Format:** `TC{number}-{test-area}-{description}.{ext}`

**Examples:**
- `TC1-persona-dropdown-display.png`
- `TC2-persona-prospect-form.png`
- `TC4-required-field-validation.png`
- `BUG-86d0re9qc-phone-validation-error.png`

**IMPORTANT:** Rename screenshots BEFORE documenting test results
- Use bash glob patterns for files with special characters
- See @exec/Screenshot-Renaming-Guide.md for detailed instructions
- Example command:
  ```bash
  for old in Screenshot*9.50.51*.png; do
    mv "$old" TC2-persona-prospect-form.png
  done
  ```

### Video Evidence Guidelines

**When to record video:**
- UI/UX behavior tests (animations, transitions, interactions)
- Complex user workflows spanning multiple steps
- Bug reproduction showing exact sequence
- Accessibility testing (keyboard navigation, screen reader)

**Format:** `.mov` (recommended for compatibility)

**Naming:** Same as screenshots - `TC{number}-{description}.mov`

**Duration:** 30-60 seconds focused on specific test scenario

**Example:** `TC6-ui-ux-behavior.mov` showing dropdown interaction, form updates, visual feedback

---

## ✅ Success Criteria for QA

### QA PASSED → Status: "Ready for UAT"
- ✅ All P1 (critical) acceptance criteria tested and passing
- ✅ No critical or high severity bugs
- ✅ Edge cases tested (P2/P3)
- ✅ Data integrity verified with SF CLI
- ✅ Documentation complete with evidence
- ✅ No regressions introduced

### QA FAILED → Status: "In QA" (return to dev)
- ❌ Any P1 (critical) acceptance criteria not met
- ❌ Critical severity bugs found
- ❌ Data integrity issues discovered
- ❌ Regressions in existing functionality

### CONDITIONAL PASS → Status: "Ready for UAT" (with notes)
- ⚠️ All P1 tests passed
- ⚠️ Only medium/low severity bugs found
- ⚠️ Minor UI/UX issues that don't block usage
- ⚠️ Issues documented for future enhancement
- ⚠️ Business stakeholder accepts known limitations

### BLOCKED → Status: "Blocked"
- 🚫 Cannot test due to environment issues
- 🚫 Dependent feature not working
- 🚫 Missing test data or access
- 🚫 Document blocker clearly in ticket

---

## 💡 Best Practices

### For QA Tester (Following @docs/personas/QA_TESTER.md)

1. **Test Critical First** - Always execute all P1 tests before P2/P3
2. **Rename Screenshots Early** - Before documenting, not after
3. **Verify Everything** - SF CLI queries for all data persistence tests
4. **Organize Evidence** - Use subfolder structure, keep evidence together
5. **Document in Real-Time** - Don't rely on memory, update doc as you test
6. **Use Standard Test Data** - Consistent naming for reproducibility
7. **Capture Videos for UX** - Complex behaviors need video evidence
8. **Distinguish Bugs vs Investigations** - Different ticket types for different issues
9. **Update Stakeholders Regularly** - Progress comments every 2-3 tests
10. **Make Evidence-Based Decisions** - Pass/fail based on criteria, not intuition

### For Communication (Following @docs/personas/COMMUNICATOR.md)

1. **Ultra-Brief Updates** - One line maximum per progress update
2. **Factual Only** - No hype, interpretation, or marketing language
3. **Include Metrics** - Pass/fail counts, bug counts, progress percentage
4. **Immediate Updates** - Post as work completes, don't batch
5. **Consistent Format** - Use templates for predictability

### Time Tracking Best Practices

1. **Multiple Sessions OK** - QA can span days, continue same time entry
2. **Meaningful Descriptions** - "QA testing for [feature name]"
3. **Track Accurately** - Start when testing begins, stop when complete
4. **Resume as Needed** - Can pause/resume across multiple sessions
5. **Final Summary** - Note total time in completion comment

---

## 🔄 Git Commit Strategy

### Commit Frequency
- After completing each major test section (e.g., all P1 tests)
- When discovering and documenting bugs/investigations
- After final test completion

### Commit Process
**IMPORTANT:** Always follow the commit instructions in @exec/COMMIT.md

### Commit Message Format
```
[clickup-ticket-id] QA: {What was tested/changed}

Examples:
[86d0ffk2b] QA: Initial test documentation and subfolder setup
[86d0ffk2b] QA: Critical tests (TC1-TC4) complete - all passed
[86d0ffk2b] QA: Bug documentation for email validation issue
[86d0ffk2b] QA Complete: PASSED - 6/6 tests, ready for UAT
```

---

## 📊 Pass/Fail Decision Template

Use this template when making final QA decision:

```markdown
## ✅ QA Decision: [PASSED / FAILED / CONDITIONAL PASS / BLOCKED]

### Test Results
**Critical Tests (P1):** [X/Y] PASSED
**High Tests (P2):** [X/Y] PASSED
**Medium Tests (P3):** [X/Y] PASSED

### Acceptance Criteria Met
- ✅ [Criterion 1] - Verified with [TC number]
- ✅ [Criterion 2] - Verified with [TC number]
- ✅ [Criterion 3] - Verified with [TC number]

### Bugs Found
- **Critical:** [Count] - [Links if any]
- **High:** [Count] - [Links if any]
- **Medium:** [Count] - [Links if any]

### Evidence Summary
- Screenshots: [Count] stored in `qa/{ticket-id}-{description}/`
- Videos: [Count] for UI/UX verification
- SF CLI Verifications: [Count] data persistence checks
- Enhanced Implementations: [Count] discovered beyond requirements

### QA Confidence Score: [0.0-1.0] ([Description])

**Confidence Justification** (See @docs/CONFIDENCE_SCORING_GUIDE_QA.md):
- Acceptance criteria mapping: [Complete/Partial/None]
- Test documentation: [Complete/Partial/Minimal]
- Evidence quality: [All tests with screenshots+CLI / Most / Some / Minimal]
- Organization: [Subfolder structure / Partial / Scattered]
- Reproducibility: [High/Medium/Low] - [Can others repeat these tests?]

**Example:**
- All 6 acceptance criteria mapped to test cases ✅ (0.3)
- Complete test documentation following methodology ✅ (0.3)
- All tests with screenshots, 5/6 with SF CLI ✅ (0.35)
- Evidence in organized subfolder ✅ (+0.1)
- Progress updates posted regularly ✅ (+0.1)
- **Total Confidence: 1.0 (Gold Standard)**

### Recommendation
**Status:** [Ready for UAT / Needs Dev Fixes / Blocked]
**Next Steps:** [What should happen next]
**Known Limitations:** [Any documented issues stakeholder should know]
```

---

## 📋 Changelog

### Version 1.3 - 2025-10-28
**Supporting Documents Integration:**
- Added Step 22: Calculate QA confidence score using @docs/CONFIDENCE_SCORING_GUIDE_QA.md
- Created @exec/TODOS_CONDITIONER_QA.md for systematic workflow breakdown
- Created @docs/CONFIDENCE_SCORING_GUIDE_QA.md for QA thoroughness assessment
- Updated QA_TESTER.md header with references to supporting documents
- Updated Pass/Fail Decision Template to include confidence score justification
- Added supporting documents list to header (TODO Conditioner, Confidence Scoring, guides)
- Renumbered workflow steps (now 26 total steps in Phase 4)

### Version 1.2 - 2025-10-28
**Major Restructure - TODO Conditioner Pattern:**
- Restructured entire workflow with persona tags and emoji indicators
- Added [@docs/personas/QA_TESTER.md] and [@docs/personas/COMMUNICATOR.md] persona attribution
- Changed from flat file to subfolder structure: `qa/{ticket-id}-{description}/`
- Added screenshot renaming as mandatory step BEFORE documentation
- Added video evidence support (.mov format) for UI/UX testing
- Added distinction between Bug tickets vs Investigation tickets
- Changed final status from "QA PASSED" to "Ready for UAT"
- Added critical bug handling: leave in "In QA" status, create bug ticket
- Added time tracking support for multiple sessions spanning days
- Added enhanced implementation documentation guidance
- Updated directory structure with subfolder examples
- Improved pass/fail decision template with evidence requirements
- Added comprehensive evidence standards section
- Made all workflow steps self-verifying with clear personas

### Version 1.1 - 2025-10-28
**Updates based on actual testing workflow:**
- Added priority-based testing approach (critical tests first)
- Added detailed interactive testing dialogue pattern
- Added Salesforce CLI verification section with example queries
- Added screenshot management guidelines
- Added specific progress comment frequency (every 2-3 tests)
- Added progress comment template
- Added test data templates section with standard naming patterns
- Added acceptance criteria priority mapping section
- Renumbered workflow steps for clarity

### Version 1.0 - 2025-10-28
**Initial creation:**
- Established QA testing methodology
- Created workflow phases
- Defined testing categories
- Created bug ticket template
- Defined success criteria

---

**Version:** 1.3
**Owner:** QA Team
**Personas:** @docs/personas/QA_TESTER.md, @docs/personas/COMMUNICATOR.md
**Supporting Documents:** @exec/TODOS_CONDITIONER_QA.md, @docs/CONFIDENCE_SCORING_GUIDE_QA.md, @exec/Screenshot-Renaming-Guide.md, @exec/COMMIT.md
