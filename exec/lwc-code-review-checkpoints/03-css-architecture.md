# Checkpoint: CSS Architecture Standards

## Priority
HIGH

## Objective
Validate CSS architecture follows BEM methodology, SLDS 2 styling hooks, design token usage, and maintainability best practices as defined in @docs/CSS_ARCHITECTURE_GUIDE.md.

## Scope
Analyze CSS files (.css) in LWC components for:
- BEM (Block-Element-Modifier) naming methodology
- SLDS 2 styling hooks (CSS custom properties)
- Design tokens centralized in :host
- No inline styles in HTML
- Shadow DOM awareness
- Utility class usage

## Review Standards
- **Project Standard**: @docs/CSS_ARCHITECTURE_GUIDE.md
- **Platform Standard**: Salesforce Lightning Design System (SLDS) 2.0
- **Methodology**: BEM naming convention
- **Theming**: CSS custom properties for design tokens

## Input Requirements
```json
{
  "files": ["array of .css and .html file paths"],
  "file_contents": ["array of file content strings matching files array"]
}
```

## Task

**Step 1: BEM Methodology Validation**

Check CSS selectors follow BEM naming pattern:

```css
/* ✅ Good - BEM naming */
.block { }
.block__element { }
.block__element--modifier { }
.block--modifier { }

/* ❌ Bad - Non-BEM naming */
.blockElement { }  /* camelCase not allowed */
.block_element { }  /* Single underscore not BEM */
.block-element-modifier { }  /* Missing __ separator */
```

**BEM Pattern Requirements**:
- **Block**: `.blockName` (single class, no separators)
- **Element**: `.blockName__elementName` (double underscore)
- **Modifier**: `.blockName--modifierName` or `.blockName__elementName--modifierName` (double dash)

**Step 2: SLDS 2 Styling Hooks**

Validate use of CSS custom properties (--slds-*) instead of legacy design tokens:

```css
/* ❌ Bad - Legacy SLDS tokens */
.button {
    background-color: #0176d3;  /* Hardcoded SLDS blue */
    padding: 0.5rem 1rem;  /* Hardcoded spacing */
}

/* ✅ Good - SLDS 2 custom properties */
.button {
    background-color: var(--slds-c-button-brand-color-background, #0176d3);
    padding: var(--slds-c-button-spacing-block-start, 0.5rem) var(--slds-c-button-spacing-inline, 1rem);
}
```

**SLDS 2 Categories to Check**:
- `--slds-c-*` (component tokens)
- `--slds-g-*` (global tokens)
- Fallback values provided: `var(--token-name, fallback)`

**Step 3: Design Tokens in :host**

Validate centralized design tokens are defined in `:host` selector:

```css
/* ✅ Good - Centralized tokens */
:host {
    --spacing-sm: 0.5rem;
    --spacing-md: 1rem;
    --spacing-lg: 1.5rem;
    --color-primary: #0176d3;
    --color-text: #374151;
}

.form-section {
    margin-bottom: var(--spacing-md);
    color: var(--color-text);
}

/* ❌ Bad - No centralization */
.form-section {
    margin-bottom: 1rem;  /* Magic number, not reusable */
    color: #374151;  /* Hardcoded color */
}
```

**Token Categories to Enforce**:
- Spacing: `--spacing-*`
- Colors: `--color-*`
- Typography: `--font-*`
- Borders: `--border-*`
- Shadows: `--shadow-*`

**Step 4: Inline Styles Detection**

Scan HTML files for `style=""` attributes:

```html
<!-- ❌ Bad - Inline styles -->
<div style="margin-top: 20px; color: #374151;">
    Content
</div>

<!-- ✅ Good - CSS class -->
<div class="content-section">
    Content
</div>
```

Flag ANY inline styles as violations.

**Step 5: Shadow DOM Awareness**

Validate CSS custom properties are used correctly across shadow boundaries:

```css
/* ✅ Good - Custom properties traverse shadow DOM */
:host {
    --button-bg: var(--slds-c-button-brand-color-background);
}

.button {
    background-color: var(--button-bg);
}

/* ❌ Bad - Direct styling won't work in child components */
.child-component-class {
    /* This won't style child LWC components */
}
```

**Step 6: Utility Class Usage**

Check for utility classes for common patterns:

```css
/* ✅ Good - Utility classes for layout/spacing */
.slds-m-top_medium { }
.slds-p-horizontal_small { }

/* ❌ Bad - Repetitive custom classes */
.section-margin-top { margin-top: 1rem; }
.section-padding-left { padding-left: 0.5rem; }
```

Recommend SLDS utility classes when custom classes repeat layout patterns.

## Output Format
```json
{
  "checkpoint_name": "css-architecture",
  "checkpoint_priority": "HIGH",
  "status": "pass|fail|warning",
  "violations": [
    {
      "severity": "high|medium|low",
      "category": "CSS Architecture: [subcategory]",
      "file": "[path]",
      "line": "[number]",
      "issue": "[description]",
      "evidence": "[code snippet]",
      "fix_guidance": "[specific fix with code example]",
      "confidence": 0.7,
      "project_reference": "@docs/CSS_ARCHITECTURE_GUIDE.md"
    }
  ],
  "summary": {
    "bem_violations": "[count]",
    "inline_styles": "[count]",
    "slds2_opportunities": "[count]",
    "design_token_missing": "[count]",
    "shadow_dom_issues": "[count]",
    "utility_class_opportunities": "[count]",
    "production_blocker": false
  }
}
```

**Status Logic:**
- `status: "fail"` if inline styles > 0 OR BEM violations > 5
- `status: "warning"` if BEM violations < 5 OR missing design tokens
- `status: "pass"` if no violations

## Confidence Scoring
- **Inline styles**: 0.9 (objective detection in HTML)
- **BEM naming**: 0.8 (pattern matching against BEM rules)
- **SLDS 2 usage**: 0.7 (requires understanding of SLDS evolution)
- **Design tokens**: 0.7 (pattern detection in :host)
- **Shadow DOM**: 0.6 (requires architectural understanding)

## Success Criteria
- All inline styles flagged
- BEM naming violations identified with examples
- SLDS 2 custom property opportunities suggested
- Design token centralization recommended
- Fix guidance includes working CSS examples

## Fix Guidance Examples

### BEM Violation
```css
/* ❌ Bad */
.formInput { }

/* ✅ Good */
.form__input { }
```

### Inline Styles
```html
<!-- ❌ Bad -->
<div style="margin-top: 20px; color: #374151;">Content</div>

<!-- ✅ Good CSS -->
:host {
    --spacing-md: 20px;
    --color-text: #374151;
}
.content-section {
    margin-top: var(--spacing-md);
    color: var(--color-text);
}

<!-- ✅ Good HTML -->
<div class="content-section">Content</div>
```

### SLDS 2 Styling Hooks
```css
/* ❌ Bad */
.button {
    background-color: #0176d3;
    padding: 0.5rem 1rem;
}

/* ✅ Good */
.button {
    background-color: var(--slds-c-button-brand-color-background, #0176d3);
    padding: var(--slds-c-button-spacing-block-start, 0.5rem)
             var(--slds-c-button-spacing-inline, 1rem);
}
```

### Design Token Centralization
```css
/* ❌ Bad - Magic numbers scattered */
.header { padding: 1rem; }
.section { padding: 1rem; }
.footer { padding: 1rem; }

/* ✅ Good - Centralized token */
:host {
    --spacing-section: 1rem;
}
.header { padding: var(--spacing-section); }
.section { padding: var(--spacing-section); }
.footer { padding: var(--spacing-section); }
```
