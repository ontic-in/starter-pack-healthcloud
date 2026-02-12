# Deployment Documentation Review Prompt

## Purpose
This prompt reviews ticket-specific deployment documentation and generates clean, production-ready deployment sections for `docs/deployment_components/deployment_components_to_prod.md`.

## Context
When completing a ticket, developers create deployment documentation at `tickets/{ticketId}/clickup_{ticketId}_deployment.md`. This prompt transforms that documentation into a clean format suitable for the production deployment registry, eliminating redundancy and improving readability.

---

## Review Instructions

You are reviewing deployment documentation for production deployment. Your goal is to create a clean, scannable deployment section that eliminates redundancy while maintaining all critical information.

### Input
- Ticket-specific deployment doc at: `tickets/{ticketId}/clickup_{ticketId}_deployment.md`
- Production deployment registry at: `docs/deployment_components/deployment_components_to_prod.md`

### Output Requirements

Generate a clean deployment section following this structure:

```markdown
# Deployment Components: {ticketId} - {Brief Title}

**Ticket:** https://app.clickup.com/t/{ticketId}

---

## Pre-Deployment

### Components Being Deployed

| Type | Component Name | Description |
|------|---------------|-------------|
| {Type} | {ComponentName} | {Brief description} |

### Dependencies

**NEW Dependencies** (must be created/configured for this deployment):

**[ACTION]** Dependency description
- Additional context if needed

**EXISTING Dependencies** (verify these already exist):

**[VERIFY]** Dependency that should already be present
- Reference to previous deployment if applicable

---

## Package.xml Components

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <!-- Component types here -->
    <version>62.0</version>
</Package>
```

---

## Post-Deployment

### Manual Configuration Steps

**[ACTION]** Step description
- Concise bullet points only
- Avoid verbose UI navigation

### Verification Steps

**[VERIFY]** What to verify:
```bash
# Command or query
```

**Expected Result:** Brief description

### Notes

**Critical Information:**
- Key decisions or rationale
- Non-obvious configuration details
- Known limitations

---
```

---

## Review Criteria

### 1. Dependency Deduplication

**Rule:** If a dependency was deployed in a previous ticket, mark it as **EXISTING** and reference the previous deployment.

**Example:**

❌ **BAD** (Repeating dependencies every time):
```markdown
**[VERIFY]** Lead object exists in target org (standard object)
**[VERIFY]** Guest user profile has Lead creation permissions
**[CONFIGURE]** Permission Set MessagingSession_Fields_Access
```

✅ **GOOD** (Deduplicate and reference):
```markdown
**EXISTING Dependencies** (verify these already exist):

**[VERIFY]** Lead object and Guest user permissions (deployed in 86d0ffk2g)
**[VERIFY]** Permission Set MessagingSession_Fields_Access (deployed in 86d0ffk2t)

**NEW Dependencies** (must be created for this deployment):

**[CREATE]** Custom field Lead.New_Field__c
**[CONFIGURE]** Flow trigger on Lead object
```

**How to identify duplicates:**

**Step 1: Search for Common Dependencies**

Use these grep commands to find existing dependencies:

```bash
# Search for Lead object dependencies
grep -n "Lead object" docs/deployment_components/deployment_components_to_prod.md

# Search for Guest User Profile
grep -n "Guest user profile\|Guest User Profile" docs/deployment_components/deployment_components_to_prod.md

# Search for Permission Sets
grep -n "Permission Set\|PermissionSet" docs/deployment_components/deployment_components_to_prod.md

# Search for Embedded Service
grep -n "Embedded Service" docs/deployment_components/deployment_components_to_prod.md

# Search for specific fields (example)
grep -n "Lead.User_Type__c\|MessagingSession.LeadId" docs/deployment_components/deployment_components_to_prod.md
```

**Step 2: Identify Ticket Reference**

When you find a match, note the ticket ID from the section header:
```markdown
# Deployment Components: 86d0ffk2g - Explorer Form Flow
```

**Step 3: Mark as EXISTING with Reference**

```markdown
**EXISTING Dependencies** (verify these already exist):

