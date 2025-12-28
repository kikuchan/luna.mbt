// CSS Direct API - Property names exposed, compression automatic
//
// Design philosophy:
// - CSS property names are NOT abstracted
// - User writes real CSS, system handles compression
// - No Tailwind-style vocabulary to learn

// ============================================================================
// Core API
// ============================================================================

/// Style registry: declaration → short class name
struct StyleRegistry {
  // "display:flex" → "_a"
  decl_to_class : @hashmap.HashMap[String, String]
  // All declarations in order (for deterministic output)
  declarations : Array[String]
  // Counter for class name generation
  mut counter : Int
}

let registry : StyleRegistry = {
  decl_to_class: @hashmap.new(),
  declarations: [],
  counter: 0,
}

/// Generate short class name
fn next_class_name() -> String {
  let chars = "abcdefghijklmnopqrstuvwxyz"
  let n = registry.counter
  registry.counter += 1
  let name = if n < 26 {
    chars[n].to_string()
  } else {
    chars[n % 26].to_string() + (n / 26).to_string()
  }
  "_" + name  // Prefix to avoid collision
}

/// Core function: css property-value pair
pub fn css(property : String, value : String) -> @luna.Attr {
  let decl = property + ":" + value

  let class_name = match registry.decl_to_class.get(decl) {
    Some(cls) => cls
    None => {
      let cls = next_class_name()
      registry.decl_to_class.set(decl, cls)
      registry.declarations.push(decl)
      cls
    }
  }

  @luna.attr("class", class_name)
}

/// Multiple CSS properties at once
pub fn styles(props : Array[(String, String)]) -> @luna.Attr {
  let classes : Array[String] = []
  for pair in props {
    let (property, value) = pair
    let decl = property + ":" + value

    let class_name = match registry.decl_to_class.get(decl) {
      Some(cls) => cls
      None => {
        let cls = next_class_name()
        registry.decl_to_class.set(decl, cls)
        registry.declarations.push(decl)
        cls
      }
    }
    classes.push(class_name)
  }

  @luna.attr("class", classes.join(" "))
}

// ============================================================================
// Output Generation
// ============================================================================

/// Generate CSS output (minified)
pub fn generate_css() -> String {
  let buf = StringBuilder::new()
  for decl in registry.declarations {
    match registry.decl_to_class.get(decl) {
      Some(cls) => {
        buf.write_string(".")
        buf.write_string(cls)
        buf.write_string("{")
        buf.write_string(decl)
        buf.write_string("}")
      }
      None => ()
    }
  }
  buf.to_string()
}

/// Generate CSS output (readable)
pub fn generate_css_pretty() -> String {
  let buf = StringBuilder::new()
  for decl in registry.declarations {
    match registry.decl_to_class.get(decl) {
      Some(cls) => {
        buf.write_string(".")
        buf.write_string(cls)
        buf.write_string(" { ")
        buf.write_string(decl)
        buf.write_string(" }\n")
      }
      None => ()
    }
  }
  buf.to_string()
}

// ============================================================================
// Usage Examples
// ============================================================================

// Example 1: Basic card
// fn card() -> @luna.Node {
//   @luna.h("div", [
//     css("display", "flex"),
//     css("align-items", "center"),
//     css("padding", "1rem"),
//     css("border-radius", "0.5rem"),
//     css("box-shadow", "0 1px 3px rgba(0,0,0,0.1)"),
//   ], [
//     @luna.text("Card content")
//   ])
// }
//
// Output: <div class="_a _b _c _d _e">Card content</div>

// Example 2: Using styles() for multiple props
// fn button() -> @luna.Node {
//   @luna.h("button", [
//     styles([
//       ("display", "inline-flex"),
//       ("align-items", "center"),
//       ("padding", "0.5rem 1rem"),
//       ("font-weight", "500"),
//       ("border-radius", "0.375rem"),
//       ("cursor", "pointer"),
//     ]),
//   ], [
//     @luna.text("Click me")
//   ])
// }

// Example 3: Reusing styles (automatic dedup)
// fn flex_center() -> Array[(String, String)] {
//   [("display", "flex"), ("align-items", "center"), ("justify-content", "center")]
// }
//
// fn modal_overlay() -> @luna.Node {
//   @luna.h("div", [styles(flex_center())], [...])
// }
//
// fn dialog() -> @luna.Node {
//   @luna.h("div", [styles(flex_center())], [...])  // Same classes reused!
// }

// ============================================================================
// Generated CSS Example
// ============================================================================

// After rendering card() and button():
//
// ._a{display:flex}
// ._b{align-items:center}
// ._c{padding:1rem}
// ._d{border-radius:0.5rem}
// ._e{box-shadow:0 1px 3px rgba(0,0,0,0.1)}
// ._f{display:inline-flex}
// ._g{padding:0.5rem 1rem}
// ._h{font-weight:500}
// ._i{border-radius:0.375rem}
// ._j{cursor:pointer}
//
// Note: "_b" (align-items:center) is shared between card and button!

// ============================================================================
// Advanced: Responsive & Pseudo-classes
// ============================================================================

// Responsive wrapper
// pub fn at_md(property: String, value: String) -> @luna.Attr {
//   let decl = "@md:" + property + ":" + value
//   // Register with media query prefix
//   ...
// }
//
// Pseudo-class wrapper
// pub fn hover(property: String, value: String) -> @luna.Attr {
//   let decl = ":hover:" + property + ":" + value
//   // Register with pseudo-class
//   ...
// }
//
// Usage:
// h("button", [
//   css("background", "#3b82f6"),
//   hover("background", "#2563eb"),
//   at_md("padding", "1.5rem"),
// ], [...])
