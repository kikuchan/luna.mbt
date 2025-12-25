import { test, expect } from "@playwright/test";
import { execSync, spawn, ChildProcess } from "node:child_process";
import { join } from "node:path";

const PROJECT_ROOT = join(import.meta.dirname, "../..");
const ASTRA_APP_DIR = join(PROJECT_ROOT, "examples/astra_app");
const CLI_PATH = join(PROJECT_ROOT, "target/js/release/build/astra/cli/cli.js");

function startStaticServer(distDir: string): Promise<{ url: string; process: ChildProcess }> {
  return new Promise((resolve, reject) => {
    const server = spawn("npx", ["serve", "-l", "0", distDir], {
      stdio: ["pipe", "pipe", "pipe"],
    });

    let output = "";
    let resolved = false;

    const tryResolve = () => {
      if (resolved) return;
      const match = output.match(/http:\/\/localhost:(\d+)/);
      if (match) {
        resolved = true;
        setTimeout(() => {
          resolve({
            url: `http://localhost:${match[1]}`,
            process: server,
          });
        }, 500);
      }
    };

    server.stdout?.on("data", (data: Buffer) => {
      output += data.toString();
      tryResolve();
    });

    server.stderr?.on("data", (data: Buffer) => {
      output += data.toString();
      tryResolve();
    });

    server.on("error", reject);

    setTimeout(() => {
      if (!resolved) {
        reject(new Error("Server failed to start within 10 seconds"));
      }
    }, 10000);
  });
}

test.describe("Dynamic Routes - _slug_ Pattern", () => {
  let server: { url: string; process: ChildProcess };

  test.beforeAll(async () => {
    // Build astra_app
    execSync(`node ${CLI_PATH} build`, {
      cwd: ASTRA_APP_DIR,
      stdio: "inherit",
    });

    // Start static server
    server = await startStaticServer(join(ASTRA_APP_DIR, "dist"));
  });

  test.afterAll(() => {
    server?.process?.kill();
  });

  test("posts index page loads with links to all posts", async ({ page }) => {
    await page.goto(`${server.url}/posts/`);

    // Check page title
    await expect(page).toHaveTitle(/Posts/);

    // Check that all post links are present in the main content area
    const mainContent = page.locator("main, .content, article").first();
    await expect(mainContent.getByRole("link", { name: "Hello World" })).toBeVisible();
    await expect(mainContent.getByRole("link", { name: "Getting Started" })).toBeVisible();
    await expect(mainContent.getByRole("link", { name: "Advanced Topics" })).toBeVisible();
  });

  test("hello-world post page is generated correctly", async ({ page }) => {
    await page.goto(`${server.url}/posts/hello-world/`);

    // Check page loads
    await expect(page.locator("h1")).toContainText("Post Page");

    // Check content is rendered
    await expect(page.locator("body")).toContainText("dynamically generated post page");
  });

  test("getting-started post page is generated correctly", async ({ page }) => {
    await page.goto(`${server.url}/posts/getting-started/`);

    // Check page loads
    await expect(page.locator("h1")).toContainText("Post Page");

    // Check it's a different page (same template content)
    await expect(page.locator("body")).toContainText("dynamically generated post page");
  });

  test("advanced-topics post page is generated correctly", async ({ page }) => {
    await page.goto(`${server.url}/posts/advanced-topics/`);

    // Check page loads
    await expect(page.locator("h1")).toContainText("Post Page");

    // Check content
    await expect(page.locator("body")).toContainText("staticParams");
  });

  test("navigation from index to post works", async ({ page }) => {
    await page.goto(`${server.url}/posts/`);

    // Click on Hello World link in main content area (not sidebar)
    const mainContent = page.locator("main, .content, article").first();
    await mainContent.getByRole("link", { name: "Hello World" }).click();

    // Verify navigation
    await expect(page).toHaveURL(/\/posts\/hello-world\/?$/);
    await expect(page.locator("h1")).toContainText("Post Page");
  });

  test("all generated posts have correct meta description", async ({ page }) => {
    // Check hello-world
    await page.goto(`${server.url}/posts/hello-world/`);
    const metaHello = page.locator('meta[name="description"]');
    await expect(metaHello).toHaveAttribute("content", "A blog post example");

    // Check getting-started
    await page.goto(`${server.url}/posts/getting-started/`);
    const metaGetting = page.locator('meta[name="description"]');
    await expect(metaGetting).toHaveAttribute("content", "A blog post example");
  });

  test("non-existent slug returns 404", async ({ page }) => {
    const response = await page.goto(`${server.url}/posts/non-existent-post/`);

    // Static server returns 404 for non-existent pages
    expect(response?.status()).toBe(404);
  });

  test("generated pages have proper HTML structure", async ({ page }) => {
    await page.goto(`${server.url}/posts/hello-world/`);

    // Check basic HTML structure
    await expect(page.locator("html")).toHaveAttribute("lang", "en");
    await expect(page.locator("meta[charset]")).toHaveAttribute("charset", "UTF-8");
    await expect(page.locator("meta[name='viewport']")).toBeAttached();
  });

  test("posts index explains _slug_ pattern usage", async ({ page }) => {
    await page.goto(`${server.url}/posts/`);

    // Check that the documentation about _slug_ pattern is present
    await expect(page.locator("body")).toContainText("_slug_");
    await expect(page.locator("body")).toContainText("staticParams");
  });
});
