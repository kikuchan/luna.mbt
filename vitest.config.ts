import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    // Default: Node.js environment with jsdom for DOM tests
    environment: "jsdom",
    include: [
      "src/**/*.test.ts",
      "packages/**/*.test.ts",
    ],
    exclude: [
      "**/node_modules/**",
      "**/.mooncakes/**",
      // Exclude CLI e2e tests (run with playwright) and temp directories
      "packages/cli/e2e/**",
      "packages/**/tmp/**",
    ],
  },
});
