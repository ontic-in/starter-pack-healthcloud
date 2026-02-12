# Screenshot Renaming Guide for QA Testing

**Purpose:** Standardize screenshot naming for better documentation, test case traceability, and chronological sorting.

**Last Updated:** 2025-11-09 | **Version:** 3.0

---

## 🎯 Naming Convention

### Format: `TC{number}_{YYYY-MM-DD}_{HH-MM-SS}_{description}.png`

**Key Changes in v3.0**:
- ✅ Uses underscores (not hyphens or brackets) - better for sorting
- ✅ Timestamp FIRST after TC number - enables chronological sorting
- ✅ ISO 8601 date format - universal standard
- ✅ Description LAST - clear readability

**Examples:**
- `TC1_2025-11-09_14-40-52_page-loaded.png`
- `TC2_2025-11-09_19-17-24_student-persona-selected.png`
- `TC3_2025-11-09_19-20-15_form-submitted-chat-loaded.png`
- `TC4a_2025-11-09_19-22-30_assignment-request-sent.png`
- `TC4b_2025-11-09_19-22-35_agent-response-full.png`

**Benefits:**
- ✅ Sorts chronologically by default (`ls` shows time order)
- ✅ TC number visible for test case mapping
- ✅ Timestamp preserved for audit trail
- ✅ Description readable for quick identification
- ✅ No special characters (brackets, spaces) - git/CLI friendly

---

## 🔧 Renaming Screenshots

### 🚨 Understanding Mac Screenshot Unicode Issues

**THE PROBLEM:**
Mac screenshots contain invisible Unicode characters that break normal bash commands:
- **U+202F (Narrow No-Break Space)** - appears between time and AM/PM
- **U+200E (Left-to-Right Mark)** - invisible control character

These characters look like regular spaces but cause `mv` commands to fail with "No such file or directory" errors.

**THE SOLUTION:**
Use array-based file listing to avoid typing special characters entirely.

---

### The Array-Based Method (REQUIRED)

**3-Step Process:**

```bash
cd tickets/{ticket-id}/screenshots

# Step 1: List all screenshots with index numbers
files=(Screenshot*.png)
for i in "${!files[@]}"; do echo "[$i] ${files[$i]}"; done

# Output:
# [0] Screenshot 2025-11-09 at 2.40.52 PM.png
# [1] Screenshot 2025-11-09 at 7.17.24 PM.png

# Step 2: Rename with proper format (TC{n}_{date}_{time}_{description})
mv "${files[0]}" "TC1_2025-11-09_14-40-52_page-loaded.png"
mv "${files[1]}" "TC2_2025-11-09_19-17-24_student-persona-selected.png"

# Step 3: Verify chronological sorting
ls -lh TC*.png
# Files now sort by timestamp automatically
```

**Timestamp Conversion Guide**:
```
Mac Screenshot Format:     Rename Format:
"2.40.52 PM"        →      "14-40-52"  (2 + 12 = 14:40:52)
"7.17.24 PM"        →      "19-17-24"  (7 + 12 = 19:17:24)
"9.30.15 AM"        →      "09-30-15"  (keep as-is for AM)
"12.05.30 PM"       →      "12-05-30"  (noon = 12, not 24)
```

---

## 📝 Best Practices

### 1. Rename IMMEDIATELY When Screenshot Provided
- Rename as soon as user provides screenshot
- Prevents confusion during test documentation
- Preserves chronological order for debugging
- Makes git history readable

### 2. Use Descriptive Suffixes
- Include what's being tested after timestamp
- Use hyphens in description (not underscores)
- Keep it brief (2-4 words max)

**Good Examples:**
- `TC1_2025-11-09_14-40-52_page-loaded.png`
- `TC4a_2025-11-09_19-22-30_request-sent.png`
- `TC4b_2025-11-09_19-22-35_agent-response.png`

**Bad Examples:**
- `TC1-2025-11-09-14-40-52-page-loaded.png` (all hyphens - hard to parse)
- `TC1_page_loaded.png` (no timestamp - loses chronology)
- `TC1_2025-11-09_14-40-52_page_loaded_showing_sim_branding_and_chat.png` (too verbose)

### 3. Always Use Array-Based Method
- **NEVER** try to type Mac screenshot filenames directly
- **ALWAYS** use array indexing: `files=(Screenshot*.png)`
- **ALWAYS** verify file list before renaming
- Convert AM/PM to 24-hour format manually

### 4. Verification Workflow

**After renaming:**
```bash
# Verify chronological sorting (should be in time order)
ls -lh TC*.png

# Output should show:
# TC1_2025-11-09_14-40-52_page-loaded.png
# TC2_2025-11-09_19-17-24_student-persona-selected.png
# (Note: TC2 timestamp is AFTER TC1 - correct chronological order)
```

---

## 🚨 Common Issues & Solutions

### Issue 1: "No such file or directory" ⚠️ MOST COMMON

**Root Cause:** Mac screenshots contain **invisible Unicode characters** (U+202F, U+200E)

**❌ WRONG - This ALWAYS fails:**
```bash
# Typing the filename directly will NEVER work
mv "Screenshot 2025-10-28 at 9.50.51 PM.png" new-name.png
# Error: No such file or directory
```

**✅ CORRECT - Use array indexing:**
```bash
# This ALWAYS works - no special characters needed
files=(Screenshot*.png)
for i in "${!files[@]}"; do echo "[$i] ${files[$i]}"; done
mv "${files[0]}" "TC1_2025-10-28_21-50-51_description.png"
```

---

### Issue 2: Files don't sort chronologically

**Problem:** Using TC number first but files out of time order

