///| WC Counter Page Server Component
///|
///| Uses wc_island() to embed a Web Components based counter.
///| Demonstrates Declarative Shadow DOM SSR with unified hydration.
///|
///| The same counter.mbt component is used for both Luna Islands and WC Islands.
///| The hydration function auto-detects WC mode (shadowRoot) vs Luna mode.

///| WC Counter page - Web Components based island
pub fn wc_counter(props : @router.PageProps) -> @luna.Node[Unit] {
  // Create props using generated types - auto-serializes to JSON
  let counter_props : @types.CounterProps = { initial_count: 0 }
  let state_json = counter_props.to_json().stringify()

  // CSS for the counter (will be in Shadow DOM)
  let counter_styles =
    #|:host { display: block; }
    #|.counter { margin: 2rem 0; padding: 1rem; border: 1px solid #ccc; border-radius: 8px; }
    #|.count-display { font-size: 2rem; font-weight: bold; }
    #|.buttons { margin-top: 1rem; }
    #|.buttons button { font-size: 1.5rem; padding: 0.5rem 1rem; margin: 0 0.5rem; cursor: pointer; }

  let content = [
    h1(children=[text("Web Components Counter")]),
    p(children=[
      text("This counter uses Declarative Shadow DOM for SSR."),
    ]),
    p(children=[
      text("CSS is encapsulated in Shadow DOM - inspect the element to see <template shadowrootmode=\"open\">."),
    ]),
    p(children=[
      text("Uses the same counter.mbt component with unified hydration (hydrate_auto_dom)."),
    ]),
    // WcIsland with Declarative Shadow DOM
    // Uses the same counter.js generated from counter.mbt
    @server_dom.wc_island(
      "wc-counter",
      "/static/counter.js", // Same component as Luna Island!
      styles=counter_styles,
      state=state_json,
      trigger=@luna.Load,
      children=[
        div(class="counter", children=[
          span(class="count-display", children=[
            text(counter_props.initial_count.to_string()),
          ]),
          div(class="buttons", children=[
            button(
              class="dec",
              attrs=[("data-on-click", @luna.attr_static("decrement"))],
              children=[text("-")],
            ),
            button(
              class="inc",
              attrs=[("data-on-click", @luna.attr_static("increment"))],
              children=[text("+")],
            ),
          ]),
        ]),
      ],
    ),
    h2(children=[text("How it works")]),
    p(children=[
      text("The WcIsland generates a custom element with Declarative Shadow DOM:"),
    ]),
    div(class="code-block", style="background: #f5f5f5; padding: 1rem; border-radius: 4px; font-family: monospace; white-space: pre; overflow-x: auto;", children=[
      text("<wc-counter data-wc-url=\"...\" data-state=\"...\">\\n"),
      text("  <template shadowrootmode=\"open\">\\n"),
      text("    <style>:host { ... }</style>\\n"),
      text("    <div class=\"counter\">...</div>\\n"),
      text("  </template>\\n"),
      text("</wc-counter>"),
    ]),
  ]

  // Fragment request: return content only (no layout)
  // Full page request: wrap with layout
  if props.params.is_fragment {
    @luna.vfragment(content)
  } else {
    layout(content)
  }
}
