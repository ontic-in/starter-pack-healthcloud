#!/bin/bash
set -e  # Exit on error

# Ensure we're in the test_website directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 Starting deployment process..."
echo ""

# 1. Get git info
BRANCH=$(git branch --show-current)
COMMIT=$(git rev-parse --short HEAD)
BUILD_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "📋 Version info:"
echo "   Branch: $BRANCH"
echo "   Commit: $COMMIT"
echo "   Built:  $BUILD_TIME"
echo ""

# 2. Build test website
echo "📦 Building test website..."
npm run build
echo "✅ JavaScript built and version info injected"
echo ""

# 4. Deploy LWC to Salesforce
echo "☁️  Deploying LWC to Salesforce..."
cd ../[SF_PROJECT_DIR]

# TODO: Update these component names to match your project's LWC components
# Deploy userTypeSelector component
echo "  → Deploying userTypeSelector..."
sf project deploy start --source-dir force-app/main/default/lwc/userTypeSelector --ignore-conflicts --concise || true

# Deploy phoneNumber component
echo "  → Deploying phoneNumber..."
sf project deploy start --source-dir force-app/main/default/lwc/phoneNumber --ignore-conflicts --concise || true

# Deploy emailAddress component
echo "  → Deploying emailAddress..."
sf project deploy start --source-dir force-app/main/default/lwc/emailAddress --ignore-conflicts --concise || true

# Deploy preChatForm component
echo "  → Deploying preChatForm..."
sf project deploy start --source-dir force-app/main/default/lwc/preChatForm --ignore-conflicts --concise || true

echo "✅ LWC deployed to Salesforce"
echo ""

# 5. Return to test_website directory
cd ../test_website

# 6. Commit and push source changes (if any)
echo "💾 Checking for source changes to commit..."

# Check if there are any source file changes (exclude dist/)
if git diff --quiet && git diff --cached --quiet; then
  echo "⚠️  No source changes to commit"
else
  echo "📝 Source changes detected, committing..."
  git add -A
  git commit -m "Deploy: $BRANCH @ $COMMIT

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
  echo "✅ Changes committed"

  # 7. Push to trigger GitHub Pages deployment
  echo "⬆️  Pushing to remote (triggers GitHub Pages deployment)..."
  git push
  echo "✅ Pushed to remote"
fi
echo ""

echo "🎉 Deployment complete!"
echo ""
echo "📋 Summary:"
echo "  - Test website built locally (dist/)"
echo "  - LWC components deployed to Salesforce"
if git diff --quiet && git diff --cached --quiet; then
  echo "  - No source changes to push"
else
  echo "  - Source changes pushed to GitHub"
fi
echo ""
echo "🌐 GitHub Pages will rebuild and deploy at:"
echo "   https://[GITHUB_ORG].github.io/[REPO_NAME]/"
