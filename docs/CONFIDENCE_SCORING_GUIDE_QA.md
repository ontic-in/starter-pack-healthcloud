# QA Testing Confidence Scoring Guide

## Overview
This guide provides confidence scoring (0.0-1.0) specifically for **QA testing thoroughness and completeness**. Confidence reflects the **quality and reproducibility of QA documentation**, not the test results themselves (user approves those).

**Core Principle**: Confidence = **Evidence Completeness + Documentation Quality + Reproducibility**, not subjective assessment of whether feature works.

**Key Distinction**:
- ❌ NOT: "How confident am I that the feature works?" (User decides this)
- ✅ YES: "How confident am I that this QA was thorough and can be reproduced?"

---

## Quick Scoring Decision Tree for QA Work

### For ANY QA Session:
START HERE → How complete is the QA documentation and evidence?

1. **Gold Standard QA (0.9-1.0)**
   - All acceptance criteria mapped to test cases with priorities
   - Every test case has screenshot/video evidence
   - All data persistence verified with SF CLI queries
   - Test documentation follows methodology template
   - Evidence organized in subfolder structure
   - Anyone could reproduce all tests from documentation

2. **Good QA with Minor Gaps (0.7-0.8)**
   - All critical (P1) tests documented with evidence
   - Most screenshots captured but some missing
   - Some SF CLI verifications but not all data tests
   - Documentation mostly complete
   - Evidence mostly organized

3. **Adequate QA with Gaps (0.5-0.6)**
   - Critical tests done but documentation incomplete
   - Some screenshots but inconsistent
   - Missing SF CLI verifications
   - Hard to reproduce without asking questions
   - Evidence scattered or poorly organized

4. **Incomplete QA (0.3-0.4)**
   - Tests performed but minimal documentation
   - Few or no screenshots
   - No SF CLI verifications
   - Cannot reproduce tests from documentation
   - "I tested it and it works" level

5. **Insufficient QA (0.1-0.2)**
   - Spot checking only
   - No systematic approach
   - No documentation
   - No evidence
   - "Looks good to me" level

---

## Evidence-Based Confidence Levels

### 0.9-1.0: Gold Standard QA

**Evidence Characteristics:**
- ✅ All acceptance criteria mapped to P1/P2/P3 priorities in test plan
- ✅ Test documentation follows @exec/QA-Testing-Methodology.md template
- ✅ Subfolder structure: `qa/{ticket-id}-{description}/` with all evidence
- ✅ Every test case has screenshot/video with proper naming (TC{number}-)
- ✅ All data persistence tests include SF CLI queries with documented results
- ✅ Progress comments posted every 2-3 test cases
- ✅ Bug/investigation tickets created with comprehensive evidence
- ✅ Final summary includes statistics, confidence score, recommendation
- ✅ Git commits follow convention with evidence committed

**Examples:**
- "QA session for ticket 86d0ffk2d: 6/6 tests documented with screenshots, 5 SF CLI verifications, subfolder with all evidence, progress updates every 2 tests, investigation ticket created for anomaly" (0.9)
- "Complete QA package: priority mapping doc, 10 test cases with TC-numbered screenshots, 7 SF CLI query verifications, video for UX behavior, organized subfolder, reproducible by anyone" (1.0)

**Reproducibility Test:**
- Could a different QA tester pick up this documentation and repeat every test exactly? **YES**

---

### 0.7-0.8: Good QA with Minor Gaps

**Evidence Characteristics:**
- ✅ Critical (P1) acceptance criteria all tested and documented
- ✅ Most test cases have screenshot evidence
- ⚠️ Some screenshots missing or poorly named
- ⚠️ Some SF CLI verifications but not comprehensive
- ✅ Test documentation exists and mostly follows template
- ⚠️ Evidence somewhat organized but not perfect subfolder structure
- ✅ Final summary posted with pass/fail decision

**Examples:**
- "QA session: 5/5 P1 tests documented with screenshots, 3/5 have SF CLI verification, evidence in subfolder but some default screenshot names" (0.8)
- "All critical tests done and documented, screenshots captured, missing SF CLI for 2 data persistence tests, final summary posted" (0.7)

