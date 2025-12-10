# Embedding Module Architecture

Portable, resumable UI snippets that can be embedded anywhere.

## Overview

This module generates self-contained HTML snippets that include:
- SSR-rendered content
- Serialized initial state
- Hydration trigger configuration
- Loader script reference

Inspired by [Qwik's Resumability](https://qwik.dev/docs/concepts/resumable/) and [Astro's Client Directives](https://docs.astro.build/en/reference/directives-reference/).

## HTML Output Format

```html
<!-- Minimal snippet -->
<div kg:id="counter-1"
     kg:url="https://cdn.example.com/components/counter.js"
     kg:trigger="visible"
     kg:state='{"count":0}'>
  <span>0</span>
  <button>+1</button>
</div>

<!-- With loader (standalone) -->
<script type="module" src="https://cdn.example.com/kg-loader-v1.js"></script>
<div kg:id="counter-1" ...>...</div>

<!-- With inline state for large data -->
<div kg:id="app-1"
     kg:url="./app.js"
     kg:trigger="load"
     kg:state="#kg-state-app-1">
  <!-- SSR content -->
</div>
<script id="kg-state-app-1" type="kg/json">{"large":"data","nested":{"items":[1,2,3]}}<\/script>

<!-- With remote state -->
<div kg:id="user-1"
     kg:url="./user-profile.js"
     kg:trigger="idle"
     kg:state="url:https://api.example.com/user/123/state">
  <span>Loading...</span>
</div>
```

## Attributes

| Attribute | Required | Description |
|-----------|----------|-------------|
| `kg:id` | Yes | Unique identifier for the component |
| `kg:url` | Yes | ES module URL to load for hydration |
| `kg:trigger` | No | When to hydrate (default: `load`) |
| `kg:state` | No | Initial state (inline JSON, `#id` ref, or `url:` prefix) |

## Trigger Types

Following Astro's naming convention:

| Trigger | Description | Implementation |
|---------|-------------|----------------|
| `load` | Hydrate on page load | `DOMContentLoaded` event |
| `idle` | Hydrate when browser is idle | `requestIdleCallback` |
| `visible` | Hydrate when element enters viewport | `IntersectionObserver` |
| `media:QUERY` | Hydrate when media query matches | `matchMedia` |
| `none` | Never auto-hydrate (manual only) | No automatic trigger |

## State Formats

### Inline JSON (default for small state)

```html
<div kg:state='{"count":0}'></div>
```

- Pros: Single HTTP request, no async loading
- Cons: HTML size increases, needs XSS escaping
- Use when: State < 1KB

### Script Reference (for medium state)

```html
<div kg:state="#kg-state-123"></div>
<script id="kg-state-123" type="kg/json">{"data":"..."}<\/script>
```

- Pros: Cleaner HTML attributes, larger capacity
- Cons: Still inline in HTML
- Use when: State 1KB - 100KB

### URL Reference (for large state)

```html
<div kg:state="url:https://api.example.com/state/123"></div>
```

- Pros: Minimal HTML size, CDN cacheable
- Cons: Extra HTTP request, latency
- Use when: State > 100KB or needs caching

## Security Considerations

### XSS Prevention for Inline JSON

All JSON embedded in HTML must escape:
- `</` → `<\/` (prevents `</script>` injection)
- `<` before `s` → `\u003c` (additional safety)

```moonbit
fn escape_json_for_html(json: String) -> String {
  json.replace("</", "<\\/")
}
```

### Content Security Policy

The loader supports CSP nonces:

```html
<script type="module" src="kg-loader-v1.js" nonce="abc123"></script>
```

## Loader Script

`kg-loader-v1.js` (~1KB minified):

1. Scans for `[kg\\:id]` elements
2. Sets up trigger listeners (IntersectionObserver, idle callback, etc.)
3. On trigger:
   - Parse state from `kg:state`
   - Dynamic import `kg:url`
   - Call exported `hydrate(element, state)` function

### Versioning

Loader uses versioned filenames (`kg-loader-v1.js`) to:
- Prevent duplicate loading via `type="module"` deduplication
- Allow multiple versions on same page
- Enable breaking changes without conflicts

```html
<!-- These won't conflict -->
<script type="module" src="kg-loader-v1.js"></script>
<script type="module" src="kg-loader-v2.js"></script>
```

## API

### EmbedConfig

```moonbit
struct EmbedConfig {
  id: String
  script_url: String
  trigger: TriggerType       // Load | Idle | Visible | Media(String) | None
  state: StateConfig         // Inline(String) | ScriptRef(String) | Url(String) | Empty
  ssr_content: String?       // Pre-rendered HTML or None
  include_loader: Bool       // Include loader script tag
  loader_url: String         // Loader URL (default: kg-loader-v1.js)
}
```

### Output

```moonbit
struct EmbedOutput {
  html: String                    // Complete HTML snippet
  head_scripts: Array[String]     // Scripts to inject in <head> (for SSR)
  state_scripts: Array[String]    // State <script> tags (if using ScriptRef)
}
```

### Usage

```moonbit
let config = EmbedConfig::{
  id: "counter-1",
  script_url: "https://cdn.example.com/counter.js",
  trigger: Visible,
  state: Inline(@json.stringify(initial_state)),
  ssr_content: Some(@ssr.render_to_string(vnode)),
  include_loader: true,
  loader_url: "https://cdn.example.com/kg-loader-v1.js",
}

let output = generate_embed(config)
// output.html contains the complete snippet
```

## Integration with packages/loader

The `packages/loader/` directory contains:
- `kg-loader-v1.js` - Production loader
- `kg-loader-v1.min.js` - Minified version

Loader expects components to export:

```typescript
// counter.js
export function hydrate(element: HTMLElement, state: unknown): void {
  // Attach event handlers, set up reactivity
}

// Optional: for render mode (no SSR content)
export function render(element: HTMLElement, state: unknown): void {
  // Render from scratch
}
```

## File Structure

```
src/embedding/
├── ARCHITECTURE.md    # This file
├── moon.pkg.json      # Package config
├── types.mbt          # EmbedConfig, TriggerType, StateConfig, EmbedOutput
├── serializer.mbt     # JSON serialization with XSS escaping
├── html_builder.mbt   # HTML snippet generation
└── embedding_test.mbt # Tests

packages/loader/
├── kg-loader-v1.js    # Loader script (renamed from loader.js)
├── kg-loader-v1.min.js
└── loader.test.ts     # Tests
```

## Future Considerations

- WebComponents output (`<kg-counter>` custom elements)
- Streaming SSR support
- State compression (gzip in base64)
- Preload hints (`<link rel="modulepreload">`)
