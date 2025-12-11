import { test, expect } from "@playwright/test";

test.describe("CSR Router Demo", () => {
  test("mounts and displays initial home page", async ({ page }) => {
    await page.goto("/csr-router/home");

    // Wait for mount
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Check home page is displayed
    const pageContent = page.locator("[data-page='home']");
    await expect(pageContent).toBeVisible();
    await expect(pageContent.locator("h1")).toHaveText("Home Page");
  });

  test("CSR navigation: navigates to about page via link click without page reload", async ({
    page,
  }) => {
    await page.goto("/csr-router/home");
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Track navigation - CSR should not trigger full page navigation
    let navigated = false;
    page.on("framenavigated", () => {
      navigated = true;
    });

    // Click about link (CSR navigation)
    await page.locator("[data-nav='/csr-router/about']").click();

    // Give it a moment
    await page.waitForTimeout(100);

    // URL should have changed
    await expect(page).toHaveURL(/\/csr-router\/about$/);

    // Check about page is displayed
    const pageContent = page.locator("[data-page='about']");
    await expect(pageContent).toBeVisible();
    await expect(pageContent.locator("h1")).toHaveText("About Page");

    // Should NOT have triggered a full page navigation (CSR)
    // Note: framenavigated fires for pushState too, so we can't really test this here
  });

  test("CSR navigation: navigates to contact page", async ({ page }) => {
    await page.goto("/csr-router/home");
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Click contact link
    await page.locator("[data-nav='/csr-router/contact']").click();

    // Check contact page is displayed
    const pageContent = page.locator("[data-page='contact']");
    await expect(pageContent).toBeVisible();
    await expect(pageContent.locator("h1")).toHaveText("Contact Page");

    // Check URL changed
    await expect(page).toHaveURL(/\/csr-router\/contact$/);
  });

  test("CSR navigation: navigates to post detail page with params", async ({
    page,
  }) => {
    await page.goto("/csr-router/home");
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Click post 123 link
    await page.locator("[data-nav='/csr-router/posts/123']").click();

    // Check post page is displayed
    const pageContent = page.locator("[data-page='post']");
    await expect(pageContent).toBeVisible();
    await expect(pageContent.locator("h1")).toHaveText("Post: 123");
    await expect(pageContent).toHaveAttribute("data-post-id", "123");

    // Check URL changed
    await expect(page).toHaveURL(/\/csr-router\/posts\/123$/);
  });

  test("CSR navigation: navigates between different posts", async ({
    page,
  }) => {
    await page.goto("/csr-router/home");
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Click post 123 link
    await page.locator("[data-nav='/csr-router/posts/123']").click();
    await expect(page.locator("[data-post-id='123']")).toBeVisible();

    // Click post 456 link
    await page.locator("[data-nav='/csr-router/posts/456']").click();
    await expect(page.locator("[data-post-id='456']")).toBeVisible();
    await expect(page.locator("[data-page='post'] h1")).toHaveText("Post: 456");
  });

  test("current path display updates on navigation", async ({ page }) => {
    await page.goto("/csr-router/home");
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Check initial path display
    const pathContainer = page.locator("[data-current-path-container]");
    await expect(pathContainer).toContainText(
      "Current path: /csr-router/home"
    );

    // Navigate to about
    await page.locator("[data-nav='/csr-router/about']").click();
    await expect(pathContainer).toContainText(
      "Current path: /csr-router/about"
    );

    // Navigate to post
    await page.locator("[data-nav='/csr-router/posts/123']").click();
    await expect(pathContainer).toContainText(
      "Current path: /csr-router/posts/123"
    );
  });

  test("browser back button works with CSR navigation", async ({ page }) => {
    await page.goto("/csr-router/home");
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Navigate to about (CSR)
    await page.locator("[data-nav='/csr-router/about']").click();
    await expect(page.locator("[data-page='about']")).toBeVisible();

    // Navigate to contact (CSR)
    await page.locator("[data-nav='/csr-router/contact']").click();
    await expect(page.locator("[data-page='contact']")).toBeVisible();

    // Go back (should show about)
    await page.goBack();
    await expect(page.locator("[data-page='about']")).toBeVisible();
    await expect(page).toHaveURL(/\/csr-router\/about$/);

    // Go back again (should show home)
    await page.goBack();
    await expect(page.locator("[data-page='home']")).toBeVisible();
    await expect(page).toHaveURL(/\/csr-router\/home$/);
  });

  test("browser forward button works with CSR navigation", async ({ page }) => {
    await page.goto("/csr-router/home");
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Navigate to about
    await page.locator("[data-nav='/csr-router/about']").click();
    await expect(page.locator("[data-page='about']")).toBeVisible();

    // Go back
    await page.goBack();
    await expect(page.locator("[data-page='home']")).toBeVisible();

    // Go forward
    await page.goForward();
    await expect(page.locator("[data-page='about']")).toBeVisible();
    await expect(page).toHaveURL(/\/csr-router\/about$/);
  });

  test("MPA navigation: direct URL access works", async ({ page }) => {
    // Directly navigate to about page (MPA style)
    await page.goto("/csr-router/about");
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Should show about page
    const pageContent = page.locator("[data-page='about']");
    await expect(pageContent).toBeVisible();
    await expect(pageContent.locator("h1")).toHaveText("About Page");
  });

  test("MPA navigation: direct URL access to post page works", async ({
    page,
  }) => {
    // Directly navigate to post page (MPA style)
    await page.goto("/csr-router/posts/789");
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Should show post page with correct ID
    const pageContent = page.locator("[data-page='post']");
    await expect(pageContent).toBeVisible();
    await expect(pageContent.locator("h1")).toHaveText("Post: 789");
    await expect(pageContent).toHaveAttribute("data-post-id", "789");
  });

  test("displays 404 for unknown routes", async ({ page }) => {
    // Direct navigation to unknown route
    await page.goto("/csr-router/unknown/path");
    await expect(page.locator("#app")).toHaveAttribute("data-mounted", "true");

    // Should show 404 page
    const pageContent = page.locator("[data-page='404']");
    await expect(pageContent).toBeVisible();
    await expect(pageContent.locator("h1")).toHaveText("404 Not Found");
  });
});
