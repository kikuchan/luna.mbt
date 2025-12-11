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

// Import MoonBit browser_components module for browser tests
const browserComponentsPath = join(
  rootDir,
  "target",
  "js",
  "release",
  "build",
  "tests",
  "browser_components",
  "browser_components.js"
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

// MoonBit browser_components module for browser tests
app.get("/components/browser-components.js", async (c) => {
  const code = readFileSync(browserComponentsPath, "utf-8");
  return c.body(code, 200, {
    "Content-Type": "application/javascript",
  });
});

// Browser test routes
const browserTestPage = (
  title: string,
  componentId: string,
  hydrateFn: string,
  state: object,
  ssrHtml: string
) => `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>${title}</title>
  <script type="module" src="/kg-loader-v1.js"></script>
  <style>
    .box { padding: 20px; border: 1px solid #ccc; margin: 10px 0; }
    .box.active { background-color: #e0ffe0; border-color: green; }
    .content-box { padding: 10px; background: #f0f0f0; margin: 10px 0; }
    .click-area { padding: 20px; border: 1px solid #ccc; cursor: pointer; }
    .input-row { display: flex; gap: 10px; margin-bottom: 10px; }
  </style>
</head>
<body>
  <h1>${title}</h1>
  <div id="app"
       kg:id="${componentId}"
       kg:url="/components/browser-components.js"
       kg:export="${hydrateFn}"
       kg:trigger="load"
       kg:state='${JSON.stringify(state).replace(/'/g, "&#39;")}'>${ssrHtml}</div>
</body>
</html>`;

// Signal/Effect basic test
app.get("/browser/signal-effect", (c) => {
  const html = browserTestPage(
    "Signal/Effect Test",
    "signal-effect-1",
    "hydrate_signal_effect",
    { count: 5 },
    `<div>
      <span data-count>5</span>
      <span data-double>10</span>
      <button data-inc>+1</button>
      <button data-dec>-1</button>
      <button data-reset>Reset</button>
    </div>`
  );
  return c.html(html);
});

// Dynamic attributes test
app.get("/browser/dynamic-attrs", (c) => {
  const html = browserTestPage(
    "Dynamic Attributes Test",
    "dynamic-attrs-1",
    "hydrate_dynamic_attrs",
    { active: false, color: "gray" },
    `<div>
      <div data-box class="box" style="background-color: gray; padding: 20px;">Inactive</div>
      <button data-toggle>Toggle Active</button>
      <button data-red>Red</button>
      <button data-blue>Blue</button>
    </div>`
  );
  return c.html(html);
});

// Show/hide toggle test
app.get("/browser/show-toggle", (c) => {
  const html = browserTestPage(
    "Show/Hide Toggle Test",
    "show-toggle-1",
    "hydrate_show_toggle",
    { visible: false },
    `<div>
      <button data-toggle>Show</button>
    </div>`
  );
  return c.html(html);
});

// For each list test
app.get("/browser/for-each", (c) => {
  const html = browserTestPage(
    "For Each List Test",
    "for-each-1",
    "hydrate_for_each",
    { items: ["Apple", "Banana", "Cherry"] },
    `<div>
      <div class="input-row">
        <input data-input type="text" placeholder="Enter item">
        <button data-add>Add</button>
      </div>
      <span data-count>3 items</span>
      <ul data-list>
        <li data-item="0"><span>Apple</span><button data-remove="0">x</button></li>
        <li data-item="1"><span>Banana</span><button data-remove="1">x</button></li>
        <li data-item="2"><span>Cherry</span><button data-remove="2">x</button></li>
      </ul>
    </div>`
  );
  return c.html(html);
});

// Events test
app.get("/browser/events", (c) => {
  const html = browserTestPage(
    "Events Test",
    "events-1",
    "hydrate_events",
    {},
    `<div>
      <div data-click-area class="click-area" style="padding: 20px; border: 1px solid #ccc; cursor: pointer;">Click or double-click me</div>
      <div>
        <span data-clicks>Clicks: 0</span> |
        <span data-dblclicks>Double-clicks: 0</span> |
        <span data-hover>Hover: none</span>
      </div>
    </div>`
  );
  return c.html(html);
});

// Input binding test
app.get("/browser/input-binding", (c) => {
  const html = browserTestPage(
    "Input Binding Test",
    "input-binding-1",
    "hydrate_input_binding",
    { text: "Initial value" },
    `<div>
      <div data-form>
        <input data-text-input type="text" value="Initial value">
        <button data-submit>Submit</button>
        <button data-clear>Clear</button>
        <button data-set-hello>Set Hello</button>
      </div>
      <div><span data-preview>Preview: Initial value</span></div>
      <div><span data-submitted>Submitted: </span></div>
    </div>`
  );
  return c.html(html);
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
