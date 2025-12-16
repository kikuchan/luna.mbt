///| Benchmarks for render_to_string
///| Run with: moon bench --target js -p mizchi/luna/core/render
///|           moon bench --target wasm-gc -p mizchi/luna/core/render
///|
///| Compare JS FFI escape vs pure MoonBit escape impact on full rendering

// =============================================================================
// Test Data - VNode Trees
// =============================================================================

///|
/// Simple text node
fn vnode_text() -> @luna.Node[Unit] {
  @luna.vtext("Hello, World!")
}

///|
/// Text with HTML special characters (needs escaping)
fn vnode_text_escape() -> @luna.Node[Unit] {
  @luna.vtext("<script>alert('xss')</script> & \"dangerous\" content")
}

///|
/// Simple element with no attrs
fn vnode_simple_element() -> @luna.Node[Unit] {
  @luna.h("div", [], [@luna.vtext("content")])
}

///|
/// Element with multiple attributes (needs attr escaping)
fn vnode_with_attrs() -> @luna.Node[Unit] {
  @luna.h(
    "div",
    [
      ("id", @luna.attr_static("main")),
      ("class", @luna.attr_static("container mx-auto")),
      ("data-value", @luna.attr_static("{\"count\":42,\"name\":\"test\"}")),
    ],
    [@luna.vtext("content")],
  )
}

///|
/// Nested elements (typical component structure)
fn vnode_nested() -> @luna.Node[Unit] {
  @luna.h("div", [("class", @luna.attr_static("card"))], [
    @luna.h("header", [("class", @luna.attr_static("card-header"))], [
      @luna.h("h2", [], [@luna.vtext("Title")]),
    ]),
    @luna.h("div", [("class", @luna.attr_static("card-body"))], [
      @luna.h("p", [], [@luna.vtext("This is the card body content.")]),
      @luna.h("button", [("class", @luna.attr_static("btn"))], [
        @luna.vtext("Click me"),
      ]),
    ]),
  ])
}

///|
/// List of items (common pattern)
fn vnode_list() -> @luna.Node[Unit] {
  let items : Array[@luna.Node[Unit]] = []
  for i = 0; i < 10; i = i + 1 {
    items.push(
      @luna.h("li", [("class", @luna.attr_static("item"))], [
        @luna.vtext("Item \{i}"),
      ]),
    )
  }
  @luna.h("ul", [("class", @luna.attr_static("list"))], items)
}

///|
/// Large list (stress test)
fn vnode_large_list() -> @luna.Node[Unit] {
  let items : Array[@luna.Node[Unit]] = []
  for i = 0; i < 100; i = i + 1 {
    items.push(
      @luna.h("li", [("class", @luna.attr_static("item"))], [
        @luna.vtext("Item \{i} with some <special> & \"characters\""),
      ]),
    )
  }
  @luna.h("ul", [("class", @luna.attr_static("list"))], items)
}

///|
/// Typical page structure
fn vnode_page() -> @luna.Node[Unit] {
  @luna.h("html", [], [
    @luna.h("head", [], [
      @luna.h("meta", [("charset", @luna.attr_static("utf-8"))], []),
      @luna.h("title", [], [@luna.vtext("Test Page")]),
    ]),
    @luna.h("body", [], [
      @luna.h("header", [], [
        @luna.h("nav", [("class", @luna.attr_static("navbar"))], [
          @luna.h("a", [("href", @luna.attr_static("/"))], [
            @luna.vtext("Home"),
          ]),
          @luna.h("a", [("href", @luna.attr_static("/about"))], [
            @luna.vtext("About"),
          ]),
        ]),
      ]),
      @luna.h("main", [("class", @luna.attr_static("container"))], [
        @luna.h("h1", [], [@luna.vtext("Welcome")]),
        @luna.h("p", [], [
          @luna.vtext("This is a test page with <special> & \"characters\"."),
        ]),
      ]),
      @luna.h("footer", [], [@luna.vtext("© 2024")]),
    ]),
  ])
}

// =============================================================================
// Render Benchmarks
// =============================================================================

test "render: text" (b : @bench.T) {
  let node = vnode_text()
  b.bench(fn() { b.keep(render_to_string(node).html) })
}

test "render: text_escape" (b : @bench.T) {
  let node = vnode_text_escape()
  b.bench(fn() { b.keep(render_to_string(node).html) })
}

test "render: simple_element" (b : @bench.T) {
  let node = vnode_simple_element()
  b.bench(fn() { b.keep(render_to_string(node).html) })
}

test "render: with_attrs" (b : @bench.T) {
  let node = vnode_with_attrs()
  b.bench(fn() { b.keep(render_to_string(node).html) })
}

test "render: nested" (b : @bench.T) {
  let node = vnode_nested()
  b.bench(fn() { b.keep(render_to_string(node).html) })
}

test "render: list (10 items)" (b : @bench.T) {
  let node = vnode_list()
  b.bench(fn() { b.keep(render_to_string(node).html) })
}

test "render: large_list (100 items with escape)" (b : @bench.T) {
  let node = vnode_large_list()
  b.bench(fn() { b.keep(render_to_string(node).html) })
}

test "render: page" (b : @bench.T) {
  let node = vnode_page()
  b.bench(fn() { b.keep(render_to_string(node).html) })
}
