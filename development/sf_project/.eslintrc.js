/**
 * ESLint Configuration for Salesforce Project
 *
 * IMPORTANT: This file uses "root: true" which prevents ESLint from
 * searching parent directories and IGNORES subdirectory configs:
 * - force-app/main/default/lwc/.eslintrc.json (IGNORED)
 * - force-app/main/default/aura/.eslintrc.json (IGNORED)
 *
 * All rules are defined here using the "overrides" pattern for
 * different file types (Aura, LWC, test files, etc.).
 *
 * Modern Variable Declarations:
 * - "no-var": "error" - Disallows var, requires let/const
 * - "prefer-const": "error" - Requires const when not reassigned
 */
module.exports = {
  root: true,
  overrides: [
    // Aura configuration
    {
      files: ["**/aura/**/*.js"],
      extends: ["plugin:@salesforce/eslint-plugin-aura/recommended"],
      rules: {
        "no-var": "error",
        "prefer-const": "error"
      }
    },
    // LWC configuration
    {
      files: ["**/lwc/**/*.js"],
      extends: ["@salesforce/eslint-config-lwc/recommended"],
      rules: {
        "no-var": "error",
        "prefer-const": "error"
      }
    },
    // LWC test files configuration
    {
      files: ["**/lwc/**/*.test.js"],
      extends: ["@salesforce/eslint-config-lwc/recommended"],
      rules: {
        "no-var": "error",
        "prefer-const": "error",
        "@lwc/lwc/no-unexpected-wire-adapter-usages": "off",
        // Prevent Common Mistakes
        "jest/expect-expect": "error",
        "jest/no-conditional-expect": "error",
        "jest/no-identical-title": "error",
        "jest/no-focused-tests": "error",
        "jest/no-disabled-tests": "error",
        // Improve Assertion Quality
        "jest/prefer-expect-assertions": "error",
        "jest/prefer-to-have-length": "error",
        "jest/prefer-to-be": "error",
        "jest/prefer-to-contain": "error",
        "jest/prefer-strict-equal": "error",
        // Better Async Testing
        "jest/no-done-callback": "error",
        "jest/prefer-expect-resolves": "error",
        "jest/valid-expect-in-promise": "error",
        // Test Structure & Readability
        "jest/consistent-test-it": "error",
        "jest/prefer-hooks-on-top": "error",
        "jest/max-nested-describe": "error",
        "jest/no-duplicate-hooks": "error",
        "jest/require-top-level-describe": "error",
        // Advanced Quality Rules
        "jest/no-standalone-expect": "error",
        "jest/no-test-return-statement": "error",
        "jest/no-conditional-in-test": "error",
        "jest/prefer-spy-on": "error",
        // Style Configuration
        "jest/prefer-lowercase-title": "warn"
      },
      env: {
        node: true,
        jest: true
      }
    },
    // Jest mocks configuration
    {
      files: ["**/jest-mocks/**/*.js"],
      extends: ["eslint:recommended", "plugin:jest/recommended"],
      rules: {
        "no-var": "error",
        "prefer-const": "error",
        // Prevent Common Mistakes
        "jest/expect-expect": "error",
        "jest/no-conditional-expect": "error",
        "jest/no-identical-title": "error",
        "jest/no-focused-tests": "error",
        "jest/no-disabled-tests": "error",
        // Improve Assertion Quality
        "jest/prefer-expect-assertions": "error",
        "jest/prefer-to-have-length": "error",
        "jest/prefer-to-be": "error",
        "jest/prefer-to-contain": "error",
        "jest/prefer-strict-equal": "error",
        // Better Async Testing
        "jest/no-done-callback": "error",
        "jest/prefer-expect-resolves": "error",
        "jest/valid-expect-in-promise": "error",
        // Test Structure & Readability
        "jest/consistent-test-it": "error",
        "jest/prefer-hooks-on-top": "error",
        "jest/max-nested-describe": "error",
        "jest/no-duplicate-hooks": "error",
        "jest/require-top-level-describe": "error",
        // Advanced Quality Rules
        "jest/no-standalone-expect": "error",
        "jest/no-test-return-statement": "error",
        "jest/no-conditional-in-test": "error",
        "jest/prefer-spy-on": "error",
        // Style Configuration
        "jest/prefer-lowercase-title": "warn"
      },
      env: {
        node: true,
        es2021: true,
        jest: true
      },
      parserOptions: {
        sourceType: "module",
        ecmaVersion: "latest"
      }
    }
  ]
};
