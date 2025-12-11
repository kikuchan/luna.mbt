///| VNode - DOM-independent virtual node representation for SSR

///|
/// Event handler type - wraps a callback function
/// For SSR: noop function. For DOM: actual event handler
pub struct EventHandler {
  /// The callback function (no-arg for simplicity, event can be captured via closure)
  callback : () -> Unit
}

///|
/// Create a placeholder event handler (for SSR - creates noop function)
pub fn event_handler() -> EventHandler {
  { callback: fn() { () } }
}

///|
/// Create an event handler from a simple callback
pub fn handler_from_callback(f : () -> Unit) -> EventHandler {
  { callback: f }
}

///|
/// Get the callback function
pub fn EventHandler::get_callback(self : EventHandler) -> () -> Unit {
  self.callback
}

///|
/// Attribute value that can be static or dynamic (signal-based)
pub enum Attr {
  VStatic(String)
  VDynamic(() -> String)
  VHandler(EventHandler)
}

///|
/// Virtual DOM node types
pub enum Node {
  Element(VElement)
  Text(String)
  DynamicText(() -> String)
  Fragment(Array[Node])
  Show(condition~ : () -> Bool, child~ : () -> Node)
  For(render~ : () -> Array[Node])
  Component(render~ : () -> Node)
}

///|
/// Virtual element node
pub struct VElement {
  tag : String
  attrs : Array[(String, Attr)]
  children : Array[Node]
}

///|
/// Create a VNode element
pub fn vnode(
  tag : String,
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  Element({ tag, attrs, children })
}

///|
/// Create a text VNode
pub fn vtext(content : String) -> Node {
  Text(content)
}

///|
/// Create a dynamic text VNode
pub fn text_dyn(content : () -> String) -> Node {
  DynamicText(content)
}

///|
/// Create a text VNode from a signal
pub fn[T : Show] vtext_sig(sig : @signal.Signal[T]) -> Node {
  DynamicText(fn() { sig.get().to_string() })
}

///|
/// Create a fragment VNode
pub fn vfragment(children : Array[Node]) -> Node {
  Fragment(children)
}

///|
/// Create a conditional VNode
pub fn vshow(when : () -> Bool, child : () -> Node) -> Node {
  Show(condition=when, child~)
}

///|
/// Create a list VNode
pub fn vfor(items : () -> Array[Node]) -> Node {
  For(render=items)
}

///|
/// Create a component VNode
pub fn vcomponent(render : () -> Node) -> Node {
  Component(render~)
}

///|
/// Check if element has dynamic content that needs hydration
pub fn has_dynamic_content(attrs : Array[(String, Attr)]) -> Bool {
  for attr in attrs {
    let (_, value) = attr
    match value {
      VDynamic(_) | VHandler(_) => return true
      _ => ()
    }
  }
  false
}

// Attr factory functions for external packages

///|
/// Create a static attribute value
pub fn attr_static(value : String) -> Attr {
  VStatic(value)
}

///|
/// Create a dynamic attribute value
pub fn attr_dynamic(getter : () -> String) -> Attr {
  VDynamic(getter)
}

///|
/// Create a handler attribute value
pub fn attr_handler(handler : EventHandler) -> Attr {
  VHandler(handler)
}

///|
/// Create a style attribute value (string form, e.g. "color: red; margin: 10px")
pub fn attr_style(style : String) -> Attr {
  VStatic(style)
}

///|
/// Create a dynamic style attribute value
pub fn attr_dynamic_style(getter : () -> String) -> Attr {
  VDynamic(getter)
}

// =============================================================================
// Element factory functions
// =============================================================================

///|
/// Create a div VNode
pub fn div(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("div", attrs, children)
}

///|
/// Create a span VNode
pub fn span(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("span", attrs, children)
}

///|
/// Create a p VNode
pub fn p(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("p", attrs, children)
}

///|
/// Create a button VNode
pub fn button(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("button", attrs, children)
}

///|
/// Create an a VNode
pub fn a(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("a", attrs, children)
}

