# Todos Conditioner - Playwright-Driven TDD

**Purpose:** Structure todos for browser-driven development with Playwright as feedback loop

**Context:** Building LWC components and domain logic, validating via multi-level TDD (Jest + Playwright)

**Related:**

- Confidence scoring: `@docs/CONFIDENCE_SCORING_PLAYWRIGHT_TDD.md`

---

## Three-Level TDD Pyramid

**Fast to Slow (Inner to Outer Loop):**

```
        🎭 Playwright E2E (Slowest - Minutes)
                    ↑
            Browser + Salesforce + Pages Integration
                    ↑
        🧪 LWC Jest Unit Tests (Fast - Seconds)
                    ↑
            Component Logic + Rendering
                    ↑
        💻 Implementation
```

**⚠️ EXCEPTION: Embedded Service Components**

For components requiring full Salesforce Embedded Service runtime (pre-chat forms, custom messaging UI):
- **Skip Jest tests** - Components require embeddedservice_bootstrap, parent window messaging, and full SF context that Jest can't replicate
- **Use Playwright only** - The deployed environment IS your unit test
- **Kent Beck discipline still applies** - Implement smallest increment, deploy, verify with Playwright, repeat

**Standard LWC Components (Use Jest):**
- Standalone components, utilities, domain logic
- Can render in isolation
- Use Jest for fast inner loop

**Embedded Service LWC (Skip Jest):**
- Pre-chat forms, custom messaging UI
- Require full runtime context
- **Playwright is your only test** - accept the slower feedback loop

**Confidence Progression (Embedded Service):**
- **0.3:** Playwright test RED (expected behavior defined)
- **0.5:** Component code exists, compiles, follows pattern
- **0.8:** Playwright GREEN (browser + integration verified)

**Key Principle:**
✅ **Don't fight the framework** - If Jest can't replicate the environment, skip it
✅ **Playwright is acceptable for these components** - It's the real test anyway
✅ **Kent Beck discipline via Playwright** - Small increments, deploy, verify, repeat

---

## Core Pattern: Playwright-Only TDD (Embedded Service Components)

### For Embedded Service LWC Components:

**Kent Beck discipline via Playwright increments:**

```
1. [📝 RED] Write Playwright test for ONE user interaction
   - Start with simplest: "Chat widget opens"
   - Then: "Form renders"
   - Then: "Persona dropdown visible"
   - Then: "Can select persona"
   - ONE assertion at a time!
   - npm run test:functional - FAILS (expected)
   - Confidence: 0.3

2. [💻 CODE] Implement MINIMAL code to pass current assertion
   - Copy TASC pattern for structure
   - Add ONLY what's needed for current spec
   - Don't add extra features "while you're at it"
   - Confidence: Still 0.3 (code exists, not tested)

3. [🚀 DEPLOY] Deploy to Salesforce
   - sf project deploy start --source-dir force-app/main/default/lwc/[component]
   - Configure in Embedded Service UI
   - Click "Publish" button, wait 60s
   - Confidence: Still 0.5 (deployed but not verified)

4. [📤 COMMIT] Trigger Pages deployment
   - git add force-app
   - git commit -m "Add minimal [feature] to pass current spec"
   - git push (triggers GitHub Pages deploy)
   - gh run watch
   - Confidence: Still 0.5

5. [🎬 RUN] Playwright headless + extract frames
   - npm run test:functional
   - npx tsx scripts/extract-video-frames.ts --all-playwright
   - Confidence: If current assertion passes → proceed to next, if fails → diagnose

6. [👀 DIAGNOSE] Read frames sequentially
   - What did video show?
   - Check error-context.md for DOM
   - Evidence-based diagnosis

7. [🔁 ITERATE] If current assertion fails
   - Fix based on video evidence
   - Redeploy (step 3)
   - Test again (step 5)
   - Repeat until current assertion GREEN

8. [✅ GREEN] When current assertion passes
   - Refactor if needed (clean up code)
   - Commit incremental progress
   - Confidence: Gradually approaches 0.8

9. [🔁 NEXT] Add ONE more Playwright assertion
   - Next simplest behavior
   - Back to step 2 (implement minimal code)
   - Repeat cycle

10. [💾 DONE] When ALL assertions GREEN
    - Confidence: 0.8
    - Commit final version with evidence
    - Video frames + screenshots

11. [💬 COMMUNICATE] Post completion
```

**No fast inner loop for Embedded Service - accept it**
**Kent Beck discipline: Small increments, even if each requires full deploy cycle**

6. [📤 COMMIT] Trigger Pages deployment
   - git add force-app development/test_website
   - git commit + push
   - gh run watch --repo ontic-in/SIM
   - Wait for deployment SUCCESS
   - Confidence: Still 0.5 (deployed everywhere, not tested)

7. [🎬 RUN] Playwright headless + extract frames
   - npm run test:functional
   - npx tsx scripts/extract-video-frames.ts --all-playwright --interval 0.5 --verbose
   - Confidence: If GREEN → 0.8, if RED → iterate

