import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    // Default: Node.js environment with jsdom for DOM tests
    environment: "jsdom",
    include: [
      "src/**/*.test.ts",
      "packages/loader/**/*.test.ts",
      "e2e/sol/**/*.test.ts",
    ],
    exclude: [
      "**/node_modules/**",
      "**/.mooncakes/**",
      "packages/**/tmp/**",
    ],
  },
});
