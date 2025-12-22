import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  timeout: 30000,
  use: {
    baseURL: 'http://localhost:3000',
    headless: true,
  },
  webServer: {
    command: 'cd ../.. && moon build --target js && cd examples/sol_app && node ../../target/js/release/build/sol/cli/cli.js build && node .sol/prod/server/main.js',
    port: 3000,
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});
