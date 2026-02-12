# QA Test Report: [Feature Name]

**Ticket ID:** [TICKET_ID]
**Ticket Name:** [TICKET_NAME]
**ClickUp URL:** https://app.clickup.com/t/[TICKET_ID]
**QA Start Date:** YYYY-MM-DD
**QA End Date:** YYYY-MM-DD
**QA Status:** 🔄 In Progress / ✅ Completed / ❌ Blocked
**Tester:** [Your Name]

---

## 📋 User Story Summary

**As a** [user type]
**I want** [goal]
**So that** [benefit]

**Business Value:** [Brief description of business value]

---

## ✅ Acceptance Criteria

### Scenario 1: [Scenario Name] (Positive)

**GIVEN** [initial context]
**WHEN** [action taken]
**THEN** [expected outcome]

### Scenario 2: [Scenario Name] (Negative)

**GIVEN** [initial context]
**WHEN** [action taken]
**THEN** [expected outcome]

### Scenario 3: [Scenario Name] (Edge Case)

**GIVEN** [initial context]
**WHEN** [action taken]
**THEN** [expected outcome]

---

## 🎯 Acceptance Criteria Priority Mapping

### ⚠️ CRITICAL (Priority 1):
1. **[Critical functionality]** → TC1
2. **[Data integrity check]** → TC2

### 🔶 HIGH (Priority 2):
1. **[Important feature]** → TC3
2. **[User-facing validation]** → TC4

### 🔷 MEDIUM (Priority 3):
1. **[Edge case]** → TC5

### ⚪ LOW (Priority 4):
1. **[UI/UX improvement]** → TC6

---

## 🧪 Test Cases

### TC1: [Test Case Name - Critical]

**Priority:** ⚠️ CRITICAL

**Description:** Test that [specific functionality] works correctly

**Pre-conditions:**
- User is authenticated
- Feature is enabled
- Test data is prepared

**Steps to Reproduce:**
1. Navigate to [URL/location]
2. Click on [element]
3. Enter [data] in [field]
4. Click [submit button]

**Expected Result:**
- System should [expected behavior]
- User should see [expected UI state]
- Data should be saved with [expected values]

**Actual Result:**
- ✅ System behaved as expected
- ✅ User saw correct UI state
- ✅ Data was saved correctly

**Status:** ✅ Pass

**Evidence:** `screenshots/TC1-test-case-name.png`

**Notes:** [Any additional observations]

---

### TC2: [Test Case Name - Data Validation]

**Priority:** ⚠️ CRITICAL

**Description:** Test that [validation] prevents [invalid data]

**Pre-conditions:**
- User is on [page/form]
- Field is visible and editable

**Steps to Reproduce:**
1. Navigate to [URL/location]
2. Enter invalid data: [specific invalid input]
3. Attempt to submit form

**Expected Result:**
- System should show error message: "[expected error message]"
- Form should not submit
- Field should be highlighted

**Actual Result:**
- ✅ Error message displayed correctly
- ✅ Form did not submit
- ✅ Field was highlighted in red

**Status:** ✅ Pass

**Evidence:** `screenshots/TC2-validation-error.png`

**Notes:** [Any additional observations]

---

### TC3: [Test Case Name - Positive Flow]

**Priority:** 🔶 HIGH

**Description:** Test complete workflow from [start] to [end]

**Pre-conditions:**
- [Prerequisite 1]
- [Prerequisite 2]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]
4. [Step 4]

**Expected Result:**
- [Expected outcome 1]
- [Expected outcome 2]
- [Expected outcome 3]

**Actual Result:**
- [Actual outcome]

**Status:** ✅ Pass / ❌ Fail

**Evidence:** `screenshots/TC3-complete-workflow.png`

**Notes:** [Any additional observations]

---

### TC4: [Test Case Name - Error Handling]

**Priority:** 🔶 HIGH

**Description:** Test that system handles [error condition] gracefully

**Pre-conditions:**
- [Setup error condition]

**Steps to Reproduce:**
1. [Step to trigger error]
2. [Step to observe error handling]

**Expected Result:**
- System should display user-friendly error message
- System should not crash
- User should be able to recover

**Actual Result:**
- [Actual outcome]

**Status:** ✅ Pass / ❌ Fail

**Evidence:** `screenshots/TC4-error-handling.png`

**Notes:** [Any additional observations]

---

### TC5: [Test Case Name - Edge Case]

**Priority:** 🔷 MEDIUM

**Description:** Test behavior with [unusual input/condition]

**Pre-conditions:**
- [Setup edge case scenario]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]

**Expected Result:**
- [Expected edge case behavior]

**Actual Result:**
- [Actual outcome]

**Status:** ✅ Pass / ❌ Fail

**Evidence:** `screenshots/TC5-edge-case.png`

**Notes:** [Any additional observations]

---

### TC6: [Test Case Name - UI/UX]

**Priority:** ⚪ LOW

