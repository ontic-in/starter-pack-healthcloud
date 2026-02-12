#!/bin/bash
set -e

# CI Prompt Template Code Review
# Runs prompt template code review on changed files as part of local CI pipeline
# Only reviews prompt template files that have been changed/staged

echo "🔍 CI Prompt Template Code Review - Checking for changed prompt files..."

# Get list of changed prompt template files (staged + unstaged)
# Use different git diff strategy based on environment
if [ -n "$GITHUB_BASE_REF" ]; then
  # Running in GitHub Actions PR context - compare against base branch
  CHANGED_FILES=$(git diff --name-only origin/$GITHUB_BASE_REF...HEAD | grep -E 'development/prompt_development_and_testing/prompts/.*\.md$' || echo "")
  STAGED_FILES=""  # No staged files concept in CI
else
  # Running locally - check working directory changes
  CHANGED_FILES=$(git diff --name-only HEAD | grep -E 'development/prompt_development_and_testing/prompts/.*\.md$' || echo "")
  STAGED_FILES=$(git diff --cached --name-only | grep -E 'development/prompt_development_and_testing/prompts/.*\.md$' || echo "")
fi

# Combine and deduplicate
ALL_CHANGED_FILES=$(echo -e "$CHANGED_FILES\n$STAGED_FILES" | sort -u | grep -v '^$' || echo "")

if [ -z "$ALL_CHANGED_FILES" ]; then
  echo "✓ No prompt template files changed - skipping code review"
  exit 0
fi

# Count files
FILE_COUNT=$(echo "$ALL_CHANGED_FILES" | wc -l | tr -d ' ')
echo "📊 Found $FILE_COUNT changed prompt template file(s):"
echo "$ALL_CHANGED_FILES" | sed 's/^/  - /'

# Extract ticket ID from branch name
BRANCH=$(git branch --show-current)
TICKET_ID=$(echo "$BRANCH" | grep -oE '86[a-z0-9]{8,}|clickup-86[a-z0-9]{8,}' | sed 's/clickup-//' | head -1 || echo "")

if [ -n "$TICKET_ID" ]; then
  echo "🎫 Detected ticket ID: $TICKET_ID"
fi

echo ""
echo "🚀 Running prompt template code review..."
echo ""

# Run code review for each changed prompt file
OVERALL_EXIT_CODE=0

for PROMPT_FILE in $ALL_CHANGED_FILES; do
  # Extract prompt name from file path (e.g., development/prompt_development_and_testing/prompts/SIM_Knowledge_Retriever.md -> SIM_Knowledge_Retriever)
  PROMPT_NAME=$(basename "$PROMPT_FILE" .md)

  # Find corresponding test file
  TEST_FILE="development/prompt_development_and_testing/tests/prompt/${PROMPT_NAME}.test.ts"

  if [ ! -f "$TEST_FILE" ]; then
    echo "⚠️  Warning: No test file found for $PROMPT_NAME (expected: $TEST_FILE)"
    echo "   Skipping review for this prompt - test file is required"
    echo ""
    continue
  fi

  echo "📝 Reviewing: $PROMPT_NAME"
  echo "   Prompt: $PROMPT_FILE"
  echo "   Test:   $TEST_FILE"
  echo ""

  # Run code review
  if [ -n "$TICKET_ID" ]; then
    node --import tsx/esm scripts/code-review/prompt-review-runner.ts \
      --prompt "$PROMPT_FILE" \
      --test "$TEST_FILE" \
      --ticket "$TICKET_ID" \
      --verbose
  else
    node --import tsx/esm scripts/code-review/prompt-review-runner.ts \
      --prompt "$PROMPT_FILE" \
      --test "$TEST_FILE" \
      --verbose
  fi

  EXIT_CODE=$?

  if [ $EXIT_CODE -ne 0 ]; then
    OVERALL_EXIT_CODE=1
    echo "❌ Review failed for $PROMPT_NAME"
  else
    echo "✅ Review passed for $PROMPT_NAME"
  fi

  echo ""
  echo "─────────────────────────────────────────────────────"
  echo ""
done

echo ""
if [ $OVERALL_EXIT_CODE -eq 0 ]; then
  echo "✅ Prompt template code review passed - no production blockers detected"
else
  echo "❌ Prompt template code review failed - production blockers or critical violations detected"
  echo ""
  echo "Review the detailed reports printed above."
  exit 1
fi

exit 0
