///| Home Page Server Component
///|
///| Uses island() to embed the counter client component.

///| Home page - with counter island
pub fn home(props : @router.PageProps) -> @luna.Node[Unit] {
  // Create props using generated types - auto-serializes to JSON
  let counter_props : @types.CounterProps = { initial_count: 0 }
  let state_json = counter_props.to_json().stringify()

  let content = [
    h1(children=[text("Welcome to Sol")]),
    p(children=[text("A SSR-first web framework for MoonBit")]),
    @server_dom.island(
      "counter",
      "/static/counter.js",
      state=state_json,
      trigger=@luna.Load,
      children=[
        div(class="counter", children=[
          span(class="count-display", children=[
            text(counter_props.initial_count.to_string()),
          ]),
          div(class="buttons", children=[
            button(class="dec", children=[text("-")]),
            button(class="inc", children=[text("+")]),
          ]),
        ]),
      ],
    ),
  ]

  // Fragment request: return content only (no layout)
  // Full page request: wrap with layout
  if props.params.is_fragment {
    @luna.vfragment(content)
  } else {
    layout(content)
  }
}
