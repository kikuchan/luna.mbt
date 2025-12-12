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

# Run all tests (MoonBit + Node)
test: test-moonbit test-vitest test-browser test-playwright

# Run MoonBit tests
test-moonbit:
    moon test --target js
    moon test --target all src/core/signal

# Run Node.js tests (vitest)
test-vitest: build
    pnpm test

# Run browser tests
test-browser: build
    pnpm test:browser

# Run E2E tests (playwright)
test-playwright: build
    pnpm test:e2e

# === Build Commands ===

# Build MoonBit
build:
    moon build --target js
    pnpm build

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

# Run benchmarks
bench:
    moon bench --target js

# Watch and rebuild
watch:
    moon build --target js --watch
