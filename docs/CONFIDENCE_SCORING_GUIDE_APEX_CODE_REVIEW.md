# Apex Code Review Confidence Scoring Guide

## Overview
This guide provides confidence scoring (0.0-1.0) specifically for **Apex code review assessments**. Confidence reflects the **validation level of code quality findings**, not the reviewer's certainty or code complexity.

**Core Principle**: Confidence = **Evidence Source Quality + Validation Scope**, not subjective assessment or theoretical analysis.

## Quick Scoring Decision Tree for Apex Reviews

### For ANY Code Quality Finding:
START HERE → What evidence do you have for this assessment?

1. **Automated Tool Detection (0.8-0.9)**
   - PMD static analysis violation → 0.9
   - Salesforce deployment error → 0.9
   - Unit test failure → 0.8

2. **Standards Compliance (0.6-0.8)**
   - RFC standard violation confirmed → 0.7
   - Best practice deviation identified → 0.6
   - Governor limit issue calculated → 0.8

3. **Manual Code Inspection (0.4-0.6)**
   - Code review identified issue → 0.5
   - Pattern analysis suggests problem → 0.4
   - Potential optimization spotted → 0.4

4. **Theoretical Assessment (0.1-0.3)**
   - Suspected anti-pattern → 0.2
   - Possible improvement area → 0.1
   - Unvalidated recommendation → 0.1

## Evidence-Based Confidence Levels

### 0.9: PMD Static Analysis Findings
- **Evidence**: Automated rule violation with line numbers
- **Examples**:
  - "ApexCRUDViolation detected at line 34" (0.9)
  - "CyclomaticComplexity measured at 14" (0.9)
  - "DebugsShouldUseLoggingLevel triggered" (0.9)

### 0.8: Deployment/Test Validation
- **Evidence**: Salesforce org feedback or test execution results
- **Examples**:
  - "Unit test fails with CRUD exception" (0.8)
  - "Deployment fails due to missing dependencies" (0.8)
  - "Org throws insufficient privileges error" (0.8)

### 0.7: RFC Standards Compliance
- **Evidence**: Direct mapping to documented RFC requirements
- **Examples**:
  - "Violates RFC 5.1 CRUD/FLS requirement" (0.7)
  - "Exceeds RFC complexity threshold (10)" (0.7)
  - "Missing RFC required unit test coverage" (0.7)

### 0.6: Salesforce Best Practices
- **Evidence**: Documented Salesforce platform guidance
- **Examples**:
  - "Violates bulkification best practice" (0.6)
  - "Uses deprecated API version" (0.6)
  - "Hard-coded values against platform guidance" (0.6)

### 0.5: Manual Code Review
- **Evidence**: Code inspection reveals implementation issues
- **Examples**:
  - "Method too complex for maintainability" (0.5)
  - "Error handling insufficient" (0.5)
  - "Naming convention inconsistent" (0.5)

### 0.4: Pattern Analysis
- **Evidence**: Code pattern suggests potential issues
- **Examples**:
  - "Similar pattern caused issues elsewhere" (0.4)
  - "Performance anti-pattern identified" (0.4)
  - "Maintenance complexity concern" (0.4)

### 0.1-0.3: Theoretical/Unvalidated
- **Evidence**: Suspicion or general guidance without specific validation
- **Examples**:
  - "Could potentially cause issues" (0.2)
  - "Might be improved with refactoring" (0.1)
  - "General recommendation for optimization" (0.1)

## Confidence Calculation for Code Reviews

### Single Evidence Source
```
PMD Violation Only: 0.9
RFC Violation Only: 0.7
Manual Review Only: 0.5
```

### Multiple Evidence Sources (Use Weighted Average)
```
PMD + RFC: (0.9 + 0.7) / 2 = 0.8
PMD + Manual: (0.9 + 0.5) / 2 = 0.7
RFC + Manual: (0.7 + 0.5) / 2 = 0.6
PMD + RFC + Manual: (0.9 + 0.7 + 0.5) / 3 = 0.7
```

## Apex Review Confidence Rationale Template

```
"[Primary evidence]: [specific PMD/RFC/manual findings]. [Validation scope]: [what was checked]. [Limitation]: [what wasn't validated]."
```

**Examples**:
- "PMD validation: ApexCRUDViolation at lines 34,59,61. RFC compliance: Violates RFC 5.1 security requirements. Production impact: Immediate data security risk. Limitation: Fix implementation not yet tested." **Score: 0.8**

- "Manual review: Method complexity appears high. RFC reference: Exceeds RFC 3.1 threshold of 10. Evidence: No automated measurement available. Limitation: Exact complexity not calculated." **Score: 0.5**

## Apex-Specific Anti-Patterns

❌ **PMD Ignorance**
- "Code looks fine" (0.7) when PMD shows 20 violations → Should be 0.3-0.4

❌ **Security Minimization**
- "Minor CRUD issue" (0.4) when PMD flags ApexCRUDViolation → Should be 0.9 CRITICAL

❌ **Tool Skepticism**
- "PMD might be wrong" (0.3) for clear rule violations → Should be 0.9

❌ **RFC Speculation**
- "Probably violates RFC" (0.7) without specific standard reference → Should be 0.2-0.3

❌ **Fix Overconfidence**
- "Easy to fix" (0.8) without implementation testing → Should be 0.4-0.5

## Evidence Requirements by Confidence Level

### 0.8-0.9: Production-Critical Evidence Required
- PMD rule violation with line numbers
- RFC standard reference with section number
- Production risk assessment completed
- Specific fix guidance with code examples

### 0.6-0.7: Standards-Based Evidence Required
- RFC standard violation confirmed
- Code inspection completed
- Impact assessment documented
- General fix approach identified

### 0.4-0.5: Review-Based Evidence Required
- Code review completed
- Issue pattern identified
- Potential impact described
- Improvement suggestion provided

### 0.1-0.3: Minimal Evidence Acceptable
- Code inspection started
- Potential issue suspected
- General recommendation only

## Decision Framework for Apex Reviews

### High Confidence (0.8+): Immediate Action Required
- PMD security violations confirmed
- RFC compliance violations validated
- Production deployment risk identified
- Specific fixes documented with examples

### Medium Confidence (0.6-0.7): Sprint Planning Priority
- RFC standard violations confirmed
- Code quality issues identified
- Manual review findings documented
- Fix approach generally understood

### Low Confidence (0.4-0.5): Investigation Needed
- Manual review suggestions only
- Potential improvements identified
- Pattern concerns noted
- Needs validation before action

### Very Low Confidence (0.1-0.3): Monitor Only
- Theoretical concerns
- Unvalidated suspicions
- General recommendations
- No immediate action required

## Remember for Apex Review Work

- PMD findings have highest confidence (0.9) due to automated validation
- RFC mappings add business context but reduce confidence to 0.7-0.8
- Manual review insights cap at 0.5 without tool validation
- Security violations require immediate CRITICAL priority regardless of confidence
- Confidence reflects evidence quality, not fix difficulty or code importance
- Multiple evidence sources increase confidence through triangulation