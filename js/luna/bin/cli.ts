#!/usr/bin/env node
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

interface Template {
  path: string;
  content: string;
}

function printHelp() {
  console.log(`
@luna_ui/luna CLI

Usage:
  npx @luna_ui/luna new <project-name> [options]

Options:
  --mbt       Generate MoonBit template (default: TSX)
  --help, -h  Show this help message

Examples:
  npx @luna_ui/luna new myapp         # TSX template
  npx @luna_ui/luna new myapp --mbt   # MoonBit template
`);
}

function getTsxTemplates(projectName: string): Template[] {
  return [
    {
      path: "package.json",
      content: JSON.stringify(
        {
          name: projectName,
          private: true,
          type: "module",
          scripts: {
            dev: "vite",
            build: "vite build",
            preview: "vite preview",
          },
          dependencies: {
            "@luna_ui/luna": "latest",
          },
          devDependencies: {
            vite: "^6.0.0",
            typescript: "^5.7.0",
          },
        },
        null,
        2
      ),
    },
    {
      path: "tsconfig.json",
      content: JSON.stringify(
        {
          compilerOptions: {
            target: "ES2023",
            module: "ESNext",
            moduleResolution: "bundler",
            noEmit: true,
            allowJs: true,
            strict: true,
            esModuleInterop: true,
            skipLibCheck: true,
            jsx: "preserve",
            jsxImportSource: "@luna_ui/luna",
          },
          include: ["src/**/*"],
        },
        null,
        2
      ),
    },
    {
      path: "vite.config.ts",
      content: `import { defineConfig } from "vite";

export default defineConfig({
  esbuild: {
    jsx: "automatic",
    jsxImportSource: "@luna_ui/luna",
  },
});
`,
    },
    {
      path: "index.html",
      content: `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${projectName}</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
`,
    },
    {
      path: "src/main.tsx",
      content: `import { render } from "@luna_ui/luna";
import { App } from "./App";

render(() => <App />, document.getElementById("app")!);
`,
    },
    {
      path: "src/App.tsx",
      content: `import { createSignal, For, Show } from "@luna_ui/luna";

export function App() {
  const [count, setCount] = createSignal(0);
  const [items, setItems] = createSignal<string[]>([]);

  const increment = () => setCount((c) => c + 1);
  const decrement = () => setCount((c) => c - 1);
  const reset = () => setCount(0);
  const addItem = () => setItems((prev) => [...prev, \`Item \${prev.length + 1}\`]);

  return (
    <div>
      <h1>Luna Counter</h1>
      <p>Count: {count}</p>
      <p>Doubled: {() => count() * 2}</p>
      <div>
        <button onClick={increment}>+1</button>
        <button onClick={decrement}>-1</button>
        <button onClick={reset}>Reset</button>
      </div>

      <h2>Items</h2>
      <button onClick={addItem}>Add Item</button>
      <Show when={() => items().length > 0} fallback={<p>No items yet</p>}>
        <ul>
          <For each={items}>
            {(item, index) => (
              <li>
                {index}: {item}
              </li>
            )}
          </For>
        </ul>
      </Show>
    </div>
  );
}
`,
    },
    {
      path: ".gitignore",
      content: `node_modules
dist
.vite
`,
    },
  ];
}

