# Default recipe
default: test

# Run all tests (MoonBit + Node)
test: test-moonbit test-vitest test-browser test-playwright

test-browser: build
    pnpm test:browser

test-playwright: build
    pnpm test:e2e

# Run MoonBit tests
test-moonbit:
    moon test --target js
    moon test --target all src/core/signal

# Run Node.js tests (vitest)
test-vitest: build
    pnpm test

# Build MoonBit
build:
    moon build --target js
    pnpm build

# Clean build artifacts
clean:
    moon clean

# Format code
fmt:
    moon fmt
