// SSR Test Component - locally defined component for SSR demo
// TODO: @element DSL returns DomNode, so it cannot be used for SSR
// Consider DSL for SSR (@luna.div, @luna.p, etc.)

///|
fn h(
  tag : String,
  attrs : Array[(String, @luna.Attr[Unit])],
  children : Array[@luna.Node[Unit]],
) -> @luna.Node[Unit] {
  @luna.h(tag, attrs, children)
}

///|
fn attr(key : String, value : String) -> (String, @luna.Attr[Unit]) {
  (key, @luna.attr_static(value))
}

///|
/// Render function - exported for SSR
pub fn render() -> @luna.Node[Unit] {
  h("div", [attr("class", "ssr-local-component")], [
    h("h2", [], [@luna.text("Local SSR Component")]),
    h("p", [], [
      @luna.text("This component is defined in docs/ssr_test_component/"),
    ]),
    h("ul", [], [
      h("li", [], [@luna.text("Built from local .mbt file")]),
      h("li", [], [@luna.text("Part of astra_app example")]),
      h("li", [], [@luna.text("SSR rendered on server")]),
    ]),
  ])
}
