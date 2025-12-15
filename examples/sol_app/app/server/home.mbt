///| Home Page Server Component
///|
///| Uses island() to embed the counter client component.

///| Home page - with counter island
pub fn home(props : @router.PageProps) -> @luna.Node[Unit] {
  let _ = props // Available for dynamic pages
  let initial_count = 0
  // Serialize initial state for hydration
  let state_json = "{\"initial_count\":" + initial_count.to_string() + "}"

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
      // SSR placeholder - will be hydrated on client
      children=[
        @luna.h("div", [("class", @luna.attr_static("counter"))], [
          @luna.h("span", [("class", @luna.attr_static("count-display"))], [
            @luna.vtext(initial_count.to_string()),
          ]),
          @luna.h("div", [("class", @luna.attr_static("buttons"))], [
            @luna.h("button", [("class", @luna.attr_static("dec"))], [
              @luna.vtext("-"),
            ]),
            @luna.h("button", [("class", @luna.attr_static("inc"))], [
              @luna.vtext("+"),
            ]),
          ]),
        ]),
      ],
    ),
  ])
}
