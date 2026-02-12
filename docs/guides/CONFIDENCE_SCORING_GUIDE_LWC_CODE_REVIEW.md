# Confidence Scoring Guide: LWC Code Review

**Document Owner**: Development Team
**Last Updated**: 2025-10-27
**Purpose**: Establish evidence-based confidence scoring methodology for Lightning Web Component code reviews

---

## Overview

This guide provides a systematic framework for assigning confidence scores (0.0-1.0) to LWC code review findings based on the quality and type of evidence supporting each assessment.

**Core Principle**: "Confidence reflects evidence strength, not issue severity. A critical security flaw with automated detection gets 0.9 confidence. A minor style issue without tooling support gets 0.5 confidence."

---

## Evidence Hierarchy

### Tier 1: Automated Static Analysis (0.9)

**Source**: ESLint-LWC Plugin (`@lwc/eslint-plugin-lwc`)

**Why 0.9**: Objective, automated detection with no human interpretation variance. Rules are maintained by Salesforce and reflect official platform standards.

**Examples**:
- `lwc/no-document-query`: Invalid DOM query at document level
- `lwc/no-deprecated`: Use of deprecated LWC APIs
- `lwc/valid-api`: Invalid `@api` decorator usage
- `lwc/no-inner-html`: Security risk from innerHTML usage

**Scoring Logic**:
```
IF violation detected by ESLint-LWC
THEN confidence = 0.9
```

**Evidence Documentation**:
```json
{
  "violation": "Direct DOM query at document level",
  "evidence_confidence": "0.9",
  "evidence_source": "ESLint-LWC: lwc/no-document-query rule",
  "eslint_rule_id": "lwc/no-document-query"
}
```

---

### Tier 2: Official Salesforce Documentation (0.9)

**Source**: Official Salesforce LWC Developer Guide (developer.salesforce.com/docs/platform/lwc/guide)

**Why 0.9**: Official platform standards documented by Salesforce. Represents authoritative guidance, not community interpretation.

**Examples**:
- @wire preferred over imperative Apex calls (documented performance benefit)
- Lightning Data Service for automatic CRUD/FLS enforcement
- Base `lightning-*` components preferred (documented as "optimized and accessible")
- No DOM manipulation libraries (documented as anti-pattern)

**Scoring Logic**:
```
IF violation contradicts documented Salesforce LWC best practice
THEN confidence = 0.9
```

**Evidence Documentation**:
```json
{
  "violation": "Imperative Apex call when @wire could be used",
  "evidence_confidence": "0.9",
  "evidence_source": "Official Salesforce LWC Guide: @wire recommended for reactive architecture",
  "documentation_url": "https://developer.salesforce.com/docs/platform/lwc/guide/..."
}
```

---

### Tier 3: Security Standards (0.8-0.9)

**Source**: Locker Service requirements, Apex security documentation, OWASP standards

**Why 0.8-0.9**: Security violations have documented attack vectors and platform-enforced protections. High confidence due to clear right/wrong determination.

**Examples**:
- Locker Service violations (lwc:dom="manual" without sanitization)
- Apex missing CRUD/FLS checks (`WITH USER_MODE`, `Security.stripInaccessible()`)
- XSS vulnerabilities (eval, unsafe DOM manipulation)
- Sensitive data exposure (console.log with passwords/tokens)

**Scoring Logic**:
```
IF violation has documented security impact
THEN confidence = 0.9 (if ESLint detected or official doc)
ELSE confidence = 0.8 (if manual detection with clear standards)
```

**Evidence Documentation**:
```json
{
  "violation": "Apex method lacks CRUD/FLS enforcement",
  "evidence_confidence": "0.9",
  "evidence_source": "Official Salesforce Apex Security Documentation",
  "documentation_url": "https://developer.salesforce.com/docs/platform/lwc/guide/apex-security.html",
  "security_impact": "Data security breach - unauthorized record access"
}
```

---

### Tier 4: Accessibility Standards (0.7-0.8)

**Source**: WCAG 2.1 AA standards, Salesforce accessibility guidelines