**[VERIFY]** Lead object and Guest user permissions (deployed in 86d0ffk2g)
**[VERIFY]** Permission Set MessagingSession_Fields_Access (deployed in 86d0ffk2t)
```

**Common Dependencies to Search For:**
- Lead object permissions (Create, Read, Edit)
- Guest User Profile configuration
- Permission Sets (MessagingSession_Fields_Access, Lead_Access_to_Service_Agent)
- Custom fields on Lead/MessagingSession
- Embedded Service Deployment configuration
- Data Cloud configuration
- Einstein GenAI components
- Salesforce Knowledge setup
- Lead assignment rules/queues

---

### 2. Remove Rollback Instructions

**Rule:** Rollback steps are NOT needed in production deployment registry.

❌ **BAD** (Including rollback):
```markdown
### Rollback Plan

If issues occur after deployment:

**Step 1: Rollback Flow Changes**
1. Open SIM_Agent_Router flow in Flow Builder
2. Click on Update_MessagingSession element
3. Remove LeadId field assignment
...
```

✅ **GOOD** (Omit rollback section entirely):
```markdown
### Notes

**Deployment completed:** 2025-01-15
**Deployed by:** DevOps Team
```

---

### 3. Simplify Manual Configuration Steps

**Rule:** Provide concise action-oriented steps. Avoid verbose UI navigation.

❌ **BAD** (Overly verbose):
```markdown
**[CONFIGURE]** Update Embedded Service Deployment Pre-Chat Settings:
1. In Salesforce Setup, Quick Find: "Embedded Service Deployments"
2. Click **Embedded Service Deployments** under Digital Experiences
3. Click on **SimTest** deployment name (or your deployment name)
4. Click **Edit** button
5. In the left sidebar, click **Pre-Chat** section
6. Scroll to **Pre-Chat Fields** or **Custom Variables** section
7. Find the **Lead** field in the available fields list
8. Click the checkbox or toggle to mark **Lead** as **Visible**
...
```

✅ **GOOD** (Concise and actionable):
```markdown
**[CONFIGURE]** Embedded Service Deployment: SimTest
- Navigate to: Setup → Embedded Service Deployments → SimTest → Edit
- Pre-Chat section: Mark "Lead" field as Visible
- Save and Publish
```

---

### 4. Consolidate Verification Steps

**Rule:** Group related verifications. Avoid repeating the same verification pattern for every component.

❌ **BAD** (Repetitive verification):
```markdown
**[VERIFY]** Flow deployed and active:
```bash
sf data query -q "SELECT MasterLabel, Status FROM Flow WHERE DeveloperName = 'Flow1'" -o TargetOrg
```

**[VERIFY]** Flow 2 deployed and active:
```bash
sf data query -q "SELECT MasterLabel, Status FROM Flow WHERE DeveloperName = 'Flow2'" -o TargetOrg
```

**[VERIFY]** Flow 3 deployed and active:
```bash
sf data query -q "SELECT MasterLabel, Status FROM Flow WHERE DeveloperName = 'Flow3'" -o TargetOrg
```
```

✅ **GOOD** (Consolidated verification):
```markdown
**[VERIFY]** All flows deployed and active:
```bash
sf data query -q "SELECT MasterLabel, Status FROM Flow WHERE DeveloperName IN ('Flow1', 'Flow2', 'Flow3')" -o TargetOrg
```

**Expected Result:** All flows show Status = 'Active'
```

---

### 5. Remove Code Implementation Details

**Rule:** Focus on WHAT is deployed, not HOW it was implemented.

❌ **BAD** (Including code snippets):
```markdown
### Code Changes Summary

**File:** `force-app/main/default/lwc/simPreChatForm/simPreChatForm.js`

**Change 1 - Add leadId property (line 64):**
```javascript
// Lead ID storage (86d0nnn23)
leadId = null;
```

**Change 2 - Store Lead ID from Prospect creation (line 312):**
```javascript
this.leadId = result.leadId;
console.log("Lead created successfully with ID:", result.leadId);
```
```

✅ **GOOD** (High-level summary):
```markdown
### Notes

**Component Changes:**
- simPreChatForm: Added Lead ID capture and pass-through to messaging session
- MessagingChannel: Configured custom parameter for Lead ID
- Router Flow: Added Lead input variable and MessagingSession update