**Reproducibility Test:**
- Could a different QA tester pick up this documentation and repeat most tests? **MOSTLY** (might need to ask a few questions)

---

### 0.5-0.6: Adequate QA with Significant Gaps

**Evidence Characteristics:**
- ✅ Critical tests performed
- ⚠️ Documentation incomplete or inconsistent
- ⚠️ Screenshots missing for several test cases
- ❌ No or minimal SF CLI verifications
- ⚠️ Evidence scattered (not in organized subfolder)
- ⚠️ Test steps vague or missing
- ⚠️ Final summary minimal or missing statistics

**Examples:**
- "QA session: Tested persona selection, got screenshots for 3/6 tests, no SF CLI queries, documentation lists test cases but missing detailed steps" (0.5)
- "Critical functionality tested with some screenshots, but hard to tell exactly what was tested, no data verification, scattered evidence" (0.6)

**Reproducibility Test:**
- Could a different QA tester pick up this documentation and repeat the tests? **DIFFICULT** (would need significant clarification)

---

### 0.3-0.4: Incomplete QA

**Evidence Characteristics:**
- ⚠️ Tests performed but minimally documented
- ❌ Few screenshots, most missing
- ❌ No SF CLI verifications at all
- ❌ No systematic test plan or priority mapping
- ❌ Evidence not organized or mostly missing
- ❌ Final summary is "tested and it works" level

**Examples:**
- "QA session: Tested the feature, got 1 screenshot, documented as 'all tests passed', no details on what was actually tested" (0.3)
- "Spot checked persona selection, works fine, no formal documentation or evidence" (0.4)

**Reproducibility Test:**
- Could a different QA tester pick up this documentation and repeat the tests? **NO** (insufficient information)

---

### 0.1-0.2: Insufficient QA

**Evidence Characteristics:**
- ❌ No systematic testing approach
- ❌ No documentation of test cases
- ❌ No evidence (screenshots/videos/queries)
- ❌ "Looks good" or "I tested it" without details
- ❌ Cannot verify what was actually tested

**Examples:**
- "Tested it, works fine" (0.1)
- "Clicked around, seems good" (0.2)

**Reproducibility Test:**
- Could a different QA tester pick up this documentation and repeat the tests? **IMPOSSIBLE** (no documentation exists)

---

## Confidence Calculation Framework

### Single QA Session Scoring

Use this formula to calculate confidence for a QA session:

```
Base Score Components:
1. Acceptance Criteria Coverage (0-0.3)
   - All mapped to test cases: 0.3
   - Partial mapping: 0.2
   - No mapping: 0.0

2. Test Documentation (0-0.3)
   - Complete with template: 0.3
   - Partial documentation: 0.2
   - Minimal/none: 0.0

3. Evidence Quality (0-0.4)
   - All tests have screenshots + SF CLI: 0.4
   - Most have screenshots, some CLI: 0.3
   - Some screenshots, no CLI: 0.2
   - Minimal evidence: 0.1
   - No evidence: 0.0

Total Confidence = Component 1 + Component 2 + Component 3
```

**Examples:**

**Example 1: Gold Standard**
- Acceptance criteria: All mapped to P1/P2/P3 (0.3)
- Documentation: Complete QA doc with template (0.3)
- Evidence: All tests with screenshots + CLI (0.4)
- **Total: 1.0**

**Example 2: Good with Gaps**
- Acceptance criteria: Partial mapping (0.2)
- Documentation: Mostly complete (0.2)
- Evidence: Most screenshots, some CLI (0.3)
- **Total: 0.7**

**Example 3: Adequate**
- Acceptance criteria: Some mapping (0.1)
- Documentation: Partial (0.2)
- Evidence: Some screenshots, no CLI (0.2)
- **Total: 0.5**

---

## Confidence Boosters (Add +0.1 each)

These factors can boost confidence by +0.1 each (max +0.3 total):

