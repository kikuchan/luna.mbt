///| About Page Server Component
///|
///| Static page without client-side hydration.

///| About page - static content
pub fn about(props : @router.PageProps) -> @luna.Node[Unit] {
  let _ = props
  layout([
    @luna.h("h1", [], [@luna.vtext("About")]),
    @luna.h("p", [], [
      @luna.vtext("Built with MoonBit and Sol framework."),
    ]),
  ])
}
