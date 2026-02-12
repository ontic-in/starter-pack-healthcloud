# Checkpoint: PMD Static Analysis

## Priority
CRITICAL

## Objective
Validate Apex code quality using PMD static analysis to detect common violations, code smells, and potential bugs automatically.

## Scope
This checkpoint analyzes the PMD report JSON to extract and categorize violations found by the PMD static analyzer. It does NOT perform new analysis - it interprets existing PMD results.

## Review Standards
- PMD Ruleset: `sim-pmd-ruleset.xml`
- Automated detection of code quality issues
- Standards: Salesforce best practices, performance, security, error-prone patterns

## Input Requirements
```json
{
  "pmd_report_json": "Complete PMD JSON report with files and violations arrays",
  "files": ["array of .cls file paths being reviewed"]
}
```

**PMD Report Structure:**
```json
{
  "formatVersion": 0,
  "pmdVersion": "7.0.0",
  "timestamp": "2025-10-30T...",
  "files": [
    {
      "filename": "path/to/File.cls",
      "violations": [
        {
          "beginline": 15,
          "endline": 15,
          "description": "Avoid using hardcoded IDs",
          "rule": "AvoidHardcodingId",
          "ruleset": "Best Practices",
          "priority": 3,
          "externalInfoUrl": "https://..."
        }
      ]
    }
  ],
  "suppressedViolations": [],
  "processingErrors": [],
  "configurationErrors": []
}
```

## Task

Analyze the provided PMD report JSON and extract all violations with proper categorization.

**Step 1: Parse PMD Report**
- Read the PMD JSON report
- Extract total file count from `files` array
- Extract all violations from each file
- Count violations by severity/priority

**Step 2: Categorize Violations**
Map PMD priority to severity:
- **Priority 1 (Critical)** → severity: "critical"
- **Priority 2 (High)** → severity: "high"
- **Priority 3 (Medium)** → severity: "medium"
- **Priority 4-5 (Low)** → severity: "low"

**Step 3: Create Violation Objects**
For each PMD violation, create:
```json
{
  "severity": "critical|high|medium|low",
  "category": "PMD: [ruleset name]",
  "file": "[filename from PMD]",
  "line": "[beginline from PMD]",
  "issue": "[description from PMD]",
  "evidence": "PMD Rule: [rule name]",
  "fix_guidance": "[Check externalInfoUrl for fix guidance, or provide generic advice]",
  "confidence": 0.9
}
```

**Step 4: Production Blocker Detection**
Set `production_blocker = true` if:
- ANY violation has priority 1 (Critical)
- Total critical violations > 0

**Step 5: Summary Generation**
Calculate:
- Total violations across all files
- Count by severity (critical, high, medium, low)
- Files with violations vs clean files
- Production blocker status

## Output Format
```json
{
  "checkpoint_name": "pmd-static-analysis",
  "checkpoint_priority": "CRITICAL",
  "status": "pass|fail|warning",
  "files_analyzed": ["array of all files from PMD report"],
  "violations": [
    {
      "severity": "critical|high|medium|low",
      "category": "PMD: [ruleset]",
      "file": "[path]",
      "line": "[number]",
      "issue": "[PMD description]",
      "evidence": "PMD Rule: [rule name]",
      "fix_guidance": "[guidance]",
      "confidence": 0.9
    }
  ],
  "summary": {
    "total_violations": "[number]",
    "critical_count": "[number]",
    "high_count": "[number]",
    "medium_count": "[number]",
    "low_count": "[number]",
    "files_analyzed": "[number]",
    "files_with_violations": "[number]",
    "clean_files": "[number]",
    "production_blocker": "[true if critical_count > 0, else false]"
  }
}
```

**Status Logic:**
- `status: "pass"` if total_violations == 0
- `status: "fail"` if critical_count > 0 OR high_count > 0
- `status: "warning"` if only medium/low violations

## Success Criteria
- All PMD violations extracted from report
- Violations correctly categorized by severity
- Production blocker flag set for critical issues
- Confidence score = 0.9 for all PMD violations (automated detection)

## Failure Handling
**CANNOT FAIL** - This checkpoint is the foundation. If PMD report is invalid or missing, throw error and halt review process.

PMD analysis must complete successfully before other checkpoints can run.

## Confidence Scoring
**All PMD violations: 0.9 confidence**

Rationale:
- PMD is an automated static analyzer with proven detection accuracy
- No manual interpretation needed
- Rules are explicitly configured in sim-pmd-ruleset.xml
- High confidence in automated findings

Lower to 0.8 only if:
- PMD version warnings present
- Processing errors in report
- Configuration errors noted