1. **+0.1 Subfolder Organization**
   - All evidence in `qa/{ticket-id}-{description}/` subfolder
   - Screenshots properly renamed (TC{number}-)
   - Clean, navigable structure

2. **+0.1 Progress Communication**
   - Regular progress comments posted (every 2-3 tests)
   - Following @docs/personas/COMMUNICATOR.md format
   - Stakeholders kept informed throughout

3. **+0.1 Bug/Investigation Management**
   - Bugs documented with comprehensive evidence
   - Proper distinction between bug vs investigation tickets
   - Evidence organized and linked

**Example:**
- Base score: 0.7 (good QA with minor gaps)
- +0.1 for subfolder organization
- +0.1 for progress communication
- **Final: 0.9** (elevated to gold standard)

---

## Confidence Penalties (Subtract -0.1 each)

These factors reduce confidence by -0.1 each:

1. **-0.1 Missing Critical Evidence**
   - No SF CLI verification for data persistence tests
   - Screenshots missing for key test cases
   - No video for complex UI/UX tests

2. **-0.1 Poor Organization**
   - Evidence scattered (not in subfolder)
   - Default screenshot names (Screenshot 2025-10-28...)
   - Hard to find specific test evidence

3. **-0.1 Incomplete Documentation**
   - Test steps vague or missing
   - No priority mapping
   - Final summary missing statistics

**Example:**
- Base score: 0.8 (good QA)
- -0.1 for missing SF CLI verifications
- -0.1 for poor screenshot organization
- **Final: 0.6** (dropped to adequate)

---

## Practical Application Examples

### Scenario 1: Feature QA Session (Persona Selection)

**What was done:**
- Loaded ticket 86d0ffk2d from ClickUp
- Created subfolder: `qa/86d0ffk2d-persona-selection/`
- Mapped 6 acceptance criteria to test cases (TC1-TC6)
- Documented all tests with screenshots (renamed TC1-TC6)
- Verified 5/6 tests with SF CLI queries
- Recorded video for UI/UX behavior test
- Created investigation ticket for anomaly
- Posted progress updates after TC1-TC3 and TC4-TC6
- Final summary with 6/6 passed, 0 bugs, 1 investigation

**Confidence Calculation:**
- Acceptance criteria: All mapped (0.3)
- Documentation: Complete with template (0.3)
- Evidence: All screenshots + most CLI (0.35)
- +0.1 Subfolder organization
- +0.1 Progress communication
- +0.1 Investigation management
- **Total: 1.0** (Gold Standard)

**Justification:** Complete, systematic, reproducible QA session with comprehensive evidence.

---

### Scenario 2: Quick Feature Test

**What was done:**
- Tested applicant form submission
- Captured 3 screenshots showing form filled out
- Checked Salesforce and saw record created
- Posted comment: "QA complete - form works as expected"

**Confidence Calculation:**
- Acceptance criteria: No mapping (0.0)
- Documentation: Minimal (0.1)
- Evidence: Some screenshots, no CLI (0.2)
- **Total: 0.3** (Incomplete)

**Justification:** Tests performed but insufficient documentation for reproduction. Missing systematic approach, SF CLI verification, test plan.

---

### Scenario 3: QA with Some Gaps

**What was done:**
- Created test doc in `qa/` folder (not subfolder)
- Tested 4 critical scenarios
- Got screenshots for 3/4 tests
- Ran 2 SF CLI queries for data verification
- Documented test results in doc
- Posted final summary: "4/4 tests passed"

**Confidence Calculation:**
- Acceptance criteria: Some mapping (0.2)
- Documentation: Partial but exists (0.2)
- Evidence: Some screenshots + some CLI (0.25)
- -0.1 Poor organization (no subfolder)
- **Total: 0.55** (Adequate with gaps)

**Justification:** Decent QA effort but missing systematic approach, full evidence coverage, and proper organization.

---

## When to Use This Guide

### Use confidence scoring to:

