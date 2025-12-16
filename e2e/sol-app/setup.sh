#!/bin/bash
# Setup script for sol-app E2E test
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
APP_DIR="$ROOT_DIR/examples/sol_app"
CLI_PATH="$ROOT_DIR/target/js/release/build/sol/cli/cli.js"
PORT="${PORT:-3457}"

echo "=== Sol App E2E Setup ==="
echo "ROOT_DIR: $ROOT_DIR"
echo "APP_DIR: $APP_DIR"
echo "PORT: $PORT"

# Build CLI first
echo "Building sol CLI..."
cd "$ROOT_DIR"
moon build --target js

# Setup example project
cd "$APP_DIR"

# Install dependencies
echo "Installing npm dependencies..."
npm install --silent

echo "Installing moon dependencies..."
moon install

# Run sol generate with dev mode
echo "Running sol generate --mode dev..."
node "$CLI_PATH" generate --mode dev

# Build MoonBit
echo "Building MoonBit..."
moon build --target js

# Bundle with rolldown using manifest.json
echo "Bundling with rolldown..."
node --input-type=module -e "
import { readFileSync } from 'node:fs';
import { build } from 'rolldown';
const manifest = JSON.parse(readFileSync('.sol/dev/manifest.json', 'utf-8'));
const input = {};
for (const island of manifest.islands) { input[island.name] = island.entry_path; }
await build({ input, output: { dir: manifest.output_dir, format: 'esm', entryFileNames: '[name].js', chunkFileNames: '_shared/[name]-[hash].js' } });
"

# Start server
echo "Starting server on port $PORT..."
export PORT="$PORT"
exec node .sol/dev/server/main.js
