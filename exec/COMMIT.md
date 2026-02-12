# Complete Commit Workflow Assistant

## Purpose

This skill handles the **complete commit workflow** from start to finish:
1. File selection and verification with user
2. ClickUp ticket ID verification
3. **Pre-commit CI validation** (Apex/LWC/Metadata/Docs) - BEFORE commit
4. Co-author detection (for pair/mob programming)
5. Create commit with proper format including CI status and co-authors
6. Push to remote
7. Post comment to ClickUp ticket
8. Check next action item and ask if user wants to continue

**Target Users**: Developers who want a streamlined "save and share" workflow without thinking about individual git commands.

## Core Principles

1. **Complete Workflow** - From file selection to next task, all in one flow
2. **Plain Language** - Use "save", "share" instead of "commit", "push"
3. **Smart Automation** - Auto-validate, auto-push, auto-comment, auto-suggest next steps
4. **Safe by Default** - Validate with CI before committing
5. **ClickUp Integration** - Automatic ticket tracking and updates
6. **Team Collaboration** - Support for pair/mob programming with co-author attribution

## Trigger Phrases

This skill activates when user says:
- "commit" or "commit my changes"
- "save my work" or "save and push"
- "save and share"
- "commit and push"

## Complete Workflow Steps

### STEP 1: File Selection and Verification

**Check current status**:
```bash
git status
```

**Get detailed file statistics**:
```bash
# Get stats for unstaged changes
git diff --stat

# Get number of lines changed per file
git diff --numstat
```

**Show user what's changed**:
```
Files with changes:

Modified:
✏️  AccountController.cls (+15 -3 lines)
✏️  AccountTrigger.trigger (+3 -1 lines)

New files:
➕ AnalyticsComponentTest.cls (+50 lines)

Deleted:
❌ old-file.cls (-25 lines)

Total: 4 files, +68 lines, -29 lines
```

**Ask user for file selection using AskUserQuestion**:
```javascript
AskUserQuestion({
  questions: [{
    question: "Which files should I include in this commit?",
    header: "File Selection",
    multiSelect: false,
    options: [
      {
        label: "All files (4 files)",
        description: "Include all changed files in the commit"
      },
      {
        label: "Let me specify",
        description: "I'll type specific file names"
      }
    ]
  }]
})
```

**If user chooses "Let me specify"**:
- User will use "Other" option to type file names
- Parse the file list and validate each file exists

**Execute git add**:
```bash
git add [selected-files]
# OR
git add .  # if all files selected
```

**Verify staged files**:
```bash
git diff --cached --name-only
```

**Show verification to user**:
```
✓ Staged files:
  - AccountController.cls
  - AccountTrigger.trigger
  - AnalyticsComponentTest.cls
  - old-file.cls (deleted)

Ready to proceed? [Yes] [No - change selection]
```

---

### STEP 2: ClickUp Ticket ID Verification

**Check current branch name**:
```bash
git branch --show-current
```

**Extract ticket ID from branch name**:
```bash
# Extract ticket ID from branch name
branch=$(git branch --show-current)
# Match patterns like: 86d0xyz123, clickup-86d0xyz123, feature/86d0xyz123
ticket_id=$(echo "$branch" | grep -oE '86[a-z0-9]{8,}' | head -1)
```

**If ticket ID detected**:
```
I found ticket ID in your branch: 86d0xyz123

Verifying with ClickUp...
```

**Validate ticket using ClickUp API**:
```javascript
mcp__ClickUp__get_task({ taskId: "86d0xyz123" })
```

**If ticket found**:
```
✓ Verified ClickUp ticket: "Implement Analytics Feature"
  Status: In Progress
  List: Development Tasks

Proceeding with ticket ID: 86d0xyz123
```

**If ticket NOT found or not in branch name**:

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "I couldn't find a ClickUp ticket ID in your branch name. Do you have a ticket ID for this work?",
    header: "Ticket ID",
    multiSelect: false,
    options: [
      {
        label: "Yes, let me provide it",
        description: "I'll enter the ClickUp ticket ID"
      },
      {
        label: "No ticket",
        description: "Proceed without linking to a ticket"
      }
    ]
  }]
})
```

**If user provides ticket ID via "Other"**:
- Validate using `mcp__ClickUp__get_task`
- Show ticket details for confirmation

**If validation fails**:
```
⚠️ Ticket ID "86d0xyz123" not found in ClickUp.

