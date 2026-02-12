# Salesforce Org Authentication

## Purpose

This skill provides an interactive workflow to authenticate or re-authenticate Salesforce orgs when their access/refresh tokens have expired.

**Target Users**: Developers who need to reconnect to Salesforce orgs for running Apex tests, deploying code, or executing CI tasks.

## Trigger Phrases

This skill activates when user says:
- "authenticate salesforce"
- "login to salesforce"
- "fix salesforce auth"
- "reconnect to org"
- "salesforce login expired"

## Complete Workflow Steps

### STEP 1: Check Current Org Status

**List all orgs and their connection status**:
```bash
sf org list
```

**Analyze the output**:
- Look for orgs with red "Unable to refresh session" or "expired access/refresh token" status
- Look for orgs with "DomainNotFoundError" status
- Identify which org(s) need re-authentication

**Show user the results**:
```
I found the following Salesforce orgs that need re-authentication:

❌ SimDev (realfastontic@sim.edu.sg.agentforce)
   Status: expired access/refresh token
   Type: Sandbox

Which org would you like to authenticate?
```

**Ask user which org to authenticate**:

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Which Salesforce org do you want to authenticate?",
    header: "Select Org",
    multiSelect: false,
    options: [
      {
        label: "SimDev",
        description: "realfastontic@sim.edu.sg.agentforce (Sandbox)"
      },
      {
        label: "hb-sandbox",
        description: "aditya@houzbay.com.realfastai (Sandbox)"
      },
      {
        label: "Other",
        description: "I'll specify a different org"
      }
    ]
  }]
})
```

---

### STEP 2: Determine Authentication Method

**For sandbox orgs** (test.salesforce.com):
- Use `--instance-url https://test.salesforce.com`

**For production orgs** (login.salesforce.com):
- Use `--instance-url https://login.salesforce.com`

**For scratch orgs**:
- May need to recreate if expired

**Show user the authentication method**:
```
For SimDev (Sandbox org), I'll use web authentication with:
- Instance URL: https://test.salesforce.com
- Alias: SimDev
```

---

### STEP 3: Prepare Authentication Command

**Build the authentication command**:

For sandbox:
```bash
sf org login web --alias <alias> --instance-url https://test.salesforce.com
```

For production:
```bash
sf org login web --alias <alias> --instance-url https://login.salesforce.com
```

**Show command to user**:
```
I'm ready to authenticate SimDev.

This will:
1. Open your default browser
2. Navigate to Salesforce login page
3. Ask you to log in with: realfastontic@sim.edu.sg.agentforce
4. Grant authorization to Salesforce CLI
5. Refresh your authentication tokens

Command that will run:
sf org login web --alias SimDev --instance-url https://test.salesforce.com
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Ready to open the browser for authentication?",
    header: "Start Auth",
    multiSelect: false,
    options: [
      {
        label: "Yes, start",
        description: "Open browser and start authentication"
      },
      {
        label: "Cancel",
        description: "Don't authenticate now"
      }
    ]
  }]
})
```

---

### STEP 4: Execute Authentication

**Run the authentication command**:
```bash
sf org login web --alias SimDev --instance-url https://test.salesforce.com
```

**IMPORTANT**: This command will:
- Open the browser automatically
- Wait for user to complete login in browser
- Return to CLI after successful authentication

**While command is running, inform user**:
```
🌐 Opening browser for authentication...

A browser window should open shortly.

What you need to do:
1. ✓ Wait for Salesforce login page to load
2. ✓ Enter username: realfastontic@sim.edu.sg.agentforce
3. ✓ Enter your password
4. ✓ Complete any 2FA/MFA if required
5. ✓ Click "Allow" to grant Salesforce CLI access
6. ✓ Wait for "Authentication successful" message
7. ✓ You can close the browser tab

⏳ Waiting for you to complete login in the browser...
```

**Monitor command output**:
- Command will block until authentication completes
- User performs actions in browser
- Command returns success/failure

---

### STEP 5: Verify Authentication Success

**After command completes, check exit code**:

**If successful** (exit code 0):
```
✅ Authentication successful!

Verifying connection...
```

**Run verification**:
```bash
sf org display --target-org SimDev
```

**Show verification results**:
```
✓ Connection verified!

Org Details:
- Alias: SimDev
- Username: realfastontic@sim.edu.sg.agentforce
- Org ID: 00D860000029LqTEAU
- Instance: https://realfast--agentforce.sandbox.my.salesforce.com
- Status: Connected
- Access Token: Valid
```

**If authentication failed** (exit code non-zero):
```
❌ Authentication failed!

Error: <error message from command>

Common issues:
- Incorrect username/password
- 2FA/MFA timeout
- Network connectivity issues
- Org access revoked
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Authentication failed. What would you like to do?",
    header: "Auth Failed",
    multiSelect: false,
    options: [
      {
        label: "Try again",
        description: "Retry authentication"
      },
      {
        label: "Show error details",
        description: "See full error message"
      },
      {
        label: "Try different org",
        description: "Authenticate a different org"
      },
      {
        label: "Cancel",
        description: "Stop authentication"
      }
    ]
  }]
})
```

---

### STEP 6: Post-Authentication Actions

**After successful authentication, suggest next steps**:

