#!/usr/bin/env node
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

// Set assets directory for MoonBit loader
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Assets are at js/astra/assets/ relative to dist/cli.js
// dist/cli.js -> js/astra/dist/cli.js
// assets -> js/astra/assets/
(globalThis as any).__astra_assets_dir = join(__dirname, "..", "assets");

// Worker script is at dist/worker.js relative to dist/cli.js
(globalThis as any).__astra_worker_script = join(__dirname, "worker.js");

// Import MoonBit CLI (dynamic import to ensure globalThis is set first)
await import("../../../target/js/release/build/sol/cli/cli");