**Integration Flow:** Pre-Chat Form → Messaging Channel → Router Flow → MessagingSession.LeadId
```

---

### 6. Eliminate Redundant Sections

**Rule:** If a section doesn't add value for deployment, remove it.

**Remove these sections:**
- ❌ Rollback Plan
- ❌ Timeline (development timeline not needed for deployment)
- ❌ Bug Discovery Process
- ❌ Key Learning
- ❌ Future Improvements
- ❌ Git Commits (detailed commit history)
- ❌ Troubleshooting (unless truly deployment-specific)

**Keep these sections:**
- ✅ Pre-Deployment (components + dependencies)
- ✅ Package.xml Components
- ✅ Post-Deployment (config steps + verification)
- ✅ Notes (critical deployment info only)

---

## Readability Issues to Fix

When reviewing `deployment_components_to_prod.md`, identify and eliminate these issues:

### Issue 1: Duplicate Dependencies
**Problem:** Same dependencies repeated across 8+ deployments
**Fix:** Reference previous deployments, only list NEW dependencies

### Issue 2: Verbose Rollback Instructions
**Problem:** 50+ lines of rollback steps per deployment
**Fix:** Remove rollback sections entirely

### Issue 3: Excessive Manual Config Detail
**Problem:** 30+ step UI navigation instructions
**Fix:** Consolidate to 3-5 bullet points

### Issue 4: Repetitive Verification Queries
**Problem:** Same query pattern repeated for every component
**Fix:** Consolidate into single queries with IN clauses

### Issue 5: Code Implementation Details
**Problem:** Full code diffs and line-by-line changes
**Fix:** Replace with high-level component change summaries

### Issue 6: Mixed Development Notes
**Problem:** Development timeline, bug discovery, git commits
**Fix:** Remove development artifacts, keep only deployment-critical info

### Issue 7: No Quick Reference
**Problem:** Can't scan quickly to see what's been deployed
**Fix:** Add component summary table at top of document

---

## Output Format

After reviewing the ticket deployment doc, provide:

1. **Clean Deployment Section** - Ready to append to `deployment_components_to_prod.md`
2. **Dependency Analysis** - List of NEW vs EXISTING dependencies
3. **Readability Improvements** - What was simplified/removed and why

---

## Example Transformation

### Before (Ticket Doc):

```markdown
# Deployment Components: 86d0xyz - Feature Name

## Pre-Deployment

### Dependencies

**[VERIFY]** Lead object exists in target org (standard object)
**[VERIFY]** Guest user profile has Lead creation permissions
**[VERIFY]** Permission Set MessagingSession_Fields_Access exists
**[CONFIGURE]** Embedded Service Deployment settings
**[CREATE]** Custom field Lead.NewField__c

## Post-Deployment

### Manual Configuration Steps

**[CONFIGURE]** Guest User Profile Permissions:
1. Navigate to: Setup → Sites → [Your Site Name]
2. Click on your Embedded Service site
3. Click **Public Access Settings** button
4. This opens the Guest User Profile associated with your site
5. Scroll to **Standard Object Permissions** section
6. Find **Lead** object
7. Enable the following permissions:
   - ✓ **Read** - Required to query Lead data
   - ✓ **Create** - Required to insert new Lead records
8. Click **Save**

### Rollback Plan

If issues occur:
1. Navigate to: Setup → Sites → Public Access Settings
2. Remove **Create** permission from Lead object
3. Alternative: Disable chatbot widget temporarily on website
```

### After (Production Registry):

```markdown
# Deployment Components: 86d0xyz - Feature Name

**Ticket:** https://app.clickup.com/t/86d0xyz

---

## Pre-Deployment

### Components Being Deployed

| Type | Component Name | Description |
|------|---------------|-------------|
| CustomField | Lead.NewField__c | New field for feature tracking |

### Dependencies

**EXISTING Dependencies** (verify these already exist):

**[VERIFY]** Lead object and Guest user permissions (deployed in 86d0ffk2g)
**[VERIFY]** Permission Set MessagingSession_Fields_Access (deployed in 86d0ffk2t)
**[VERIFY]** Embedded Service Deployment configured (deployed in 86d0ffj9x)

