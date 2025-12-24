---
title: "Luna UI"
layout: home
---

# Luna UI

A blazing-fast reactive UI framework written in MoonBit

Fine-grained reactivity meets Island Architecture. **So small that compile-time optimization is unnecessary.**

[Get Started →](/introduction/) | [Luna](/luna/) | [Sol](/sol/) | [Astra](/astra/)

---

## Why Luna?

Existing solutions didn't meet our needs:

- **React** - Too large for performance-critical applications
- **Qwik / Solid** - Compile-time expansion gets in the way
- **No WebComponents-first framework existed** - Until now

Luna addresses these gaps with a minimal runtime and native browser standards.

### Minimal Runtime, Maximum Performance

| Component | Size |
|-----------|------|
| Hydration Loader | **~1.6 KB** |
| Island Runtime | **~3.2 KB** |
| **Total** | **~6.7 KB** (vs Preact ~20 KB) |

Luna is small enough that **compile-time optimization is unnecessary**. The framework overhead is negligible.

### Runtime Performance

| Scenario | Luna | React |
|----------|------|-------|
| 100×100 DOM shooting game | **60 FPS** | 12 FPS |

Fine-grained reactivity without Virtual DOM diffing delivers real performance gains.

### Fine-Grained Reactivity

No virtual DOM. No diffing. Direct DOM updates at the signal level.

```typescript
import { createSignal, createEffect } from '@luna_ui/luna';

const [count, setCount] = createSignal(0);

// Only this text node updates - nothing else
createEffect(() => console.log(count()));

setCount(1);  // Logs: 1
setCount(c => c + 1);  // Logs: 2
```

### WebComponents First

Luna is the **first framework to support WebComponents SSR + Hydration**.

- Native browser standards over framework abstractions
- Style encapsulation with Shadow DOM
- Framework-agnostic islands that work anywhere

### Island Architecture

Partial hydration with smart loading strategies:

| Trigger | When |
|---------|------|
| `load` | Immediately on page load |
| `idle` | During browser idle time |
| `visible` | When scrolled into view |
| `media` | When media query matches |

```html
<!-- Only this island ships JavaScript -->
<my-counter luna:client-trigger="visible">
  <template shadowrootmode="open">
    <button>Count: 0</button>
  </template>
</my-counter>
<!-- Everything else is pure HTML -->
```

### SSR Performance

Near-zero overhead for Shadow DOM SSR:

| Operation | Overhead |
|-----------|----------|
| Shadow DOM template syntax | **~0%** vs Plain HTML |
| Hydration update | **~12%** slower |
| adoptable Stylesheets | **8.4x faster** |

The bottleneck is attribute escaping, not the template format.

---

## Multi-Target Architecture

Write once, run anywhere:

| Target | Signal | Render | DOM |
|--------|:------:|:------:|:---:|
| JavaScript | ✅ | ✅ | ✅ |
| Native | ✅ | ✅ | - |
| Wasm | ✅ | ✅ | - |
| Wasm-GC | ✅ | ✅ | - |

Core reactivity works on all MoonBit targets. Use native for SSR, JavaScript for the browser.

---

## Quick Start

### Install

```bash
npm install @luna_ui/luna
```

### Create a Component

```tsx
import { createSignal } from '@luna_ui/luna';

function Counter() {
  const [count, setCount] = createSignal(0);

  return (
    <button onClick={() => setCount(c => c + 1)}>
      Count: {count()}
    </button>
  );
}
```

### Use with MoonBit

```moonbit
let count = @luna.signal(0)
let doubled = @luna.memo(fn() { count.get() * 2 })

@luna.effect(fn() {
  println("Count: \{count.get()}, Doubled: \{doubled()}")
})

count.set(5)  // Prints: Count: 5, Doubled: 10
```

---

## Philosophy

1. **Ship Less JavaScript** - Static content shouldn't cost runtime
2. **Fine-Grained Updates** - Update only what changed, at the DOM level
3. **Progressive Enhancement** - Works without JavaScript, enhances with it
4. **Type Safety** - MoonBit's type system catches errors at compile time

---

## Learn More

- 📖 [Introduction](/introduction/) - Overview, Getting Started, FAQ
- 🌙 [Luna](/luna/) - Core reactive library with Signals and Islands
- ☀️ [Sol](/sol/) - Full-stack SSR framework
- ✨ [Astra](/astra/) - Static site generator for documentation
- ⭐ [Stella](/stella/) - Development tools

---

## Status

> **Experimental** - Luna is under active development. APIs may change.

Built with [MoonBit](https://www.moonbitlang.com/) - a fast, safe language designed for cloud and edge computing.

[GitHub](https://github.com/aspect-build/aspect-cli) | [npm](https://www.npmjs.com/package/@luna_ui/luna)

