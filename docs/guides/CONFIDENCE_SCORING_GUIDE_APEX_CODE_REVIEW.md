# Confidence Scoring Guide - Apex Code Review

## Confidence Levels

- **0.9**: Automated detection (PMD, static analysis, keyword detection)
- **0.8**: Pattern matching with context (CRUD/FLS checks)
- **0.7**: Pattern detection requiring interpretation (architecture, standards)
- **0.6**: Subjective quality assessment (testing standards)
- **0.5**: Manual review recommended (quality process, code smells)

## Rationale
Higher confidence in automated detections, lower confidence in subjective assessments.
