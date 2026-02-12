# New Project Setup Checklist

After creating a repository from this template, complete these steps to customize for your project.

## Phase 1: Update Placeholders

### 1.1 README.md
- [ ] Replace `[PROJECT_NAME]` with actual project name
- [ ] Replace `[REPO_NAME]` with repository name
- [ ] Replace `[ORG_NAME]` with GitHub organization name
- [ ] Replace `[CLIENT_NAME]` with client name
- [ ] Replace `[ONE_SENTENCE_DESCRIPTION]` with project description
- [ ] Replace `[DESCRIBE_CLIENT_PROBLEM]` with problem statement
- [ ] Update `[SOLUTION_COMPONENT_1/2/3]` with actual solution components
- [ ] Replace `[DESCRIBE_ARCHITECTURE_LAYERS]` with architecture description
- [ ] Update `[CLICKUP_PROJECT_URL]` with project ClickUp URL
- [ ] Replace `[SF_ORG_ALIAS]` with Salesforce org alias (if applicable)
- [ ] Update authentication instructions for your specific tech stack
- [ ] Fill in architecture table with actual layers
- [ ] Add project-specific development workflows

### 1.2 package.json
- [ ] Update `name` field with project name
- [ ] Update `description` field
- [ ] Update `author` field
- [ ] Update `keywords` array
- [ ] Review and remove unused dependencies
- [ ] Update `ci:*` scripts if needed for your tech stack

### 1.3 Workflows
Search and replace in `.github/workflows/`:
- [ ] Update `[SF_ORG_ALIAS]` in workflows (if Salesforce project)
- [ ] Review workflow triggers (branches, paths)
- [ ] Update workflow names if needed
- [ ] Verify all workflow paths match your project structure

### 1.4 Scripts
Review `scripts/` directory:
- [ ] Update any hardcoded project names
- [ ] Verify script paths match your project structure
- [ ] Test scripts locally before relying on CI

---

## Phase 2: GitHub Repository Configuration

### 2.1 Repository Settings
- [ ] Enable GitHub Actions in Settings → Actions → General
- [ ] Set Actions permissions to "Allow all actions and reusable workflows"
- [ ] Enable "Read and write permissions" for GITHUB_TOKEN
- [ ] Set repository visibility (public/private) as needed

### 2.2 Branch Protection Rules
Configure for `main` branch in Settings → Branches:
- [ ] Require pull request reviews (recommended: 1 approval)
- [ ] Require status checks to pass before merging
- [ ] Enable required status checks:
  - [ ] PMD Code Quality Check (if applicable)
  - [ ] Apex Code Review (if applicable)
  - [ ] LWC Code Review (if applicable)
  - [ ] Prompt Template Review (if applicable)
- [ ] Require branches to be up to date before merging
- [ ] Include administrators in restrictions

### 2.3 Repository Secrets
Add in Settings → Secrets and variables → Actions:
- [ ] `ANTHROPIC_API_KEY` - For Claude Code integration
- [ ] [Add project-specific secrets here]

### 2.4 Collaborators
- [ ] Add team members with appropriate permissions
- [ ] Configure CODEOWNERS file if needed

---

## Phase 3: Local Development Setup

### 3.1 Clone and Initialize
```bash
# Clone repository
git clone git@github.com:[ORG_NAME]/[REPO_NAME].git
cd [REPO_NAME]

# Install dependencies
npm install
```

### 3.2 Set Up learn-run Symlinks
```bash
# Clone learn-run repo (if not already cloned)
cd ..
git clone git@github.com:ontic-in/learn-run.git

# Create symlinks
cd [REPO_NAME]
ln -s ../learn-run/learn learn
ln -s ../learn-run/run run
mkdir -p .claude
ln -s ../../learn-run/agents .claude/agents
```

### 3.3 Claude Code Configuration
```bash
# Create local settings
cat > .claude/settings.local.json << 'EOF'
{
  "includeCoAuthoredBy": false
}
EOF
```

### 3.4 Environment Variables
```bash
# Copy example env file
cp .env.example .env

# Edit .env and add your credentials
# [LIST REQUIRED ENVIRONMENT VARIABLES]
```

---

## Phase 4: Integration Setup

### 4.1 ClickUp Integration
1. Get ClickUp API key: Settings → Apps → API
2. Follow `learn/mcp/CLICKUP_MCP_SETUP.md`
3. Create project in ClickUp (Team ID: 9016365878)
4. Update `[CLICKUP_PROJECT_URL]` in README with your project URL

