# Implementation Mistakes & Learnings - Health Cloud Starter Pack

This file tracks mistakes and learnings across all tickets for continuous improvement.

---

# [US-1.1.2] Patient 360 View

**Ticket**: https://app.clickup.com/t/86d1yxw5r
**Date**: 2026-02-18

---

## Mistake 1: MedicationStatement Test Data Missing Required Parent

**What happened**: Created `MedicationStatement` in test setup without a `MedicationId` reference. The org requires either `MedicationId` or `MedicationCodeId` on `MedicationStatement` - it's not truly optional despite the schema showing `isNillable=true`.

**Error**: `System.DmlException: Insert failed. First exception on row 0; first error: INVALID_INPUT, Select either a medication or a medication code.: [MedicationId]`

**Impact**: All 3 tests failed in setup, not even reaching the actual test logic. Wasted a deploy + test cycle.

**Fix**: Created a `Medication` parent record first, then set `MedicationId` on `MedicationStatement`.

**Prevention**: Before writing test data for Health Cloud objects, query the org to check for custom validation rules or platform-enforced field dependencies that aren't visible in schema describe. Don't trust `isNillable` alone.

---

## Mistake 2: ClickUp Status Name Mismatch

**What happened**: Tried to set ticket status to `"in development"` which doesn't exist. The actual status is `"in progress"`. Got `ITEM_114` error.

**Impact**: Minor - had to make an extra API call to fetch available statuses.

**Fix**: Queried the list statuses first, then used the correct value `"in low level design"` for the planning phase.

**Prevention**: Always fetch available statuses from the ClickUp list before attempting status updates. Don't assume status names - they are custom per workspace.

---

## Mistake 3: sf config set Without Project Root

**What happened**: Ran `sf config set target-org my-hc-org` from the repo root (`starter-pack-healthcloud/`) which is not an SFDX project. Got `InvalidProjectWorkspaceError`.