**NEW Dependencies** (must be created for this deployment):

**[CREATE]** Custom field Lead.NewField__c (Type: Text, Length: 100)

---

## Package.xml Components

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>Lead.NewField__c</members>
        <name>CustomField</name>
    </types>
    <version>62.0</version>
</Package>
```

---

## Post-Deployment

### Manual Configuration Steps

**[CONFIGURE]** Guest User Profile Permissions:
- Setup → Sites → Public Access Settings
- Grant Lead object: Read + Create permissions
- Save changes

### Verification Steps

**[VERIFY]** Custom field deployed:
```bash
sf data query -q "SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'Lead' AND QualifiedApiName = 'NewField__c'" -o TargetOrg
```

**Expected Result:** Field returned with correct API name

### Notes

**Field Purpose:** Tracks feature-specific data for Lead records created via chatbot

---
```

---

---

## Action Tag Standardization

Use these action tags consistently:

| Tag | When to Use | Example |
|-----|------------|---------|
| **[CREATE]** | New component/object that must be created | `[CREATE]` Custom field Lead.NewField__c |
| **[CONFIGURE]** | Existing component that needs configuration | `[CONFIGURE]` Embedded Service Deployment settings |
| **[VERIFY]** | Dependency that should already exist | `[VERIFY]` Lead object permissions (deployed in 86d0xyz) |
| **[ACTIVATE]** | Component that needs activation after deployment | `[ACTIVATE]` Flow: SIM_Agent_Router |
| **[ASSIGN]** | Permission/access that needs assignment | `[ASSIGN]` Permission Set to service agent users |

---

## Workflow: Step-by-Step Review Process

Follow this workflow when reviewing a ticket deployment doc:

### Step 1: Read Ticket Deployment Doc
```bash
# Navigate to ticket directory
cd tickets/{ticketId}/

# Read the deployment doc
cat clickup_{ticketId}_deployment.md
```

### Step 2: Extract Components List
- Identify all components in "Components Being Deployed" table
- Note component types (ApexClass, Flow, CustomField, etc.)
- List all dependencies mentioned

### Step 3: Search for Duplicate Dependencies

Run dependency search commands:
```bash
# Example: Search for Lead-related dependencies
grep -n "Lead object\|Lead\..*__c\|Lead permissions" docs/deployment_components/deployment_components_to_prod.md

# Example: Search for Permission Sets
grep -n "MessagingSession_Fields_Access\|Lead_Access_to_Service_Agent" docs/deployment_components/deployment_components_to_prod.md
```

Record findings:
- **Ticket 86d0xyz, Line 450**: Lead object permissions configured
- **Ticket 86d0abc, Line 750**: Permission Set MessagingSession_Fields_Access deployed

### Step 4: Categorize Dependencies

**NEW Dependencies** (truly new for this deployment):
- Components not found in previous deployments
- New custom fields, new Apex classes, new flows

**EXISTING Dependencies** (already deployed):
- Components found in previous deployments
- Include ticket reference: `(deployed in 86d0xyz)`

### Step 5: Apply Review Criteria

Checklist:
- [ ] Deduplicated dependencies with ticket references
- [ ] Removed rollback section
- [ ] Simplified manual config steps (max 5 bullet points each)
- [ ] Consolidated verification queries
- [ ] Removed code implementation details
- [ ] Removed development artifacts (timeline, bug discovery, git commits)
- [ ] Used standard action tags ([CREATE], [VERIFY], [CONFIGURE], etc.)

### Step 6: Generate Clean Section

Follow the output format exactly:
1. Section header with ticket ID and brief title
2. Pre-Deployment (Components table + Dependencies)
3. Package.xml
4. Post-Deployment (Config + Verification + Notes)

### Step 7: Validate Output Quality

Run quality checklist (see below)

---

## Quality Checklist

Before submitting the clean deployment section, verify:

### Structure ✅
- [ ] Section follows 4-part structure (Pre-Deployment, Package.xml, Post-Deployment, Notes)
- [ ] Components table includes Type, Name, Description columns
- [ ] Dependencies clearly separated into NEW vs EXISTING
- [ ] All EXISTING dependencies have ticket references