What should I do?
[Try again] [Proceed without ticket]
```

---

### STEP 3: Pre-Commit CI Validation

**CRITICAL**: Run CI checks BEFORE creating the commit. Only proceed if CI passes.

**Get list of staged files**:
```bash
# Get all files that will be committed
git diff --cached --name-only
```

**Categorize files and determine CI strategy**:

```bash
# Get all staged files
files=$(git diff --cached --name-only)

# Initialize counters
has_apex=false
has_lwc=false
has_metadata=false
has_docs=false

# Check each file
for file in $files; do
  # Check for Apex
  if [[ "$file" == *.cls ]] || [[ "$file" == *.trigger ]] || [[ "$file" == force-app/main/default/classes/* ]] || [[ "$file" == force-app/main/default/triggers/* ]]; then
    has_apex=true
  fi

  # Check for LWC
  if [[ "$file" == force-app/main/default/lwc/*/*.js ]] || [[ "$file" == force-app/main/default/lwc/*/*.html ]] || [[ "$file" == force-app/main/default/lwc/*/*.css ]]; then
    has_lwc=true
  fi

  # Check for Metadata (XML)
  if [[ "$file" == *.xml ]] || [[ "$file" == *-meta.xml ]]; then
    has_metadata=true
  fi

  # Check for Documentation
  if [[ "$file" == *.md ]] || [[ "$file" == docs/* ]] || [[ "$file" == tickets/* ]] || [[ "$file" == exec/* ]]; then
    has_docs=true
  fi
done

# Determine CI strategy
if $has_apex && $has_lwc; then
  # Mixed changes - run full CI
  ci_command="npm run ci"
  change_type="Mixed (Apex + LWC)"
  ci_ran=true
elif $has_lwc && ! $has_apex; then
  # LWC only
  ci_command="npm run ci:lwc && npm run ci:lint"
  change_type="LWC only"
  ci_ran=true
elif $has_apex && ! $has_lwc; then
  # Apex only
  ci_command="npm run ci:apex && npm run ci:pmd"
  change_type="Apex only"
  ci_ran=true
elif ($has_metadata || $has_docs) && ! $has_apex && ! $has_lwc; then
  # Metadata or docs only - skip CI
  ci_command=""
  change_type="Metadata/Documentation only"
  ci_ran=false
else
  # Unknown or no code changes
  ci_command=""
  change_type="Unknown"
  ci_ran=false
fi
```

**Show change analysis**:

**For code changes (Apex/LWC)**:
```
📊 Analyzing changes before commit...

Change analysis:
  - Apex: 2 files (AccountController.cls, AccountTrigger.trigger)
  - LWC: 1 file (analyticsComponent.js)

This is a mixed change set.

🔄 Running pre-commit validation...
  Command: npm run ci

This will run:
- Apex tests (sf apex run test)
- Apex PMD analysis (pmd check)
- LWC tests (npm test)
- ESLint linting
```

**For metadata/docs only**:
```
📊 Analyzing changes before commit...

Change analysis:
  - Documentation: 2 files (tickets/86d0xyz123/implementation.md, README.md)

This is documentation-only changes.

✓ Skipping CI validation (no code changes require testing)
```

**Execute CI if needed**:
```bash
npm run ci
# OR
npm run ci:lwc && npm run ci:lint
# OR
npm run ci:apex && npm run ci:pmd
```

**If CI passes**:
```
✅ All pre-commit validation passed!

  ✓ Apex tests: 45 passed, 0 failed
  ✓ PMD analysis: No violations
  ✓ LWC tests: 12 passed, 0 failed
  ✓ ESLint: No errors

Ready to commit!
```

**If CI fails**:
```
❌ Pre-commit validation failed!

You cannot commit with failing tests or violations.

Failures:
  ✗ Apex tests: 2 failed
    - AccountControllerTest.testGetAccount (line 45)
    - AccountControllerTest.testUpdateAccount (line 78)

  ✗ PMD analysis: 3 violations
    - AccountController.cls:23 - Avoid using SOQL in loops
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Pre-commit validation failed. What should I do?",
    header: "CI Failed",
    multiSelect: false,
    options: [
      {
        label: "Show full output",
        description: "See detailed error messages"
      },
      {
        label: "Cancel commit",
        description: "Let me fix the issues first"
      }
    ]
  }]
})
```

---

### STEP 4: Co-Author Detection (Pair Programming)

**Ask if user is pair/mob programming**:

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Are you pair programming on this change?",
    header: "Pair Programming",
    multiSelect: false,
    options: [
      {
        label: "Yes - Solo work",
        description: "Just me working on this"
      },
      {
        label: "Yes - Pairing",
        description: "I'm pairing with someone"
      },
      {
        label: "Yes - Mob programming",
        description: "Multiple people working together"
      }
    ]
  }]
})
```

**If pairing or mob programming**:

Ask for co-author name:
```javascript
AskUserQuestion({
  questions: [{
    question: "Who are you pairing with? (Enter name or email)",
    header: "Co-Author",
    multiSelect: false,
    options: [
      {
        label: "Let me type the name",
        description: "I'll provide name or email to search"
      }
    ]
  }]
})
```

**Look up co-author in git history**:
```bash
# Search git history for the name/email
git log --all --format="%an <%ae>" | sort -u | grep -i "<search-term>"
```

**Known contributors** (from exec/COMMIT.md):
- Sidu Ponnappa: sidu@realfast.ai
- Aniket Hendre: hendre.ani@gmail.com
- Bharat: bharat@realfast.ai
- Saurav Shah: saurav@realfast.ai
- Namanpreet Singh: namanpreet.singh@realfast.ai
- Ganesh Hegde: ganesh.hegde@realfast.ai
- Harsh: harsh@realfast.ai
- Shubham Kumar: shubham.kumar@realfast.ai
- Suraj Chandola: suraj@realfast.ai

**Show found co-author for confirmation**:
```
Found: Sidu Ponnappa <sidu@realfast.ai>

Is this correct?
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Is this the correct co-author: Sidu Ponnappa <sidu@realfast.ai>?",
    header: "Confirm",
    multiSelect: false,
    options: [
      {
        label: "Yes, correct",
        description: "Use this co-author"
      },
      {
        label: "No, try again",
        description: "Search for a different person"
      }
    ]
  }]
})
```

**For mob programming, repeat for additional co-authors**.

---

### STEP 5: Create Commit with Proper Format

**Ask for commit message**:

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Describe what you did (brief summary):",
    header: "Commit Message",
    multiSelect: false,
    options: [
      {
        label: "Type custom message",
        description: "I'll provide the commit message"
      }
    ]
  }]
})
```

User will use "Other" to type the message.

**Format commit message according to exec/COMMIT.md**:

**Solo commit (no co-authors)**:
```
[86d0xyz123] Add analytics tracking feature

- Added AccountController for analytics
- Implemented trigger for tracking
- Added comprehensive test coverage

CI: ✅ All checks passed
ClickUp: https://app.clickup.com/t/86d0xyz123
```

**Pair programming commit (one co-author)**:
```
[86d0xyz123] Add analytics tracking feature

- Added AccountController for analytics
- Implemented trigger for tracking
- Added comprehensive test coverage

CI: ✅ All checks passed
ClickUp: https://app.clickup.com/t/86d0xyz123

Co-authored-by: Sidu Ponnappa <sidu@realfast.ai>
```

**Mob programming commit (multiple co-authors)**:
```
[86d0xyz123] Add analytics tracking feature

- Added AccountController for analytics
- Implemented trigger for tracking
- Added comprehensive test coverage

CI: ✅ All checks passed
ClickUp: https://app.clickup.com/t/86d0xyz123

Co-authored-by: Sidu Ponnappa <sidu@realfast.ai>
Co-authored-by: Bharat <bharat@realfast.ai>
```

**If CI was skipped (docs/metadata only)**:
```
[86d0xyz123] Update implementation documentation

- Updated tickets/86d0xyz123/implementation.md
- Added deployment notes

CI: ⏭️ Skipped (documentation changes only)
ClickUp: https://app.clickup.com/t/86d0xyz123
```

**If CI failed but user chose to skip**:
```
[86d0xyz123] WIP: Add analytics tracking

- Added AccountController for analytics
- TODO: Fix failing tests

CI: ❌ Skipped (failures present - needs fixing)
ClickUp: https://app.clickup.com/t/86d0xyz123
```

**CRITICAL commit message formatting rules**:
1. First line: `[ticket-id] Brief summary`
2. Blank line
3. Bulleted details (one per line)
4. Blank line
5. `CI: <status>` line
6. `ClickUp: <url>` line
7. Blank line (REQUIRED before Co-authored-by)
8. `Co-authored-by: Name <email>` (if applicable)
9. NO CLAUDE ADS in commit message

**Show commit preview to user**:
```
I'll create this commit:

───────────────────────────────────────
[86d0xyz123] Add analytics tracking feature

- Added AccountController for analytics
- Implemented trigger for tracking
- Added comprehensive test coverage

CI: ✅ All checks passed
ClickUp: https://app.clickup.com/t/86d0xyz123

Co-authored-by: Sidu Ponnappa <sidu@realfast.ai>
───────────────────────────────────────

Proceed with commit?
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Proceed with this commit?",
    header: "Confirm Commit",
    multiSelect: false,
    options: [
      {
        label: "Yes, commit",
        description: "Create the commit"
      },
      {
        label: "No, edit message",
        description: "Let me change the message"
      },
      {
        label: "Cancel",
        description: "Don't commit"
      }
    ]
  }]
})
```

**Execute commit**:
```bash
git commit -m "$(cat <<'EOF'
[86d0xyz123] Add analytics tracking feature

- Added AccountController for analytics
- Implemented trigger for tracking
- Added comprehensive test coverage

CI: ✅ All checks passed
ClickUp: https://app.clickup.com/t/86d0xyz123

Co-authored-by: Sidu Ponnappa <sidu@realfast.ai>
EOF
)"
```

**After successful commit**:
```
✓ Commit created successfully!

Commit: [86d0xyz123] Add analytics tracking feature
Hash: abc1234
Files: 4 changed
```

---

### STEP 6: Push to Remote

**Check if remote tracking is set up**:
```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
```

**If upstream is set**:
```
Pushing changes to remote server...

Command: git push
```

**If upstream NOT set (first push)**:
```
This is the first push for this branch.

Setting up remote tracking...

Command: git push -u origin [branch-name]
```

**Execute push**:
```bash
git push
# OR
git push -u origin $(git branch --show-current)
```

**If push succeeds**:
```
✓ Pushed to remote successfully!

Your changes are now available to the team.
```

**If push is rejected** (someone else pushed first):
```
⚠️ Push rejected - branch is out of date

Someone else has pushed changes to this branch.
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "The remote branch has new changes. What should I do?",
    header: "Push Rejected",
    multiSelect: false,
    options: [
      {
        label: "Pull and rebase",
        description: "Get latest changes and rebase (recommended)"
      },
      {
        label: "Cancel",
        description: "Don't push, let me check manually"
      }
    ]
  }]
})
```

**If pull and rebase chosen**:
```bash
git pull --rebase
# Then retry push
git push
```

---

### STEP 7: Post Comment to ClickUp Ticket

**If ticket ID exists, ALWAYS post comment** (don't ask):

```
✓ Posting progress update to ClickUp ticket 86d0xyz123...
```

**Get commit details**:
```bash
# Get commit message
git log -1 --pretty=%B

# Get commit hash
git log -1 --pretty=%h

# Get files changed
git diff-tree --no-commit-id --name-status -r HEAD
```

**Format ClickUp comment**:
```
✅ Commit pushed: [86d0xyz123] Add analytics tracking feature

Changes:
- AccountController.cls (modified, +15 -3 lines)
- AccountTrigger.trigger (new file, +50 lines)
- AnalyticsComponentTest.cls (new file, +45 lines)

CI Status: ✅ All checks passed
Commit: abc1234
Branch: clickup-86d0xyz123-analytics

Total: 4 files changed
```

**Post using ClickUp MCP**:
```javascript
mcp__ClickUp__create_task_comment({
  taskId: "86d0xyz123",
  commentText: "[formatted comment above]"
})
```

**Show confirmation**:
```
✓ Progress update posted to ClickUp ticket 86d0xyz123

Your team can see this update in ClickUp.
```

**If posting fails**:
```
⚠️ Could not post to ClickUp

Error: [error details]

Your commit is saved and pushed. Only the ClickUp comment failed.
```

---

### STEP 8: Check Next Action Item

**Check for implementation doc in tickets folder**:
```bash
# Check for implementation doc
ticket_id="86d0xyz123"

if test -f "tickets/$ticket_id/implementation.md"; then
  doc_path="tickets/$ticket_id/implementation.md"
elif test -f "tickets/$ticket_id/spec.md"; then
  doc_path="tickets/$ticket_id/spec.md"
elif test -f "tickets/$ticket_id/plan.md"; then
  doc_path="tickets/$ticket_id/plan.md"
else
  doc_path=""
fi
```

**If implementation doc exists, read it**:
```bash
cat "$doc_path"
```

**Parse for task status**:
- Look for `[ ]` (pending tasks)
- Look for `[x]` (completed tasks)
- Look for `- [ ]` or `* [ ]` variations
- Identify next pending task

**Suggest next task**:
```
✅ Great work! You've completed this task.

Looking at tickets/86d0xyz123/implementation.md, here's what's next:

Next task:
[ ] Write integration tests for analytics module

Would you like to work on this next?
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Would you like to start the next task: 'Write integration tests for analytics module'?",
    header: "Next Task",
    multiSelect: false,
    options: [
      {
        label: "Yes, let's start",
        description: "Help me with the next task"
      },
      {
        label: "Show all tasks",
        description: "Let me see all remaining tasks"
      },
      {
        label: "Take a break",
        description: "I'm done for now"
      }
    ]
  }]
})
```

**If user chooses "Show all tasks"**:
```
Remaining tasks in tickets/86d0xyz123/implementation.md:

[ ] Write integration tests for analytics module
[ ] Add error handling for edge cases
[ ] Update user documentation
[x] Implement core analytics tracking (completed)
[x] Add unit tests (completed)
```

**If implementation doc NOT found**:
```
✓ All done!

No implementation doc found at tickets/86d0xyz123/

You can now:
- Continue working on this branch
- Switch to another task
- Create a pull request
```

---

## Configuration Options

Users can customize behavior by adding `.claude/commit-workflow-config.json`:

```json
{
  "autoAddAll": false,
  "alwaysPush": true,
  "alwaysPostClickUp": true,
  "requireTicketId": true,
  "ciValidation": "always",
  "implementationDocPaths": [
    "tickets/{ticketid}/implementation.md",
    "tickets/{ticketid}/spec.md",
    "tickets/{ticketid}/plan.md"
  ],
  "ciDetection": {
    "enabled": true,
    "apexPatterns": ["*.cls", "*.trigger", "force-app/main/default/classes/**"],
    "lwcPatterns": ["force-app/main/default/lwc/**/*.js", "force-app/main/default/lwc/**/*.html"],
    "metadataPatterns": ["*.xml", "*-meta.xml"],
    "docsPatterns": ["*.md", "docs/**", "tickets/**", "exec/**"]
  }
}
```

---

## Error Handling

### CI Validation Failures

When CI fails, use `AskUserQuestion` to give options:
- Show full output
- Cancel commit (recommended)
- Skip validation (creates commit with "CI: ❌ Skipped" message)

### Push Failures

When push is rejected:
- Offer to pull --rebase (recommended)
- Or cancel for manual intervention

### ClickUp Errors

If ClickUp comment fails:
- Log the error
- Note that commit and push succeeded
- Don't block the workflow

---

## Success Criteria

A successful workflow means:
1. ✅ User selected and verified files
2. ✅ Ticket ID validated via ClickUp API
3. ✅ Appropriate CI validation ran (or skipped for docs/metadata)
4. ✅ Co-authors detected if pair programming
5. ✅ Commit created with proper format including CI status
6. ✅ Changes pushed to remote
7. ✅ ClickUp comment posted
8. ✅ User knows next action from implementation doc

---

## Remember

- **File selection** - Always verify with user
- **Ticket validation** - Always check with ClickUp API
- **CI before commit** - CRITICAL! Only commit if CI passes (or is skipped for docs)
- **Co-author attribution** - Support pair/mob programming properly
- **Commit format** - Follow exec/COMMIT.md format exactly
- **CI status in commit** - Always include CI status line
- **NO CLAUDE ADS** - Never add Claude attribution to commits
- **Blank line before Co-authored-by** - REQUIRED for git to parse correctly
- **Use AskUserQuestion** - For all user interactions
- **Plain language** - Avoid git jargon

**CI Validation Rules** (BEFORE commit):
- Mixed (Apex + LWC) → `npm run ci` (full suite)
- LWC only → `npm run ci:lwc && npm run ci:lint`
- Apex only → `npm run ci:apex && npm run ci:pmd`
- Metadata/Docs only → Skip CI

**Our job**: Make committing a smooth, safe workflow that ensures quality through automated validation and proper team attribution.
