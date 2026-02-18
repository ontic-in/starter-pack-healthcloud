# Ticket Implementation Workflow

**Project**: 
 Cloud
**Last Updated**: 2026-02-17

---

## Prerequisites

**Branch**: Use `clickup-<ticketId>` or `clickup-<parentTicketId>` for subtasks
**Working Directory**: Run sf commands from `development/sf_project/`

---

## Standard Workflow for Each Ticket

### Step 0: Check Dependencies
- Review ticket description for dependencies (e.g., "Depends on US-3.5")
- Verify dependent tickets are complete before starting
- Check if required objects exist: `ls force-app/main/default/objects/`

### Step 1: Start Ticket
1. **Add ClickUp comment** - Post "Starting [ticket name]" with acceptance criteria
2. **Update status** - Set ticket to "In Progress"

### Step 2: Create Ticket Directory
```
tickets/<ticketId>/implementation.md
```

**Implementation.md structure:**
- Ticket link and branch
- Acceptance criteria checklist
- Implementation plan with phases
- Key learnings to apply
- Progress tracking table

### Step 3: Create Detailed Todos
Follow `exec/TODOS_CONDITIONER_DOCS.md`:
- Investigate first (check existing objects/code)
- Create fine-grained, sequenced todos
- Include verification steps
- Tag with appropriate personas

### Step 4: Check Specifications
**Custom Objects**: `docs/user-stories/custom-objects/<ObjectName>.md`
- Contains complete field definitions
- Validation rules
- Page layout structure
- Relationships

### Step 5: Check Org for Existing Components
Before creating anything, verify what already exists in the target org:

```bash
# Check if object exists in org
sf org list metadata --metadata-type CustomObject | grep <ObjectName>

# Check if specific fields exist
sf org list metadata --metadata-type CustomField | grep <ObjectName>

# Check if permission set exists
sf org list metadata --metadata-type PermissionSet | grep <PermSetName>

# Check if tab exists
sf org list metadata --metadata-type CustomTab | grep <ObjectName>
```

**If components already exist**: Document what exists and skip creating those.
**If components do NOT exist**: Present a creation plan to the user listing all components to be created, and proceed only after user approval.

### Step 6: Implement
**Order of creation:**
1. Object definition (.object-meta.xml)
2. Custom fields
3. Validation rules
4. Permission set (include tabSettings!)
5. Custom tab
6. Page layout
7. Apex test class

**Key learnings to apply:**
- Percent fields: validation checks sum = 1 (decimal)
- Include tabSettings in permission sets for App Launcher visibility
- Manual UI test first for complex field behaviors

### Step 6: Deploy & Test

**IMPORTANT**: Run commands from `development/sf_project/` directory

```bash
# Deploy object/fields
sf project deploy start --source-dir force-app/main/default/objects/<Object> --target-org healthcloud --wait 10

# Deploy tab, permission set, layout
sf project deploy start --source-dir force-app/main/default/tabs/<Object>.tab-meta.xml \
  --source-dir force-app/main/default/permissionsets/<Name>.permissionset-meta.xml \
  --target-org healthcloud --wait 10

# Assign permission set
sf org assign permset --name <PermissionSetName>
# Run tests
sf apex run test --class-names <TestClass> --target-org healthcloud --wait 10 --result-format human
```

- All Apex tests must pass (100%)
- Manual verification in UI
- If complex field behavior (Percent, Currency), test in UI first before debugging code

### Step 7: Update Documentation
**docs/analysis/DECISIONS_GOTCHAS.md:**
- User decisions made
- Technical gotchas encountered
- Learnings for future

**docs/analysis/TESTING_TRACKER.md:**
- Test results
- Manual testing status

### Step 8: Commit
Follow `exec/COMMIT.md` format.

**Pairing check**: Ask if solo or pairing before commit.

**Format**:
```
[<ticketId>] Brief description

- Bullet point changes
- Another change

CI: ✅ Apex tests passed
ClickUp: https://app.clickup.com/t/<ticketId>
```

**If pairing**, add co-author:
```
Co-authored-by: Name <email@example.com>
```

### Step 9: Complete Ticket
1. Push to remote
2. Post completion comment on ClickUp
3. Update ticket status to "Complete"

---

