///|
/// Minimal Luna Counter - for bundle size measurement
///
/// This is the simplest possible Luna app:
/// - One Signal (count)
/// - One button with click handler
/// - Text that updates reactively
fn test_app() -> @luna_dom.DomNode {
  let count = @signal.signal(0)
  @luna_dom.div([
    @luna_dom.p([
      @luna_dom.text_dyn(fn() { "Count: " + count.get().to_string() }),
    ]),
    @luna_dom.button(
      [@luna_dom.text("Increment")],
      on=@luna_dom.events().click(fn(_) { count.update(fn(n) { n + 1 }) }),
    ),
    @luna_dom.show(() => count.get() % 2 == 0, () => inner_app()),
  ])
}

///|
fn inner_app() -> @luna_dom.DomNode {
  @luna.on_cleanup(fn() { println("Inner App cleaned up") })
  @luna.on_mount(fn() { println("Inner App mounted") })
  @luna_dom.div([@luna_dom.p([@luna_dom.text("Inner App")])])
}

///|
fn main {
  let doc = @dom.document()
  println("Hello, Luna!")
  match doc.getElementById("app") {
    Some(el) => {
      // let count = @signal.signal(0)
      let app = @luna_dom.div([
          // @luna_dom.p([
          //   @luna_dom.text_dyn(fn() { "Count: " + count.get().to_string() }),
          // ]),
          test_app(),
        ],
        // @luna.component(() => test_app()),
        // @luna_dom.button(
        //   on=@luna_dom.events().click(fn(_) { count.update(fn(n) { n + 1 }) }),
        //   [@luna_dom.text("Click me")],
        // ),
      )
      @luna_dom.render(el |> @luna_dom.DomElement::from_dom, app)
    }
    None => ()
  }
}
