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
      "packages/luna/**/*.test.ts",
      "packages/luna/**/*.bench.ts",
    ],
    exclude: [
      "**/node_modules/**",
      "**/.mooncakes/**",
      "packages/**/tmp/**",
      // TSX tests use old bun:test format - need migration
      "packages/luna/**/*.test.tsx",
    ],
  },
});
