---
title: Tutorial (MoonBit)
---

# Tutorial (MoonBit)

> For the full tutorial with both TypeScript and MoonBit examples, see the [main Tutorial](/tutorial-js/).

## MoonBit Quick Start

Add Luna to your `moon.mod.json`:

```json
{
  "deps": {
    "mizchi/luna": "0.1.0"
  }
}
```

## Basic Counter Example

```moonbit
using @element {
  div, p, button, text, text_dyn, events,
  type DomNode,
}
using @luna { signal }

fn counter() -> DomNode {
  let count = signal(0)

  div([
    p([text_dyn(() => "Count: " + count.get().to_string())]),
    button(
      on=events().click(_ => count.update(n => n + 1)),
      [text("Increment")],
    ),
  ])
}
```

## Key Differences from TypeScript

| TypeScript | MoonBit |
|------------|---------|
| `createSignal(0)` | `signal(0)` |
| `count()` | `count.get()` |
| `setCount(5)` | `count.set(5)` |
| `setCount(c => c + 1)` | `count.update(n => n + 1)` |
| `createEffect(() => ...)` | `effect(() => ...)` |
| `createMemo(() => ...)` | `memo(() => ...)` |

## See Also

- [Tutorial](/tutorial-js/) - Full tutorial with all topics
- [Luna Core](/luna/) - Core concepts
- [Luna API](/luna/signals/) - Signals API reference
