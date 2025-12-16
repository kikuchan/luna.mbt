///| About Page Server Component
///|
///| Static page without client-side hydration.

///| About page - static content
pub fn about(props : @router.PageProps) -> @luna.Node[Unit] {
  let content = [
    h1(children=[text("About")]),
    p(children=[text("Built with MoonBit and Sol framework.")]),
  ]

  // Fragment request: return content only (no layout)
  // Full page request: wrap with layout
  if props.params.is_fragment {
    @luna.vfragment(content)
  } else {
    layout(content)
  }
}
