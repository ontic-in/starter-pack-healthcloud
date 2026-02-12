#!/bin/bash
# Validate deployment documentation using AI (Claude Code CLI)
#
# Usage:
#   ./scripts/validate-deployment-doc.sh              # Auto-detect from current branch
#   ./scripts/validate-deployment-doc.sh --verbose    # Show detailed output
#   ./scripts/validate-deployment-doc.sh --help       # Show usage
#
# Exit Codes:
#   0 - Validation passed OR deployment doc not needed
#   1 - Validation failed (missing/incomplete deployment doc)
#   2 - Script error (invalid inputs, missing dependencies)
#
# Requirements:
#   - @anthropic-ai/claude-code installed globally
#   - ANTHROPIC_API_KEY environment variable set
#   - Git repository with proper branch naming: clickup-{ticketId}-*

set -e
set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VERBOSE=false
OUTPUT_FILE="validation-output.json"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--verbose] [--help]"
      echo ""
      echo "Validates Salesforce deployment documentation using AI."
      echo ""
      echo "Options:"
      echo "  --verbose, -v   Show detailed output"
      echo "  --help, -h      Show this help message"
      echo ""
      echo "Environment Variables:"
      echo "  ANTHROPIC_API_KEY   Required - Claude API key"
      echo ""
      echo "Exit Codes:"
      echo "  0   Validation passed OR deployment doc not needed"
      echo "  1   Validation failed"
      echo "  2   Script error"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 2
      ;;
  esac
done

# Check dependencies
if ! command -v npx &> /dev/null; then
    echo -e "${RED}Error: npx not found. Please install Node.js/npm.${NC}"
    exit 2
fi

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "${RED}Error: ANTHROPIC_API_KEY environment variable not set.${NC}"
    echo "Set it with: export ANTHROPIC_API_KEY=your-api-key"
    exit 2
fi

# Check if Claude Code CLI is available
if ! npx --yes @anthropic-ai/claude-code --version &> /dev/null; then
    echo -e "${YELLOW}Installing Claude Code CLI...${NC}"
    npm install -g @anthropic-ai/claude-code || {
        echo -e "${RED}Failed to install Claude Code CLI${NC}"
        exit 2
    }
fi

echo -e "${BLUE}📋 Validating Deployment Documentation...${NC}"
echo ""

# Extract ticket ID from branch name
CURRENT_BRANCH=$(git branch --show-current)
TICKET_ID=$(echo "$CURRENT_BRANCH" | grep -oP 'clickup-\K[0-9a-z]+' || echo "")

if [ -z "$TICKET_ID" ]; then
    echo -e "${YELLOW}Warning: Could not extract ticket ID from branch: $CURRENT_BRANCH${NC}"
    echo "Expected branch format: clickup-{ticketId}-description"
    TICKET_ID="unknown"
fi

if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}Ticket ID: $TICKET_ID${NC}"
    echo -e "${BLUE}Branch: $CURRENT_BRANCH${NC}"
    echo ""
fi

# Get git diff of potentially deployment-critical files
# Looking for Salesforce metadata in force-app directory
GIT_DIFF=$(git diff --name-only HEAD~1..HEAD 2>/dev/null || git diff --name-only --cached 2>/dev/null || echo "")

if [ -z "$GIT_DIFF" ]; then
    echo -e "${YELLOW}Warning: No git changes detected. Using staged files...${NC}"
    GIT_DIFF=$(git diff --name-only --cached || echo "")
fi

if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}Changed files:${NC}"
    echo "$GIT_DIFF" | sed 's/^/  /'
    echo ""
fi

# Check if deployment doc exists
DEPLOYMENT_DOC_PATH="tickets/${TICKET_ID}/clickup_${TICKET_ID}_deployment.md"
DEPLOYMENT_DOC_CONTENT=""

if [ -f "$DEPLOYMENT_DOC_PATH" ]; then
    DEPLOYMENT_DOC_CONTENT=$(cat "$DEPLOYMENT_DOC_PATH")
    if [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}✓ Deployment doc found at: $DEPLOYMENT_DOC_PATH${NC}"
        echo ""
    fi
else
    if [ "$VERBOSE" = true ]; then
        echo -e "${YELLOW}! Deployment doc not found at: $DEPLOYMENT_DOC_PATH${NC}"
        echo ""
    fi
fi

# Export inputs as environment variables for the prompt
export TICKET_ID
export GIT_DIFF
export DEPLOYMENT_DOC_CONTENT

# Execute AI validation prompt via Claude Code CLI
if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}Running AI validation...${NC}"
    echo ""
fi

CLAUDE_OUTPUT=$(npx claude --print --dangerously-skip-permissions \
  "execute exec/DEPLOYMENT_DOC_REVIEW.md" 2>&1 || echo '{"status":"error","reason":"Claude execution failed"}')

# Save output to file
echo "$CLAUDE_OUTPUT" > "$OUTPUT_FILE"

# Try to extract JSON from output using multiple strategies
# Strategy 1: Look for JSON in markdown code blocks (```json ... ```)
JSON_OUTPUT=$(echo "$CLAUDE_OUTPUT" | sed -n '/^```json$/,/^```$/p' | sed '1d;$d' | jq -c '.' 2>/dev/null || echo "")