### 4.2 Slack Integration
1. Follow `learn/mcp/SLACK_MCP_SETUP.md`
2. Use Channel ID: C08V3EPT8LD (#exo-agent-collab)
3. Team ID: 9016365878
4. Test: Ask Claude Code "Read latest messages from Slack"

### 4.3 Perplexity Integration (Optional)
1. Follow `learn/mcp/PERPLEXITY_MCP_SETUP.md`
2. Test: Ask Claude Code "Search for [topic] using Perplexity"

### 4.4 Project-Specific Authentication
**[ADD PROJECT-SPECIFIC AUTH SETUP INSTRUCTIONS]**

Examples:
- Salesforce: `sf org login web --alias [ALIAS]`
- AWS: Configure AWS credentials
- Database: Set up connection strings

---

## Phase 5: Verify Setup

### 5.1 Test CI Locally
```bash
# Run full CI suite
npm run ci

# Expected: All checks pass ✅
# If any fail, fix before committing
```

### 5.2 Test Integrations
In Claude Code, test each integration:
```
"List my available ClickUp spaces"
"Read latest messages from Slack"
"Query [ENTITY] from [SYSTEM]" (if applicable)
```

### 5.3 Create Test Commit
```bash
# Create a test branch
git checkout -b test-setup

# Make a trivial change (add comment to README)
echo "<!-- Setup verified -->" >> README.md

# Commit with proper format
git add README.md
git commit -m "[setup] Verify template setup complete

Tested:
- Local CI passes
- ClickUp integration working
- Slack integration working

ClickUp: https://app.clickup.com/t/[TEST_TICKET_ID]"

# Push and watch CI
git push -u origin test-setup
gh run watch
```

### 5.4 Verify CI Workflows
- [ ] All GitHub Actions workflows execute successfully
- [ ] Status badges in README show passing
- [ ] Artifacts uploaded correctly (if applicable)

---

## Phase 6: Project-Specific Setup

### 6.1 Update Documentation
- [ ] Create `requirements/` README explaining how to organize requirements
- [ ] Create `designs/` README with design documentation guidelines
- [ ] Create `qa/` README with QA methodology
- [ ] Add project-specific docs to `docs/`

### 6.2 Configure Development Environments
**[ADD PROJECT-SPECIFIC ENVIRONMENT SETUP]**

Examples:
- Salesforce: Deploy metadata, configure orgs
- Web: Set up local dev server, database
- Mobile: Configure emulators, devices

### 6.3 Create Initial Ticket Structure
```bash
# Example: Create first ticket folders
mkdir -p tickets/[TICKET_ID]-initial-setup
mkdir -p qa/[TICKET_ID]-initial-setup
```

### 6.4 Team Onboarding
- [ ] Share repository with team
- [ ] Schedule walkthrough of project structure
- [ ] Assign first tickets in ClickUp
- [ ] Create team personas in `docs/personas/` if needed

---

## Phase 7: Cleanup and Validation

### 7.1 Remove Template Artifacts
- [ ] Delete this `SETUP_CHECKLIST.md` file (or move to `docs/`)
- [ ] Remove placeholder comments from code
- [ ] Clean up any template-specific examples

### 7.2 Final Validation
- [ ] README is complete and accurate
- [ ] All placeholders replaced
- [ ] CI passes on main branch
- [ ] All team members have access
- [ ] ClickUp project created and linked
- [ ] First sprint/milestone planned

### 7.3 Announce Project
- [ ] Post in Slack #exo-agent-collab
- [ ] Update ClickUp with project kickoff notes
- [ ] Schedule first sprint planning

---

## Common Issues and Solutions

### Issue: CI Fails with "SimDev" Not Found
**Solution**: Search and replace "SimDev" with your actual org alias in all files.

### Issue: Scripts Fail with Path Errors
**Solution**: Update paths in `package.json` scripts to match your project structure.

### Issue: GitHub Actions Don't Trigger
**Solution**: Check Settings → Actions → General - ensure Actions are enabled and have correct permissions.

### Issue: learn/run Symlinks Broken
**Solution**: Ensure learn-run repo is cloned at same level as your project repo:
```
parent-dir/
  ├── learn-run/
  └── [your-project]/
```

### Issue: ClickUp/Slack Integration Not Working
**Solution**: Verify MCP server configuration in Claude Code settings. Re-run setup guides in `learn/mcp/`.

---

## Next Steps

After completing this checklist:

1. **Create your first ticket** in ClickUp
2. **Follow the workflow** in README "Working with Tickets" section
3. **Maintain green builds** - run `npm run ci` before every commit
4. **Use XP discipline** - TDD, pair programming, continuous integration

**Questions?** Post in Slack #exo-agent-collab or check `docs/` for guides.

---

**Setup Complete! 🎉 You're ready to start development following realfast's XP discipline.**
