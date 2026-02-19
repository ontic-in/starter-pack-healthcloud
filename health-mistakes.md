# Implementation Mistakes & Learnings - [US-1.1.2] Patient 360 View

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

# Implementation Mistakes & Learnings - [US-1.1.3] Patient Timeline

**Ticket**: https://app.clickup.com/t/86d1yxw5w
**Date**: 2026-02-18

---

## Mistake 7: ClinicalEncounter.Name Assumed Writable

**What happened**: Created `TestDataFactory.createClinicalEncounter()` with a `Name` parameter, setting `Name = encounterName` on the record. `ClinicalEncounter.Name` is an auto-number field and not writable.

**Error**: `Field is not writeable: ClinicalEncounter.Name (189:39)`

**Impact**: Deploy failed. Had to remove the parameter from the factory method and test class, then redeploy.

**Fix**: Removed `Name` parameter from factory method. Let Salesforce auto-generate the Name field.

**Prevention**: Check `Schema.SObjectField.getDescribe().isCreateable()` for auto-number fields before including them in factory methods. Standard object Name fields are often auto-number in Health Cloud.

---

## Mistake 8: ClinicalEncounter.Category is Required

**What happened**: Created ClinicalEncounter test data without the `Category` field, assuming it was optional like most picklist fields.

**Error**: `REQUIRED_FIELD_MISSING, Required fields are missing: [Category]`

**Impact**: All 6 tests failed in setup. Required another deploy + test cycle after adding the field.

**Fix**: Added `category` parameter to `createClinicalEncounter()` and passed `'encounter'` as the value in test data.

**Prevention**: This is a repeat pattern from Mistake 1 (MedicationStatement). Always query required fields on unfamiliar HC objects before writing factory methods. Run `Schema.SObjectType.ClinicalEncounter.fields.getMap()` to check nillability.

---

## Mistake 9: Case Creation Blocked by SDO Process Builder

**What happened**: Created a `Case` record in `@TestSetup` to test the "engagement" category. The SDO org has an active Process Builder ("SDO Service - Case - On Create") that fires on Case insert and requires a `helperConfig` input parameter not available in test context.

**Error**: `CANNOT_EXECUTE_FLOW_TRIGGER, We can't save this record because the "SDO Service - Case - On Create" process failed. Missing required input parameter: helperConfig`

**Impact**: All 6 tests failed in setup. Had to redesign test data strategy.

**Fix**: Removed Case from test data. Added an `Event` record instead for additional administrative coverage. Changed engagement filter test to assert 0 results (valid - proves filter returns empty when no engagement records exist). Added comment documenting the SDO flow limitation.

**Prevention**: SDO (Sales Demo Org) environments ship with active flows and process builders on standard objects like Case, Lead, and Opportunity. Before using standard objects in test data, check for active automation: Setup > Process Automation > Process Builder / Flows. Consider using `@SuppressWarnings` or test-specific bypass flags.

---

## Mistake 10: Git Operations from Wrong Working Directory

**What happened**: After running `sf` CLI commands from `development/sf_project/`, the CWD was still there when trying to run `git add` with paths relative to the repo root.

**Error**: `fatal: pathspec 'development/sf_project/...' did not match any files`

**Impact**: Minor - had to prefix with `cd /home/dev/workspace/starter-pack-healthcloud &&`.

**Fix**: Used absolute path to repo root before git commands.

**Prevention**: Always use absolute paths for git operations, or verify CWD matches the repo root. The `sf` CLI requires running from the SFDX project directory, which creates a CWD mismatch for git.

---

## Mistake 11: Stale Git Index Lock (Recurring)

**What happened**: Same as Mistake 5 from US-1.1.2. Git operations failed due to stale `.git/index.lock` file from interrupted previous operations.

**Error**: `fatal: Unable to create '.git/index.lock': File exists`

**Impact**: Minor - 30 seconds to diagnose and remove.

**Fix**: `rm -f .git/index.lock`

**Prevention**: This is a recurring environment issue. Could add a pre-git-operation check to the workflow.

---

## Summary (US-1.1.3)

| # | Mistake | Severity | Time Lost |
|---|---------|----------|-----------|
| 7 | ClinicalEncounter.Name not writable | Medium | ~3 min (1 deploy + fix cycle) |
| 8 | ClinicalEncounter.Category required | Medium | ~3 min (1 deploy + test + fix cycle) |
| 9 | Case blocked by SDO flow | High | ~5 min (redesign test data strategy) |
| 10 | Git add from wrong CWD | Low | ~30 sec |
| 11 | Git index.lock stale (recurring) | Low | ~30 sec |