8. [👀 DIAGNOSE] Read frames sequentially
   - frame-00000.jpg: Page load
   - frame-00010.jpg: Chat opened - form visible?
   - frame-00020.jpg: What's actually rendering?
   - error-context.md: DOM snapshot at failure
   - Evidence-based diagnosis

9. [🔁 ITERATE] If Playwright fails (confidence <0.8)
   - Based on video evidence:
     - Component not rendering? → Check Embedded Service config, redeploy
     - Wrong selectors? → Update test.config.ts from error-context.md
     - Component logic broken? → Back to step 4 (Jest), fix, redeploy
   - Repeat from step 5 or 7 depending on issue

10. [✅ VERIFY] Both tests GREEN
    - Jest: ✅ Component logic verified (fast)
    - Playwright: ✅ Browser integration verified (slow but thorough)
    - Confidence: 0.8

11. [💾 COMMIT] Final commit with evidence
    - Include confidence score + rationale
    - Link to video frames + screenshots

12. [💬 COMMUNICATE] Post with confidence progression
    - ClickUp + Slack
    - What works, what's TODO
```

---

## Specific Todo Patterns

### Pattern 1: LWC Jest Unit Testing (Fast Inner Loop)

**Purpose:** Verify component logic without Salesforce deployment

```
1. [📁 SETUP] Create Jest test file
   - force-app/main/default/lwc/[component]/__tests__/[component].test.js
   - Import: @salesforce/sfdx-lwc-jest utilities

2. [📝 RED] Write failing test
   test('renders persona dropdown with 4 options', () => {
     const element = createElement('c-sim-pre-chat-form', {
       is: SimPreChatForm
     });
     document.body.appendChild(element);

     const dropdown = element.shadowRoot.querySelector('#persona-select');
     expect(dropdown.options.length).toBe(4);
   });

   - Run: npm test - FAILS (expected)

3. [💻 CODE] Implement component to pass
   - Add personaOptions = [{...}, {...}]
   - Render in template: <select id="persona-select">

4. [🧪 GREEN] Run Jest with watch mode
   - npm test --watch
   - Iterate in SECONDS (no deployment!)
   - Fix until GREEN
   - Confidence: 0.5

5. [🔁 REPEAT] For each component behavior
   - Event handlers (handlePersonaChange)
   - Form submission (handleSubmit dispatches event)
   - Validation logic (if any)
```

**Jest tests catch:**
- ✅ Missing properties/arrays
- ✅ Broken event handlers
- ✅ Template rendering issues
- ✅ Validation logic errors

**Playwright tests catch:**
- ✅ Salesforce deployment/configuration issues
- ✅ CSP/CORS security blocks
- ✅ Actual browser rendering differences
- ✅ Integration with Embedded Service

**Use Jest for rapid iteration (seconds), Playwright for final verification (minutes)**

---

### Pattern 2: Discovering Form Selectors

```
1. [🔍 INSPECT] Run Playwright headed mode
   - npm run test:functional:headed
   - Pause at form
   - Inspect elements in browser DevTools

2. [📝 DOCUMENT] Capture selectors
   - Name field: [selector]
   - Email field: [selector]
   - Phone field: [selector]
   - Submit button: [selector]

3. [✏️ UPDATE] Replace TODOs in test
   - Fill actual selectors
   - Add waits if needed

4. [🧪 TEST] Run again
   - Verify form fills correctly
   - Screenshot evidence
```

### Pattern 2: Verifying Lead Updates

```
1. [📧 CREATE] Generate unique test email
   - `playwright-test-${Date.now()}@example.com`

2. [📝 SUBMIT] Fill form with test email
   - Playwright fills form
   - Submit

3. [⏱️ WAIT] Allow backend processing
   - Flow needs time to run
   - 5-10 seconds typical

4. [🔍 QUERY] Check Salesforce
   - await sfApi.queryLeadByEmail(testEmail)
   - Verify Lead exists

5. [✅ ASSERT] Verify fields
   - Lead.Techvsnontech__c === expected
   - Lead.NoOfHiresHeadcount__c === expected
   - etc.

6. [🧹 CLEANUP] Delete test Lead
   - await sfApi.deleteTestLead(testEmail)
```

### Pattern 3: Debugging Failed Browser Test (CRITICAL - USE VIDEO FRAMES!)

```
1. [🎬 EXTRACT FRAMES] Don't guess - WATCH what happened!
   - npx tsx scripts/extract-video-frames.ts --all-playwright --interval 0.5 --verbose
   - Extracts 71 frames for 35-second video (frame every 0.5s)

2. [👀 READ FRAMES SEQUENTIALLY] Visual debugging
   - frame-000.jpg: Page load start
   - frame-010.jpg: 5 seconds in - what's visible?
   - frame-020.jpg: 10 seconds - form rendered?
   - frame-034.jpg: End - where did it timeout?
   - READ FRAMES LIKE A MOVIE - see actual execution flow

3. [📄 CHECK ERROR CONTEXT] Understand DOM at failure
   - Read test-results/[test-name]/error-context.md
   - Shows exact DOM snapshot when test failed
   - Find: "textbox", "button [disabled]", iframe structure
   - Example: "button [disabled]" means form validation blocking

