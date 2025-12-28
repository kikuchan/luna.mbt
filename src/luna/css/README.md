# Luna CSS Utility Module

Atomic CSS generation for Luna. Automatically deduplicates and compresses CSS declarations.

## Features

- **Direct CSS API**: Use CSS property names directly (`css("display", "flex")`)
- **Automatic deduplication**: Same declarations share class names
- **Minimal output**: Short class names (`_a`, `_b`, `_c`...)
- **Collision-free**: `_` prefix avoids conflicts with external CSS
- **SSR-only**: CSS rules determined at SSR time

## Basic Usage

```moonbit
// Import from luna/css
import { css, styles, combine } from "@luna/css"

// Or use re-exports from static_dom/element
import { ucss, ustyles } from "@luna/static_dom/element"

// Single property
let flex = css("display", "flex")  // "_a"

// Multiple properties
let card_class = styles([
  ("display", "flex"),
  ("align-items", "center"),
  ("padding", "1rem"),
])  // "_a _b _c"

// Use with elements
div(class=card_class, [
  text("Card content")
])
```

## Pseudo-classes

```moonbit
import { hover, focus, active, on } from "@luna/css"

// Convenience wrappers
let h = hover("background", "#2563eb")   // "_h0"
let f = focus("outline", "2px solid blue")  // "_f0"
let a = active("transform", "scale(0.98)")  // "_ac0"

// Generic pseudo-class
let before = on("::before", "content", "\"→\"")  // "_p0"
```

## Media Queries

```moonbit
import { at_md, at_lg, dark, media } from "@luna/css"

// Breakpoint wrappers
let m = at_md("padding", "2rem")  // "_m0"
let l = at_lg("font-size", "1.25rem")  // "_m1"

// Dark mode
let d = dark("background", "#1a1a1a")  // "_m2"

// Generic media query
let custom = media("min-width: 1440px", "max-width", "1200px")
```

## CSS Generation (SSR)

```moonbit
import { generate_css, generate_full_css } from "@luna/css"

// After rendering components, generate CSS
let base_css = generate_css()
// ._a{display:flex}._b{align-items:center}._c{padding:1rem}

let full_css = generate_full_css()
// Includes base + pseudo-classes + media queries
// ._a{display:flex}...
// ._h0:hover{background:#2563eb}...
// @media(min-width:768px){._m0{padding:2rem}}
```

## Full Example

```moonbit
fn card(title: String, content: String) -> @luna.Node[Unit] {
  div(
    class=styles([
      ("display", "flex"),
      ("flex-direction", "column"),
      ("padding", "1.5rem"),
      ("border-radius", "0.5rem"),
      ("background", "white"),
      ("box-shadow", "0 1px 3px rgba(0,0,0,0.1)"),
    ]) + " " + hover("box-shadow", "0 4px 12px rgba(0,0,0,0.15)")
       + " " + dark("background", "#1e1e1e")
       + " " + at_md("padding", "2rem"),
    [
      h2(class=css("font-size", "1.25rem"), [text(title)]),
      p(class=css("color", "#666"), [text(content)]),
    ]
  )
}

// In your page render:
fn page() -> @luna.Node[Unit] {
  html(lang="en", [
    head([
      style_(generate_full_css()),  // Inject generated CSS
    ]),
    body([
      card("Hello", "World"),
    ])
  ])
}
```

## API Reference

### Base Styles

| Function | Description | Example |
|----------|-------------|---------|
| `css(prop, val)` | Single declaration | `css("display", "flex")` |
| `styles(pairs)` | Multiple declarations | `styles([("a", "b"), ...])` |
| `combine(classes)` | Join class names | `combine([c1, c2])` |

### Pseudo-classes

| Function | Description |
|----------|-------------|
| `on(pseudo, prop, val)` | Generic pseudo |
| `hover(prop, val)` | :hover |
| `focus(prop, val)` | :focus |
| `active(prop, val)` | :active |

### Media Queries

| Function | Condition |
|----------|-----------|
| `media(cond, prop, val)` | Generic |
| `at_sm(prop, val)` | min-width: 640px |
| `at_md(prop, val)` | min-width: 768px |
| `at_lg(prop, val)` | min-width: 1024px |
| `at_xl(prop, val)` | min-width: 1280px |
| `dark(prop, val)` | prefers-color-scheme: dark |

### Generation

| Function | Description |
|----------|-------------|
| `generate_css()` | Base styles only |
| `generate_full_css()` | All styles (base + pseudo + media) |
| `reset_all()` | Clear all registries (testing) |
