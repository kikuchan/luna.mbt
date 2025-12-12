import { defineConfig } from "vitest/config";
import { playwright } from "@vitest/browser-playwright";

export default defineConfig({
  test: {
    browser: {
      enabled: true,
      headless: true,
      provider: playwright(),
      instances: [
        { browser: "chromium" },
      ],
    },
    include: [
      "packages/**/*.test.ts",
      "packages/**/*.bench.ts",
    ],
    exclude: [
      "**/node_modules/**",
      "**/.mooncakes/**",
      // Exclude tests that use Node.js-specific features
      "src/resume/**",
      "packages/loader/**",
      // Exclude CLI e2e tests (run with playwright) and temp directories
      "packages/cli/e2e/**",
      "packages/**/tmp/**",
    ],
  },
});