**Description:** Test that [UI element] displays correctly

**Pre-conditions:**
- [UI state setup]

**Steps to Reproduce:**
1. [Step to view UI]
2. [Step to interact with UI]

**Expected Result:**
- UI should display [expected appearance]
- Animations should be smooth
- Responsive behavior should work

**Actual Result:**
- [Actual outcome]

**Status:** ✅ Pass / ❌ Fail

**Evidence:** `screenshots/TC6-ui-display.png` or `videos/TC6-ui-behavior.mov`

**Notes:** [Any additional observations]

---

## 🐛 Bugs Found

### Bug 1: [Bug Title]

**Related Test Case:** TC[X]

**Severity:** Critical / High / Medium / Low

**Description:** [Detailed description of the bug]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior:** [What should happen]

**Actual Behavior:** [What actually happens]

**Evidence:** `screenshots/BUG1-description.png`

**Bug Ticket:** [CLICKUP_BUG_TICKET_URL]

**Status:** 🔴 Open / 🟡 In Progress / 🟢 Fixed / ✅ Verified Fixed

**Notes:** [Additional context]

---

## 📊 Test Results Summary

### Overall Statistics

- **Total Test Cases:** 6
- **Passed:** 5 ✅
- **Failed:** 1 ❌
- **Blocked:** 0 ⛔
- **Pass Rate:** 83%

### By Priority

| Priority | Total | Passed | Failed | Pass Rate |
|----------|-------|--------|--------|-----------|
| ⚠️ CRITICAL | 2 | 2 | 0 | 100% |
| 🔶 HIGH | 2 | 2 | 0 | 100% |
| 🔷 MEDIUM | 1 | 1 | 0 | 100% |
| ⚪ LOW | 1 | 0 | 1 | 0% |

### Test Execution Timeline

| Date | Test Cases Run | Status |
|------|----------------|--------|
| YYYY-MM-DD | TC1-TC3 | Initial testing |
| YYYY-MM-DD | TC4-TC6 | Completed remaining tests |
| YYYY-MM-DD | TC3 (retest) | After bug fix |

---

## 🔍 Critical Issues Summary

### Issues Found

1. **[Critical Issue 1]** (TC2)
   - Status: ✅ Fixed and verified
   - Fix ticket: [CLICKUP_URL]

2. **[High Issue 1]** (TC4)
   - Status: 🔴 Open
   - Blocking production release: Yes/No

### Risk Assessment

**Risk Level:** Low / Medium / High / Critical

**Recommendation:**
- ✅ Ready for production deployment
- ⚠️ Ready with known issues (list issues)
- ❌ Not ready - critical bugs must be fixed first

---

## 📝 Testing Notes

### Environment

- **Salesforce Org:** [Sandbox/Production]
- **Browser:** Chrome 120.x / Firefox 121.x / Safari 17.x
- **OS:** macOS 14.x / Windows 11
- **Test Data:** [Link to test data or description]
- **Test Account:** [Test user email]

### Additional Observations

1. [Observation 1]
2. [Observation 2]
3. [Observation 3]

### Known Limitations

1. [Limitation 1]
2. [Limitation 2]

### Recommendations

1. [Recommendation 1]
2. [Recommendation 2]

---

## ✍️ Sign-off

### QA Engineer

**Name:** [Your Name]
**Date:** YYYY-MM-DD
**Signature:** ✅ Approved / ❌ Not Approved

**Comments:**
[Any final comments or notes]

### Developer Review (Optional)

**Name:** [Developer Name]
**Date:** YYYY-MM-DD
**Acknowledgment:** ✅ Reviewed

**Comments:**
[Developer response to test results]

### Product Owner Review (Optional)

**Name:** [PO Name]
**Date:** YYYY-MM-DD
**Approval:** ✅ Approved for Production

**Comments:**
[Product owner final approval]

---

## 📎 Attachments

### Screenshots

Located in `screenshots/` directory:
- `TC1-test-case-name.png`
- `TC2-validation-error.png`
- `TC3-complete-workflow.png`
- `TC4-error-handling.png`
- `TC5-edge-case.png`
- `TC6-ui-display.png`
- `BUG1-description.png`

### Videos

Located in `videos/` directory (if applicable):
- `TC6-ui-behavior.mov` - Demonstration of UI behavior

### Test Data

Located in `test-data/` directory (if applicable):
- `test-data.csv` - Test data used
- `test-accounts.md` - Test account credentials

---

## 🔗 Related Links

- **ClickUp Ticket:** [CLICKUP_URL]
- **Requirements Doc:** `requirements/[TICKET_ID]-requirements.md`
- **Design Doc:** `designs/[TICKET_ID]-design.md`
- **Deployment Doc:** `tickets/[TICKET_ID]/DEPLOYMENT.md`
- **Bug Tickets:** [Links to any bug tickets created]

---

**Last Updated:** YYYY-MM-DD
**Report Version:** 1.0
