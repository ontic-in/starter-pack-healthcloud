# [PROJECT_NAME] - Realfast Delivery Project

[![PMD Code Quality Check](https://github.com/[ORG_NAME]/[REPO_NAME]/actions/workflows/pmd-check.yml/badge.svg)](https://github.com/[ORG_NAME]/[REPO_NAME]/actions/workflows/pmd-check.yml)

**AI-Driven Platform for [CLIENT_NAME]**

> Structured collaboration between realfast and client teams using ExoWork (realfast's Claude Code SDK solution). All work is organized around ClickUp tickets and follows Extreme Programming (XP) discipline for quality, transparency, and traceability.

## What is [PROJECT_NAME]?

**[PROJECT_NAME] is [ONE_SENTENCE_DESCRIPTION].**

**The Problem**: [DESCRIBE_CLIENT_PROBLEM]

**Solution**:
1. **[SOLUTION_COMPONENT_1]** - [Description]
2. **[SOLUTION_COMPONENT_2]** - [Description]
3. **[SOLUTION_COMPONENT_3]** - [Description]
4. **Quality Assurance** - All code follows strict XP discipline: green builds always, TDD-first development, spec-validated code reviews

**Architecture**: [DESCRIBE_ARCHITECTURE_LAYERS]

---

## Quick Start

**5-minute setup to start developing [PROJECT_NAME] features:**

### Prerequisites

Complete environment setup is critical for productive development. Follow these steps in order:

#### 1. Core Development Tools

**Required:**
- **Node.js** (v18+): [Download](https://nodejs.org/)
  ```bash
  node --version  # Should be v18.0.0 or higher
  ```
- **npm** (comes with Node.js): Package manager
  ```bash
  npm --version
  ```
- **Git**: Version control
  ```bash
  git --version
  ```
- **ExoWork (Claude Code)**: AI development assistant
  - Install from: [Claude Code Documentation](https://docs.claude.com/claude-code)

#### 2. Code Quality Tools

**PMD (Static Analysis for Apex/Java)**:
```bash
# Download PMD 7.17.0
cd ~/tools
wget https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.17.0/pmd-dist-7.17.0-bin.zip
unzip pmd-dist-7.17.0-bin.zip

# Add to PATH (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/tools/pmd-bin-7.17.0/bin:$PATH"

# Verify installation
pmd --version
```

**ESLint & Prettier** (via npm):
```bash
# Will be installed with project dependencies
npm install  # Installs eslint, prettier, and all dev dependencies
```

#### 3. Salesforce CLI (if Salesforce project)

```bash
# Install Salesforce CLI
npm install -g @salesforce/cli

# Verify installation
sf --version

# Authenticate with org (replace [SF_ORG_ALIAS] with your alias)
sf org login web --alias [SF_ORG_ALIAS] --instance-url https://test.salesforce.com
```

#### 4. Project Dependencies

```bash
# From project root
npm install

# Install husky git hooks
npm run prepare

# Verify all scripts available
npm run  # Lists all available scripts
```

#### 5. Playwright (for E2E testing)

```bash
# Install Playwright browsers
npx playwright install

# Verify installation
npx playwright --version
```

#### 6. MCP Integrations

**ClickUp MCP:**
1. Get API key: ClickUp Settings → Apps → API
2. Follow setup guide: `learn/mcp/CLICKUP_MCP_SETUP.md`
3. Test: Ask Claude Code "List my ClickUp spaces"

**Slack MCP:**
1. Get bot token from Slack workspace admin
2. Follow setup guide: `learn/mcp/SLACK_MCP_SETUP.md`
3. Use Team ID: 9016365878, Channel: C08V3EPT8LD
4. Test: Ask Claude Code "Read latest Slack messages"

**Perplexity MCP (Optional):**
1. Get API key from Perplexity
2. Follow setup guide: `learn/mcp/PERPLEXITY_MCP_SETUP.md`

#### 7. Learn-Run Repository

```bash
# Clone learn-run repository (one level up from project)
cd ..
git clone git@github.com:ontic-in/learn-run.git

# Return to project and create symlinks
cd [REPO_NAME]
ln -s ../learn-run/learn learn
ln -s ../learn-run/run run

# Set up Claude Code agents
mkdir -p .claude
ln -s ../../learn-run/agents .claude/agents

# Verify symlinks
ls -la learn run .claude/agents  # Should show symlinks
```

#### 8. Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit .env and add your credentials
# Required variables (adjust for your project):
# - ANTHROPIC_API_KEY=your_key_here
# - CLICKUP_API_KEY=your_key_here
# - SALESFORCE_USERNAME=your_username (if applicable)
# - SALESFORCE_PASSWORD=your_password (if applicable)
# [Add project-specific variables]
```

#### 9. Claude Code Settings

```bash
# Create Claude Code local settings
cat > .claude/settings.local.json << 'SETTINGS_EOF'
{
  "includeCoAuthoredBy": false
}
SETTINGS_EOF
```

#### 10. Verification

**Verify complete setup:**
```bash
# Check all tools installed
node --version
npm --version
git --version
pmd --version  # If using PMD
sf --version   # If Salesforce project
npx playwright --version

# Check project dependencies
npm list --depth=0

# Run CI locally to verify everything works
npm run ci

# Expected: All checks pass ✅
```

**Verify integrations:**
```bash
# In Claude Code, test each integration:
# "List my ClickUp spaces"  # Should list your ClickUp workspaces
# "Read latest Slack messages"  # Should show recent Slack messages
# "Query [ENTITY] from [SYSTEM]"  # If applicable
```

#### Troubleshooting

**PMD not found:**
```bash
# Add PMD to PATH
export PATH="$HOME/tools/pmd-bin-7.17.0/bin:$PATH"
echo 'export PATH="$HOME/tools/pmd-bin-7.17.0/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**npm install fails:**
```bash
# Clear cache and retry
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

**Salesforce auth fails:**
```bash
# Use web authentication (more reliable)
sf org login web --alias [SF_ORG_ALIAS]
# Browser will open for authentication
```

**Symlinks broken:**
```bash
# Ensure learn-run is at correct location
cd ..
ls -la  # Should see both learn-run/ and [your-project]/

# Recreate symlinks
cd [your-project]
rm learn run
ln -s ../learn-run/learn learn
ln -s ../learn-run/run run
```

**Claude Code integrations not working:**
```bash
# Check MCP server configuration
# Settings → MCP Servers → Verify all servers configured
# Re-run setup guides in learn/mcp/ if needed
```

**[ADD PROJECT-SPECIFIC AUTHENTICATION INSTRUCTIONS]**

```bash
# Example: Salesforce authentication
sf org login web --alias [SF_ORG_ALIAS] --instance-url https://test.salesforce.com

# Verify connection
sf org list | grep [SF_ORG_ALIAS]
```

### 1. Prompt Library & MCP Setup

```bash
# Clone shared prompt library
cd ..
git clone git@github.com:ontic-in/learn-run.git

# From project repo root:
cd [REPO_NAME]
ln -s ../learn-run/learn learn
ln -s ../learn-run/run run
mkdir -p .claude
ln -s ../../learn-run/agents .claude/agents

# Configure Claude Code settings
cat > .claude/settings.local.json << 'EOF'
{
  "includeCoAuthoredBy": false
}
EOF
```

### 2. Set Up ClickUp & Slack Integration

Follow these setup guides in order (in `learn/mcp/`):
- **ClickUp**: Get API key from Settings → Apps → API, then follow `learn/mcp/CLICKUP_MCP_SETUP.md`
- **Slack**: Create bot token, then follow `learn/mcp/SLACK_MCP_SETUP.md` (Team ID: 9016365878, Channel: C08V3EPT8LD)

### 3. Test Complete Setup

```bash
# Verify ClickUp access
# In Claude Code, ask: "List my available ClickUp spaces"

# Verify Slack connection
# In Claude Code, ask: "Read latest messages from Slack"

# Verify authentication (if applicable)
# In Claude Code, ask: "Query [ENTITY] records from [SYSTEM]"
```

---

## For AI Agents: First-Time Setup & Task Entry Points

**You are an AI agent (Claude Code) picking up a ticket. Start here.**

### 0. Verify Authentication (REQUIRED FIRST)

Before doing ANY work, verify your authentication is configured.

**Why this matters**: All work requires proper authentication to run tests, deploy code, and verify green builds. No connection = no work can be completed.

### 1. Understand the Architecture (2 minutes)

[PROJECT_NAME] has [NUMBER] independent layers that must work together:

| Layer | File | What It Does | You Need To Know |
|-------|------|--------------|------------------|
| **[LAYER_1]** | `[FILE_PATH]` | [DESCRIPTION] | [KEY_INFO] |
| **[LAYER_2]** | `[FILE_PATH]` | [DESCRIPTION] | [KEY_INFO] |
| **[LAYER_3]** | `[FILE_PATH]` | [DESCRIPTION] | [KEY_INFO] |

**Critical**: A bug in ANY layer breaks the whole flow.

### 2. Understand the Workflow

```
[USER_ACTION]
        ↓
[LAYER_1_PROCESS]
        ↓
[LAYER_2_PROCESS]
        ↓
[LAYER_3_PROCESS]
        ↓
[VALIDATION]
```

**Your job as developer**: Ensure ALL pieces work together. Don't assume one layer is done - verify the end-to-end flow.

### 3. Pick Up a Ticket: Exact Steps

When Claude Code asks you to work on a ticket:

```bash
# Step 1: Read the ticket description (ClickUp)
# Step 2: Check which layer(s) are affected
# Step 3: Navigate to the right file
# Step 4: Check existing test cases (qa/ folder)
# Step 5: Create or update tests FIRST (RED phase of TDD)
# Step 6: Read this README's "Development Workflows" section
```

### 4. Critical Constraint: Never Skip Green Build

```bash
# BEFORE committing ANYTHING:
npm run ci  # This must pass

# If it fails:
# - Fix the error (don't commit red builds)
# - Run npm run ci again
# - Only commit when green
```

**Why**: Red builds block the entire team. One broken commit breaks CI for everyone. XP discipline demands we keep the build green always.

---

## Development Workflows

[ADD PROJECT-SPECIFIC DEVELOPMENT WORKFLOWS HERE]

---

## Working with Tickets

**REQUIRED: Every task MUST have a ClickUp ticket**

### Workflow Pattern

1. Create ClickUp ticket in [PROJECT_NAME] project
2. Create branch: `git checkout -b clickup-{ticket-id}-ticket-name`
3. Create ticket folders in `tickets/` (convention):
   ```bash
   mkdir -p tickets/{ticket-id}-ticket-name
   ```
4. Store QA test cases in `qa/{ticket-id}-ticket-name/` if needed
5. All ticket-related work lives in `tickets/` directory (analysis, notes, test evidence, docs)
6. Commit with ticket ID: `git commit -m "[{ticket-id}] description"`

**Important Naming Convention**:
- Folder names MUST include both ticket ID and a brief descriptive name
- Ticket work belongs in `tickets/`, NOT `docs/`
- This expresses intent and makes navigation easy without consulting ClickUp

---

## Repository Structure

```
[REPO_NAME]/
├── requirements/                    # Source-of-truth: SOW, transcripts, worksheets
├── designs/                         # Architecture/UX design artifacts
├── development/                     # Implementation code
│   ├── [PROJECT_SPECIFIC_DIR]/      # Project-specific code
│   └── [SUBDIRS]/                   # Additional development directories
├── docs/
│   ├── analysis/                    # Bug RCA, accountability investigations
│   ├── brds/                        # Business Requirements Documents
│   ├── personas/                    # Team personas
│   └── deployment_components/       # Production deployment history
├── qa/                              # QA test cases and validation
├── exec/                            # Project-specific prompts & tools (use these)
├── learn@ -> ../learn-run/learn     # Shared learning prompts & MCP docs
├── run@ -> ../learn-run/run         # Shared executable prompts
├── .claude/
│   ├── agents@ -> ../../learn-run/agents
│   └── settings.local.json
└── README.md                        # This file
```

---

## Resource Links

### Project Management
- **ClickUp Project**: [CLICKUP_PROJECT_URL]
- **Shared Team ID**: 9016365878
- **Slack Channel**: #exo-agent-collab (Channel ID: C08V3EPT8LD)

### Setup Guides (in `learn/mcp/`)
- **ClickUp MCP**: `learn/mcp/CLICKUP_MCP_SETUP.md`
- **Slack MCP**: `learn/mcp/SLACK_MCP_SETUP.md`
- **Perplexity MCP**: `learn/mcp/PERPLEXITY_MCP_SETUP.md`

### Key Documentation
- **Confidence Scoring Guides**: `docs/CONFIDENCE_SCORING_GUIDE_*.md`
- **Architecture Guides**: `docs/*_ARCHITECTURE_GUIDE.md`

---

## XP Discipline & Green Build

**NEVER commit on a red build. NEVER push red builds to origin.**

### Commit Workflow

```bash
# Before EVERY commit:
npm run ci  # Run ALL checks locally first

# If ANY check fails:
# - Fix it immediately
# - Run npm run ci again
# - Only commit when green

# Commit message format
git commit -m "[ticket-id] Brief description

Detailed explanation of changes.

ClickUp: https://app.clickup.com/t/ticket-id"
```

### Key XP Principles

- **TDD (Test-Driven Development)**: Write RED test first, watch it fail, implement GREEN, refactor
- **Pair Programming**: Use `exec/COMMIT.md` for co-authored commits with proper attribution
- **Continuous Integration**: Green builds always. One broken commit blocks the entire team
- **Spec-First**: Compare implementation against BRD requirements in code review

---

## Getting Help

### For Humans
- **Claude Code Help**: Use `/help` in Claude Code
- **Directory Navigation**: `tree -L 2 docs/` or `tree -L 1 learn/`
- **Find Specific Docs**: `grep -r "topic" docs/ learn/`
- **Recent Work**: `ls -lt docs/analysis/*.md | head -5`
- **Slack Channel**: Post questions in #exo-agent-collab

### For AI Agents
- **Start Here**: Read "For AI Agents" section (above) for exact entry point and workflow
- **Common Patterns**: `learn/` directory contains guides for typical workflows
- **Executable Prompts**: `run/` directory contains prompts you can execute directly
- **Latest Analysis**: Check `docs/analysis/` for recent bug investigations and solutions

---

## Philosophy: Why We Do Things This Way

[PROJECT_NAME] follows **Extreme Programming (XP)** discipline to prevent data loss bugs and maintain code quality.

### XP Principles We Follow

1. **TDD (Test-Driven Development)**
   - Write RED test first that fails
   - Implement GREEN to make it pass
   - REFACTOR to clean up
   - **Why**: The test documents the requirement. A passing test proves the code meets the spec.

2. **Pair Programming**
   - Co-authored commits with explicit attribution
   - Knowledge sharing, faster code review
   - **Why**: Two heads catch bugs the first head missed

3. **Green Build Discipline**
   - NEVER commit red builds
   - One broken commit blocks everyone
   - **Why**: Broken CI is team bankruptcy

4. **Spec-Validated Code Review**
   - Compare implementation against BRD requirements
   - Verify field mappings are complete
   - Count required fields vs implemented fields
   - **Why**: Code quality ≠ spec completeness

5. **Continuous Integration**
   - Small, frequent commits
   - Automated checks on every commit
   - **Why**: Early detection is cheaper than late detection

---

**Ready to get started? See "Quick Start" section above or "For AI Agents" if you're picking up a ticket.**
