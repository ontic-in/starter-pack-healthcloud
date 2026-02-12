# Salesforce Metadata Query Guide

## Purpose

This guide provides commands and patterns for fetching various metadata information from Salesforce orgs. Use this when you need to discover what exists in an org, validate configurations, or understand the org structure.

**Target Users**: Developers who need to inspect Salesforce metadata without manually navigating Setup.

## Prerequisites

- Authenticated Salesforce org (run `sf org list` to verify)
- Salesforce CLI installed
- Target org alias (e.g., `SimDev`, `SimProd`)

If authentication needed, use `@exec/AUTHENTICATE_SF_ORG.md`

---

## Common Metadata Queries

### 1. Prompt Templates (GenAiPromptTemplate)

**List all prompt templates:**
```bash
sf project retrieve start --metadata GenAiPromptTemplate --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "GenAiPromptTemplate") | .fullName' | sort
```

**Example:**
```bash
sf project retrieve start --metadata GenAiPromptTemplate --target-org SimDev --json | jq -r '.result.files[] | select(.type == "GenAiPromptTemplate") | .fullName' | sort
```

**Output:**
```
Alumni_Careers_Persona_Knowledge_Based_Response
SIM_Knowledge_Retriever_With_History_Context
SIM_Web_Crawler_With_History_Context_V1
...
```

**Use when:**
- Validating prompt template API names for tests
- Checking if a prompt exists before deploying
- Finding all prompts with specific naming patterns

---

### 2. Agentforce Topics (GenAiPlugin)

**List all Agentforce topics:**
```bash
sf project retrieve start --metadata GenAiPlugin --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "GenAiPlugin") | .fullName' | sort
```

**Filter by name pattern:**
```bash
sf project retrieve start --metadata GenAiPlugin --target-org SimDev --json | jq -r '.result.files[] | select(.type == "GenAiPlugin" and (.fullName | contains("Student"))) | .fullName'
```

**Use when:**
- Checking which topics are configured in the bot
- Validating topic names before creating actions
- Auditing bot capabilities

---

### 3. Agentforce Actions (GenAiFunction)

**List all Agentforce actions:**
```bash
sf project retrieve start --metadata GenAiFunction --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "GenAiFunction") | .fullName' | sort
```

**Get action count:**
```bash
sf project retrieve start --metadata GenAiFunction --target-org SimDev --json | jq -r '.result.files[] | select(.type == "GenAiFunction") | .fullName' | wc -l
```

**Use when:**
- Verifying action deployment
- Checking action naming conventions
- Finding actions by name pattern

---

### 4. Apex Classes

**List all Apex classes:**
```bash
sf project retrieve start --metadata ApexClass --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "ApexClass") | .fullName' | sort
```

**Find specific class pattern:**
```bash
sf project retrieve start --metadata ApexClass --target-org SimDev --json | jq -r '.result.files[] | select(.type == "ApexClass" and (.fullName | contains("Test"))) | .fullName'
```

**Count classes:**
```bash
sf project retrieve start --metadata ApexClass --target-org SimDev --json | jq -r '.result.files[] | select(.type == "ApexClass") | .fullName' | wc -l
```

**Use when:**
- Checking if a class exists before deploying
- Finding test classes
- Auditing code coverage targets

---

### 5. Lightning Web Components (LWC)

**List all LWC components:**
```bash
sf project retrieve start --metadata LightningComponentBundle --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "LightningComponentBundle") | .fullName' | sort
```

**Find specific component:**
```bash
sf project retrieve start --metadata LightningComponentBundle --target-org SimDev --json | jq -r '.result.files[] | select(.type == "LightningComponentBundle" and (.fullName == "simPreChatForm")) | .fullName'
```

**Use when:**
- Verifying LWC deployment
- Checking component names for embedded service
- Finding form components

---

### 6. Flows

**List all flows:**
```bash
sf project retrieve start --metadata Flow --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "Flow") | .fullName' | sort
```

**Find active flows only:**
```bash
sf data query --query "SELECT DeveloperName, Label, ProcessType, Status FROM FlowDefinitionView WHERE IsActive = true" --target-org <OrgAlias> --result-format json | jq -r '.result.records[] | .DeveloperName'
```

**Use when:**
- Checking if a flow is deployed
- Finding flows by naming convention
- Auditing active vs inactive flows

---

### 7. Custom Objects

**List all custom objects:**
```bash
sf project retrieve start --metadata CustomObject --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "CustomObject") | .fullName' | sort
```

**Find specific object pattern:**
```bash
sf project retrieve start --metadata CustomObject --target-org SimDev --json | jq -r '.result.files[] | select(.type == "CustomObject" and (.fullName | endswith("__c"))) | .fullName'
```

**Use when:**
- Checking if custom object exists
- Finding all custom objects (ending with __c)
- Validating object deployment

---

### 8. Permission Sets

**List all permission sets:**
```bash
sf project retrieve start --metadata PermissionSet --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "PermissionSet") | .fullName' | sort
```