**❌ WRONG Format:**
```
TC1-page-loaded-2025-11-09-2.40.52PM.png     # Sorts by TC, not time
TC2-persona-2025-11-09-7.17.24PM.png         # Can't see time order easily
```

**✅ CORRECT Format:**
```
TC1_2025-11-09_14-40-52_page-loaded.png      # Timestamp after TC
TC2_2025-11-09_19-17-24_persona.png          # Sorts chronologically
```

When sorted by `ls`, you see time progression clearly.

---

### Issue 3: AM/PM confusion in 24-hour conversion

**Conversion Rules:**
- **12:00 AM - 12:59 AM** → `00-00-00` to `00-59-59` (midnight hour)
- **1:00 AM - 11:59 AM** → `01-00-00` to `11-59-59` (morning - keep as-is)
- **12:00 PM - 12:59 PM** → `12-00-00` to `12-59-59` (noon - keep as-is)
- **1:00 PM - 11:59 PM** → `13-00-00` to `23-59-59` (afternoon/evening - add 12)

**Examples:**
```
2:40:52 PM  → 14-40-52  (2 + 12 = 14)
7:17:24 PM  → 19-17-24  (7 + 12 = 19)
9:30:15 AM  → 09-30-15  (keep as-is)
12:05:30 PM → 12-05-30  (noon, keep as 12)
12:05:30 AM → 00-05-30  (midnight, change to 00)
```

---

## 📋 QA Workflow Integration

### Step-by-Step Process

1. **User provides screenshot**
   ```
   User: Added Screenshot 2025-11-09 at 7.17.24 PM.png
   ```

2. **Immediately rename using array method**
   ```bash
   cd tickets/{ticket-id}/screenshots

   # List all screenshots
   files=(Screenshot*.png)
   for i in "${!files[@]}"; do echo "[$i] ${files[$i]}"; done

   # Rename to sortable format
   mv "${files[0]}" "TC2_2025-11-09_19-17-24_student-persona-selected.png"

   # Verify
   ls -lh TC*.png
   ```

3. **Update test documentation with new name**
   ```markdown
   **Screenshot:** TC2_2025-11-09_19-17-24_student-persona-selected.png
   ```

4. **Commit with renamed file**
   ```bash
   git add tickets/{ticket-id}/screenshots/
   git commit -m "[ticket-id] test: Add TC2 screenshot

   TC2_2025-11-09_19-17-24_student-persona-selected.png

   ClickUp: https://app.clickup.com/t/{ticket-id}"
   ```

---

## 🎨 Naming Patterns by Test Type

### Standard Format Components

```
TC{number}_{YYYY-MM-DD}_{HH-MM-SS}_{description}.png
│         │            │           │
│         │            │           └─ What's shown (2-4 words)
│         │            └─ Time in 24-hour format
│         └─ Date in ISO format
└─ Test case number
```

### Functional Tests
- `TC1_2025-11-09_14-30-22_login-success.png`
- `TC2_2025-11-09_14-32-45_chat-opened.png`

### Validation Tests
- `TC3_2025-11-09_14-35-10_validation-email-invalid.png`
- `TC4_2025-11-09_14-37-22_validation-error-message.png`

### Multi-Part Tests (use a, b, c suffixes)
- `TC5a_2025-11-09_14-40-15_request-sent.png`
- `TC5b_2025-11-09_14-40-18_agent-response.png`
- `TC5c_2025-11-09_14-40-22_console-check.png`

### Bug Screenshots
- `BUG_{ticket-id}_{YYYY-MM-DD}_{HH-MM-SS}_{description}.png`
- Example: `BUG_86d0wtq5y_2025-11-09_19-17-24_offers-assignment-help.png`

---

## ✅ Quick Reference Commands

### Method: With Timestamp (RECOMMENDED)

```bash
cd tickets/{ticket-id}/screenshots

# List files with indices
files=(Screenshot*.png)
for i in "${!files[@]}"; do echo "[$i] ${files[$i]}"; done

# Output shows you the file to rename:
# [0] Screenshot 2025-11-09 at 7.17.24 PM.png

# Rename to sortable format (convert PM time: 7 + 12 = 19)
mv "${files[0]}" "TC2_2025-11-09_19-17-24_student-persona-selected.png"

# Verify chronological sorting
ls -lh TC*.png
# Files now listed in time order automatically
```

---

## 📚 Summary of Key Changes (v3.0)

### What's New:
1. ✅ **Underscore Separators**: `TC1_2025-11-09_14-40-52_description.png` (not hyphens/brackets)
2. ✅ **Timestamp-First Sorting**: Date/time comes before description for chronological ls output
3. ✅ **24-Hour Format Required**: No AM/PM - use 00-23 hour format
4. ✅ **ISO 8601 Dates**: YYYY-MM-DD standard (universal, sortable)
5. ✅ **Description Last**: Human-readable suffix after timestamp

### What's Changed from v2.0:
- ❌ Removed brackets around timestamp: `[2025-11-09-19-17-24]` → `2025-11-09_19-17-24`
- ❌ Removed hyphens between TC and timestamp: `TC1-[timestamp]` → `TC1_{timestamp}`
- ✅ Added underscore separators for clean parsing
- ✅ Made timestamp mandatory (not optional) for audit trail
- ✅ Standardized on 24-hour time format

### Migration from v2.0:
**Old format:** `TC2-[2025-11-05-13-15-59]-persona-prospect-form.png`
**New format:** `TC2_2025-11-05_13-15-59_persona-prospect-form.png`

**Why the change:** Files now sort correctly by `ls -l` (chronological order) and parse cleanly in scripts.

---

**Last Updated:** 2025-11-09
**Version:** 3.0
**Referenced by:** @docs/personas/QA_TESTER.md
