# CSS Architecture Guide: BEM + Utilities for SIM LWC Components

**Status**: Living Document
**Owner**: Development Team
**Last Updated**: 2025-10-12
**Purpose**: Standardize CSS architecture across LWC components for consistency, maintainability, and team velocity

---

## Table of Contents

1. [Why BEM + Utilities?](#why-bem--utilities)
2. [Design Tokens (CSS Custom Properties)](#design-tokens)
3. [BEM Naming Conventions](#bem-naming-conventions)
4. [Utility Classes](#utility-classes)
5. [Component Patterns](#component-patterns)
6. [File Organization](#file-organization)
7. [Quick Reference](#quick-reference)
8. [Anti-Patterns](#anti-patterns)

---

## Why BEM + Utilities?

### The Hybrid Approach

We use **BEM (Block Element Modifier)** for component-specific styling combined with **utility classes** for layout and spacing. This approach is ideal for Lightning Web Components because:

1. **Shadow DOM Encapsulation**: LWC automatically scopes CSS via Shadow DOM - no naming collisions
2. **Clear Relationships**: BEM makes component hierarchy obvious
3. **Reusable Layouts**: Utility classes prevent repetitive layout code
4. **Team Velocity**: New developers can quickly understand the pattern
5. **No Build Tools**: Works natively without webpack/PostCSS complexity

### Why NOT Other Approaches?

| Approach | Why Not for LWC |
|----------|-----------------|
| Pure Utility (Tailwind-like) | Too verbose in HTML, no Tailwind in LWC |
| CSS Modules | Build tool overhead, Shadow DOM already provides scoping |
| CSS-in-JS | Not supported in LWC, performance concerns |
| SLDS Only | Limited flexibility, can't achieve custom designs like card-based selection |

---

## Design Tokens

### The Foundation: CSS Custom Properties

All design values are centralized in `:host` as CSS custom properties. This makes brand updates trivial and ensures consistency.

**File Location**: Every LWC component's `.css` file starts with:

```css
:host {
  /* ============================================
     COLORS - SIM Brand
     ============================================ */
  --color-primary: #1394af;              /* SIM teal - primary actions */
  --color-primary-hover: #0f7a94;        /* Darker teal for hover */
  --color-text-primary: #374151;         /* Dark gray - body text */
  --color-text-secondary: #6b7280;       /* Medium gray - secondary text */
  --color-text-placeholder: #9ca3af;     /* Light gray - placeholders */
  --color-text-dark: #101828;            /* Very dark gray - chat messages (from Figma) */
  --color-error: #ef4444;                /* Red - errors/required */
  --color-focus: #3b82f6;                /* Blue - focus states */
  --color-border: #e5e7eb;               /* Light gray - borders */
  --color-background-light: #f5f5f5;     /* Input backgrounds */
  --color-background-page: #f8f9fa;      /* Page background */

  /* ============================================
     SPACING SYSTEM (8px base grid)
     ============================================ */
  --spacing-xs: 4px;   /* 0.5× base */
  --spacing-sm: 8px;   /* 1× base */
  --spacing-md: 16px;  /* 2× base */
  --spacing-lg: 24px;  /* 3× base */
  --spacing-xl: 32px;  /* 4× base */

  /* ============================================
     TYPOGRAPHY
     ============================================ */
  --font-family: 'Montserrat', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-size-xs: 12px;
  --font-size-sm: 14px;
  --font-size-base: 16px;
  --font-size-lg: 18px;

  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;

  /* Chat Message Content Typography (from Figma) */
  --chat-message-font-size: 14px;
  --chat-message-line-height: 22.75px;
  --chat-message-font-weight: 400;
  --chat-message-letter-spacing: 0px;

  /* ============================================
     BORDERS & RADIUS
     ============================================ */
  --border-width: 1px;
  --border-radius-sm: 6px;
  --border-radius-md: 8px;
  --border-radius-full: 50%;

  /* ============================================
     SHADOWS
     ============================================ */
  --shadow-sm: 0 2px 4px rgba(0, 0, 0, 0.1);
  --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.15);
  --shadow-focus: 0 0 0 3px rgba(59, 130, 246, 0.1);

  /* ============================================
     TRANSITIONS
     ============================================ */
  --transition-base: 0.2s ease;
  --transition-slow: 0.3s ease;

  /* ============================================
     COMPONENT DIMENSIONS
     ============================================ */
  --height-interactive: 48px;    /* Buttons, inputs, selects */
  --width-icon: 48px;            /* Icon containers */
  --max-width-form: 400px;       /* Form containers */

  /* Chat Widget Container (from Figma) */
  --chat-widget-width: 400px;    /* Overall chat widget width */
  --chat-widget-max-width: 400px; /* Max width for responsive */
}
```

### Usage Example

```css
.submit-button {
  background-color: var(--color-primary);
  border-radius: var(--border-radius-sm);
  transition: all var(--transition-base);
}
```

---

## BEM Naming Conventions

### Structure

```
.block                  /* Independent component */
.block__element         /* Part of the block */
.block--modifier        /* Variation of the block */
.block__element--modifier  /* Variation of the element */
```

### Real Examples from simPreChatForm

#### 1. Form Field Component

```css
/* Block: The main component */
.form-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

/* Elements: Parts of the form-field */
.form-field__label {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-primary);
}

.form-field__input {
  height: var(--height-interactive);
  padding: 0 12px;
  background: var(--color-background-light);
  border: var(--border-width) solid var(--color-border);
  border-radius: var(--border-radius-sm);
  transition: all var(--transition-base);
}

.form-field__error {
  font-size: var(--font-size-xs);
  color: var(--color-error);
}

/* Modifier: State variation */
.form-field__input--invalid {
  border-color: var(--color-error);
}
```

#### 2. Persona Card Component (New Pattern)

```css
/* Block */
.persona-card {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  padding: var(--spacing-md);
  background: white;
  border: var(--border-width) solid var(--color-border);
  border-radius: var(--border-radius-sm);
  cursor: pointer;
  transition: all var(--transition-base);
}

/* Modifier: Selected state */
.persona-card--selected {
  border-color: var(--color-primary);
  background: rgba(19, 148, 175, 0.05);
  box-shadow: var(--shadow-sm);
}

/* Elements */
.persona-card__icon {
  flex-shrink: 0;
  width: var(--width-icon);
  height: var(--width-icon);
  border-radius: var(--border-radius-full);
  background: var(--color-background-light);
  display: flex;
  align-items: center;
  justify-content: center;
}

.persona-card__content {
  flex: 1;
}

.persona-card__title {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-primary);
  margin: 0 0 4px 0;
}

.persona-card__description {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
  margin: 0;
}
```

#### 3. Button Component

```css
/* Block */
.button {
  height: var(--height-interactive);
  padding: 0 var(--spacing-lg);
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-medium);
  border: none;
  border-radius: var(--border-radius-sm);
  cursor: pointer;
  transition: all var(--transition-base);
}

/* Modifier: Primary button */
.button--primary {
  background: var(--color-primary);
  color: white;
}

.button--primary:hover:not(:disabled) {
  background: var(--color-primary-hover);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(19, 148, 175, 0.3);
}

/* Modifier: Disabled state */
.button:disabled {
  background: var(--color-text-placeholder);
  cursor: not-allowed;
  transform: none;
}
```

### BEM Naming Rules

1. **Block names**: Describe what it is, not what it looks like
   - ✅ `.persona-card` (describes component)
   - ❌ `.blue-box` (describes appearance)

2. **Element names**: Single underscore, describes relationship
   - ✅ `.persona-card__title`
   - ❌ `.persona-card__content__title` (don't nest elements)

3. **Modifier names**: Double dash, describes variation
   - ✅ `.persona-card--selected`
   - ❌ `.persona-card-selected` (use double dash)

4. **No nesting in class names**: BEM elements are always children of the block
   - ✅ `.card__header`, `.card__body`, `.card__footer`
   - ❌ `.card__header__title` (flat structure only)

---

## Utility Classes

### Layout Utilities

Reusable classes for common layout patterns. Defined once, used everywhere.

```css
/* ============================================
   FLEXBOX UTILITIES
   ============================================ */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.flex-row { flex-direction: row; }
.items-center { align-items: center; }
.justify-center { justify-content: center; }
.justify-between { justify-content: space-between; }

/* ============================================
   GAP UTILITIES (using 8px grid)
   ============================================ */
.gap-xs { gap: var(--spacing-xs); }   /* 4px */
.gap-sm { gap: var(--spacing-sm); }   /* 8px */
.gap-md { gap: var(--spacing-md); }   /* 16px */
.gap-lg { gap: var(--spacing-lg); }   /* 24px */

/* ============================================
   PADDING UTILITIES
   ============================================ */
.p-xs { padding: var(--spacing-xs); }
.p-sm { padding: var(--spacing-sm); }
.p-md { padding: var(--spacing-md); }
.p-lg { padding: var(--spacing-lg); }

/* ============================================
   MARGIN UTILITIES
   ============================================ */
.m-xs { margin: var(--spacing-xs); }
.m-sm { margin: var(--spacing-sm); }
.m-md { margin: var(--spacing-md); }
.m-lg { margin: var(--spacing-lg); }

/* ============================================
   STATE UTILITIES
   ============================================ */
.hidden { display: none; }
.visible { display: block; }
.disabled { pointer-events: none; opacity: 0.5; }
```

### Usage Example

```html
<div class="flex flex-col gap-md">
  <div class="persona-card persona-card--selected">
    <div class="persona-card__icon">
      <lightning-icon icon-name="utility:search"></lightning-icon>
    </div>
    <div class="persona-card__content">
      <h3 class="persona-card__title">Explorer</h3>
      <p class="persona-card__description">Exploring SIM programmes</p>
    </div>
  </div>
</div>
```

---

## Component Patterns

### Pattern 1: Chat Message Bubble

```html
<div class="chat-message">
  <div class="chat-message__header">
    <div class="chat-message__avatar"></div>
    <span class="chat-message__author">Charlene</span>
    <span class="chat-message__timestamp">06:02 PM</span>
  </div>
  <div class="chat-message__content">
    Hi, I am Charlene, your digital AI assistant.
  </div>
</div>
```

```css
.chat-message {
  background: var(--color-background-light);
  border-radius: var(--border-radius-md);
  padding: var(--spacing-md);
  margin-bottom: var(--spacing-md);
}

.chat-message__header {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  margin-bottom: var(--spacing-sm);
}

.chat-message__avatar {
  width: 32px;
  height: 32px;
  border-radius: var(--border-radius-full);
  background: var(--color-text-secondary);
}

.chat-message__author {
  font-weight: var(--font-weight-medium);
  color: var(--color-text-primary);
}

.chat-message__timestamp {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
}

.chat-message__content {
  font-family: var(--font-family);
  font-size: var(--chat-message-font-size);
  font-weight: var(--chat-message-font-weight);
  line-height: var(--chat-message-line-height);
  letter-spacing: var(--chat-message-letter-spacing);
  color: var(--color-text-dark);
}
```

**Figma Specs Applied**:
- ✅ Font: Montserrat 400 (Regular)
- ✅ Size: 14px
- ✅ Line height: 22.75px
- ✅ Letter spacing: 0px
- ✅ Color: #101828 (very dark gray)
- ✅ Layout dimensions: 298px width × 46px height (for message bubble)

---

### Pattern 2: Interactive Card with Icon

```html
<div class="selection-card" onclick={handleSelect} data-value="option1">
  <div class="selection-card__icon">
    <lightning-icon icon-name="utility:user" size="small"></lightning-icon>
  </div>
  <div class="selection-card__content">
    <h4 class="selection-card__title">Option Title</h4>
    <p class="selection-card__description">Brief description here</p>
  </div>
</div>
```

```css
.selection-card {
  display: flex;
  align-items: center;
  gap: var(--spacing-md);
  padding: var(--spacing-md);
  background: white;
  border: var(--border-width) solid var(--color-border);
  border-radius: var(--border-radius-sm);
  cursor: pointer;
  transition: all var(--transition-base);
}

.selection-card:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-sm);
  transform: translateY(-1px);
}

.selection-card--selected {
  border-color: var(--color-primary);
  background: rgba(19, 148, 175, 0.05);
}

.selection-card__icon {
  flex-shrink: 0;
  width: var(--width-icon);
  height: var(--width-icon);
  border-radius: var(--border-radius-full);
  background: var(--color-background-light);
  display: flex;
  align-items: center;
  justify-content: center;
}

.selection-card__content {
  flex: 1;
}

.selection-card__title {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-primary);
  margin: 0 0 4px 0;
}

.selection-card__description {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
  margin: 0;
}
```

### Pattern 3: Form Input with Label and Error

```html
<div class="form-field">
  <label class="form-field__label">
    Email Address
    <span class="form-field__required">*</span>
  </label>
  <input
    type="email"
    class="form-field__input"
    placeholder="name@example.com"
  />
  <span class="form-field__error">Please enter a valid email</span>
</div>
```

```css
.form-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-field__label {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-primary);
}

.form-field__required {
  color: var(--color-error);
  margin-left: 2px;
}

.form-field__input {
  height: var(--height-interactive);
  padding: 0 12px;
  background: var(--color-background-light);
  border: var(--border-width) solid var(--color-border);
  border-radius: var(--border-radius-sm);
  font-size: var(--font-size-sm);
  transition: all var(--transition-base);
}

.form-field__input:focus {
  outline: none;
  border-color: var(--color-focus);
  background: white;
  box-shadow: var(--shadow-focus);
}

.form-field__input::placeholder {
  color: var(--color-text-placeholder);
}

.form-field__error {
  font-size: var(--font-size-xs);
  color: var(--color-error);
}
```

### Pattern 4: Chat Header (From Figma Specs)

**Design Source**: Figma mockups
**Dimensions**: 400px (Fill) × 80px (Fixed Height)

```html
<header class="chat-header">
  <div class="chat-header__brand">
    <div class="chat-header__icon">
      <lightning-icon icon-name="utility:chat" size="x-small" variant="inverse"></lightning-icon>
    </div>
    <div class="chat-header__text">
      <h1 class="chat-header__title">SIM Support</h1>
      <p class="chat-header__subtitle">Charlene is here to help!</p>
    </div>
  </div>
  <button class="chat-header__close" onclick={handleClose} aria-label="Close chat">
    <lightning-icon icon-name="utility:close" size="small" variant="inverse"></lightning-icon>
  </button>
</header>
```

```css
/* ==================================================
   CHAT HEADER DESIGN TOKENS (from Figma)
   ================================================== */
:host {
  /* Header-specific tokens */
  --chat-header-height: 80px;
  --chat-header-bg: #000000;
  --chat-header-padding: 20px;

  /* Icon container */
  --chat-icon-size: 40px;
  --chat-icon-radius: 28px;
  --chat-icon-bg: rgba(255, 255, 255, 0.2);
  --chat-icon-padding: 10px;

  /* Typography - Title */
  --chat-title-size: 15px;
  --chat-title-line-height: 22.5px;
  --chat-title-weight: 500;
  --chat-title-color: #FFFFFF;

  /* Typography - Subtitle */
  --chat-subtitle-size: 12px;
  --chat-subtitle-line-height: 16px;
  --chat-subtitle-weight: 400;
  --chat-subtitle-color: rgba(255, 255, 255, 0.9);

  /* Layout */
  --chat-header-gap: 12px;
}

/* ==================================================
   CHAT HEADER COMPONENT
   ================================================== */
.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  height: var(--chat-header-height);
  background: var(--chat-header-bg);
  padding: 0 var(--chat-header-padding);
}

.chat-header__brand {
  display: flex;
  align-items: center;
  gap: var(--chat-header-gap);
}

.chat-header__icon {
  width: var(--chat-icon-size);
  height: var(--chat-icon-size);
  background: var(--chat-icon-bg);
  border-radius: var(--chat-icon-radius);
  padding: var(--chat-icon-padding);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.chat-header__text {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.chat-header__title {
  font-family: var(--font-family);
  font-size: var(--chat-title-size);
  font-weight: var(--chat-title-weight);
  line-height: var(--chat-title-line-height);
  color: var(--chat-title-color);
  margin: 0;
}

.chat-header__subtitle {
  font-family: var(--font-family);
  font-size: var(--chat-subtitle-size);
  font-weight: var(--chat-subtitle-weight);
  line-height: var(--chat-subtitle-line-height);
  color: var(--chat-subtitle-color);
  margin: 0;
}

.chat-header__close {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  transition: opacity var(--transition-base);
}

.chat-header__close:hover {
  opacity: 0.8;
}

.chat-header__close:active {
  opacity: 0.6;
}
```

**Figma Specs Applied**:
- ✅ Container: 400px × 80px with black background
- ✅ Horizontal layout with space-between
- ✅ Icon container: 40px × 40px, 28px radius, 20% white opacity
- ✅ Title: Montserrat 500, 15px, 22.5px line-height
- ✅ Subtitle: Montserrat 400, 12px, 16px line-height, 90% opacity
- ✅ 12px gap between icon and text
- ✅ 20px horizontal padding

---

## File Organization

### LWC Component Structure

```
simPreChatForm/
├── simPreChatForm.html         # Template with BEM classes
├── simPreChatForm.js           # Component logic
├── simPreChatForm.css          # Styles following this guide
└── simPreChatForm.js-meta.xml  # Metadata
```

### CSS File Structure

Every `.css` file should follow this order:

```css
/* 1. Design Tokens (:host) */
:host {
  /* All CSS custom properties */
}

/* 2. Layout Utilities (if needed) */
.flex { display: flex; }
.gap-md { gap: var(--spacing-md); }

/* 3. Component Styles (BEM blocks) */
.block { /* ... */ }
.block__element { /* ... */ }
.block--modifier { /* ... */ }

/* 4. State Classes */
.hidden { display: none; }
.disabled { opacity: 0.5; }
```

---

## Quick Reference

### Creating a New Component

1. **Start with design tokens** in `:host`
2. **Use BEM for component-specific styles**
3. **Add utility classes for layout**
4. **Follow the 8px spacing grid**
5. **Use CSS custom properties for all values**

### Checklist

- [ ] Design tokens defined in `:host`
- [ ] BEM naming follows conventions (`.block__element--modifier`)
- [ ] Utility classes used for layout/spacing
- [ ] Interactive elements are 48px height
- [ ] Hover/focus states defined
- [ ] Transitions use `var(--transition-base)`
- [ ] Colors reference CSS custom properties
- [ ] Mobile-responsive (flexbox, max-width)

### Common Patterns

| Pattern | When to Use | Example |
|---------|-------------|---------|
| `flex flex-col gap-md` | Vertical stacking with spacing | Form fields, card lists |
| `flex items-center gap-sm` | Horizontal items with icons | Headers, button groups |
| `border-radius: var(--border-radius-sm)` | Interactive elements | Buttons, inputs, cards |
| `transition: all var(--transition-base)` | Smooth interactions | Hover states, focus |
| `height: var(--height-interactive)` | Clickable elements | Buttons, inputs, selects |

---

## Anti-Patterns

### ❌ What NOT to Do

#### 1. Don't Use Inline Styles

```html
<!-- ❌ BAD -->
<div style="display: flex; gap: 16px;">

<!-- ✅ GOOD -->
<div class="flex gap-md">
```

#### 2. Don't Nest BEM Elements

```css
/* ❌ BAD */
.card__header__title { }

/* ✅ GOOD */
.card__header { }
.card__title { }
```

#### 3. Don't Use Magic Numbers

```css
/* ❌ BAD */
.button {
  padding: 13px 17px;
  margin-top: 23px;
}

/* ✅ GOOD */
.button {
  padding: var(--spacing-md) var(--spacing-lg);
  margin-top: var(--spacing-lg);
}
```

#### 4. Don't Repeat Layout Code

```css
/* ❌ BAD */
.form-fields {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.persona-cards {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* ✅ GOOD */
.flex-col { flex-direction: column; }
.gap-md { gap: var(--spacing-md); }

/* In HTML */
<div class="flex flex-col gap-md">
```

#### 5. Don't Use Generic Class Names

```css
/* ❌ BAD */
.box { }
.container { }
.item { }

/* ✅ GOOD */
.persona-card { }
.form-container { }
.chat-message { }
```

#### 6. Don't Hardcode Brand Colors

```css
/* ❌ BAD */
.submit-button {
  background: #1394af;
}

/* ✅ GOOD */
.submit-button {
  background: var(--color-primary);
}
```

---

## Real-World Example: Complete Component

Here's how all these principles come together in `simPreChatForm.css`:

**HTML Structure:**
```html
<template>
  <div class="form-container">
    <div class="form-content flex flex-col gap-lg">
      <h2>Welcome! Please fill in your details.</h2>

      <div class="form-fields flex flex-col gap-md">
        <div class="form-field">
          <label class="form-field__label">
            Email <span class="form-field__required">*</span>
          </label>
          <input
            type="email"
            class="form-field__input"
            placeholder="name@example.com"
          />
        </div>
      </div>

      <button class="button button--primary">Continue</button>
    </div>
  </div>
</template>
```

**CSS (Actual Production Code):**
```css
:host {
  /* Design tokens omitted for brevity - see full example above */
}

/* Layout utilities */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.gap-md { gap: var(--spacing-md); }
.gap-lg { gap: var(--spacing-lg); }

/* Component: Form container */
.form-container {
  width: 100%;
  max-width: var(--max-width-form);
  background-color: white;
  border-radius: var(--border-radius-md);
  box-shadow: var(--shadow-md);
  padding: var(--spacing-md);
}

.form-content {
  flex: 1;
}

/* Component: Form field */
.form-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-field__label {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-primary);
}

.form-field__required {
  color: var(--color-error);
  margin-left: 2px;
}

.form-field__input {
  height: var(--height-interactive);
  padding: 0 12px;
  background: var(--color-background-light);
  border: var(--border-width) solid var(--color-border);
  border-radius: var(--border-radius-sm);
  transition: all var(--transition-base);
}

.form-field__input:focus {
  outline: none;
  border-color: var(--color-focus);
  background: white;
  box-shadow: var(--shadow-focus);
}

/* Component: Button */
.button {
  height: var(--height-interactive);
  padding: 0 var(--spacing-lg);
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-medium);
  border: none;
  border-radius: var(--border-radius-sm);
  cursor: pointer;
  transition: all var(--transition-base);
}

.button--primary {
  background: var(--color-primary);
  color: white;
}

.button--primary:hover:not(:disabled) {
  background: var(--color-primary-hover);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(19, 148, 175, 0.3);
}

.button:disabled {
  background: var(--color-text-placeholder);
  cursor: not-allowed;
}
```

---

## Summary

### The Three Pillars

1. **Design Tokens** - All values in CSS custom properties
2. **BEM** - Component-specific styling with clear relationships
3. **Utilities** - Reusable layout classes for common patterns

### Benefits Delivered

✅ **Consistency**: SIM brand colors and spacing enforced
✅ **Velocity**: New components built faster with patterns
✅ **Maintainability**: Easy to update brand values globally
✅ **Clarity**: Team understands structure immediately
✅ **No Conflicts**: Shadow DOM prevents collisions
✅ **No Build Tools**: Works natively in LWC

### Next Steps

1. Apply this guide to all new LWC components
2. Gradually refactor existing components
3. Update this guide as new patterns emerge
4. Share feedback in team reviews

---

**Questions or Improvements?**
This is a living document. If you discover a pattern not covered here, document it and submit for review.