**Query permission set details:**
```bash
sf data query --query "SELECT Id, Name, Label, Description FROM PermissionSet WHERE IsCustom = true" --target-org <OrgAlias> --result-format json
```

**Use when:**
- Checking permission set names
- Validating guest user permissions
- Auditing security setup

---

### 9. Static Resources

**List all static resources:**
```bash
sf project retrieve start --metadata StaticResource --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "StaticResource") | .fullName' | sort
```

**Query static resource details:**
```bash
sf data query --query "SELECT Name, ContentType, BodyLength FROM StaticResource" --target-org <OrgAlias> --result-format json
```

**Use when:**
- Checking if images/files are deployed
- Finding static resources by name
- Validating file uploads

---

### 10. Profiles

**List all profiles:**
```bash
sf project retrieve start --metadata Profile --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "Profile") | .fullName' | sort
```

**Query profile details:**
```bash
sf data query --query "SELECT Id, Name, UserType FROM Profile WHERE Name LIKE '%Guest%'" --target-org <OrgAlias> --result-format json
```

**Use when:**
- Finding guest user profiles
- Checking profile names for sites
- Auditing profile configurations

---

### 11. Bots (Bot)

**List all bots:**
```bash
sf project retrieve start --metadata Bot --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "Bot") | .fullName' | sort
```

**Query bot versions:**
```bash
sf data query --query "SELECT Id, VersionNumber, Status FROM BotVersion LIMIT 10" --target-org <OrgAlias> --result-format json
```

**Use when:**
- Checking bot deployment
- Finding bot version numbers
- Validating bot configuration

---

### 12. Knowledge Articles (KnowledgeArticleVersion)

**Query knowledge articles:**
```bash
sf data query --query "SELECT Id, Title, ArticleNumber, PublishStatus FROM Knowledge__kav WHERE PublishStatus = 'Online' LIMIT 10" --target-org <OrgAlias> --result-format json
```

**Count online articles:**
```bash
sf data query --query "SELECT COUNT() FROM Knowledge__kav WHERE PublishStatus = 'Online'" --target-org <OrgAlias> --result-format json | jq '.result.totalSize'
```

**Use when:**
- Checking knowledge base content
- Validating article count
- Finding articles by title pattern

---

### 13. Sites (ExperienceBundle)

**List all Experience Cloud sites:**
```bash
sf project retrieve start --metadata ExperienceBundle --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "ExperienceBundle") | .fullName' | sort
```

**Query site details:**
```bash
sf data query --query "SELECT Id, Name, Status, UrlPathPrefix FROM Site" --target-org <OrgAlias> --result-format json
```

**Use when:**
- Checking site deployment
- Finding site URLs
- Validating guest user access

---

### 14. Custom Metadata Types

**List all custom metadata types:**
```bash
sf project retrieve start --metadata CustomMetadata --target-org <OrgAlias> --json | jq -r '.result.files[] | select(.type == "CustomMetadata") | .fullName' | sort
```

**Query custom metadata records:**
```bash
sf data query --query "SELECT DeveloperName, MasterLabel FROM <CustomMetadataType>__mdt" --target-org <OrgAlias> --result-format json
```

**Use when:**
- Checking configuration records
- Validating metadata deployment
- Finding custom metadata by name

---

### 15. Queues

**Query queues:**
```bash
sf data query --query "SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue'" --target-org <OrgAlias> --result-format json
```

**Find specific queue:**
```bash
sf data query --query "SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName LIKE '%Agent%'" --target-org SimDev --result-format json
```

**Use when:**
- Checking if queue exists
- Finding queue IDs for configuration
- Validating queue assignments

---

## Advanced Patterns

### Retrieve Multiple Metadata Types at Once

```bash
sf project retrieve start \
  --metadata GenAiPromptTemplate \
  --metadata GenAiPlugin \
  --metadata GenAiFunction \
  --target-org SimDev \
  --json | jq -r '.result.files[] | "\(.type): \(.fullName)"' | sort
```

### Count All Metadata by Type

```bash
sf project retrieve start --metadata GenAiPromptTemplate --target-org SimDev --json | jq -r '.result.files | group_by(.type) | .[] | "\(.[0].type): \(length)"'
```

### Find Metadata Modified Recently (requires local files)

```bash
find force-app/main/default/genAiPromptTemplates -name "*.xml" -mtime -7 -exec basename {} \; | sed 's/.genAiPromptTemplate-meta.xml//'
```

### Check if Specific Metadata Exists

```bash
sf project retrieve start --metadata GenAiPromptTemplate:SIM_Knowledge_Retriever_With_History_Context --target-org SimDev --json | jq -r '.result.files[] | select(.fullName == "SIM_Knowledge_Retriever_With_History_Context") | "EXISTS: \(.fullName)"'
```

---

## Troubleshooting

### Error: "Missing metadata type definition in registry"

**Problem:** The metadata type is not supported by Salesforce CLI retrieve command.

**Solution:** Use SOQL queries instead:
```bash
sf data query --query "SELECT <fields> FROM <Object>" --target-org SimDev --result-format json
```

### Error: "sObject type is not supported"