## Output Format Standards

### Deployment Summary
Use clean box format for completion summaries:

```
┌────────────────────────────────────────────────────────────────────┐
│                         DEPLOYMENT SUMMARY                          │
├────────────────────────────────────────────────────────────────────┤
│  Ticket: <ticketId>                                                │
│  Status: Complete                                                  │
└────────────────────────────────────────────────────────────────────┘

DEPLOYED COMPONENTS:
├── Object + Fields (count)
├── Controller + Tests
└── Supporting (Tab, Layout, Permission Set)

TEST RESULTS:
├── Tests: X/X Passed (100%)
└── Coverage: XX%

FILES UPDATED:
├── tickets/<ticketId>/implementation.md
├── docs/analysis/DECISIONS_GOTCHAS.md
└── docs/analysis/TESTING_TRACKER.md
```

### Commit Summary
```
┌────────────────────────────────────────────────────────────────────┐
│                         COMMIT COMPLETE                             │
├────────────────────────────────────────────────────────────────────┤
│  Commit: <hash>                                                    │
│  Branch: <branch>                                                  │
│  Status: Clean                                                     │
└────────────────────────────────────────────────────────────────────┘

COMMITTED:
├── X files changed
├── +X lines added
└── Message: [ticketId] Brief description
```

### Key Principles
- Simple boxes with clean borders
- Tree structure (├── └──) for hierarchy
- No emojis unless explicitly requested
- Concise, scannable information

---

## Quick Reference

| Step | Action | File/Tool |
|------|--------|-----------|
| 1 | Start | ClickUp comment |
| 2 | Plan | tickets/<id>/implementation.md |
| 3 | Todos | exec/TODOS_CONDITIONER_DOCS.md |
| 4 | Spec | docs/user-stories/custom-objects/ |
| 5 | Build | force-app/main/default/ |
| 6 | Test | sf apex run test |
| 7 | Docs | docs/analysis/ |
| 8 | Commit | exec/COMMIT.md |
| 9 | Done | ClickUp status |

---

## Directory Structure

```
tickets/
└── <ticketId>/
    └── implementation.md

docs/
├── user-stories/
│   └── custom-objects/
│       └── <Object>.md
└── analysis/
    ├── DECISIONS_GOTCHAS.md
    ├── TESTING_TRACKER.md
    └── IMPLEMENTATION_TRACKER.md

development/sf_project/force-app/main/default/
├── objects/<Object>/
│   ├── <Object>.object-meta.xml
│   ├── fields/
│   └── validationRules/
├── classes/
├── permissionsets/
├── tabs/
└── layouts/
```

---

## Checklist Template

```markdown
## Pre-Implementation
- [ ] Dependencies checked (required tickets complete)
- [ ] ClickUp comment posted
- [ ] Ticket directory created (tickets/<ticketId>/implementation.md)
- [ ] Todos created
- [ ] Spec reviewed (docs/user-stories/custom-objects/)

## Implementation
- [ ] Object created
- [ ] Fields created
- [ ] Validation rules created
- [ ] Permission set (with tabSettings!)
- [ ] Custom tab
- [ ] Page layout
- [ ] Apex tests

## Deployment
- [ ] Object deployed
- [ ] Permission set assigned
- [ ] Tests passing (100%)
- [ ] Manual UI verification done

## Post-Implementation
- [ ] docs/analysis/DECISIONS_GOTCHAS.md updated
- [ ] docs/analysis/TESTING_TRACKER.md updated
- [ ] Committed with proper format (exec/COMMIT.md)
- [ ] Pushed to remote
- [ ] ClickUp comment posted
- [ ] ClickUp status updated to complete
```

---

## Common Commands Reference

```bash
# Check existing objects
ls development/sf_project/force-app/main/default/objects/

# Deploy from sf_project directory
cd development/sf_project
sf project deploy start --source-dir <path> --target-org healthcloud --wait 10

# Assign permission set
sf org assign permset --name <Name>
# Run specific test class
sf apex run test --class-names <TestClass> --target-org healthcloud --wait 10 --result-format human

# Run all tests
sf apex run test --target-org healthcloud --wait 10

# Check git status
git status

# Commit with format
git commit -m "[<ticketId>] Description"

# Push
git push
```
