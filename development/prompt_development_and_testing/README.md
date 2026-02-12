# Prompt Development & Testing Framework

A Test-Driven Development (TDD) framework for Salesforce Agentforce prompt templates, designed for iterative prompt engineering with comprehensive testing automation.

## 🎯 Philosophy: Test-Driven Prompt Development

### The TDD Cycle for Prompts

```
1. 🔴 RED: Write failing tests that describe desired prompt behavior
2. 🟢 GREEN: Create/update prompt template to make tests pass
3. 🔵 REFACTOR: Improve prompt clarity, reduce tokens, optimize performance
4. 🔄 REPEAT: Continue the cycle for new requirements
```

### Why TDD for Prompts?

- **Clear Specification**: Tests define exact expected behavior before implementation
- **Regression Prevention**: Ensure prompt changes don't break existing functionality
- **Iterative Improvement**: Systematic approach to prompt refinement
- **Quality Assurance**: Comprehensive validation across diverse input scenarios
- **Documentation**: Tests serve as living documentation of prompt capabilities

## 🚀 Quick Start Guide

### Prerequisites

Before starting, ensure you have:

1. **CC Menu 2** - For GitHub CI status monitoring
   - Download from [CC Menu website](https://ccmenu.org/)
   - Configure with your GitHub repository for real-time build status

2. **Node.js 18+** - Required for the testing framework

3. **Salesforce Org Access** - With Prompt Builder and Connected App setup

### 1. Installation & Setup

```bash
# Install dependencies
npm install

# Setup pre-commit hooks (Husky)
npm run prepare

# Copy environment template
cp .env.example .env
```

### 2. Configure Environment

Edit `.env` with your Salesforce Connected App credentials:

```env
SF_LOGIN_URL=https://login.salesforce.com
SF_CLIENT_ID=your_connected_app_consumer_key
SF_CLIENT_SECRET=your_connected_app_consumer_secret
SF_REDIRECT_URI=http://localhost:3000/oauth/callback
```

### 3. Authenticate with Salesforce

```bash
npm run auth
```

This opens your browser for OAuth2 authentication and stores secure tokens locally.

### 4. Verify Setup

```bash
# Run TypeScript check
npm run build

# Run linting
npm run lint

# Run sample tests
npm run test:prompt
```

## 📋 TDD Workflow for Prompt Development

### Step 1: Define Test Behavior (RED Phase)

**Before writing any prompt**, define the expected behavior through tests:

```typescript
// tests/prompt/my_new_prompt.test.ts
describe('My New Prompt Template', () => {
  it('should provide helpful customer service responses', async () => {
    const result = await testPrompt(client, 'I need help with my order');

    expect(result.passed).toBe(true);
    expect(result.actualOutput).toMatch(/order|help|assist/i);
    expect(result.actualOutput.length).toBeGreaterThan(20);
  });

  it('should handle angry customer complaints professionally', async () => {
    const result = await testPrompt(client, 'This is terrible service!');

    expect(result.passed).toBe(true);
    expect(result.actualOutput).toMatch(/understand|sorry|apologize/i);
    expect(result.actualOutput).not.toMatch(/angry|terrible|bad/i);
  });
});
```

### Step 2: Follow Development Guide

Refer to the comprehensive guide in `@development/prompt_development_and_testing/guide/` for:

- Prompt engineering best practices
- Token optimization strategies
- Context management techniques
- Performance considerations
- Security guidelines

### Step 3: Create Prompt Content

Write your prompt template content in markdown format:

```markdown
<!-- prompts/my_new_prompt.md -->
# My New Prompt Template

## Prompt Content

You are a helpful customer service agent. Always respond professionally and empathetically to customer inquiries.

Guidelines:
- Be polite and understanding
- Provide clear, actionable solutions
- Acknowledge customer concerns
- Avoid negative language

## Example Inputs & Expected Outputs

**Input**: "I need help with my order"
**Expected**: Professional assistance offer with specific steps

**Input**: "This is terrible service!"
**Expected**: Empathetic response with apology and solution focus
```

### Step 4: Manual Prompt Builder Update

⚠️ **Critical Manual Step**: Tests won't automatically pass until you update the actual prompt template in Salesforce.

1. **Navigate to Salesforce Setup** → **Prompt Builder**
2. **Find your prompt template** (or create new one)
3. **Create new version** with content from `prompts/my_new_prompt.md`
4. **Set API Name** to match your test configuration
5. **Activate the new version**

### Step 5: Run Tests (GREEN Phase)

```bash
# Run specific prompt tests
npm run test:prompt -- -t "My New Prompt"

# Run with verbose output
LOG_LEVEL=debug npm run test:prompt

# Run all tests
npm test
```

### Step 6: Iterate and Refactor (REFACTOR Phase)

Based on test results:

1. **Analyze failures** - What behaviors aren't working?
2. **Update prompt content** - Refine the prompt in `prompts/` directory
3. **Update Salesforce** - Create new version in Prompt Builder
4. **Re-run tests** - Verify improvements
5. **Optimize performance** - Reduce tokens, improve response times

## 🔍 Automated Quality Review System

### Overview

The framework includes an automated review system that evaluates both **prompt template quality** (using Prompt Engineering Guide standards) and **test suite quality** (using Kent Beck's TDD philosophy). This ensures prompts are well-designed AND their tests serve as complete, readable specifications.

### Quick Usage

```bash
# Review a prompt template and its test suite
npm run review-prompt -- \
  --prompt prompts/Example_Data_Extraction.md \
  --test tests/prompt/example-data-extraction.test.ts

# Verbose mode (shows full JSON review)
npm run review-prompt -- \
  --prompt prompts/my_prompt.md \
  --test tests/prompt/my_prompt.test.ts \
  --verbose
```

### PASS/FAIL Criteria

The review returns **PASS=true** only if ALL 5 criteria are met:

1. ✅ **all_behaviors_tested** - Every prompt behavior has corresponding tests
2. ✅ **no_generic_test_names** - Test names tell stories (Kent Beck principle: "test names should tell little stories")
3. ✅ **no_critical_violations** - No critical issues in prompt structure or tests
4. ✅ **alignment_score_acceptable** - Specification alignment score ≥ 0.7
5. ✅ **kent_beck_quality_acceptable** - Tests serve as executable specifications

**Any single failing criterion = FAIL**

### What the Reviewer Evaluates

**Prompt Template Analysis:**
- ✅ XML structure (role, task, output_format, guidelines, examples)
- ✅ Decision logic completeness
- ✅ Edge case handling
- ✅ Validation rules
- ✅ Quality standards (consistency, transparency, grounding, maintainability)

**Test Suite Analysis (Kent Beck TDD Philosophy):**
- ✅ Tests tell stories - Do names reveal scenarios?
- ✅ Tests as specification - Can you understand the prompt by reading tests alone?
- ✅ Communication quality - Do tests reveal intent clearly?
- ✅ Behavioral focus - Do tests check 'what', not 'how'?
- ✅ Cheap to read - Are tests immediately understandable?

**Specification Alignment:**
- ✅ Behaviors with tests - Which prompt behaviors are covered?
- ✅ Behaviors without tests - Which are missing?
- ✅ Orphan tests - Tests without matching behaviors
- ✅ Coverage quality - Comprehensive, partial, or minimal?

### CI/CD Integration

The review command uses proper exit codes for pipeline integration:

```bash
# Exit code 0 if PASS=true (build continues)
# Exit code 1 if PASS=false (build fails)

npm run review-prompt -- --prompt prompts/my_prompt.md --test tests/prompt/my_prompt.test.ts
echo $?  # 0 for PASS, 1 for FAIL
```

### Using Review Results to Improve Quality

1. **Check behaviors_without_tests** - Add tests for missing behaviors
2. **Review generic test names** - Rename tests to tell stories about scenarios
3. **Fix critical violations** - Address structural issues in prompt template
4. **Improve alignment score** - Ensure tests cover all prompt behaviors
5. **Enhance specification quality** - Make tests readable as documentation

### Review System Architecture

- **Reviewer Template**: `exec/PROMPT_TEMPLATE_AND_TESTS_REVIEWER.md`
- **NPM Script**: `scripts/review-prompt.ts`
- **Standards Reference**: `guide/prompt-guide.md` (Prompt Engineering Guide)
- **Philosophy**: Kent Beck's TDD principles for test quality

The reviewer loads the Prompt Engineering Guide, analyzes both prompt and tests, cross-references behaviors with test coverage, and generates a comprehensive JSON report with a PASS/FAIL decision.

## 🔧 Development Commands

### TDD Development Workflow

```bash
# Start TDD cycle - watch mode for immediate feedback
npm run dev

# Run specific prompt tests during development
npm run test:prompt -- -t "your prompt name"

# Debug mode with detailed logging
LOG_LEVEL=debug npm run test:prompt

# Run tests with UI for visual feedback
npm run test:ui
```

### Code Quality & Pre-commit Hooks

```bash
# Manual validation (same as pre-commit hook)
npm run check

# TypeScript compilation check
npm run build

# ESLint with auto-fix
npm run lint:fix

# Comprehensive validation (checks + tests)
npm run validate
```

### Authentication Management

```bash
# Initial authentication setup
npm run auth

# Check authentication status
npm run auth -- --info

# Clear tokens and re-authenticate
npm run auth -- --clear
npm run auth

# Test current authentication
npm run auth -- --test
```

### Pre-commit Hook Validation

The framework includes robust pre-commit hooks that automatically:

1. **Run full TypeScript compilation** (`tsc --noEmit`)
2. **Execute ESLint validation** on staged files
3. **Block commits** if any errors are found
4. **Auto-fix** ESLint issues when possible

```bash
# Pre-commit hook runs automatically on git commit
git commit -m "your message"

# Manual validation (same checks as pre-commit)
npm run check

# Emergency bypass (NOT RECOMMENDED)
git commit --no-verify -m "emergency commit"
```

### Token Security

- **OAuth2 with PKCE** - Industry standard secure authentication
- **Local token storage** - Tokens stored in `.tokens/` (gitignored)
- **Automatic refresh** - Transparent token renewal
- **No secrets in code** - All sensitive data in environment variables

### API Rate Limiting

- **Built-in delays** between test requests
- **Performance monitoring** to detect rate limiting
- **Configurable timeouts** for different operations
- **Health checks** for API reliability

## 🚨 Troubleshooting

### Authentication Issues

```bash
# Clear all tokens and restart auth flow
npm run auth -- --clear
npm run auth

# Check current authentication status
npm run auth -- --info

# Test API connectivity
npm run auth -- --test
```

### Common Test Failures

1. **"Tests are being skipped"**
   - Check authentication: `npm run auth -- --info`
   - Re-authenticate if needed: `npm run auth`

2. **"Prompt template not found"**
   - Verify template exists in Salesforce Prompt Builder
   - Check API name matches test configuration
   - Ensure template is activated

3. **"Unexpected response format"**
   - Update prompt content in Salesforce Prompt Builder
   - Check prompt template version is active
   - Verify input/output expectations in tests

4. **"TypeScript compilation errors"**
   - Run `npm run build` to see detailed errors
   - Fix type issues before committing
   - Pre-commit hooks will prevent broken code

### Performance Issues

```bash
# Debug with detailed logging
LOG_LEVEL=debug npm run test:prompt

# Check API response times
npm run test:prompt -- -t "Performance"

# Monitor system health
npm run auth -- --test
```

## 📚 Additional Resources
- **[Kent Beck's TDD Principles](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)** - Original TDD methodology
- **Salesforce Prompt Builder Documentation** - Official Salesforce guides
- **CC Menu 2 Setup** - GitHub CI integration for development workflow

## 🤝 Contributing

1. **Follow TDD workflow** - Write tests first, then implement prompts
2. **Use the guide** - Reference `guide/` directory for best practices
3. **Test thoroughly** - Ensure all tests pass before submitting changes
4. **Document behavior** - Update tests to reflect new prompt capabilities
5. **Security first** - Never commit tokens or sensitive data

## 📞 Support

For framework issues:

1. **Check troubleshooting section** above
2. **Review test logs** for detailed error information
3. **Use diagnostic commands** (`npm run auth -- --info`)
4. **Verify Salesforce setup** in Prompt Builder

---

**Remember**: In TDD for prompts, tests are your specification. Write them first, make them pass, then refine. The manual step of updating Salesforce Prompt Builder is crucial - tests validate behavior, but the actual prompt content lives in Salesforce.