import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/functional',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,

  reporter: process.env.CI
    ? [['list'], ['json', { outputFile: 'test-results/results.json' }]]
    : [['html', { open: 'never' }]],

  outputDir: 'test-results',
  timeout: 30000,

  use: {
    baseURL: 'https://ontic-in.github.io/SIM',
    trace: 'on-first-retry',
    screenshot: 'on',
    video: 'on',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
