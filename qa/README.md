# QA Testing

Quality assurance testing documentation and test reports organized by ClickUp ticket.

## Purpose

This directory contains all QA-related documentation including:
- Test plans and test cases
- QA test reports
- Screenshots and evidence
- Test data and scripts
- Bug reports and regression tests

## Directory Structure

```
qa/
├── README.md                           # This file - QA guidelines
├── [TICKET_ID]-[FEATURE_NAME]/        # One directory per feature/ticket
│   ├── QA-[TICKET_ID]-[NAME].md       # Main QA test report
│   ├── TEST_PLAN.md                   # Optional detailed test plan
│   ├── screenshots/                   # Test evidence screenshots
│   │   ├── TC1-test-case-name.png
│   │   ├── TC2-test-case-name.png
│   │   └── ...
│   └── videos/                        # Optional test videos
│       └── TC-demo.mov
└── example-test-case/                 # Example template
```

## Naming Convention

### Directory Names

Format: `[TICKET_ID]-[FEATURE_NAME]`

Examples:
- `86d0abc12-user-authentication`
- `86d0def34-data-validation`
- `86d0ghi56-analytics-dashboard`

### Test Report Names

Format: `QA-[TICKET_ID]-[FEATURE_NAME].md`

Examples:
- `QA-86d0abc12-user-authentication.md`
- `QA-86d0def34-data-validation.md`

### Screenshot Names

Format: `TC[NUMBER]-[DESCRIPTIVE_NAME].png`

Examples:
- `TC1-login-form-display.png`
- `TC2-error-message-validation.png`
- `TC3-success-confirmation.png`

## QA Test Report Template

See `example-test-case/QA-TEMPLATE.md` for the standard template.

### Required Sections

1. **Header Information**
   - Ticket ID and name
   - ClickUp URL
   - QA dates and status
   - Tester name

2. **User Story Summary**
   - As a [user type]
   - I want [goal]
   - So that [benefit]

3. **Acceptance Criteria**
   - Given/When/Then format
   - Organized by scenario
   - Positive and negative test cases

4. **Test Cases**
   - Test case ID (TC1, TC2, etc.)
   - Description
   - Steps to reproduce
   - Expected result
   - Actual result
   - Status (✅ Pass / ❌ Fail)
   - Evidence (screenshot/video reference)

5. **Test Results Summary**
   - Total test cases
   - Passed/Failed breakdown
   - Critical issues found
   - Overall status

6. **Sign-off**
   - QA engineer approval
   - Date
   - Notes

## Test Case Priority Levels

### ⚠️ CRITICAL (Priority 1)
- Core functionality
- Data integrity
- Security features
- Regression-prone areas

### 🔶 HIGH (Priority 2)
- Important features
- User-facing functionality
- Common workflows

### 🔷 MEDIUM (Priority 3)
- Nice-to-have features
- Edge cases
- UI/UX improvements

### ⚪ LOW (Priority 4)
- Cosmetic issues
- Rare scenarios
- Non-blocking items

## Testing Workflow

### 1. Pre-Testing Setup

1. Review ticket requirements in ClickUp
2. Create QA directory: `qa/[TICKET_ID]-[FEATURE_NAME]/`
3. Copy QA template: `QA-[TICKET_ID]-[FEATURE_NAME].md`
4. Review acceptance criteria with developer

### 2. Test Execution

1. Execute each test case systematically
2. Capture screenshots for evidence
3. Record videos for complex workflows
4. Document actual results
5. Mark each test as Pass/Fail

### 3. Bug Reporting

If bugs found:
1. Document in test report with ❌ status
2. Create bug ticket in ClickUp
3. Link bug ticket to original feature ticket
4. Include reproduction steps and evidence
5. Assign to developer

### 4. Test Report Completion

1. Complete all test cases
2. Fill test results summary
3. Add sign-off section
4. Commit to repository
5. Update ClickUp ticket with QA status

### 5. Regression Testing

After bug fixes:
1. Re-test failed test cases
2. Update test report with new results
3. Verify no new bugs introduced
4. Final sign-off when all tests pass

## Best Practices

### Documentation

1. **Be Specific**: Write clear, reproducible test steps
2. **Use Evidence**: Always include screenshots/videos
3. **Track Changes**: Update test reports as bugs are fixed
4. **Link Tickets**: Reference ClickUp tickets in test reports

### Test Coverage

1. **Positive Tests**: Happy path scenarios
2. **Negative Tests**: Error handling and validation
3. **Edge Cases**: Boundary conditions and unusual inputs
4. **Regression Tests**: Re-test previous features
5. **Cross-Browser**: Test on multiple browsers (if applicable)
6. **Mobile**: Test responsive behavior (if applicable)

### Screenshots

1. **Full Context**: Capture full screen or relevant section
2. **Clear Labels**: Use descriptive filenames
3. **Annotations**: Add arrows/highlights if needed
4. **Consistent Format**: Use PNG for screenshots
5. **Organize**: Place in `screenshots/` subdirectory

### Videos

1. **Short & Focused**: 30-60 seconds per test case
2. **Show Complete Flow**: Start to finish
3. **Clear Actions**: Show mouse clicks and inputs
4. **Audio Optional**: Narration can be helpful
5. **Organize**: Place in `videos/` subdirectory (if used)

## Example Test Case

See `example-test-case/` directory for a complete example demonstrating:
- Proper directory structure
- QA test report format
- Screenshot organization
- Test case documentation
- Sign-off procedures

## QA Sign-off Criteria

Before marking a ticket as "Ready for Production":

- ✅ All critical test cases pass
- ✅ All high priority test cases pass
- ✅ Known issues documented and accepted
- ✅ Regression tests pass
- ✅ Test report completed and committed
- ✅ Developer has reviewed test results
- ✅ Product owner (if applicable) has reviewed

## Integration with Development

### Developer Collaboration

1. **Pre-Development**: Review acceptance criteria together
2. **During Development**: Provide early feedback on WIP features
3. **Post-Development**: Thorough testing with documented results
4. **Bug Fixes**: Re-test and verify fixes
5. **Sign-off**: Final approval before production

### ClickUp Workflow

1. Developer moves ticket to "Ready for QA"
2. QA picks up ticket and creates test directory
3. QA executes tests and documents results
4. If bugs found, ticket returns to "In Progress"
5. When all tests pass, QA moves to "Ready for Production"
6. Product owner reviews and approves for release

## References

- **QA Methodology**: `exec/QA-Testing-Methodology.md`
- **Test Website**: `development/test_website/`
- **ClickUp Project**: [CLICKUP_PROJECT_URL]