1. **Self-assess QA quality** before marking ticket as "Ready for UAT"
2. **Identify documentation gaps** mid-session to improve thoroughness
3. **Communicate QA completeness** to stakeholders objectively
4. **Improve QA processes** by understanding what raises/lowers confidence
5. **Validate reproducibility** of test results for future reference

### Don't use confidence scoring for:

1. ❌ Assessing whether the feature works (user approves that)
2. ❌ Determining if bugs should be fixed (severity assessment handles that)
3. ❌ Judging tester competence (measures documentation, not ability)

---

## Integration with QA Workflow

**Step 27 of @exec/TODOS_CONDITIONER_QA.md:**
```
27. [🧪] [@docs/personas/QA_TESTER.md] Calculate QA confidence score
    - Use @docs/CONFIDENCE_SCORING_GUIDE_QA.md
    - Score based on documentation completeness, not test results
    - Include confidence in final summary
```

**Include in Final Summary:**
```markdown
## ✅ QA Decision: PASSED

### QA Confidence Score: 0.9 (Gold Standard)

**Confidence Justification:**
- All 6 acceptance criteria mapped to test cases ✅
- Complete test documentation following methodology template ✅
- All test cases have screenshot evidence (TC1-TC6) ✅
- 5/6 data persistence tests verified with SF CLI ✅
- Evidence organized in subfolder: qa/86d0ffk2d-persona-selection/ ✅
- Progress updates posted every 2-3 tests ✅
- Investigation ticket created for anomaly ✅

**Reproducibility:** High - any QA tester could repeat all tests from documentation
```

---

## Confidence Thresholds for Status Changes

Use these thresholds to guide ticket status decisions:

### Ready for UAT: Confidence ≥ 0.7
- QA documentation complete enough for UAT
- Evidence sufficient to reproduce if issues found
- Systematic testing approach followed
- Critical gaps identified and documented

### Needs More QA: Confidence < 0.7
- Documentation insufficient for UAT confidence
- Missing critical evidence or verification
- Cannot reproduce tests reliably
- Should improve QA before moving forward

**Note:** These are guidelines, not hard rules. User has final say on UAT readiness.

---

## Continuous Improvement

### Raising Confidence Over Time

**From 0.5 to 0.7:**
- Add SF CLI verifications for data persistence tests
- Create systematic test plan with priority mapping
- Organize evidence in subfolders
- Document test steps clearly

**From 0.7 to 0.9:**
- Ensure every test case has evidence
- Post progress updates regularly
- Use proper screenshot naming (TC{number}-)
- Create comprehensive final summary

**From 0.9 to 1.0:**
- Video evidence for complex UI/UX
- Investigation tickets for anomalies
- Perfect evidence organization
- Git commits following conventions
- Anyone could reproduce exactly

---

## Common Pitfalls

### Overconfidence Traps

1. **"I tested everything"** → Confidence 0.2
   - No documentation = not reproducible
   - Need systematic evidence

2. **"All tests passed"** → Confidence 0.4
   - What tests? With what evidence?
   - Need documented test cases

3. **"Screenshots captured"** → Confidence 0.6
   - Are they organized? Named properly?
   - Do you have SF CLI verifications?

### Underconfidence Traps

1. **"Only got 5/6 SF CLI verifications"** → Still could be 0.9
   - If one test didn't need CLI, that's fine
   - Don't penalize yourself unnecessarily

2. **"Used default names for 1 screenshot"** → Still could be 0.8
   - If everything else is perfect, minor gap
   - Rename and boost to 0.9

---

## Key Takeaways

1. **Confidence measures QA thoroughness**, not feature quality
2. **User approves test results**, confidence measures documentation
3. **Reproducibility is key**: Can someone else repeat your tests?
4. **Evidence + Organization + Documentation** = High Confidence
5. **Use mid-session** to identify gaps before completion
6. **Thresholds are guidelines**, user decides UAT readiness
7. **Continuous improvement** from session to session

---

**Version:** 1.0
**Created:** 2025-10-28
**Owner:** QA Team
**Related:** @docs/personas/QA_TESTER.md, @exec/QA-Testing-Methodology.md, @exec/TODOS_CONDITIONER_QA.md