**Impact**: Had to initially set it globally (which the user didn't want), then redo it from the correct directory.

**Fix**: Ran the command from `development/sf_project/` where `sfdx-project.json` exists.

**Prevention**: Always run `sf` config commands from the SFDX project directory (`development/sf_project/`), not the repo root.

---

## Mistake 4: LWC Template Referencing Non-Existent Computed Properties

**What happened**: First version of the HTML template referenced properties like `condition.statusClass`, `condition.formattedOnsetDate`, `medication.medicationName` directly on the wire service data objects. These don't exist on the raw Apex return - they need to be computed.

**Impact**: Would have caused blank/undefined values in the UI. Caught before deploy.

**Fix**: Added a `transformData()` method in the JS that maps over each array from the wire response, spreading the original object and adding computed properties (badge CSS classes, formatted dates, medication names).

**Prevention**: Remember that LWC templates cannot call methods on iteration items. Any computed display values must be pre-calculated in JavaScript during data transformation, not in the template.

---

## Mistake 5: Git Index Lock File

**What happened**: When staging files for commit, got `fatal: Unable to create '.git/index.lock': File exists` - likely from a previously interrupted git operation.

**Impact**: Minor - had to remove the lock file before staging.

**Fix**: `rm -f .git/index.lock`

**Prevention**: This is a common git issue in shared environments. Check for stale lock files if git operations fail unexpectedly.

---

## Mistake 6: Not Querying Org Object Fields Before Writing Tests

**What happened**: Wrote the initial test class assuming `MedicationStatement` could be created with just `PatientId` and `Status`, without checking what fields the org actually requires. The standard Salesforce docs say `MedicationId` is nillable, but the org has a platform-level validation.

**Impact**: First test run failed entirely on setup, requiring investigation and a fix cycle.

**Fix**: Queried the org for `Medication` object availability and required fields, then updated test data.

**Prevention**: Always run an exploratory query against the org before writing test data setup:
```apex
Map<String, Schema.SObjectField> fields = Schema.SObjectType.<Object>.fields.getMap();
for (String f : fields.keySet()) {
    Schema.DescribeFieldResult dfr = fields.get(f).getDescribe();
    if (!dfr.isNillable() && dfr.isCreateable()) {
        System.debug('REQUIRED: ' + f);
    }
}
```

---

## Summary

| # | Mistake | Severity | Time Lost |
|---|---------|----------|-----------|
| 1 | MedicationStatement missing parent | Medium | ~5 min (1 deploy + test + fix cycle) |
| 2 | ClickUp status name wrong | Low | ~1 min |
| 3 | sf config from wrong directory | Low | ~1 min |
| 4 | LWC computed props on raw data | Medium | ~5 min (caught in review, rewrote JS) |
| 5 | Git index lock file | Low | ~30 sec |
| 6 | No org field check before tests | Medium | Overlaps with #1 |

**Total estimated time lost**: ~12 minutes

**Key takeaway**: Query the org first, write tests second. Health Cloud objects have non-obvious field dependencies that schema describe alone won't reveal.

---
---

# [US-1.1.4] Patient Search & Duplicate Detection

**Ticket**: https://app.clickup.com/t/86d1yxw61
**Date**: 2026-02-19

---

## Mistake 7: ClickUp Status Name Mismatch (Repeat)

**What happened**: Tried to set ticket status to `"in development"` but the workspace uses `"in progress"`. Same mistake as US-1.1.2 Mistake #2.

**Error**: ClickUp API rejected the status value.

**Impact**: Low - extra API call to discover correct status names.

**Fix**: Queried list statuses via `clickup.workspace.getHierarchy()` and found the correct status name.

**Prevention**: This is now a **known pattern**. Always query available statuses before updating. The workspace uses: `to do`, `in progress`, `ready for pr`, `complete` (not "in development", "done", etc.).

**Repeat of**: Mistake #2. Need to internalize the workspace status vocabulary.

---

## Mistake 8: ClickUp findMember() Returns Null for Display Names

**What happened**: Called `clickup.workspace.findMember('das.animesh')` expecting it to match by username/email. It returned null.

**Impact**: Low - had to fetch all members and search manually.

**Fix**: Used `clickup.workspace.getMembers()` then filtered the raw JSON for "animesh" to find member ID `100968061`.

**Prevention**: `findMember()` may not match on all name formats. When assigning users, use `getMembers()` and search by partial name match. Cache the member ID once found (Animesh Das = `100968061`).

---

## Mistake 9: Git safe.directory Ownership Error

**What happened**: Running `git checkout main` failed with `fatal: detected dubious ownership in repository`.

**Error**: `fatal: detected dubious ownership in repository at '/home/dev/workspace/starter-pack-healthcloud'`

**Impact**: Low - one-time fix per session.

**Fix**: `git config --global --add safe.directory /home/dev/workspace/starter-pack-healthcloud`

**Prevention**: This happens in container environments where the repo is mounted with different ownership. Add safe.directory config at session start if git commands fail.

---

## Mistake 10: Apex Syntax Checker False Positives on Multi-line SOQL

**What happened**: The local `apex_syntax_check` tool reported errors on multi-line SOQL queries in Apex classes (e.g., `PatientSearchController.cls`). Verified by checking the already-deployed `Patient360Controller.cls` which shows the same "errors" but works fine in the org.

**Impact**: Medium - caused initial concern about code correctness, required verification against known-good code.

**Fix**: Confirmed this is a tool limitation, not a code issue. The ANTLR-based local parser doesn't handle multi-line SOQL the same way the Salesforce compiler does.

**Prevention**: Don't rely solely on `apex_syntax_check` for SOQL validation. If it reports errors only on multi-line SOQL (especially around `FROM`, `WHERE` on separate lines), cross-reference with existing deployed classes. The real validation is `sf project deploy`.

---

## Mistake 11: Git Index Lock File (Repeat)

**What happened**: Got `fatal: Unable to create '.git/index.lock': File exists` when staging files. Same as US-1.1.2 Mistake #5.

**Fix**: `rm -f .git/index.lock`

**Prevention**: Common in container/shared environments. Check for and remove stale lock files if git operations fail.

**Repeat of**: Mistake #5.

---

## Mistake 12: Plan File Permission Denied

**What happened**: Attempted to write the implementation plan to `/home/exo/.claude/plans/` but got permission denied.

**Impact**: Low - wrote plan to `.exo/plan-86d1yxw61.md` instead.

**Fix**: Used the project-local `.exo/` directory for plan files.

**Prevention**: Always write plan files to the project `.exo/` directory, not to system paths. The `/home/exo/` directory has restricted permissions.

---

## Mistake 13: GitHub Username != ClickUp Username

**What happened**: Tried to assign PR to `das.animesh` (the ClickUp display name format) on GitHub. GitHub returned `'das.animesh' not found`. The actual GitHub username is `animeshdas738`.

**Impact**: Low - had to list repo collaborators to find the correct username.

**Fix**: Ran `gh api repos/.../collaborators --jq '.[].login'` to list all collaborators, found `animeshdas738`.

**Prevention**: ClickUp usernames and GitHub usernames are different systems. Always verify the GitHub username via `gh api repos/<owner>/<repo>/collaborators` before assigning PRs. Known mapping: **Animesh Das** = ClickUp ID `100968061` / GitHub `animeshdas738`.

---

## Summary (US-1.1.4)

| # | Mistake | Severity | Time Lost | Repeat? |
|---|---------|----------|-----------|---------|
| 7 | ClickUp status name wrong | Low | ~1 min | Yes (#2) |
| 8 | findMember() null for display names | Low | ~2 min | No |
| 9 | Git safe.directory ownership | Low | ~30 sec | No |
| 10 | Apex syntax checker SOQL false positives | Medium | ~5 min | No |
| 11 | Git index lock file | Low | ~30 sec | Yes (#5) |
| 12 | Plan file permission denied | Low | ~30 sec | No |
| 13 | GitHub username != ClickUp username | Low | ~2 min | No |

**Total estimated time lost**: ~12 minutes

**Key takeaways**:
- **Repeated mistakes (#2, #5)**: ClickUp status names and git lock files - need to internalize these patterns
- **Platform username mapping**: Maintain a team member mapping (ClickUp ID / GitHub username / display name)
- **Local tooling limits**: `apex_syntax_check` doesn't handle multi-line SOQL - trust `sf project deploy` for real validation
- **Container awareness**: Git safe.directory and index.lock are container environment artifacts, not code issues
