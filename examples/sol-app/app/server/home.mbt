///| Home Page Server Component
///|
///| Uses island() to embed the counter client component.

///| Home page - with counter island
pub fn home(props : @router.PageProps) -> @luna.Node[Unit] {
  let _ = props // Available for dynamic pages
  let initial_count = 0
  // TODO: Use proper JSON serialization when available
  let state_json = "{\"count\":" + initial_count.to_string() + "}"

  layout([
    @luna.h("h1", [], [@luna.vtext("Welcome to Sol")]),
    @luna.h("p", [], [
      @luna.vtext("A SSR-first web framework for MoonBit"),
    ]),
    @server_dom.island(
      "counter",
      "/static/hydrate_counter.js",
      state=state_json,
      trigger=@luna.Load,
      children=[@client.counter({ initial_count, })],
    ),
  ])
}