```
✅ SimDev is now authenticated and ready to use!

What would you like to do next?
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like to do now?",
    header: "Next Steps",
    multiSelect: false,
    options: [
      {
        label: "Run Apex tests",
        description: "Execute npm run ci:apex"
      },
      {
        label: "Run full CI",
        description: "Execute npm run ci"
      },
      {
        label: "Authenticate another org",
        description: "Login to a different org"
      },
      {
        label: "Nothing - I'm done",
        description: "Authentication complete"
      }
    ]
  }]
})
```

**If user chooses to run tests/CI**:
```
Running Apex tests...

Command: npm run ci:apex
```

Execute the chosen command.

---

## Multiple Org Authentication

**If multiple orgs need authentication**:

After completing one org, ask:
```
You have more orgs that need authentication:

Remaining:
❌ hb-sandbox (aditya@houzbay.com.realfastai)
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Would you like to authenticate the remaining orgs?",
    header: "More Orgs",
    multiSelect: false,
    options: [
      {
        label: "Yes, continue",
        description: "Authenticate the next org"
      },
      {
        label: "No, I'm done",
        description: "Stop after current org"
      }
    ]
  }]
})
```

If yes, repeat STEP 2-6 for next org.

---

## Special Cases

### Case 1: Scratch Org Expired

If a scratch org is expired:
```
⚠️ This is a scratch org that has expired.

Scratch orgs cannot be re-authenticated after expiration.

Options:
1. Create a new scratch org
2. Remove the expired org from the list
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "This scratch org is expired. What should I do?",
    header: "Expired Scratch",
    multiSelect: false,
    options: [
      {
        label: "Remove it",
        description: "Delete the expired org from the list"
      },
      {
        label: "Create new scratch org",
        description: "Create a replacement scratch org"
      },
      {
        label: "Skip it",
        description: "Leave it and continue"
      }
    ]
  }]
})
```

**If remove chosen**:
```bash
sf org delete scratch --target-org <alias> --no-prompt
```

### Case 2: Production Org Authentication

For production orgs, add extra warning:
```
⚠️ WARNING: You are about to authenticate to a PRODUCTION org.

Org: <alias>
Username: <username>
Instance: https://login.salesforce.com

Please ensure:
- You have the correct credentials
- You are authorized to access this production org
- You understand the implications of running commands against production
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "Are you sure you want to authenticate to PRODUCTION?",
    header: "Confirm Prod",
    multiSelect: false,
    options: [
      {
        label: "Yes, I'm sure",
        description: "Proceed with production authentication"
      },
      {
        label: "No, cancel",
        description: "Don't authenticate to production"
      }
    ]
  }]
})
```

### Case 3: Domain Not Found Error

For orgs with "DomainNotFoundError":
```
⚠️ This org has a domain issue.

Status: DomainNotFoundError

This usually means:
- The My Domain URL has changed
- The org has been deleted
- The domain configuration is incorrect

Options:
1. Try re-authentication (may fix it)
2. Remove this org from the list
3. Contact org administrator
```

Use `AskUserQuestion`:
```javascript
AskUserQuestion({
  questions: [{
    question: "This org has a domain error. What should I do?",
    header: "Domain Error",
    multiSelect: false,
    options: [
      {
        label: "Try re-auth",
        description: "Attempt to re-authenticate"
      },
      {
        label: "Remove org",
        description: "Delete from org list"
      },
      {
        label: "Skip",
        description: "Leave it for now"
      }
    ]
  }]
})
```

---

## Error Handling

### Browser Doesn't Open

If user reports browser didn't open:
```
⚠️ Browser didn't open automatically.

You can manually authenticate using this URL:
<copy the URL from command output>

Paste this URL in your browser and complete the authentication.
```

Wait for command to complete or timeout.

### Timeout During Authentication

If authentication times out:
```
⏰ Authentication timed out.

The browser session expired before you completed login.

Please try again and complete the login within 10 minutes.
```

### Wrong Credentials

If authentication fails due to wrong credentials:
```
❌ Login failed - incorrect username or password

Please check:
- Username: <username>
- Password: Make sure you're using the correct password
- Is 2FA enabled? Make sure to complete 2FA if prompted
```

### Network Issues

If network error occurs:
```
🌐 Network error during authentication

Please check:
- Internet connection is stable
- Firewall/VPN is not blocking Salesforce
- Salesforce status: https://status.salesforce.com
```

---

## Configuration Options

Users can customize behavior by adding `.claude/sf-auth-config.json`:

```json
{
  "defaultAuthMethod": "web",
  "autoVerifyAfterAuth": true,
  "defaultSandboxUrl": "https://test.salesforce.com",
  "defaultProdUrl": "https://login.salesforce.com",
  "requireProdConfirmation": true,
  "autoListOrgsOnStart": true
}
```

---

## Success Criteria

A successful authentication workflow means:
1. ✅ Identified orgs needing authentication
2. ✅ User selected which org to authenticate
3. ✅ Correct authentication method determined (sandbox/prod)
4. ✅ Browser opened for user to log in
5. ✅ User completed login in browser
6. ✅ Authentication tokens refreshed successfully
7. ✅ Connection verified with sf org display
8. ✅ User knows next steps

---

## Remember

- **Wait for user actions** - Don't rush through browser login
- **Clear instructions** - Tell user exactly what to do in browser
- **Verify success** - Always run sf org display after authentication
- **Handle errors gracefully** - Offer retry or alternative options
- **Security awareness** - Warn when authenticating to production
- **Use AskUserQuestion** - For all user interactions
- **Plain language** - Avoid CLI jargon where possible

**Our job**: Make Salesforce authentication smooth and stress-free, with clear guidance at every step.
