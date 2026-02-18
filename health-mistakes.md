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
