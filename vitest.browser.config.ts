import { defineConfig } from "vitest/config";
import { playwright } from "@vitest/browser-playwright";

export default defineConfig({
  esbuild: {
    jsx: "automatic",
    jsxImportSource: "@mizchi/luna",
  },
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
      "js/luna/**/*.test.ts",
      "js/luna/**/*.bench.ts",
    ],
    exclude: [
      "**/node_modules/**",
      "**/.mooncakes/**",
      "js/**/tmp/**",
      // TSX tests use old bun:test format - need migration
      "js/luna/**/*.test.tsx",
    ],
  },
});
