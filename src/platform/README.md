# Platform

Platform-specific implementations.

## Module Structure

| Submodule | Responsibility |
|-----------|----------------|
| `dom/` | Browser DOM operations |
| `js/` | JS-specific APIs |
| `server_dom/` | Server-side DOM (no events) |

## dom/

DOM operations for browser environment.

| Path | Responsibility |
|------|----------------|
| `element/` | Low-level DOM operations (render, diff, reconcile) |
| `client/` | Client-side Hydration |
| `router/` | Client-side routing |
| `portal/` | Portal component |
| `island.mbt` | Island Hydration |
| `wc_island.mbt` | Web Components Island (Declarative Shadow DOM) |

## js/

JavaScript-specific functionality.

| Path | Responsibility |
|------|----------------|
| `api/` | Public API for JS (`@luna_ui/luna`) |
| `stream_renderer/` | Streaming SSR |
| `cache/` | File cache (mtime-based) |
| `fs_adapter/` | FileSystem adapter (Node.js, memfs) |

## server_dom/

Server-side DOM generation. No event handlers.

| Path | Responsibility |
|------|----------------|
| `element/` | HTML element factory (html, head, body, etc.) |
| `island.mbt` | Island helper |
| `wc_island.mbt` | Web Components Island |
| `render.mbt` | Rendering functions |

## Usage Guide

```
Browser runtime → dom/
Server runtime  → server_dom/
JS-specific     → js/
```

## References

- [Luna Core](../luna/README.md) - VNode definitions
- [Stella](../stella/README.md) - Shard generation