**Problem:** The object cannot be queried via SOQL.

**Solution:** Try metadata retrieval:
```bash
sf project retrieve start --metadata <MetadataType> --target-org SimDev --json
```

### Error: "does not contain a valid Salesforce DX project"

**Problem:** Running retrieve command from wrong directory.

**Solution:** Navigate to Salesforce project directory:
```bash
cd /Users/aniket/realfast/SIM/development/SIM_SF_project
```

### Slow Retrieval Performance

**Problem:** Retrieving all metadata types takes too long.

**Solution:** Retrieve specific items only:
```bash
sf project retrieve start --metadata GenAiPromptTemplate:PromptName --target-org SimDev --json
```

---

## Best Practices

1. **Always use --json flag** for programmatic parsing with jq
2. **Use --target-org** explicitly instead of relying on default org
3. **Store results in temp files** for large retrievals to avoid re-fetching
4. **Use jq for filtering** instead of grep when possible (better JSON handling)
5. **Sort output** for consistent, readable results
6. **Check authentication first** before running queries (`sf org list`)
7. **Use concise flags** to minimize output (`--concise` for deploy/test commands)

---

## Common Use Cases

### Use Case 1: Validate Test File API Names

**Scenario:** Test file references a prompt, need to verify it exists in org.

**Commands:**
```bash
# Step 1: Get prompt name from test file
PROMPT_NAME=$(grep "PROMPT_TEMPLATE_ID" tests/prompt/MyTest.test.ts | cut -d"'" -f2)

# Step 2: Check if exists in org
sf project retrieve start --metadata GenAiPromptTemplate --target-org SimDev --json | jq -r --arg name "$PROMPT_NAME" '.result.files[] | select(.fullName == $name) | "✅ EXISTS: \(.fullName)"'
```

### Use Case 2: Compare Metadata Between Orgs

**Scenario:** Check if SimDev and SimProd have the same prompts.

**Commands:**
```bash
# Get SimDev prompts
sf project retrieve start --metadata GenAiPromptTemplate --target-org SimDev --json | jq -r '.result.files[].fullName' | sort > /tmp/simdev_prompts.txt

# Get SimProd prompts
sf project retrieve start --metadata GenAiPromptTemplate --target-org SimProd --json | jq -r '.result.files[].fullName' | sort > /tmp/simprod_prompts.txt

# Compare
diff /tmp/simdev_prompts.txt /tmp/simprod_prompts.txt
```

### Use Case 3: Find All Test Classes

**Scenario:** Need to run all test classes matching a pattern.

**Commands:**
```bash
sf project retrieve start --metadata ApexClass --target-org SimDev --json | jq -r '.result.files[] | select(.type == "ApexClass" and (.fullName | endswith("Test"))) | .fullName'
```

### Use Case 4: Audit Bot Configuration

**Scenario:** Get complete bot setup overview.

**Commands:**
```bash
echo "=== Prompts ===" && \
sf project retrieve start --metadata GenAiPromptTemplate --target-org SimDev --json | jq -r '.result.files[].fullName' | wc -l && \
echo "=== Topics ===" && \
sf project retrieve start --metadata GenAiPlugin --target-org SimDev --json | jq -r '.result.files[].fullName' | wc -l && \
echo "=== Actions ===" && \
sf project retrieve start --metadata GenAiFunction --target-org SimDev --json | jq -r '.result.files[].fullName' | wc -l
```

---

## Quick Reference Card

| What You Want | Command Pattern |
|---------------|----------------|
| List prompts | `sf project retrieve start --metadata GenAiPromptTemplate --target-org <Org> --json \| jq -r '.result.files[].fullName'` |
| List topics | `sf project retrieve start --metadata GenAiPlugin --target-org <Org> --json \| jq -r '.result.files[].fullName'` |
| List actions | `sf project retrieve start --metadata GenAiFunction --target-org <Org> --json \| jq -r '.result.files[].fullName'` |
| List Apex classes | `sf project retrieve start --metadata ApexClass --target-org <Org> --json \| jq -r '.result.files[].fullName'` |
| List LWC components | `sf project retrieve start --metadata LightningComponentBundle --target-org <Org> --json \| jq -r '.result.files[].fullName'` |
| Count metadata | `sf project retrieve start --metadata <Type> --target-org <Org> --json \| jq '.result.files \| length'` |
| Check if exists | `sf project retrieve start --metadata <Type>:<Name> --target-org <Org> --json \| jq -r '.result.files[]'` |

---

## Related Documentation

- `@exec/AUTHENTICATE_SF_ORG.md` - Authenticate to Salesforce orgs
- `@learn/USE_SF_CLI.md` - Salesforce CLI best practices
- `@exec/SF_DEPLOY.md` - Deploy metadata to orgs

---

## Remember

- **Metadata retrieval** = structure/configuration (Classes, Prompts, Flows)
- **SOQL queries** = data/records (Leads, Accounts, Knowledge Articles)
- Use retrieve for "what's configured", use query for "what data exists"
- Always check authentication status before running metadata commands
- Use `--json` for parsing, avoid parsing human-readable output