**Why 0.7-0.8**:
- **0.8** if automated tool (Axe, Lighthouse) detected OR manually tested with screen readers
- **0.7** if based on WCAG standards but not yet tested with assistive technology

**Examples**:
- Missing ARIA labels on interactive elements (WCAG 4.1.2)
- Non-semantic HTML (`<div onclick>` instead of `<button>`)
- Missing keyboard navigation (WCAG 2.1.1)
- Color contrast below 4.5:1 for text (WCAG 1.4.3)

**Scoring Logic**:
```
IF violation detected by automated accessibility tool OR tested with screen reader
THEN confidence = 0.8
ELSE IF violation contradicts WCAG 2.1 AA standard (not yet tested)
THEN confidence = 0.7
```

**Evidence Documentation**:
```json
{
  "violation": "Button lacks accessible label (WCAG 4.1.2)",
  "evidence_confidence": "0.8",
  "evidence_source": "Axe DevTools automated scan + WCAG 2.1 AA standard",
  "wcag_reference": "4.1.2 Name, Role, Value (Level A)",
  "accessibility_impact": "Screen reader users cannot understand button purpose"
}
```

---

### Tier 5: Project CSS Architecture Standards (0.6-0.7)

**Source**: @docs/CSS_ARCHITECTURE_GUIDE.md, @docs/personas/LWC_FRONTEND_ENGINEER.md

**Why 0.6-0.7**: Project-specific standards with clear documentation but not platform-enforced.

**Examples**:
- BEM methodology violations (incorrect Block-Element-Modifier naming)
- Inline styles instead of CSS files
- Legacy design tokens instead of SLDS 2 styling hooks
- Missing design tokens in `:host`

**Scoring Logic**:
```
IF violation contradicts documented project CSS standard
THEN confidence = 0.7 (if pattern is explicit in guide)
ELSE confidence = 0.6 (if pattern is implied/recommended)
```

**Evidence Documentation**:
```json
{
  "violation": "Inline styles used instead of CSS file",
  "evidence_confidence": "0.7",
  "evidence_source": "@docs/CSS_ARCHITECTURE_GUIDE.md - No inline styles policy",
  "project_impact": "Cannot theme, maintain, or reuse styling"
}
```

---

### Tier 6: Manual Code Review (0.5-0.6)

**Source**: Reviewer inspection without automated tools or explicit standards

**Why 0.5-0.6**: Subjective assessment based on experience. Higher variance between reviewers.

**Examples**:
- Code complexity concerns (no complexity threshold defined)
- Naming clarity issues (subjective readability)
- Component organization preferences
- Performance suspicions without profiling data

**Scoring Logic**:
```
IF observation based on best practices but no explicit standard
THEN confidence = 0.6
ELSE IF observation is reviewer opinion/preference
THEN confidence = 0.5
```

**Evidence Documentation**:
```json
{
  "issue": "Method appears overly complex",
  "evidence_confidence": "0.5",
  "evidence_source": "Manual code review - subjective complexity assessment",
  "recommendation": "Consider refactoring for clarity"
}
```

---

### Tier 7: Testing Gaps (0.6)

**Source**: Missing Jest tests for logic-heavy components

**Why 0.6**: Testing is recommended but not mandatory for LWC (unlike Apex 75% requirement). Clear guideline exists (test logic, skip presentational) but not enforced.

**Examples**:
- Component with complex logic lacks Jest tests
- Test coverage below 80% for logic-heavy components
- Missing test cases for error handling

**Scoring Logic**:
```
IF logic-heavy component lacks tests
THEN confidence = 0.6 (clear recommendation, not requirement)
```

**Evidence Documentation**:
```json
{
  "issue": "Logic-heavy component lacks Jest tests",
  "evidence_confidence": "0.6",
  "evidence_source": "Salesforce Jest testing recommendations (not mandatory)",
  "recommendation": "Add tests for selection logic and event dispatching"
}
```

---

### Tier 8: Theoretical/Unvalidated (0.1-0.3)

