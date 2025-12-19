---
title: Overview
---

# Luna Ecosystem Overview

Luna is a suite of tools for building modern web applications with MoonBit and JavaScript. This documentation covers four interconnected projects.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Your Application                         │
├─────────────────────────────────────────────────────────────┤
│  Astra (SSG)          │  Sol (SSR Framework)                 │
│  Static docs sites    │  Full-stack apps with islands        │
├─────────────────────────────────────────────────────────────┤
│                       Luna (Core)                            │
│           Signals, Islands, Hydration, Components            │
├─────────────────────────────────────────────────────────────┤
│                      MoonBit / JavaScript                    │
└─────────────────────────────────────────────────────────────┘
```

## Projects

### [Luna](/luna/) - Core UI Library

The foundation of everything. Luna provides:

- **Signals** - Fine-grained reactive primitives
- **Islands** - Partial hydration for optimal performance
- **Components** - Web Components with declarative syntax
- **Hydration** - Smart loading strategies (load, idle, visible, media)

```typescript
import { createSignal, createEffect } from '@mizchi/luna';

const [count, setCount] = createSignal(0);
createEffect(() => console.log(count()));
setCount(1);  // Logs: 1
```

### [Astra](/astra/) - Static Site Generator

Build documentation sites and blogs from Markdown. Features:

- Markdown with frontmatter support
- Auto-generated navigation and sidebar
- i18n (internationalization) support
- Syntax highlighting with Shiki
- SPA navigation with View Transitions

This documentation site is built with Astra.

### [Sol](/sol/) - Full-Stack Framework

Server-side rendering framework with Hono integration:

- Island Architecture for SSR + partial hydration
- File-based routing
- Edge-ready deployment
- State serialization and resumption

### [Stella](/stella/) - Dev Tools

Development utilities and experimental features:

- Development server with hot reload
- Build tools integration
- Testing utilities

## Learning Paths

### For JavaScript Developers

1. Start with [Tutorial (JavaScript)](/tutorial-js/)
2. Learn [Signals](/luna/signals/) and [Islands](/luna/islands/)
3. Build a site with [Astra](/astra/) or app with [Sol](/sol/)

### For MoonBit Developers

1. Start with [Tutorial (MoonBit)](/tutorial-moonbit/)
2. Explore core Luna APIs in MoonBit
3. Build server-side components

## Quick Comparison

| Feature | Astra | Sol |
|---------|-------|-----|
| Use Case | Documentation, blogs | Web applications |
| Rendering | Static (build-time) | Dynamic (request-time) |
| Routing | File-based | File-based + API routes |
| Islands | Markdown embedded | Component-based |
| Deployment | Static hosting | Edge runtime / Node.js |

## Getting Started

Choose based on your needs:

- **Building docs?** → [Astra Quick Start](/astra/)
- **Building an app?** → [Sol Quick Start](/sol/)
- **Just want reactivity?** → [Luna Signals](/luna/signals/)

## Status

> **Experimental** - All projects are under active development. APIs may change.

Built with [MoonBit](https://www.moonbitlang.com/) - a fast, safe language for cloud and edge computing.
