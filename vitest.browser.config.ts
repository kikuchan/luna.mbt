import { defineConfig } from "vitest/config";
import { playwright } from "@vitest/browser-playwright";

export default defineConfig({
  test: {
    browser: {
      enabled: true,
      provider: playwright(),
      instances: [
        { browser: "chromium" },
      ],
    },
    include: [
      "packages/**/*.test.ts",
    ],
    exclude: [
      "node_modules/**",
      ".mooncakes/**",
      // Exclude tests that use Node.js-specific features
      "src/resume/**",
    ],
  },
});