### Content ✅
- [ ] No rollback section included
- [ ] Manual config steps are 3-5 bullet points max per step
- [ ] Verification queries are consolidated (no repetitive patterns)
- [ ] No code snippets or line-by-line diffs
- [ ] No development artifacts (timeline, bug process, git commits, troubleshooting)

### Accuracy ✅
- [ ] All components from ticket doc are included in components table
- [ ] Package.xml includes all deployed metadata types
- [ ] Dependencies accurately reflect what's NEW vs EXISTING
- [ ] Verification steps match the components being deployed

### Readability ✅
- [ ] Action tags used correctly ([CREATE], [VERIFY], [CONFIGURE], [ACTIVATE], [ASSIGN])
- [ ] Concise language (no verbose UI navigation)
- [ ] Scannable format (bullet points, tables, code blocks)
- [ ] Clear expected results for verification steps

### Completeness ✅
- [ ] All critical deployment information included
- [ ] No information gaps that would block deployment execution
- [ ] Notes section includes rationale for non-obvious decisions
- [ ] Known limitations documented if applicable

---

## Edge Case Handling

### Edge Case 1: Ticket Deployment Doc Doesn't Exist

**Issue:** No deployment doc found at `tickets/{ticketId}/clickup_{ticketId}_deployment.md`

**Action:**
1. Check if deployment is needed by reviewing ticket description
2. If Salesforce metadata changes exist, create minimal deployment section:
```markdown
# Deployment Components: {ticketId} - {Title}

**Ticket:** https://app.clickup.com/t/{ticketId}

**Note:** No deployment documentation provided. Review git changes to determine components.

**Action Required:** Developer must create deployment doc before production deployment.
```

### Edge Case 2: Unclear Dependencies

**Issue:** Ticket doc lists dependencies but unclear if NEW or EXISTING

**Action:**
1. Search deployment registry thoroughly
2. If unsure, mark as **[VERIFY]** with note:
```markdown
**[VERIFY]** Component X (check if deployed in previous ticket - not found in search)
```

### Edge Case 3: Massive Deployment (50+ Components)

**Issue:** Too many components to list individually

**Action:**
1. Group by type in components table:
```markdown
| Type | Component Count | Description |
|------|----------------|-------------|
| ApexClass | 15 classes | Domain objects and controllers |
| GenAiPromptTemplate | 10 templates | Persona-based knowledge responses |
```

2. Use wildcard in package.xml verification:
```bash
sf data query -q "SELECT MasterLabel, Status FROM GenAiPromptTemplate WHERE DeveloperName LIKE 'SIM%'" -o TargetOrg
```

### Edge Case 4: No NEW Dependencies

**Issue:** All dependencies already exist from previous deployments

**Action:**
```markdown
### Dependencies

**EXISTING Dependencies** (verify these already exist):

**[VERIFY]** All dependencies previously deployed (see 86d0xyz, 86d0abc)

**NEW Dependencies:** None - this deployment uses only existing infrastructure
```

---

## Usage Summary

When reviewing a ticket deployment doc:

1. **Read the ticket doc** at `tickets/{ticketId}/clickup_{ticketId}_deployment.md`
2. **Search deployment registry** for duplicate dependencies (use grep commands above)
3. **Categorize dependencies** into NEW vs EXISTING with ticket references
4. **Apply all 6 review criteria** (deduplication, remove rollback, simplify config, consolidate verification, remove code, remove artifacts)
5. **Generate clean section** following output format and action tag standards
6. **Run quality checklist** to validate completeness
7. **Provide dependency analysis** (list of NEW vs EXISTING with line references)
8. **Explain simplifications** (what was removed/simplified and why)

The result should be a deployment section that:
- ✅ Is scannable and easy to execute (5-minute read max)
- ✅ References previous deployments for existing dependencies
- ✅ Contains only deployment-critical information
- ✅ Uses concise action-oriented language (3-5 bullets per step)
- ✅ Groups related verification steps (consolidated queries)
- ✅ Omits rollback, development timeline, and code details
- ✅ Uses standardized action tags consistently
- ✅ Passes all quality checklist items
