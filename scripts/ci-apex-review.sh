#!/bin/bash
set -e

# CI Apex Code Review
# Runs Apex code review on changed files as part of local CI pipeline
# Only reviews Apex files that have been changed/staged

echo "🔍 CI Apex Code Review - Checking for changed Apex files..."

# Get list of changed Apex files (staged + unstaged)
# Use different git diff strategy based on environment
if [ -n "$GITHUB_BASE_REF" ]; then
  # Running in GitHub Actions PR context - compare against base branch
  CHANGED_FILES=$(git diff --name-only origin/$GITHUB_BASE_REF...HEAD | grep -E '\.(cls|trigger)$' | grep 'force-app' || echo "")
  STAGED_FILES=""  # No staged files concept in CI
else
  # Running locally - check working directory changes
  CHANGED_FILES=$(git diff --name-only HEAD | grep -E '\.(cls|trigger)$' | grep 'force-app' || echo "")
  STAGED_FILES=$(git diff --cached --name-only | grep -E '\.(cls|trigger)$' | grep 'force-app' || echo "")
fi

# Combine and deduplicate
ALL_CHANGED_FILES=$(echo -e "$CHANGED_FILES\n$STAGED_FILES" | sort -u | grep -v '^$' || echo "")

if [ -z "$ALL_CHANGED_FILES" ]; then
  echo "✓ No Apex files changed - skipping code review"
  exit 0
fi

# Count files
FILE_COUNT=$(echo "$ALL_CHANGED_FILES" | wc -l | tr -d ' ')
echo "📊 Found $FILE_COUNT changed Apex file(s):"
echo "$ALL_CHANGED_FILES" | sed 's/^/  - /'

# Extract ticket ID from branch name
BRANCH=$(git branch --show-current)
TICKET_ID=$(echo "$BRANCH" | grep -oE '86[a-z0-9]{8,}|clickup-86[a-z0-9]{8,}' | sed 's/clickup-//' | head -1 || echo "")

if [ -n "$TICKET_ID" ]; then
  echo "🎫 Detected ticket ID: $TICKET_ID"
fi

# Convert to comma-separated list
FILES_CSV=$(echo "$ALL_CHANGED_FILES" | tr '\n' ',' | sed 's/,$//')

echo ""
echo "🚀 Running Apex code review in modular mode..."
echo ""

# Run code review with modular checkpoint mode
if [ -n "$TICKET_ID" ]; then
  node scripts/code-review/apex-review-runner.js \
    --mode modular \
    --files "$FILES_CSV" \
    --ticket "$TICKET_ID" \
    --verbose
else
  node scripts/code-review/apex-review-runner.js \
    --mode modular \
    --files "$FILES_CSV" \
    --verbose
fi

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ Apex code review passed - no production blockers detected"
else
  echo "❌ Apex code review failed - production blockers or critical violations detected"
  echo ""
  echo "Review the detailed report printed above."
  exit 1
fi

exit 0
