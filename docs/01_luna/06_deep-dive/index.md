---
title: Deep Dive
---

# Deep Dive

Advanced concepts and internal architecture.

## Design Decisions

### Why No Compile-Time Optimization?

Many modern frameworks (Svelte, Solid, Qwik) rely heavily on compile-time transformations:

| Framework | Approach | Trade-off |
|-----------|----------|-----------|
| Svelte | Compiles to imperative code | Magic syntax, harder debugging |
| Solid | JSX transformation | Build complexity |
| Qwik | Resumability via code splitting | Complex mental model |
| **Luna** | **Minimal runtime, no magic** | **What you write is what runs** |

Luna takes a different approach: **make the runtime so small that optimization becomes unnecessary**.

At ~6.7KB total, Luna's overhead is already negligible. This means:
- No build-time surprises
- Easier debugging (code behaves as written)
- Simpler mental model
- Works with any bundler

### WebComponents SSR: World's First Implementation

Luna is the first framework to support full WebComponents SSR + Hydration using Declarative Shadow DOM:

```html
<!-- Server-rendered output -->
<my-counter luna:client-trigger="visible">
  <template shadowrootmode="open">
    <style>button { color: blue; }</style>
    <button>Count: 0</button>
  </template>
</my-counter>
```

The key insight: Declarative Shadow DOM (`<template shadowrootmode="open">`) allows Shadow DOM to be serialized as HTML. Combined with Luna's hydration system, this enables:

- **SSR with encapsulated styles** - No FOUC (Flash of Unstyled Content)
- **Progressive enhancement** - Content visible before JS loads
- **Framework agnostic** - Islands work with any frontend code

## Reactivity System

Luna's reactivity is based on fine-grained signals:

```
Signal
  └── Subscribers (Effects, Memos)
        └── DOM Updates
```

When a signal changes:
1. All subscribers are notified
2. Effects run synchronously (batched)
3. DOM updates happen directly (no diffing)

### Performance Characteristics

| Operation | Complexity |
|-----------|------------|
| Signal read | O(1) |
| Signal write | O(subscribers) |
| DOM update | O(1) per affected node |

Compare to Virtual DOM:
- React: O(n) tree diff on every render
- Luna: O(1) direct updates

This difference is why Luna achieves 60 FPS where React achieves 12 FPS on the same workload.

## Hydration Strategies

Luna supports multiple hydration strategies:

| Strategy | When hydrates | Use case |
|----------|--------------|----------|
| `load` | Immediately | Critical interactions |
| `idle` | Browser idle | Secondary features |
| `visible` | In viewport | Below-the-fold content |
| `media` | Media query matches | Device-specific |

### Web Components Integration

Islands can be implemented as Web Components:

```typescript
hydrateWC("my-counter", (root, props, trigger) => {
  // root: ShadowRoot
  // props: Serialized props
  // trigger: Hydration trigger info
});
```

Benefits:
- Style encapsulation via Shadow DOM
- Native browser support
- Framework agnostic islands

### SSR and Serialization

Server-rendered HTML includes:
- Static markup with Declarative Shadow DOM
- Island placeholders with hydration attributes
- Serialized props (base64 encoded)

The client loader:
1. Finds island placeholders
2. Deserializes props
3. Hydrates based on strategy
