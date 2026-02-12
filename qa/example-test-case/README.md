# Example Test Case

This directory contains an example QA test case demonstrating the standard format and structure for test reports.

## Contents

- `QA-TEMPLATE.md` - Complete QA test report template
- `screenshots/` - Directory for test evidence screenshots
- `README.md` - This file

## How to Use This Template

### 1. Create New Test Case Directory

```bash
# Create directory for your ticket
mkdir qa/[TICKET_ID]-[FEATURE_NAME]
cd qa/[TICKET_ID]-[FEATURE_NAME]

# Copy the template
cp ../example-test-case/QA-TEMPLATE.md QA-[TICKET_ID]-[FEATURE_NAME].md

# Create screenshots directory
mkdir screenshots
```

### 2. Fill in the Template

1. **Replace placeholders:**
   - `[TICKET_ID]` → Your ClickUp ticket ID (e.g., `86d0abc12`)
   - `[TICKET_NAME]` → Your ticket name
   - `[Feature Name]` → Feature being tested
   - `[Your Name]` → Your name
   - Date fields with actual dates

2. **Update User Story:**
   - Copy from ClickUp ticket or requirements doc
   - Include business value

3. **List Acceptance Criteria:**
   - Copy from ClickUp ticket
   - Use Given/When/Then format
   - Organize by positive/negative/edge cases

4. **Map Test Cases:**
   - Assign test case IDs (TC1, TC2, etc.)
   - Map to acceptance criteria
   - Assign priority levels

### 3. Execute Tests

1. **Run each test case systematically**
2. **Capture screenshots:**
   ```bash
   # Save with descriptive names
   screenshots/TC1-test-case-description.png
   screenshots/TC2-validation-error.png
   ```
3. **Document results:**
   - Mark each test as ✅ Pass or ❌ Fail
   - Record actual vs expected results
   - Note any observations

### 4. Report Bugs

If bugs are found:
1. Document in "Bugs Found" section
2. Create bug ticket in ClickUp
3. Link bug ticket in test report
4. Include screenshot evidence
5. Track bug status

### 5. Complete Test Report

1. **Fill Test Results Summary**
   - Calculate pass/fail statistics
   - Update by-priority breakdown

2. **Add Testing Notes**
   - Document environment
   - List observations
   - Note any limitations

3. **Add Sign-off**
   - QA engineer approval
   - Developer acknowledgment (optional)
   - Product owner approval (optional)

### 6. Commit and Update ClickUp

```bash
# Commit test report
git add qa/[TICKET_ID]-[FEATURE_NAME]/
git commit -m "test: Add QA test report for [TICKET_ID]"
git push

# Update ClickUp ticket
# - Add comment with test results summary
# - Move ticket to appropriate status
# - Link to test report in GitHub
```

## Template Sections Explained

### Header Information
- Basic ticket metadata
- Tester identification
- QA timeline tracking

### User Story Summary
- Feature context and purpose
- Business value justification

### Acceptance Criteria
- Testable requirements in Given/When/Then format
- Organized by scenario type

### Priority Mapping
- Links acceptance criteria to test cases
- Groups by priority level for risk assessment

### Test Cases
- Detailed test execution documentation
- Each test case includes:
  - Priority level
  - Description
  - Pre-conditions
  - Steps to reproduce
  - Expected vs actual results
  - Pass/Fail status
  - Evidence references

### Bugs Found
- Detailed bug documentation
- Links to bug tickets
- Tracking of bug status

### Test Results Summary
- Statistics and metrics
- Pass rate calculation
- Priority-based breakdown
- Timeline of test execution

### Critical Issues Summary
- High-level overview of blocking issues
- Risk assessment
- Production readiness recommendation

### Testing Notes
- Environment details
- Additional observations
- Known limitations
- Recommendations for improvement

### Sign-off
- QA engineer approval
- Developer review acknowledgment
- Product owner final approval

## Best Practices

### DO:
- ✅ Be specific and detailed in test steps
- ✅ Include screenshots for every test case
- ✅ Update test report as bugs are fixed
- ✅ Calculate accurate pass/fail statistics
- ✅ Provide clear recommendations

### DON'T:
- ❌ Skip documenting failed tests
- ❌ Use vague descriptions like "works fine"
- ❌ Forget to link bug tickets
- ❌ Approve without testing critical paths
- ❌ Leave template placeholders unfilled

## Tips for Effective Test Reports

1. **Write for Future Reference**
   - Someone should be able to reproduce your tests 6 months later
   - Include all context and environment details

2. **Use Clear Evidence**
   - Screenshots should show full context
   - Annotate screenshots if needed
   - Videos for complex workflows

3. **Track Everything**
   - Document both passes and failures
   - Note unexpected behavior even if not a bug
   - Record performance issues

4. **Communicate Clearly**
   - Use consistent terminology
   - Be objective, not subjective
   - Separate facts from opinions

5. **Think About Risk**
   - Prioritize critical functionality
   - Don't skip edge cases
   - Consider regression impact

## Example Test Case Naming

Good examples:
- `qa/86d0abc12-user-login/QA-86d0abc12-user-login.md`
- `qa/86d0def34-data-validation/QA-86d0def34-data-validation.md`
- `qa/86d0ghi56-chat-widget/QA-86d0ghi56-chat-widget.md`

Bad examples:
- `qa/test1.md` (no structure)
- `qa/feature-x/test.md` (no ticket ID)
- `qa/QA-report.md` (not specific)

## Screenshot Organization

```
qa/[TICKET_ID]-[FEATURE_NAME]/
├── screenshots/
│   ├── TC1-form-display.png           # Test case 1 evidence
│   ├── TC2-validation-error.png       # Test case 2 evidence
│   ├── TC3-success-message.png        # Test case 3 evidence
│   ├── BUG1-data-loss.png             # Bug evidence
│   └── BUG2-ui-misalignment.png       # Bug evidence
```

## Video Guidelines

Videos are optional but helpful for:
- Complex multi-step workflows
- UI/UX behavior demonstrations
- Reproduction of intermittent bugs
- Performance issues

Keep videos:
- Short (30-60 seconds per test case)
- Focused on specific functionality
- Clear with visible actions
- Named consistently (TC[N]-description.mov)

## Questions?

If you have questions about:
- **Template usage** → Review this README
- **QA process** → Check `exec/QA-Testing-Methodology.md`
- **Specific features** → Ask on Slack (Channel ID: C08V3EPT8LD)
- **ClickUp workflow** → Review main project README

## Template Version

**Version:** 1.0
**Last Updated:** 2025-11-11
**Maintained By:** QA Team