function getMbtTemplates(projectName: string): Template[] {
  return [
    {
      path: "package.json",
      content: JSON.stringify(
        {
          name: projectName,
          private: true,
          type: "module",
          scripts: {
            dev: "vite",
            build: "moon build && vite build",
          },
          devDependencies: {
            vite: "^6.0.0",
            "vite-plugin-moonbit": "^0.1.0",
          },
        },
        null,
        2
      ),
    },
    {
      path: "moon.mod.json",
      content: JSON.stringify(
        {
          name: `internal/${projectName}`,
          version: "0.0.1",
          deps: {
            "mizchi/luna": "0.1.3",
            "mizchi/js": "0.10.6",
          },
          source: "src",
          "preferred-target": "js",
        },
        null,
        2
      ),
    },
    {
      path: "tsconfig.json",
      content: JSON.stringify(
        {
          compilerOptions: {
            target: "ES2023",
            module: "ESNext",
            moduleResolution: "bundler",
            noEmit: true,
            allowJs: true,
            strict: true,
            esModuleInterop: true,
            skipLibCheck: true,
            paths: {
              [`mbt:internal/${projectName}`]: [
                "./target/js/release/build/app/app.js",
              ],
            },
          },
          include: ["*.ts"],
        },
        null,
        2
      ),
    },
    {
      path: "vite.config.ts",
      content: `import { defineConfig } from "vite";
import { moonbit } from "vite-plugin-moonbit";

export default defineConfig({
  plugins: [
    moonbit({
      watch: true,
      showLogs: true,
    }),
  ],
});
`,
    },
    {
      path: "index.html",
      content: `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${projectName}</title>
  </head>
  <body>
    <h1>${projectName}</h1>
    <div id="app"></div>
    <script type="module" src="/main.ts"></script>
  </body>
</html>
`,
    },
    {
      path: "main.ts",
      content: `// Import MoonBit module via mbt: prefix
import "mbt:internal/${projectName}";
`,
    },
    {
      path: "src/moon.pkg.json",
      content: JSON.stringify(
        {
          "is-main": true,
          "supported-targets": ["js"],
          import: [
            "mizchi/luna",
            {
              path: "mizchi/luna/platform/dom/element",
              alias: "element",
            },
            {
              path: "mizchi/js/browser/dom",
              alias: "dom",
            },
          ],
        },
        null,
        2
      ),
    },
    {
      path: "src/lib.mbt",
      content: `// Luna Counter App

fn main {
  let count = @luna.signal(0)
  let doubled = @luna.memo(fn() { count.get() * 2 })

  @luna.render(
    @element.div([
      @element.h1_([
        @luna.text("Luna Counter (MoonBit)"),
      ]),
      @element.p([
        @luna.text("Count: "),
        @luna.text_dyn(fn() { count.get().to_string() }),
      ]),
      @element.p([
        @luna.text("Doubled: "),
        @luna.text_dyn(fn() { doubled().to_string() }),
      ]),
      @element.div([
        @element.button(
          @luna.events().on_click(fn(_e) { count.update(fn(n) { n + 1 }) }),
          [@luna.text("+1")],
        ),
        @element.button(
          @luna.events().on_click(fn(_e) { count.update(fn(n) { n - 1 }) }),
          [@luna.text("-1")],
        ),
        @element.button(
          @luna.events().on_click(fn(_e) { count.set(0) }),
          [@luna.text("Reset")],
        ),
      ]),
    ]),
    @dom.query_selector!("#app"),
  )
}
`,
    },
    {
      path: ".gitignore",
      content: `node_modules
dist
target
.mooncakes
`,
    },
  ];
}

function createProject(
  projectName: string,
  templates: Template[],
  targetDir: string
) {
  if (fs.existsSync(targetDir)) {
    console.error(`Error: Directory "${projectName}" already exists.`);
    process.exit(1);
  }

  fs.mkdirSync(targetDir, { recursive: true });

  for (const template of templates) {
    const filePath = path.join(targetDir, template.path);
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(filePath, template.content);
    console.log(`  Created: ${template.path}`);
  }
}

function main() {
  const args = process.argv.slice(2);

  if (args.length === 0 || args.includes("--help") || args.includes("-h")) {
    printHelp();
    process.exit(0);
  }

  const command = args[0];

  if (command !== "new") {
    console.error(`Unknown command: ${command}`);
    printHelp();
    process.exit(1);
  }

  const projectName = args[1];
  if (!projectName) {
    console.error("Error: Project name is required.");
    printHelp();
    process.exit(1);
  }

  // Validate project name
  if (!/^[a-zA-Z0-9_-]+$/.test(projectName)) {
    console.error(
      "Error: Project name can only contain letters, numbers, hyphens, and underscores."
    );
    process.exit(1);
  }

  const useMbt = args.includes("--mbt");
  const targetDir = path.resolve(process.cwd(), projectName);

  console.log(`\nCreating ${useMbt ? "MoonBit" : "TSX"} project: ${projectName}\n`);

  const templates = useMbt
    ? getMbtTemplates(projectName)
    : getTsxTemplates(projectName);

  createProject(projectName, templates, targetDir);

  console.log(`\nDone! To get started:\n`);
  console.log(`  cd ${projectName}`);

  if (useMbt) {
    console.log(`  moon update`);
    console.log(`  npm install`);
    console.log(`  moon build`);
    console.log(`  npm run dev`);
  } else {
    console.log(`  npm install`);
    console.log(`  npm run dev`);
  }

  console.log();
}

main();
