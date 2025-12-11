///| Framework Example Application

///|

///| Demonstrates SSR with ui.mbt VNodes using the framework.

///|
/// Home page component
fn home_page(_ctx : @framework.Ctx) -> @kaguya.Node {
  @kaguya.div([@kaguya.class("container")], [
    @kaguya.h1([], [@kaguya.vtext("Welcome to MoonBit Framework")]),
    @kaguya.p([], [
      @kaguya.vtext("A SSR-first web framework built on Hono and ui.mbt"),
    ]),
    @kaguya.div([@kaguya.class("nav")], [
      @kaguya.ul([], [
        @kaguya.li([], [@kaguya.a([@kaguya.href("/")], [@kaguya.vtext("Home")])]),
        @kaguya.li([], [
          @kaguya.a([@kaguya.href("/about")], [@kaguya.vtext("About")]),
        ]),
        @kaguya.li([], [
          @kaguya.a([@kaguya.href("/counter")], [@kaguya.vtext("Counter Demo")]),
        ]),
      ]),
    ]),
  ])
}

///|
/// About page component
fn about_page(_ctx : @framework.Ctx) -> @kaguya.Node {
  @kaguya.div([@kaguya.class("container")], [
    @kaguya.h1([], [@kaguya.vtext("About")]),
    @kaguya.p([], [@kaguya.vtext("This is a demonstration of SSR with MoonBit.")]),
    @kaguya.p([], [
      @kaguya.vtext("The HTML is rendered on the server using ui.mbt VNodes."),
    ]),
    @kaguya.a([@kaguya.href("/")], [@kaguya.vtext("← Back to Home")]),
  ])
}

///|
/// Counter page with reactive state (demonstrates hydration markers)
fn counter_page(_ctx : @framework.Ctx) -> @kaguya.Node {
  let count = @signal.signal(0)
  @kaguya.div([@kaguya.class("container")], [
    @kaguya.h1([], [@kaguya.vtext("Counter Demo")]),
    @kaguya.p([], [
      @kaguya.vtext("This page demonstrates reactive state with hydration markers."),
    ]),
    @kaguya.div([@kaguya.class("counter")], [
      @kaguya.span([], [@kaguya.vtext("Count: ")]),
      @kaguya.span([], [@kaguya.text_dyn(fn() { count.get().to_string() })]),
    ]),
    @kaguya.div([@kaguya.class("buttons")], [
      @kaguya.button([@kaguya.on_click(@kaguya.event_handler())], [@kaguya.vtext("-")]),
      @kaguya.button([@kaguya.on_click(@kaguya.event_handler())], [@kaguya.vtext("+")]),
    ]),
    @kaguya.a([@kaguya.href("/")], [@kaguya.vtext("← Back to Home")]),
  ])
}

///|
/// Configure the application with routes
fn configure_app(app : @framework.App) -> @framework.App {
  // Register pages
  let app = @framework.page(
    app,
    "/",
    home_page,
    title="Home - MoonBit Framework",
    head="<style>body { font-family: system-ui; max-width: 800px; margin: 0 auto; padding: 2rem; }</style>",
  )
  let app = @framework.page(
    app,
    "/about",
    about_page,
    title="About - MoonBit Framework",
    head="<style>body { font-family: system-ui; max-width: 800px; margin: 0 auto; padding: 2rem; }</style>",
  )
  let app = @framework.page(
    app,
    "/counter",
    counter_page,
    title="Counter - MoonBit Framework",
    head="<style>body { font-family: system-ui; max-width: 800px; margin: 0 auto; padding: 2rem; } .counter { font-size: 2rem; margin: 1rem 0; } .buttons button { font-size: 1.5rem; padding: 0.5rem 1rem; margin: 0.25rem; }</style>",
  )

  // Register API endpoint
  let app = @framework.api(app, "/api/health", fn(_c) {
    @core.any({ "status": "ok" })
  })
  app
}

///|
fn main {
  let port = 3000
  @framework.create_app_then(fn(app) {
    let app = configure_app(app)
    println("Starting MoonBit Framework on port " + port.to_string() + "...")
    @framework.serve(app, port)
  })
}
