/**
 * E2E Test Server - Unified server for Playwright tests
 *
 * Uses MoonBit Hono app for test routes, with JS wrapper for:
 * - Static file serving (loader, components)
 * - API endpoints
 */
import { Hono } from "hono";
import { serve } from "@hono/node-server";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const rootDir = join(__dirname, "..");

// Load static assets
const loaderPath = join(rootDir, "packages", "loader", "kg-loader-v1.js");
const loaderCode = readFileSync(loaderPath, "utf-8");

// Import MoonBit counter_component module for SSR
const counterComponentPath = join(
  rootDir,
  "target",
  "js",
  "release",
  "build",
  "tests",
  "counter_component",
  "counter_component.js"
);

// Import MoonBit counter_client module path for client hydration
const counterClientPath = join(
  rootDir,
  "target",
  "js",
  "release",
  "build",
  "tests",
  "counter_client",
  "counter_client.js"
);

// Import MoonBit e2e_server module
const e2eServerPath = join(
  rootDir,
  "target",
  "js",
  "release",
  "build",
  "tests",
  "e2e_server",
  "e2e_server.js"
);

// Promisify MoonBit async callback
function promisifyMoonBit<T>(fn: (cont: (v: T) => void, err: (e: Error) => void) => void): Promise<T> {
  return new Promise((resolve, reject) => {
    fn(resolve, reject);
  });
}

// Create the main Hono app
const app = new Hono();

// Health check
app.get("/", (c) => c.text("ok"));

// Serve static assets
app.get("/kg-loader-v1.js", (c) => {
  return c.body(loaderCode, 200, {
    "Content-Type": "application/javascript",
  });
});

// Component hydration scripts (legacy JS version)
app.get("/components/counter.js", (c) => {
  const code = `
export function hydrate(el, state, id) {
  const countSpan = el.querySelector('[data-count]');
  const incBtn = el.querySelector('[data-inc]');
  const decBtn = el.querySelector('[data-dec]');

  let count = state?.count ?? 0;

  const render = () => {
    countSpan.textContent = count;
    countSpan.setAttribute('data-hydrated', 'true');
  };

  incBtn?.addEventListener('click', () => {
    count++;
    render();
  });

  decBtn?.addEventListener('click', () => {
    count--;
    render();
  });

  el.setAttribute('data-hydrated', 'true');
  render();
}
`;
  return c.body(code, 200, {
    "Content-Type": "application/javascript",
  });
});

// MoonBit counter client module (compiled from counter_client/hydrate.mbt)
app.get("/components/counter-mbt.js", async (c) => {
  const code = readFileSync(counterClientPath, "utf-8");
  return c.body(code, 200, {
    "Content-Type": "application/javascript",
  });
});

app.get("/components/lazy.js", (c) => {
  const code = `
export function hydrate(el, state, id) {
  el.setAttribute('data-hydrated', 'true');
  el.querySelector('[data-content]').textContent = 'Hydrated: ' + (state?.message ?? 'no message');
}
`;
  return c.body(code, 200, {
    "Content-Type": "application/javascript",
  });
});

app.get("/components/greeting.js", (c) => {
  const code = `
export function hydrate(el, state, id) {
  el.setAttribute('data-hydrated', 'true');
  const nameEl = el.querySelector('[data-name]');
  if (nameEl && state?.name) {
    nameEl.textContent = state.name;
  }
}
`;
  return c.body(code, 200, {
    "Content-Type": "application/javascript",
  });
});

app.get("/components/user.js", (c) => {
  const code = `
export function hydrate(el, state, id) {
  el.setAttribute('data-hydrated', 'true');
  el.querySelector('[data-name]').textContent = state?.name ?? 'Unknown';
  el.querySelector('[data-email]').textContent = state?.email ?? '';
}
`;
  return c.body(code, 200, {
    "Content-Type": "application/javascript",
  });
});

// API endpoints
app.get("/api/state/user", (c) => {
  return c.json({ name: "Alice", email: "alice@example.com" });
});

// Idempotent hydration test route
// Uses MoonBit SSR for initial render, MoonBit hydrate for client
app.get("/test/idempotent-hydrate", async (c) => {
  const counterComponent = await import(counterComponentPath);
  const count = 5;
  const ssrHtml = counterComponent.render_counter_html(count);
  const stateJson = counterComponent.serialize_state(count);

  const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Idempotent Hydration Test</title>
  <script type="module" src="/kg-loader-v1.js"></script>
</head>
<body>
  <h1>Idempotent Hydration Test</h1>
  <p>Initial count: ${count}</p>

  <!-- SSR content with kg attributes for loader -->
  <div id="counter"
       kg:id="counter-1"
       kg:url="/components/counter-mbt.js"
       kg:trigger="load"
       kg:state='${stateJson}'>${ssrHtml}</div>

  <!-- Debug info -->
  <div id="debug">
    <h3>SSR Output (before hydration):</h3>
    <pre id="ssr-html"></pre>
    <h3>DOM after hydration:</h3>
    <pre id="hydrated-html"></pre>
  </div>

  <script type="module">
    // Capture SSR HTML before hydration
    const ssrHtml = document.getElementById('counter').innerHTML;
    document.getElementById('ssr-html').textContent = ssrHtml;

    // Wait for hydration and capture DOM after
    const checkHydration = setInterval(() => {
      const counter = document.getElementById('counter');
      if (counter.hasAttribute('data-hydrated')) {
        clearInterval(checkHydration);
        document.getElementById('hydrated-html').textContent = counter.innerHTML;
      }
    }, 50);
  </script>
</body>
</html>`;

  return c.html(html);
});

// Mount MoonBit Hono app
async function setupMoonBitRoutes() {
  const e2eServer = await import(e2eServerPath);
  const moonbitApp = await promisifyMoonBit<any>(e2eServer.create_app);

  // Mount loader routes at /loader/*
  // Mount embedding routes at /embedding/*
  app.route("/", moonbitApp);
}

// Start server
const port = parseInt(process.env.PORT || "3456");

async function main() {
  await setupMoonBitRoutes();

  if (process.env.E2E_SERVER_START !== "false") {
    serve({ fetch: app.fetch, port, hostname: "0.0.0.0" }, () => {
      console.log(`E2E test server running at http://localhost:${port}`);
    });
  }
}

main().catch(console.error);

export { app, port };
