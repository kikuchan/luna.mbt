# Default recipe
default: test

# === CI Commands ===

# Run all CI checks (use before PR)
ci: check test size-check
    @echo "✓ All CI checks passed"

# Type check
check:
    moon check --target js

# Check bundle sizes are within limits
size-check:
    #!/usr/bin/env bash
    set -e
    LOADER_SIZE=$(wc -c < packages/loader/ln-loader-v1.js)
    LOADER_MIN_SIZE=$(wc -c < packages/loader/loader.min.js)
    echo "ln-loader-v1.js: ${LOADER_SIZE} bytes"
    echo "loader.min.js: ${LOADER_MIN_SIZE} bytes"
    if [ "$LOADER_SIZE" -gt 5120 ]; then
        echo "❌ ln-loader-v1.js exceeds 5KB limit"
        exit 1
    fi
    if [ "$LOADER_MIN_SIZE" -gt 1024 ]; then
        echo "❌ loader.min.js exceeds 1KB limit"
        exit 1
    fi
    echo "✓ Bundle sizes OK"

# === Test Commands ===

# Run all tests
test: test-moonbit test-vitest test-browser test-e2e
    @echo "✓ All tests passed"

# Run MoonBit unit tests
test-moonbit:
    moon test --target js
    moon test --target all src/core/signal

# Run vitest tests
test-vitest: build-moon
    pnpm vitest run

# Run browser tests
test-browser: build-moon
    pnpm vitest run --config vitest.browser.config.ts

# Run E2E tests (playwright)
test-e2e: build-moon
    pnpm playwright test --config e2e/playwright.config.mts

# Run E2E tests with UI
test-e2e-ui: build-moon
    pnpm playwright test --config e2e/playwright.config.mts --ui

# Run sol new template test
test-sol-new: build-moon
    node scripts/test-sol-new.ts

# === Build Commands ===

# Build MoonBit only
build-moon:
    moon build --target js

# Build all (MoonBit + Vite)
build: build-moon
    pnpm vite build

# Clean build artifacts
clean:
    moon clean
    rm -rf target

# Format code
fmt:
    moon fmt

# === Utility Commands ===

# Show bundle sizes
size:
    @echo "=== Bundle Sizes ==="
    @ls -lh packages/loader/*.js 2>/dev/null | awk '{print $9 ": " $5}'
    @echo ""
    @echo "=== MoonBit Output Sizes ==="
    @find target/js/release/build -name "*.js" -exec ls -lh {} \; 2>/dev/null | awk '{print $9 ": " $5}' | head -20

# Minify loader
minify-loader:
    pnpm terser packages/loader/loader.js --module --compress --mangle -o packages/loader/loader.min.js

# Run benchmarks
bench:
    node bench/run.js

# Run benchmarks with happydom
bench-happydom:
    node bench/run-happydom.js

# Watch and rebuild
watch:
    moon build --target js --watch

# === Sol CLI Commands ===

# Run sol CLI
sol *args:
    node target/js/release/build/sol/cli/cli.js {{args}}

# Create new sol project
sol-new name:
    node target/js/release/build/sol/cli/cli.js new {{name}}
