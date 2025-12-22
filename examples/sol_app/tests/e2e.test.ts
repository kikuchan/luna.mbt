import { test, expect } from '@playwright/test';

test.describe('Sol App E2E', () => {
  test('full user flow: counter interaction and navigation', async ({ page }) => {
    // 1. Navigate to home page
    await page.goto('/');
    await expect(page).toHaveURL('/');

    // 2. Verify home page content
    const counter = page.locator('.counter');
    await expect(counter).toBeVisible();

    const countDisplay = page.locator('.count-display');
    // Get initial value (can be random)
    const initialText = await countDisplay.textContent();
    const initialValue = parseInt(initialText || '0', 10);

    // 3. Wait for hydration
    await page.waitForTimeout(500);

    // 4. Click counter and verify increment
    const incButton = page.locator('button.inc');
    await incButton.click();
    await expect(countDisplay).toHaveText(String(initialValue + 1));

    // Click again to verify multiple increments work
    await incButton.click();
    await expect(countDisplay).toHaveText(String(initialValue + 2));

    // 5. Navigate to About page via navigation link
    const aboutLink = page.locator('nav a[href="/about"]');
    await aboutLink.click();

    // 6. Verify URL changed to /about
    await expect(page).toHaveURL('/about');

    // 7. Verify About page content is visible
    await expect(page.locator('body')).toContainText('About');
  });

  test('navigation between all pages', async ({ page }) => {
    // Start at home
    await page.goto('/');
    await expect(page).toHaveURL('/');

    // Navigate to About
    await page.locator('nav a[href="/about"]').click();
    await expect(page).toHaveURL('/about');

    // Navigate to Form
    await page.locator('nav a[href="/form"]').click();
    await expect(page).toHaveURL('/form');

    // Navigate to WC Counter
    await page.locator('nav a[href="/wc-counter"]').click();
    await expect(page).toHaveURL('/wc-counter');

    // Navigate back to Home
    await page.locator('nav a[href="/"]').click();
    await expect(page).toHaveURL('/');
  });

  test('API health endpoint', async ({ request }) => {
    const response = await request.get('/api/health');
    expect(response.ok()).toBeTruthy();
    const json = await response.json();
    expect(json.status).toBe('ok');
  });
});
