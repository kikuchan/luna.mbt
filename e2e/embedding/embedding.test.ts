import { test, expect } from "@playwright/test";

test.describe("Embedding Module E2E Tests", () => {
  test.describe("generate_minimal_embed", () => {
    test("generates correct HTML structure", async ({ page }) => {
      await page.goto("/embedding/minimal");

      // Check kg:* attributes are present
      const component = page.locator('[kg\\:id="counter-1"]');
      await expect(component).toHaveAttribute("kg:url", "/components/counter.js");
      // State attribute is HTML-escaped in source but browser parses it correctly
      const state = await component.getAttribute("kg:state");
      expect(state).toBe('{"count":42}');
    });

    test("hydrates and responds to interactions", async ({ page }) => {
      await page.goto("/embedding/minimal");

      // Wait for hydration
      await expect(page.locator('[kg\\:id="counter-1"]')).toHaveAttribute(
        "data-hydrated",
        "true"
      );

      const count = page.locator("[data-count]");
      await expect(count).toHaveText("42");

      // Increment
      await page.locator("[data-inc]").click();
      await expect(count).toHaveText("43");

      // Decrement
      await page.locator("[data-dec]").click();
      await expect(count).toHaveText("42");
    });
  });

  test.describe("generate_standalone_embed", () => {
    test("includes loader script in output", async ({ page }) => {
      await page.goto("/embedding/standalone");

      // Loader should be embedded
      const loaderScript = page.locator('script[src="/kg-loader-v1.js"]');
      await expect(loaderScript).toHaveCount(1);
    });

    test("hydrates correctly", async ({ page }) => {
      await page.goto("/embedding/standalone");

      await expect(page.locator('[kg\\:id="greeting-1"]')).toHaveAttribute(
        "data-hydrated",
        "true"
      );

      await expect(page.locator("[data-name]")).toHaveText("World");
    });
  });

  test.describe("generate_lazy_embed", () => {
    test("sets visible trigger", async ({ page }) => {
      await page.goto("/embedding/lazy");

      const component = page.locator('[kg\\:id="lazy-counter"]');
      await expect(component).toHaveAttribute("kg:trigger", "visible");
    });

    test("does not hydrate until visible", async ({ page }) => {
      await page.goto("/embedding/lazy");

      const component = page.locator('[kg\\:id="lazy-counter"]');

      // Should not be hydrated yet (below fold)
      await expect(component).not.toHaveAttribute("data-hydrated", "true");
    });

    test("hydrates when scrolled into view", async ({ page }) => {
      await page.goto("/embedding/lazy");

      const component = page.locator('[kg\\:id="lazy-counter"]');

      // Scroll to component
      await component.scrollIntoViewIfNeeded();

      // Should hydrate
      await expect(component).toHaveAttribute("data-hydrated", "true", {
        timeout: 5000,
      });

      // Check state was applied
      await expect(page.locator("[data-count]")).toHaveText("100");
    });
  });

  test.describe("XSS Safety", () => {
    test("escapes dangerous content in state", async ({ page }) => {
      await page.goto("/embedding/xss-safety");

      // XSS should not have been triggered
      const xssTriggered = await page.evaluate(() => (window as any).xssTriggered);
      expect(xssTriggered).toBe(false);
    });

    test("escape_json_for_html properly escapes script tags", async ({ page }) => {
      await page.goto("/embedding/xss-safety");

      // Verify the component rendered (was not broken by XSS)
      const component = page.locator('[kg\\:id="xss-test"]');
      await expect(component).toBeVisible();

      // The state value contains dangerous content but it was safely escaped in HTML
      // Browser parses the HTML entities back, so we just verify the component exists
      const stateValue = await component.getAttribute("kg:state");
      expect(stateValue).toContain("<script>");
      expect(stateValue).toContain("</script>");

      // Most importantly: XSS was not triggered
      const xssTriggered = await page.evaluate(() => (window as any).xssTriggered);
      expect(xssTriggered).toBe(false);
    });
  });

  test.describe("generate_state_script", () => {
    test("creates script element with correct type", async ({ page }) => {
      await page.goto("/embedding/state-script");

      const stateScript = page.locator('script[type="kg/json"]#counter-state');
      await expect(stateScript).toHaveCount(1);
    });

    test("state is loaded from script reference", async ({ page }) => {
      await page.goto("/embedding/state-script");

      await expect(page.locator('[kg\\:id="counter-script"]')).toHaveAttribute(
        "data-hydrated",
        "true"
      );

      await expect(page.locator("[data-count]")).toHaveText("999");
    });

    test("interactions work with script-referenced state", async ({ page }) => {
      await page.goto("/embedding/state-script");

      await expect(page.locator('[kg\\:id="counter-script"]')).toHaveAttribute(
        "data-hydrated",
        "true"
      );

      const count = page.locator("[data-count]");
      await expect(count).toHaveText("999");

      await page.locator("[data-inc]").click();
      await expect(count).toHaveText("1000");
    });
  });
});