# Strategy 2: If no JSON block found, try to extract any JSON object
if [ -z "$JSON_OUTPUT" ] || [ "$JSON_OUTPUT" == "null" ]; then
    # Use Python to extract JSON more reliably (handles multiline)
    JSON_OUTPUT=$(python3 -c "
import json
import sys
import re

text = '''$CLAUDE_OUTPUT'''

# Try to find JSON object in the text
json_match = re.search(r'\{[^}]*\"status\"[^}]*\}', text, re.DOTALL)
if json_match:
    try:
        obj = json.loads(json_match.group(0))
        print(json.dumps(obj))
    except:
        pass
" 2>/dev/null || echo "")
fi

# Strategy 3: Fallback - use original grep approach
if [ -z "$JSON_OUTPUT" ] || [ "$JSON_OUTPUT" == "null" ]; then
    JSON_OUTPUT=$(echo "$CLAUDE_OUTPUT" | grep -oP '\{(?:[^{}]|(?R))*\}' | tail -1 || echo "$CLAUDE_OUTPUT")
fi

# Final fallback
if [ -z "$JSON_OUTPUT" ]; then
    JSON_OUTPUT='{"status":"error","reason":"Failed to parse JSON from Claude output"}'
fi

if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}Full AI Response:${NC}"
    echo "$CLAUDE_OUTPUT" | sed 's/^/  /'
    echo ""
    echo -e "${BLUE}Extracted JSON:${NC}"
    echo "$JSON_OUTPUT" | jq '.' 2>/dev/null || echo "$JSON_OUTPUT"
    echo ""
fi

# Parse JSON output for status
STATUS=$(echo "$JSON_OUTPUT" | jq -r '.status // "error"' 2>/dev/null || echo "error")
REASON=$(echo "$JSON_OUTPUT" | jq -r '.reason // "Unknown reason"' 2>/dev/null || echo "Unknown reason")

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"

# Determine exit code based on status
case "$STATUS" in
  pass)
    echo -e "${GREEN}✅ PASS: Deployment documentation is valid${NC}"
    echo ""
    echo -e "${GREEN}Reason: $REASON${NC}"
    EXIT_CODE=0
    ;;
  not_needed)
    echo -e "${GREEN}✅ PASS: Deployment documentation not needed${NC}"
    echo ""
    echo -e "${GREEN}Reason: $REASON${NC}"
    EXIT_CODE=0
    ;;
  fail)
    echo -e "${RED}❌ FAIL: Deployment documentation validation failed${NC}"
    echo ""
    echo -e "${RED}Reason: $REASON${NC}"
    echo ""

    # Show errors
    ERRORS=$(echo "$JSON_OUTPUT" | jq -r '.errors[]? | "  [\(.severity | ascii_upcase)] \(.section): \(.message)"' 2>/dev/null || echo "")
    if [ -n "$ERRORS" ]; then
      echo -e "${RED}Errors:${NC}"
      echo "$ERRORS"
      echo ""
    fi

    # Show missing components
    MISSING=$(echo "$JSON_OUTPUT" | jq -r '.missingComponents[]? | "  - \(.)"' 2>/dev/null || echo "")
    if [ -n "$MISSING" ]; then
      echo -e "${RED}Missing Components:${NC}"
      echo "$MISSING"
      echo ""
    fi

    # Show suggestions
    SUGGESTIONS=$(echo "$JSON_OUTPUT" | jq -r '.suggestions[]? | "  💡 \(.)"' 2>/dev/null || echo "")
    if [ -n "$SUGGESTIONS" ]; then
      echo -e "${YELLOW}Suggestions:${NC}"
      echo "$SUGGESTIONS"
      echo ""
    fi

    # Show deployment doc path
    DOC_PATH=$(echo "$JSON_OUTPUT" | jq -r '.deploymentDocPath // ""' 2>/dev/null || echo "")
    if [ -n "$DOC_PATH" ]; then
      echo -e "${YELLOW}Expected deployment doc path:${NC}"
      echo "  $DOC_PATH"
      echo ""
    fi

    EXIT_CODE=1
    ;;
  error|*)
    echo -e "${RED}❌ ERROR: Validation script encountered an error${NC}"
    echo ""
    echo -e "${RED}Details: $REASON${NC}"
    echo ""
    echo "Full output saved to: $OUTPUT_FILE"
    EXIT_CODE=2
    ;;
esac

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Show next steps on failure
if [ $EXIT_CODE -eq 1 ]; then
  echo -e "${YELLOW}📖 Next Steps:${NC}"
  echo "  1. Review the errors and missing components above"
  echo "  2. Update your deployment doc at: $DEPLOYMENT_DOC_PATH"
  echo "  3. Use template: docs/deployment_components/deployment_components_to_prod.md"
  echo "  4. Re-run validation: npm run validate:deployment"
  echo ""
  echo -e "${YELLOW}💡 Tip: Use --verbose flag for detailed output${NC}"
  echo ""
fi

# Show output file location
if [ "$VERBOSE" = true ]; then
  echo -e "${BLUE}Validation results saved to: $OUTPUT_FILE${NC}"
  echo ""
fi

exit $EXIT_CODE