**Source**: Speculation without evidence

**Why 0.1-0.3**: No supporting evidence, standards, or tools. Pure conjecture.

**Examples**:
- "This might cause performance issues" (without profiling)
- "Users probably won't understand this" (without user testing)
- "This could be a problem in the future" (without specific scenario)

**Scoring Logic**:
```
IF concern has no supporting evidence or standards
THEN confidence = 0.1-0.3 (depending on plausibility)
```

**Evidence Documentation**:
```json
{
  "concern": "Component might have performance issues with large datasets",
  "evidence_confidence": "0.3",
  "evidence_source": "Theoretical concern - no profiling data available",
  "recommendation": "Monitor performance metrics in production"
}
```

---

## Weighted Confidence Calculation

When multiple evidence sources support a finding, calculate weighted average:

### Formula
```
Overall Confidence = (Source1_Confidence * Source1_Weight + Source2_Confidence * Source2_Weight) / Total_Weight
```

### Example 1: ESLint + Official Docs
**Finding**: Component uses imperative Apex call when @wire available

```
ESLint Detection: No (manual observation) = 0 weight
Official Docs: Yes (documented @wire preference) = 0.9 confidence
Manual Review: Yes (confirmed pattern exists) = 0.5 confidence

Calculation:
(0.9 * 1.0 + 0.5 * 0.5) / 1.5 = 0.77

Overall Confidence: 0.8 (rounded up for documented standard)
```

### Example 2: Security Violation with Multiple Sources
**Finding**: Missing CRUD check in Apex

```
ESLint Detection: No (Apex not in ESLint scope) = 0 weight
Official Docs: Yes (Apex security documented) = 0.9 confidence
Security Impact: Yes (documented attack vector) = 0.9 confidence
Manual Review: Yes (confirmed missing check) = 0.6 confidence

Calculation:
(0.9 * 1.0 + 0.9 * 1.0 + 0.6 * 0.3) / 2.3 = 0.86

Overall Confidence: 0.9 (security violations rounded to 0.8+)
```

### Example 3: Accessibility Issue
**Finding**: Button lacks ARIA label

```
Axe DevTools: Yes (automated detection) = 0.9 confidence
WCAG 2.1 AA: Yes (standard 4.1.2) = 0.9 confidence
Screen Reader Test: Not performed = 0 weight

Calculation:
(0.9 * 1.0 + 0.9 * 1.0) / 2.0 = 0.9

Overall Confidence: 0.9 (but note: screen reader testing still recommended)
```

---

## Priority vs. Confidence

**IMPORTANT**: Priority (severity) is INDEPENDENT from confidence (evidence strength).

| Finding | Confidence | Priority | Rationale |
|---------|-----------|----------|-----------|
| ESLint detects XSS vulnerability | 0.9 | CRITICAL | High confidence + high severity |
| Missing ARIA label (Axe detected) | 0.9 | CRITICAL | High confidence + accessibility blocker |
| Reviewer suspects performance issue | 0.3 | LOW | Low confidence (theoretical concern) |
| Inline styles found | 0.7 | MEDIUM | High confidence + medium severity |
| Complex method (no threshold) | 0.5 | LOW | Medium confidence + low severity |

**Decision Rule**:
- **CRITICAL Priority**: Security or accessibility violations (confidence ≥ 0.7)
- **HIGH Priority**: Code standards violations with tools/docs (confidence ≥ 0.7)
- **MEDIUM Priority**: Project standards violations (confidence 0.6-0.7)
- **LOW Priority**: Subjective recommendations (confidence < 0.6)

---

## Confidence Rationale Template

Every finding must include a confidence rationale explaining the score:

### Template
```
"confidence_rationale": "[Evidence type]: [specific sources]. [Triangulation]: [consistency across sources]. [Documentation]: [official reference quality]. [Limitation]: [what's still uncertain]."
```

### Example 1: High Confidence (0.9)
```json
{
  "confidence_score": "0.9",
  "confidence_rationale": "ESLint-LWC: lwc/no-document-query rule violation at line 45. Official Salesforce docs: Locker Service requires template queries for security. Triangulation: Automated tool + official standard alignment. Limitation: None - clear violation with documented fix."
}
```