4. [🔍 DIAGNOSE FROM EVIDENCE]
   - Frames show form never filled? → Selectors wrong
   - Frames show button stays disabled? → Validation failed (fields not filled correctly)
   - Frames show element appears late? → Add wait
   - error-context shows different structure? → Update selectors

5. [🐛 FIX BASED ON VIDEO EVIDENCE]
   - Use selectors from error-context.md DOM
   - Add waits based on frame timing
   - Handle disabled states (validation issues)

6. [🔄 RE-RUN AND EXTRACT AGAIN]
   - npm run test:functional (headless)
   - Extract new video frames
   - Compare frame-by-frame: Did behavior change?

7. [✅ VERIFY] Green when:
   - Frames show complete flow (form filled → submitted → success)
   - No errors in error-context.md
   - Test passes
```

**KEY INSIGHT:** Don't run headed mode to watch - run HEADLESS, extract frames, READ them like a flipbook. Faster and you have evidence!

**Headed mode use:**

- ONLY when you need to interact/pause
- NOT for debugging (use frames instead)

---

## Confidence Progression Checklist

**After each todo cycle, verify:**

- [ ] Code compiles (0.3)
- [ ] LWC Jest tests GREEN (0.5) ← **FAST checkpoint before deploy**
- [ ] Salesforce deployed successfully (0.5)
- [ ] Browser opens chatbot (0.7)
- [ ] Playwright test GREEN (0.8) ← **Integration verified**
- [ ] Form submits, Lead created (0.8)
- [ ] Lead fields verified (0.9)
- [ ] All scenarios passing (1.0)

**Don't deploy to Salesforce until Jest GREEN (0.5)**
**Don't commit until Playwright GREEN (0.8)**

---

## Communication Pattern

**Every 2-3 commits:**

```
[💬] [@communicator] Post to ClickUp:
"✅ [ValueObject] complete - Confidence: 0.X

Browser validation: [What works in Playwright]
Lead verification: [Which fields confirmed]
TODO: [What remains]"
```

**Include:**

- Screenshot links
- Confidence score with rationale
- What's verified vs what's TODO

---

## Fast Feedback Loop

**Optimize for speed - Use fastest test that catches the bug:**

**Fastest (run constantly):**
- LWC Jest tests: `npm test --watch` (~seconds)
- Component logic, rendering, events
- NO deployment needed

**Fast (run after Jest GREEN):**
- Apex unit tests: `sf apex run test --tests [Class]Test` (~10 seconds)
- Server-side logic validation

**Medium (run after Salesforce deploy):**
- Playwright headed: `npm run test:functional:headed` (~2 minutes)
- Visual feedback, can pause/inspect
- Requires: Salesforce deploy + Publish + Pages deploy

**Slow (run before final commit):**
- Playwright headless: `npm run test:functional` (~2 minutes)
- Automated, CI-ready, captures evidence

**Very slow (run before merge to main):**
- All tests: `npm test && npm run ci && npm run test:functional` (~5-7 minutes)

**Strategy:**
1. Jest first (catch logic bugs fast)
2. Deploy only after Jest GREEN
3. Playwright for integration verification
4. Use Playwright frames for diagnosis, not headed watching

---

## Example: Complete Cycle

**Goal:** Implement CompanyInfo, verify via Playwright

```
1. [📝] Write Playwright test expecting company field
2. [🔍] Run headed - inspect form, find company selector
3. [🟥] Test fails - CompanyInfo doesn't exist
4. [💻] Implement CompanyInfo
5. [🧪] Unit tests GREEN (0.5)
6. [🌐] Run Playwright headed
7. [📸] Screenshot shows form filled
8. [✅] Lead created, Company field verified (0.8)
9. [💾] Commit with confidence 0.8
10. [💬] Update ClickUp: "CompanyInfo works in browser"
```

**Time per cycle:** ~15 minutes (including browser inspection)

---

## Anti-Patterns to Avoid

❌ **Writing multiple specs upfront** - Kent Beck violation! ONE spec at a time, RED-GREEN-REFACTOR
❌ **Skipping Jest tests** - Waste time deploying broken component logic
❌ **Only Jest tests** - Miss integration issues (CSP, selectors, Embedded Service config)
❌ **Writing code without browser validation** - Can't see if integration works
❌ **Running headless only** - Miss visual feedback for debugging
❌ **Not capturing screenshots** - Lose evidence
❌ **Skipping confidence levels** - Jump from 0.3 to 0.9 without validation
❌ **Not documenting selectors** - Forget what you learned in headed mode
❌ **Batch commits** - Lose granular feedback
❌ **Deploying before Jest GREEN** - Slow outer loop with broken inner loop
❌ **Batch specs** - Write all tests, then implement all - loses tight feedback

---

**Use this conditioner to:**

- Structure three-level TDD iterations (Jest → Deploy → Playwright)
- Progress confidence systematically (0.3 → 0.5 → 0.8 → 0.9)
- Maintain fast inner loop (Jest - seconds) before slow outer loop (Playwright - minutes)
- Catch component bugs before deployment (Jest)
- Verify integration after deployment (Playwright)
- Document learnings (selectors, timings, field mappings, video evidence)
