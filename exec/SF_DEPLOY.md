# Salesforce Deploy - LWC & Configuration Changes

**Purpose:** Deploy Salesforce LWC components and configuration as part of TDD iteration loop

**Context:** Use for LWC JavaScript/HTML/CSS changes and Embedded Service configuration

**Related:**
- TDD cycle: `@exec/TODOS_CONDITIONER_PLAYWRIGHT_TDD.md`
- Confidence scoring: `@docs/CONFIDENCE_SCORING_PLAYWRIGHT_TDD.md`

FOR THE SIM PROJECT:
- Auth: `sf org login sfdx-url --sfdx-url-file tmp/authFile.json -a SimDev` (from SIM root)
- Work dir: `development/SIM_SF_project`

---

## Quick LWC Deploy & Publish Loop

**Use for:** Fast iteration when developing `simPreChatForm` LWC (email validation, form logic, etc.)

**⚠️ CRITICAL:** Deploy ALL modified LWC components, including imported dependencies!

**Architecture Context:**
- LWC deployed to Salesforce contains the form logic (e.g., `emailAddress.js` validation)
- Embedded Service on https://ontic-in.github.io/SIM loads LWC directly from Salesforce
- GitHub Pages site (`realfast.js`) is separate - only handles chat initialization
- **After publishing, you MUST hard refresh browser (Cmd+Shift+R) to bypass cache**

```bash
# Working directory: development/SIM_SF_project

# 1. Deploy LWC (deploy ALL modified components!)
# Example: If you modified emailAddress.js (imported by simPreChatForm):
sf project deploy start --metadata LightningComponentBundle:emailAddress --target-org SimDev --concise 2>&1 | tail -3
# If you also modified simPreChatForm:
sf project deploy start --metadata LightningComponentBundle:simPreChatForm --target-org SimDev --concise 2>&1 | tail -3

# 2. Open authenticated publish page (no manual login needed)
sf org open --target-org SimDev --path /lightning/setup/EmbeddedServiceDeployments/04I860000000VdJEAU/view

# 3. Human publishes & verifies:
#    a. Click "Publish" button
#    b. Wait for notification: "We're processing your update. The change can take up to 10 minutes to complete."
#    c. Refresh page (Cmd+R) until "Published on:" timestamp updates (usually ~1-2 min)
#    d. Timestamp change confirms publish completed

# 4. Test at https://ontic-in.github.io/SIM
#    IMPORTANT: Hard refresh (Cmd+Shift+R / Ctrl+Shift+R) to bypass browser cache
#    The Embedded Service loads LWC JavaScript directly from Salesforce CDN
```

**Key Details:**
- Deploy time: ~3 seconds
- Publish propagation: ~1-2 minutes (watch timestamp)
- Browser cache: MUST hard refresh (Cmd+Shift+R) after publish
- Deployment ID: `04I860000000VdJEAU` = SimTest

**Common Issue - "Changes not appearing":**
1. Did you hard refresh browser? (Cmd+Shift+R, not just Cmd+R)
2. Did publish timestamp update in Salesforce?
3. Check browser console for JavaScript errors
4. Verify correct LWC component deployed: `sf project deploy start --metadata LightningComponentBundle:simPreChatForm`

---

## When to Use This

**Use for:**
- LWC component changes (JavaScript, HTML, CSS)
- Form validation logic
- Client-side business logic

**Also works for:**
- Apex class changes (add `--metadata ApexClass:ClassName`)
- Flows, Embedded Service config (modify `--metadata` parameter)

**Deployment scope:** Any Salesforce metadata type

---

## Integration with Manual Testing (AI-Guided)

**When E2E tests blocked (shadow DOM, framework issues), use structured manual testing:**

```
1. [🔧 DEPLOY] Deploy LWC changes
   - Run quick deploy loop (see above)
   - Publish and wait for timestamp update

2. [📸 TEST] AI specifies, human executes:
   - AI: "Enter test@gmial.com in email field, tab out, screenshot error message"
   - Human: Performs action, provides screenshot
   - AI: Analyzes evidence, assigns confidence

3. [✅ VERIFY] Evidence-based validation:
   - Screenshots show expected behavior
   - Console logs confirm no errors
   - Confidence: 0.8-0.9 with screenshot evidence

4. [💾 COMMIT] Document with evidence:
   - Include screenshots in commit message or link
   - Confidence score based on visual verification
```

---

## Complete Manual Testing Workflow