///|
/// Create an input VNode
pub fn input(attrs : Array[(String, Attr)]) -> Node {
  vnode("input", attrs, [])
}

///|
/// Create a form VNode
pub fn form(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("form", attrs, children)
}

///|
/// Create a label VNode
pub fn label(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("label", attrs, children)
}

///|
/// Create h1 VNode
pub fn h1(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("h1", attrs, children)
}

///|
/// Create h2 VNode
pub fn h2(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("h2", attrs, children)
}

///|
/// Create h3 VNode
pub fn h3(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("h3", attrs, children)
}

///|
/// Create ul VNode
pub fn ul(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("ul", attrs, children)
}

///|
/// Create ol VNode
pub fn ol(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("ol", attrs, children)
}

///|
/// Create li VNode
pub fn li(
  attrs : Array[(String, Attr)],
  children : Array[Node],
) -> Node {
  vnode("li", attrs, children)
}

///|
/// Create img VNode
pub fn img(attrs : Array[(String, Attr)]) -> Node {
  vnode("img", attrs, [])
}

///|
/// Create br VNode
pub fn br() -> Node {
  vnode("br", [], [])
}

///|
/// Create hr VNode
pub fn hr() -> Node {
  vnode("hr", [], [])
}

// =============================================================================
// Attribute helper functions
// =============================================================================

///|
/// Create a static attribute tuple
pub fn attr(key : String, value : String) -> (String, Attr) {
  (key, attr_static(value))
}

///|
/// Create a dynamic attribute tuple
pub fn attr_dyn(key : String, getter : () -> String) -> (String, Attr) {
  (key, attr_dynamic(getter))
}

///|
/// Create a className attribute
pub fn class(value : String) -> (String, Attr) {
  ("class", attr_static(value))
}

///|
/// Create a dynamic className attribute
pub fn class_dyn(getter : () -> String) -> (String, Attr) {
  ("class", attr_dynamic(getter))
}

///|
/// Create an id attribute
pub fn id(value : String) -> (String, Attr) {
  ("id", attr_static(value))
}

///|
/// Create a href attribute
pub fn href(value : String) -> (String, Attr) {
  ("href", attr_static(value))
}

///|
/// Create a src attribute
pub fn src(value : String) -> (String, Attr) {
  ("src", attr_static(value))
}

///|
/// Create an alt attribute
pub fn alt(value : String) -> (String, Attr) {
  ("alt", attr_static(value))
}

///|
/// Create a type attribute
pub fn type_(value : String) -> (String, Attr) {
  ("type", attr_static(value))
}

///|
/// Create a value attribute
pub fn value(value : String) -> (String, Attr) {
  ("value", attr_static(value))
}

///|
/// Create a dynamic value attribute
pub fn value_dyn(getter : () -> String) -> (String, Attr) {
  ("value", attr_dynamic(getter))
}

///|
/// Create a placeholder attribute
pub fn placeholder(value : String) -> (String, Attr) {
  ("placeholder", attr_static(value))
}

///|
/// Create a disabled attribute
pub fn disabled(value : Bool) -> (String, Attr) {
  if value {
    ("disabled", attr_static(""))
  } else {
    ("disabled", attr_static("__remove__"))
  }
}

///|
/// Create an onClick handler
pub fn on_click(handler : EventHandler) -> (String, Attr) {
  ("onClick", attr_handler(handler))
}

///|
/// Create an onInput handler
pub fn on_input(handler : EventHandler) -> (String, Attr) {
  ("onInput", attr_handler(handler))
}

///|
/// Create an onChange handler
pub fn on_change(handler : EventHandler) -> (String, Attr) {
  ("onChange", attr_handler(handler))
}

///|
/// Create an onSubmit handler
pub fn on_submit(handler : EventHandler) -> (String, Attr) {
  ("onSubmit", attr_handler(handler))
}

///|
/// Create a style attribute
pub fn style(value : String) -> (String, Attr) {
  ("style", attr_style(value))
}

///|
/// Create a dynamic style attribute
pub fn style_dyn(getter : () -> String) -> (String, Attr) {
  ("style", attr_dynamic_style(getter))
}
