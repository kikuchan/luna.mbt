///| Counter Component - Shared component for SSR and hydration testing
///|
///| This component is used to verify idempotent hydration:
///| SSR output should match the DOM after hydration.
///| Uses Signal for reactive state management.

///|
/// Render counter component to VNode
/// Takes a signal for reactive updates and callbacks for event handlers
/// For SSR: pass noop handlers (event_handler())
/// For client: pass actual callbacks that update the signal
pub fn render_counter(
  count_sig : @ui.Signal[Int],
  on_inc : @ui.EventHandler,
  on_dec : @ui.EventHandler,
) -> @ui.Node {
  @element.div(
    [
      ("class", @ui.attr_static("counter")),
      ("data-count", @ui.attr_dynamic(fn() { count_sig.get().to_string() })),
    ],
    [
      @element.span(
        [("data-count", @ui.attr_static("true"))],
        [@ui.text_dyn(fn() { count_sig.get().to_string() })],
      ),
      @element.button(
        [
          ("data-inc", @ui.attr_static("true")),
          ("onClick", @ui.attr_handler(on_inc)),
        ],
        [@ui.vtext("+1")],
      ),
      @element.button(
        [
          ("data-dec", @ui.attr_static("true")),
          ("onClick", @ui.attr_handler(on_dec)),
        ],
        [@ui.vtext("-1")],
      ),
    ],
  )
}

///|
/// Render counter to HTML string (for SSR)
/// Uses static signal value and noop handlers
/// Uses render_to_string_with_hydration to add data-hk markers for client hydration
pub fn render_counter_html(count : Int) -> String {
  let sig = @ui.signal(count)
  let noop = @ui.event_handler()
  let vnode = render_counter(sig, noop, noop)
  @ssr.render_to_string_with_hydration(vnode)
}

///|
/// Serialize state to JSON string
pub fn serialize_state(count : Int) -> String {
  "{\"count\":" + count.to_string() + "}"
}