**After deploying LWC changes, follow this exact sequence:**

```
1. [🔧 DEPLOY] Deploy LWC changes
   cd development/SIM_SF_project
   sf project deploy start --metadata LightningComponentBundle:emailAddress --target-org SimDev --concise 2>&1 | tail -3

2. [🌐 OPEN] Open Embedded Service deployment settings page (authenticated)
   sf org open --target-org SimDev --path /lightning/setup/EmbeddedServiceDeployments/04I860000000VdJEAU/view

3. [📤 PUBLISH] Human publishes changes
   a. Click "Publish" button (top right)
   b. Wait for notification: "We're processing your update. The change can take up to 10 minutes to complete."
   c. Refresh page (Cmd+R / Ctrl+R) until "Published on:" timestamp under button updates
   d. Timestamp change confirms publish completed (usually 1-2 minutes)

4. [🧪 TEST] Open test site and verify changes
   a. Open https://ontic-in.github.io/SIM/
   b. Hard refresh browser (Cmd+Shift+R / Ctrl+Shift+R) to bypass cache
   c. Perform manual test (e.g., enter test@gmial.com in email field)

5. [📸 EVIDENCE] Human captures screenshot
   a. Screenshot showing expected behavior (error message, validation, etc.)
   b. Paste screenshot back for AI to verify

6. [✅ VERIFY] AI analyzes evidence
   a. Compare screenshot to expected behavior
   b. Assign confidence score (0.8-0.9 with screenshot evidence)
   c. Document result

7. [💾 COMMIT] Commit with evidence reference
   git commit -m "[ticket] Description

   - Confidence: 0.85
   - Evidence: Screenshot confirms error message for gmial.com typo
   - Testing: Manual verification via browser"
```

**Critical steps:**
- **MUST wait for notification** before refreshing for timestamp
- **MUST hard refresh browser** (Cmd+Shift+R) to bypass CDN/browser cache
- **MUST provide screenshot** for AI verification (not just "it works")

---

## Troubleshooting

**"Changes not appearing after publish"**
1. Hard refresh browser (Cmd+Shift+R / Ctrl+Shift+R)
2. Check publish timestamp updated in Salesforce
3. Open browser console (F12), check for JavaScript errors
4. Verify deployment included correct component: check deploy command output

**"Which component do I deploy?"**
- Pre-chat form changes → `LightningComponentBundle:simPreChatForm`
- Email validation changes → `LightningComponentBundle:emailAddress` (imported by simPreChatForm)
- Phone validation changes → `LightningComponentBundle:phoneNumber` (imported by simPreChatForm)
- **CRITICAL:** LWC imports are NOT bundled automatically - deploy each component separately
- Apex classes → `ApexClass:[ClassName]`

**"How do I know which LWC components to deploy?"**
1. Check the main component's imports (e.g., `simPreChatForm.js`)
2. Deploy BOTH the main component AND all imported components
3. Example: If `simPreChatForm` imports `EmailAddress from "c/emailAddress"`, deploy BOTH:
   ```bash
   sf project deploy start --metadata LightningComponentBundle:simPreChatForm --target-org SimDev --concise
   sf project deploy start --metadata LightningComponentBundle:emailAddress --target-org SimDev --concise
   ```

**"Do I need to republish after every deploy?"**
- Yes, for Embedded Service deployments
- Publish propagates LWC changes to CDN
- Without publish, changes stay in Salesforce but don't reach site

**"Can I use npm packages in LWC?"**
- **NO** - Salesforce LWC platform does NOT support `import` from npm packages
- Example: `import levenshtein from 'js-levenshtein';` will NOT work when deployed
- **Solution 1 (Recommended):** Inline the algorithm directly in your LWC JavaScript
- **Solution 2:** Upload as static resource and use `loadScript` from `lightning/platformResourceLoader`
- **For small algorithms:** Inlining is simpler and avoids async loading complexity
- **Reference:** See `emailAddress.js` for inlined Levenshtein algorithm example

**"My code works in Jest tests but fails after deploy?"**
- Check if you're importing npm packages (not supported in Salesforce LWC)
- Jest runs in Node.js environment (supports npm imports)
- Salesforce LWC runs in browser sandbox (does NOT support npm imports)
- Open browser console (F12) to see JavaScript errors like "module not found"

---

**Key Principle:** Deploy fast, publish, hard refresh, verify with evidence

**Remember:** LWC imports must be deployed separately, npm packages don't work in Salesforce LWC
