///| Server Layout Component
///|
///| Provides the basic HTML structure for all pages.
///| This is a server component - no event handlers.

///| Default page styles
let default_style : String = "<style>body { font-family: system-ui; max-width: 800px; margin: 0 auto; padding: 2rem; } .counter { margin: 2rem 0; padding: 1rem; border: 1px solid #ccc; border-radius: 8px; } .buttons { margin-top: 1rem; } .buttons button { font-size: 1.5rem; padding: 0.5rem 1rem; margin: 0 0.5rem; cursor: pointer; } nav { margin-bottom: 1rem; } nav a { margin-right: 1rem; }</style>"

///| Luna loader script (for island hydration)
let loader_script : String = "<script type=\"module\" src=\"/static/loader.min.js\"></script>"

///| Sol navigation script
let sol_nav_script : String = "<script type=\"module\" src=\"/static/sol-nav.min.js\"></script>"

///| Get default head HTML (styles + loader + sol-nav)
pub fn head() -> String {
  default_style + loader_script + sol_nav_script
}

///| Basic layout wrapper - wraps content in container with navigation
pub fn layout(inner : Array[@luna.Node[Unit]]) -> @luna.Node[Unit] {
  div(class="container", children=[
    nav(children=[
      sol_link(href="/", children=[text("Home")]),
      sol_link(href="/about", children=[text("About")]),
    ]),
    outlet(name="main", children=inner),
  ])
}
