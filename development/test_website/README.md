# Test Website

Test harness for Salesforce Embedded Messaging integration testing.

## Purpose

This test website serves multiple purposes:
1. **Integration Testing**: Test Salesforce Embedded Messaging (chat widget) in a production-like environment
2. **GitHub Pages Deployment**: Practice CI/CD workflows with automatic deployments
3. **Version Tracking**: Track deployed versions with git branch, commit, and build timestamps

## Directory Structure

```
test_website/
├── index.html              # Main production page
├── integration.html        # Staging/integration environment page
├── src/
│   ├── realfast.js        # Production chat integration code
│   └── integration.js     # Staging chat integration code
├── static/
│   └── first-level.html   # Test page for navigation testing
├── tests/
│   └── setup.js           # Vitest test setup
├── dist/                  # Built files (generated)
├── package.json           # npm scripts and dependencies
├── babel.config.json      # Babel transpiler configuration
├── eslint.config.js       # ESLint code quality rules
├── vitest.config.js       # Vitest test configuration
└── deploy-from-local.sh   # Deployment script
```

## Setup

### 1. Install Dependencies

```bash
cd development/test_website
npm install
```

### 2. Configure Salesforce Embedded Messaging

Update the placeholders in `src/realfast.js` and `src/integration.js`:

**Production (`src/realfast.js`):**
```javascript
const AGENT_ID = '[SALESFORCE_AGENT_ID]';
const AGENT_NAME = '[AGENT_NAME]';
const AGENT_URL = '[SALESFORCE_EMBEDDED_MESSAGING_URL]';
```

**Staging (`src/integration.js`):**
```javascript
const AGENT_ID = '[SALESFORCE_AGENT_ID_STAGING]';
const AGENT_NAME = '[AGENT_NAME]';
const AGENT_URL = '[SALESFORCE_EMBEDDED_MESSAGING_URL_STAGING]';
```

Get these values from Salesforce:
1. Go to Setup → Embedded Service Deployments
2. Select your deployment
3. Copy the Agent ID, Agent Name, and Embedded Messaging URL
4. For staging, use your sandbox org's configuration

### 3. Update HTML Placeholders

Replace in `index.html` and `integration.html`:
- `[PROJECT_NAME]` → Your project name
- `[SALESFORCE_EMBEDDED_MESSAGING_URL]` → Your Salesforce embedded messaging URL
- `[SALESFORCE_SCRT2_URL]` → Your Salesforce SCRT2 URL (in JS files)

### 4. Configure Deploy Script

Update `deploy-from-local.sh`:
- `[SF_PROJECT_DIR]` → Your Salesforce project directory name
- Update LWC component names to match your project's components

## Usage

### Build Test Website

```bash
npm run build
```

This will:
1. Clean `dist/` directory
2. Transpile JavaScript with Babel
3. Inject git version info into HTML
4. Copy static files to `dist/`

### Run Tests

```bash
npm test
```

This builds the website and runs all Vitest tests.

### Deploy to Salesforce and GitHub Pages

```bash
./deploy-from-local.sh
```

This will:
1. Build the test website
2. Deploy LWC components to Salesforce
3. Commit changes (if any)
4. Push to GitHub (triggers GitHub Pages deployment)

### Lint Code

```bash
npm run lint          # Check for issues
npm run lint:fix      # Auto-fix issues
```

## GitHub Pages Setup

1. Go to Repository Settings → Pages
2. Source: Deploy from a branch
3. Branch: `main` (or your default branch)
4. Folder: `/development/test_website/dist`
5. Click Save

Your site will be available at: `https://[GITHUB_ORG].github.io/[REPO_NAME]/`

## Testing Scenarios

### Test Chat Widget

1. Build and deploy: `./deploy-from-local.sh`
2. Open `https://[GITHUB_ORG].github.io/[REPO_NAME]/index.html`
3. Verify chat widget loads
4. Test chat prompt message appears after 500ms
5. Click chat prompt or chat button to open chat
6. Test pre-chat form (if configured)
7. Test chat conversation flow

### Test Integration Environment

1. Open `https://[GITHUB_ORG].github.io/[REPO_NAME]/integration.html`
2. Verify "INTEGRATION" badge appears
3. Verify staging chat widget loads with staging configuration
4. Test chat functionality in staging environment

### Test Navigation

1. Test first-level page navigation
2. Verify all links work correctly
3. Verify version info displays correctly

## Version Information

The version info badge (bottom-left) shows:
- **Branch**: Current git branch at build time
- **Commit**: Short git commit hash
- **Built**: ISO 8601 timestamp of build

This helps track which version is deployed to GitHub Pages.

## Environment Badge

The integration environment shows an orange "INTEGRATION" badge in the top-right to distinguish it from production.

## Troubleshooting

### Chat Widget Not Loading

1. Check browser console for errors
2. Verify Salesforce configuration in `src/realfast.js` or `src/integration.js`
3. Verify CORS settings in Salesforce (Setup → CORS)
4. Check Embedded Service Deployment is active in Salesforce

### Build Fails

1. Ensure Node.js v18+ is installed
2. Run `npm install` to install dependencies
3. Check for syntax errors in JavaScript files
4. Verify Babel configuration

### Deploy Script Fails

1. Ensure Salesforce CLI is installed and authenticated
2. Verify LWC component names match your project
3. Check git repository is clean before deploying
4. Ensure you have push access to GitHub repository

### GitHub Pages Not Updating

1. Check GitHub Actions tab for build status
2. Verify Pages settings are correct
3. Clear browser cache
4. Check if changes were actually pushed to GitHub

## Chat Integration Features

### Floating Chat Prompt

- Appears 500ms after page load
- Only shows if user hasn't opened chat before (uses localStorage)
- Dismissible with close button
- Clickable to open chat

### Event Tracking

The integration includes Clarity event tracking for:
- `Clicked_Chat_Prompt` - User clicked chat prompt message
- `Clicked_Open_Chat` - User clicked chat button
- `Clicked_Close_Chat` - User closed chat prompt

### Chat Window Customization

- Fixed height: 700px (no scrolling)
- Responsive design
- Montserrat font for consistent branding

## Development Workflow

1. Make changes to source files (`src/`, `index.html`, `integration.html`)
2. Test locally: `npm run build && open dist/index.html`
3. Run tests: `npm test`
4. Lint code: `npm run lint:fix`
5. Deploy: `./deploy-from-local.sh`
6. Verify on GitHub Pages

## Best Practices

1. **Always Build Before Deploy**: Never edit `dist/` files directly
2. **Test Both Environments**: Test both production and integration pages
3. **Version Control**: Commit source files, not built files
4. **Clear Placeholders**: Replace all `[PLACEHOLDER]` values before deploying
5. **Test LWC Separately**: Deploy and test LWC components in Salesforce before deploying website

## Related Documentation

- [Salesforce Embedded Messaging Guide](https://developer.salesforce.com/docs/service/messaging-web/guide/overview.html)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Babel Configuration](https://babeljs.io/docs/en/configuration)
- [Vitest Documentation](https://vitest.dev/)
