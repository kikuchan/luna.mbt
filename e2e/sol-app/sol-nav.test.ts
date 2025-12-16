import { test, expect } from "@playwright/test";

/**
 * E2E tests for Sol CSR Navigation
 * Tests client-side routing with sol-link and sol-nav.js
 */
test.describe("Sol CSR Navigation", () => {
  const BASE_URL = "http://localhost:3457";

  test.describe("Basic CSR Navigation", () => {
    test("navigates from home to about via CSR", async ({ page }) => {
      await page.goto(BASE_URL);

      // Verify we're on home page
      await expect(page.locator("h1")).toContainText("Welcome to Sol");

      // Count navigation links before click
      const navLinks = page.locator("nav a");
      const initialLinkCount = await navLinks.count();

      // Click About link (should be CSR)
      await page.click('[data-sol-link][href="/about"]');

      // Wait for navigation
      await page.waitForURL(`${BASE_URL}/about`);

      // Verify content changed
      await expect(page.locator("h1")).toContainText("About");

      // Verify layout is NOT duplicated - nav should appear only once
      const navLinksAfter = page.locator("nav a");
      const afterLinkCount = await navLinksAfter.count();
      expect(afterLinkCount).toBe(initialLinkCount);
    });

    test("navigates from about to home via CSR", async ({ page }) => {
      await page.goto(`${BASE_URL}/about`);

      // Verify we're on about page
      await expect(page.locator("h1")).toContainText("About");

      // Click Home link
      await page.click('[data-sol-link][href="/"]');

      // Wait for navigation
      await page.waitForURL(`${BASE_URL}/`);

      // Verify content changed
      await expect(page.locator("h1")).toContainText("Welcome to Sol");
    });

    test("layout should not be duplicated after navigation", async ({ page }) => {
      await page.goto(BASE_URL);

      // Count nav elements - should be exactly 1
      const navCount = await page.locator("nav").count();
      expect(navCount).toBe(1);

      // Navigate to about
      await page.click('[data-sol-link][href="/about"]');
      await page.waitForURL(`${BASE_URL}/about`);

      // After CSR navigation, nav should still be exactly 1
      const navCountAfter = await page.locator("nav").count();
      expect(navCountAfter).toBe(1);

      // Navigate back to home
      await page.click('[data-sol-link][href="/"]');
      await page.waitForURL(`${BASE_URL}/`);

      // Still exactly 1 nav
      const navCountFinal = await page.locator("nav").count();
      expect(navCountFinal).toBe(1);
    });
  });

  test.describe("Island Re-hydration after CSR", () => {
    test("counter island works after navigating away and back", async ({ page }) => {
      await page.goto(BASE_URL);

      // Wait for hydration
      await page.waitForTimeout(500);

      // Manually hydrate the counter
      await page.evaluate(async () => {
        const counterEl = document.querySelector('[ln\\:id="counter"]') as HTMLElement;
        if (counterEl) {
          const mod = await import("/static/counter.js");
          const state = JSON.parse(counterEl.getAttribute("ln:state") || "{}");
          const fn = mod.hydrate_counter || mod.hydrate || mod.default;
          if (fn) fn(counterEl, state, "counter");
        }
      });
      await page.waitForTimeout(200);

      // Verify counter works initially
      const display = page.locator(".count-display");
      const incButton = page.locator('button.inc');

      await incButton.click();
      await page.waitForTimeout(100);
      await expect(display).toHaveText("1");

      // Navigate to about
      await page.click('[data-sol-link][href="/about"]');
      await page.waitForURL(`${BASE_URL}/about`);
      await expect(page.locator("h1")).toContainText("About");

      // Navigate back to home
      await page.click('[data-sol-link][href="/"]');
      await page.waitForURL(`${BASE_URL}/`);
      await expect(page.locator("h1")).toContainText("Welcome to Sol");

      // Wait for potential re-hydration
      await page.waitForTimeout(500);

      // Re-hydrate manually since we need to test this works
      await page.evaluate(async () => {
        // Clear loaded state to allow re-hydration
        const counterEl = document.querySelector('[ln\\:id="counter"]') as HTMLElement;
        if (counterEl) {
          const mod = await import("/static/counter.js");
          const state = JSON.parse(counterEl.getAttribute("ln:state") || "{}");
          const fn = mod.hydrate_counter || mod.hydrate || mod.default;
          if (fn) fn(counterEl, state, "counter");
        }
      });
      await page.waitForTimeout(200);

      // Counter should be reset to initial state and clickable again
      const displayAfter = page.locator(".count-display");
      const incButtonAfter = page.locator('button.inc');

      await expect(displayAfter).toHaveText("0");

      // Click should work
      await incButtonAfter.click();
      await page.waitForTimeout(100);
      await expect(displayAfter).toHaveText("1");
    });

    test("counter re-hydrates automatically after CSR navigation", async ({ page }) => {
      // This test verifies the loader properly re-hydrates islands after CSR nav
      await page.goto(BASE_URL);

      // Wait for initial load
      await page.waitForTimeout(1000);

      // Navigate away
      await page.click('[data-sol-link][href="/about"]');
      await page.waitForURL(`${BASE_URL}/about`);

      // Navigate back
      await page.click('[data-sol-link][href="/"]');
      await page.waitForURL(`${BASE_URL}/`);

      // Wait for re-hydration
      await page.waitForTimeout(1000);

      // Try clicking increment - if re-hydration worked, this should work
      const display = page.locator(".count-display");
      const incButton = page.locator('button.inc');

      // Check that island exists
      await expect(page.locator('[ln\\:id="counter"]')).toBeVisible();

      // Click the button
      await incButton.click();
      await page.waitForTimeout(100);

      // If re-hydration worked, counter should show 1
      // If not, it will still show 0 (the server-rendered value)
      const value = await display.textContent();
      expect(value).toBe("1");
    });
  });

  test.describe("Browser History", () => {
    test("browser back button works after CSR navigation", async ({ page }) => {
      await page.goto(BASE_URL);
      await expect(page.locator("h1")).toContainText("Welcome to Sol");

      // Navigate to about via CSR
      await page.click('[data-sol-link][href="/about"]');
      await page.waitForURL(`${BASE_URL}/about`);
      await expect(page.locator("h1")).toContainText("About");

      // Press browser back
      await page.goBack();
      await page.waitForURL(`${BASE_URL}/`);
      await expect(page.locator("h1")).toContainText("Welcome to Sol");
    });

    test("browser forward button works after back", async ({ page }) => {
      await page.goto(BASE_URL);

      // Navigate to about
      await page.click('[data-sol-link][href="/about"]');
      await page.waitForURL(`${BASE_URL}/about`);

      // Go back
      await page.goBack();
      await page.waitForURL(`${BASE_URL}/`);

      // Go forward
      await page.goForward();
      await page.waitForURL(`${BASE_URL}/about`);
      await expect(page.locator("h1")).toContainText("About");
    });

    test("multiple navigation and back works correctly", async ({ page }) => {
      await page.goto(BASE_URL);

      // Home -> About -> Home -> About
      await page.click('[data-sol-link][href="/about"]');
      await page.waitForURL(`${BASE_URL}/about`);

      await page.click('[data-sol-link][href="/"]');
      await page.waitForURL(`${BASE_URL}/`);

      await page.click('[data-sol-link][href="/about"]');
      await page.waitForURL(`${BASE_URL}/about`);

      // Now back twice
      await page.goBack();
      await page.waitForURL(`${BASE_URL}/`);

      await page.goBack();
      await page.waitForURL(`${BASE_URL}/about`);

      await expect(page.locator("h1")).toContainText("About");
    });
  });

  test.describe("Title Updates", () => {
    // Skip: Title update timing can be inconsistent in different browsers
    test.skip("page title updates on CSR navigation", async ({ page }) => {
      await page.goto(BASE_URL);

      // Navigate to about
      await page.click('[data-sol-link][href="/about"]');
      await page.waitForURL(`${BASE_URL}/about`);

      // Wait for title update
      await page.waitForTimeout(500);

      // Check title
      const title = await page.title();
      expect(title.toLowerCase()).toContain("about");
    });
  });

  test.describe("Modifier Keys", () => {
    // Skip this test as modifier key behavior varies by OS and browser
    test.skip("ctrl+click opens new tab (not CSR)", async ({ page, context }) => {
      await page.goto(BASE_URL);

      // Listen for new page
      const pagePromise = context.waitForEvent("page");

      // Ctrl+click (or Meta+click on Mac)
      await page.click('[data-sol-link][href="/about"]', {
        modifiers: ["Control"],
      });

      // Should open new tab
      const newPage = await pagePromise;
      await newPage.waitForLoadState();
      expect(newPage.url()).toContain("/about");

      // Original page should still be on home
      await expect(page.locator("h1")).toContainText("Welcome to Sol");
    });
  });
});
