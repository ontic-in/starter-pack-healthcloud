#!/bin/bash
# Wrapper for Playwright tests that provides failure analysis instructions

# Run playwright with all arguments passed through
playwright "$@"
EXIT_CODE=$?

# If tests failed, provide debugging instructions
if [ $EXIT_CODE -ne 0 ]; then
  echo ""
  echo "========================================="
  echo "📹 INSTRUCTION FOR AI AGENT:"
  echo "========================================="
  echo "Tests failed. Analyze failures by:"
  echo ""
  echo "1. View screenshots in test-results/ directories"
  echo "2. Extract video frames to 'watch' what happened:"
  echo "   npx tsx scripts/extract-video-frames.ts --all-playwright --interval 0.5 --verbose"
  echo ""
  echo "3. Read extracted frames sequentially to understand:"
  echo "   - Page load timing"
  echo "   - Element visibility/animations"
  echo "   - Click/interaction timing"
  echo "   - Unexpected UI states"
  echo ""
  echo "Frames are named with zero-padded timestamps for chronological viewing."
  echo "========================================="
  echo ""
fi

exit $EXIT_CODE
