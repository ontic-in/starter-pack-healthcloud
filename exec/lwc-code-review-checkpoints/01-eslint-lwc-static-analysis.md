# Checkpoint: ESLint-LWC Static Analysis

## Priority
CRITICAL

## Objective
Validate LWC code quality using ESLint-LWC static analysis to detect common violations, code smells, and LWC-specific anti-patterns automatically.

## Scope
This checkpoint analyzes the ESLint report JSON to extract and categorize violations found by the ESLint-LWC analyzer. It does NOT perform new analysis - it interprets existing ESLint results.

## Review Standards
- ESLint-LWC Plugin: Official Salesforce LWC linting rules
- Automated detection of code quality issues
- Standards: Salesforce LWC best practices, performance, security, component patterns

## Input Requirements
```json
{
  "eslint_report": "Complete ESLint JSON report with file violations",
  "files": ["array of .js/.html/.css file paths being reviewed"]
}
```

**ESLint Report Structure:**
```json
[
  {
    "filePath": "/path/to/component.js",
    "messages": [
      {
        "ruleId": "lwc/no-document-query",
        "severity": 2,
        "message": "Invalid usage of document.querySelector",
        "line": 45,
        "column": 12,
        "nodeType": "MemberExpression"
      }
    ],
    "errorCount": 1,
    "warningCount": 0
  }
]
```

## Task

Analyze the provided ESLint report JSON and extract all violations with proper categorization.

**Step 1: Parse ESLint Report**
- Read the ESLint JSON report
- Extract total file count from array
- Extract all violations from each file
- Count violations by severity (error=2, warning=1)

**Step 2: Categorize Violations**
Map ESLint severity to our severity:
- **severity: 2 (error)** → severity: "critical" or "high" (based on rule)
- **severity: 1 (warning)** → severity: "medium"

**Critical Rules** (severity 2 → critical):
- `lwc/no-document-query` - Breaks encapsulation
- `lwc/no-inner-html` - XSS security risk
- `lwc/no-api-reassignments` - Breaks public API contract
- `lwc/valid-api` - Invalid @api usage
- `lwc/valid-wire` - Invalid @wire usage

**High Rules** (severity 2 → high):
- `lwc/no-async-await` - Performance anti-pattern in certain contexts
- `lwc/no-deprecated` - Using deprecated APIs
- All other severity 2 errors

**Step 3: Create Violation Objects**
For each ESLint violation, create:
```json
{
  "severity": "critical|high|medium|low",
  "category": "ESLint-LWC: [rule category]",
  "file": "[filePath from ESLint]",
  "line": "[line from ESLint]",
  "issue": "[message from ESLint]",
  "evidence": "ESLint Rule: [ruleId]",
  "fix_guidance": "[Provide LWC-specific fix guidance based on rule]",
  "confidence": 0.9
}
```

**Step 4: Production Blocker Detection**
Set `production_blocker = true` if:
- ANY critical severity violation exists
- Total critical violations > 0
- Security-related rules triggered (no-inner-html, etc.)

**Step 5: Summary Generation**
Calculate:
- Total violations across all files
- Count by severity (critical, high, medium, low)
- Files with violations vs clean files
- Production blocker status

## Output Format
```json
{
  "checkpoint_name": "eslint-lwc-static-analysis",
  "checkpoint_priority": "CRITICAL",
  "status": "pass|fail|warning",
  "files_analyzed": ["array of all files from ESLint report"],
  "violations": [
    {
      "severity": "critical|high|medium|low",
      "category": "ESLint-LWC: [rule category]",
      "file": "[path]",
      "line": "[number]",
      "issue": "[ESLint message]",
      "evidence": "ESLint Rule: [ruleId]",
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
- All ESLint violations extracted from report
- Violations correctly categorized by severity
- Production blocker flag set for critical/security issues
- Confidence score = 0.9 for all ESLint violations (automated detection)

## Failure Handling
**CANNOT FAIL** - This checkpoint is the foundation. If ESLint report is invalid or missing, throw error and halt review process.

ESLint analysis must complete successfully before other checkpoints can run.

## Confidence Scoring
**All ESLint violations: 0.9 confidence**

Rationale:
- ESLint-LWC is the official Salesforce static analyzer with proven detection accuracy
- No manual interpretation needed
- Rules are explicitly maintained by Salesforce
- High confidence in automated findings

## Fix Guidance by Rule

### lwc/no-document-query
```javascript
// ❌ Bad
document.querySelector('.my-element')

// ✅ Good
this.template.querySelector('.my-element')
```

### lwc/no-inner-html
```javascript
// ❌ Bad - XSS risk
this.template.querySelector('div').innerHTML = userInput;

// ✅ Good - Use LWC data binding
<div>{sanitizedContent}</div>
```

### lwc/no-api-reassignments
```javascript
// ❌ Bad
@api myProp;
this.myProp = newValue; // Mutating public API

// ✅ Good
@api myProp;
@track _internalProp;
connectedCallback() {
    this._internalProp = this.myProp;
}
```

### lwc/valid-wire
```javascript
// ❌ Bad
@wire(getRecord)
wiredRecord;

// ✅ Good
@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
wiredRecord({ error, data }) {
    // Handle response
}
```
