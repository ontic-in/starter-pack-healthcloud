// Vitest setup file
import { vi } from 'vitest';

// Mock localStorage
global.localStorage = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn()
};

// Mock window.clarity (Microsoft Clarity analytics)
global.window.clarity = vi.fn();

// Mock embeddedservice_bootstrap
global.embeddedservice_bootstrap = {
  settings: {},
  init: vi.fn()
};
