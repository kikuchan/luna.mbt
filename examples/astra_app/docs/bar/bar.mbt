// Bar component - demonstrates SSR rendering for component directories

///|
/// Render the Bar component - this function is called during SSR
pub fn render() -> @element.DomNode {
  @element.div(class="bar-component", [
    @element.h2([], [@element.text("Bar Component")]),
    @element.p([], [@element.text("This component is SSR rendered from bar.mbt")]),
    @element.ul([], [
      @element.li([], [@element.text("Defined in docs/bar/bar.mbt")]),
      @element.li([], [@element.text("Uses Luna's VNode system")]),
      @element.li([], [@element.text("Can be hydrated on client")]),
    ]),
    @element.div(
      class="demo-box",
      style="padding: 1rem; background: #f0f0f0; border-radius: 8px; margin-top: 1rem;",
      [@element.p([], [@element.text("This is a demo box rendered on the server.")])],
    ),
  ])
}