### Example 2: Medium Confidence (0.7)
```json
{
  "confidence_score": "0.7",
  "confidence_rationale": "Project CSS standard: @docs/CSS_ARCHITECTURE_GUIDE.md explicitly prohibits inline styles. Manual review: 3 instances found in simPreChatForm.html. Triangulation: Consistent with project standards. Limitation: Not platform-enforced, project-specific policy."
}
```

### Example 3: Low Confidence (0.5)
```json
{
  "confidence_score": "0.5",
  "confidence_rationale": "Manual review: Method appears complex with nested conditionals. No automated complexity metrics available. No project-defined complexity threshold. Triangulation: Subjective assessment only. Limitation: Needs cyclomatic complexity analysis for objective measurement."
}
```

---

## Common Confidence Scoring Scenarios

### Scenario 1: ESLint Violation
```
Finding: lwc/no-inner-html triggered
Evidence: Automated ESLint detection
Confidence: 0.9
Rationale: "ESLint-LWC rule violation with clear security implications"
```

### Scenario 2: Official Salesforce Best Practice
```
Finding: Custom button component instead of lightning-button
Evidence: Official docs recommend base components
Confidence: 0.9
Rationale: "Official Salesforce LWC Guide: Use base components first (optimized, accessible)"
```

### Scenario 3: Security Without Automation
```
Finding: Apex missing WITH USER_MODE
Evidence: Official Apex security docs, manual review
Confidence: 0.9
Rationale: "Official Salesforce security documentation + confirmed via manual inspection"
```

### Scenario 4: Accessibility (Automated)
```
Finding: Missing alt text on image
Evidence: Axe DevTools detection
Confidence: 0.8
Rationale: "Axe DevTools automated scan + WCAG 1.1.1 standard"
```

### Scenario 5: CSS Architecture
```
Finding: Inline styles used
Evidence: Project CSS guide, manual review
Confidence: 0.7
Rationale: "@docs/CSS_ARCHITECTURE_GUIDE.md policy + confirmed instances"
```

### Scenario 6: Testing Gap
```
Finding: Logic component lacks Jest tests
Evidence: Salesforce testing recommendations
Confidence: 0.6
Rationale: "Recommended but not mandatory per Salesforce Jest guidance"
```

### Scenario 7: Code Complexity
```
Finding: Method seems complex
Evidence: Reviewer observation
Confidence: 0.5
Rationale: "Subjective assessment - no complexity metrics or thresholds defined"
```

### Scenario 8: Performance Concern
```
Finding: Potential performance issue
Evidence: Speculation, no data
Confidence: 0.3
Rationale: "Theoretical concern - no profiling data or documented thresholds"
```

---

## Quality Checklist

Before finalizing confidence scores, verify:

- [ ] Every finding has explicit confidence score (0.0-1.0)
- [ ] Every finding has confidence rationale explaining score
- [ ] Evidence sources are documented (ESLint, docs, manual, etc.)
- [ ] Automated findings (ESLint, Axe) scored at 0.9
- [ ] Official Salesforce docs violations scored at 0.9
- [ ] Security violations scored at 0.8-0.9
- [ ] Project standards violations scored at 0.6-0.7
- [ ] Manual subjective observations scored at 0.5-0.6
- [ ] Theoretical concerns scored at 0.1-0.3
- [ ] Priority is independent from confidence

---

## Integration with LWC_CODE_REVIEW.md

The LWC code review prompt uses this framework to:
1. Parse ESLint violations (automatic 0.9 confidence)
2. Cross-reference with official Salesforce standards (0.9 confidence if violated)
3. Apply project standards (0.6-0.7 confidence)
4. Document manual findings (0.5-0.6 confidence)
5. Calculate weighted overall assessment confidence
6. Prioritize fixes by impact, not just confidence

**Result**: Evidence-based, defensible code review assessments for managed services clients.