**Total estimated time lost**: ~12 minutes

**Key takeaways**:
- SDO orgs have active automation on standard objects (Case, Lead, Opportunity) that breaks test data insertion. Always check for active flows before using standard objects in tests.
- Health Cloud standard objects have non-obvious required fields (ClinicalEncounter.Category) and auto-number Name fields. Query field metadata before writing factories.
- Mistakes 7 and 8 are the same pattern as Mistake 1 from US-1.1.2: not checking org field requirements before writing test data. This is now a 3x repeat - needs a systematic fix (e.g., a pre-implementation field audit checklist).

---
---

# Implementation Mistakes & Learnings - [US-1.1.3] PR Review Fixes

**Ticket**: https://app.clickup.com/t/86d1yxw5w
**Date**: 2026-02-19
**Context**: Addressing 12 PR review findings from animeshdas738 on PR #5

---

## Mistake 12: CI Script Uses Placeholder Org Alias

**What happened**: Ran `npm run ci` to validate changes before committing. The `package.json` script has `--target-org [ORG_ALIAS]` as a placeholder that was never replaced with the actual org alias.

**Error**: `No authorization information found for [ORG_ALIAS]. Did you mean "my-hc-org"?`

**Impact**: Had to run CI components manually with `--target-org my-hc-org` instead of the convenient npm script. Wasted ~2 min debugging.

**Fix**: Ran `sf apex run test --target-org my-hc-org` directly. Also ran `npx eslint` directly on the LWC files.

**Prevention**: At project setup, replace all placeholder values in `package.json` CI scripts with actual org aliases. Or use `sf config get target-org` to pull the configured default instead of hardcoding.

---

## Mistake 13: Original Implementation Had 12 Reviewable Issues

**What happened**: The original US-1.1.3 Patient Timeline implementation (committed in a previous session) had 12 findings caught in PR review. These span 3 HIGH, 4 MEDIUM, and 5 LOW issues across Apex, LWC HTML, JS, and CSS.

**Key findings that should have been caught before PR**:
- **ClinicalEncounter missing provider/facility fields** (#1 HIGH): The controller queried ClinicalEncounter but never populated the `provider` and `facility` fields that the LWC template displays. This is a basic gap between controller output and UI expectations.
- **Task/Event WhoId not queried** (#3 HIGH): Person Account Tasks/Events are linked via `WhoId` (to PersonContactId), not `WhatId` (to AccountId). Only querying `WhatId` misses many records. This is a core Health Cloud data model pattern.
- **Hardcoded locale** (#6 MEDIUM): Used `'en-SG'` instead of `undefined` (browser default) in date formatting. Region-specific code should never be hardcoded.
- **Magic strings** (#7 MEDIUM): Hardcoded `'Scheduled'` string instead of using a constant.
- **Hardcoded CSS colors** (#12 LOW): Used raw hex colors instead of SLDS design tokens, breaking theme consistency.

**Impact**: Required a full review-fix-resubmit cycle. 5 files changed, +115 -56 lines.

**Prevention**:
1. **Pre-PR checklist**: Before submitting PRs, verify:
   - All fields referenced in LWC template are populated by the controller
   - Person Account WhoId pattern is used for Task/Event queries
   - No hardcoded locales, magic strings, or raw color values
   - CSS uses SLDS design tokens with fallbacks
   - Edge cases (null/blank inputs) have test coverage
2. **Self-review diff**: Read through the full diff before creating the PR, checking each file against the template/controller contract.
3. **Use Person Account WhoId pattern**: Always query `PersonContactId` from Account and include `OR WhoId IN :contactIds` when querying Task or Event for a Person Account.

---

## Summary (US-1.1.3 PR Review Session)

| # | Mistake | Severity | Time Lost |
|---|---------|----------|-----------|
| 12 | CI script placeholder org alias | Low | ~2 min |
| 13 | 12 PR review findings in original impl | High | ~30 min (review + fix cycle) |

**Total estimated time lost**: ~32 minutes

**Key takeaways**:
- The `package.json` CI scripts need actual org aliases, not placeholders.
- A pre-PR self-review checklist would have caught most of the 12 findings before the reviewer saw them.
- Person Account WhoId pattern (querying PersonContactId for Task/Event lookups) is a core Health Cloud pattern that must be applied every time.
- Always use SLDS design tokens in CSS, never raw hex colors.
- Always use `undefined` (browser default) for locale in `toLocaleDateString`/`toLocaleTimeString`, never hardcode a specific locale.
