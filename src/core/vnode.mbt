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
  VAction(String) // Action name for declarative event handling
}

///|
/// Island hydration trigger types
pub(all) enum IslandTrigger {
  Load // Hydrate immediately on page load
  Idle // Hydrate during browser idle time
  Visible // Hydrate when element becomes visible
  Media(String) // Hydrate when media query matches
}

// Factory functions for IslandTrigger (for external package access)

///|
/// Create a Load trigger (hydrate immediately on page load)
pub fn trigger_load() -> IslandTrigger {
  Load
}

///|
/// Create an Idle trigger (hydrate during browser idle time)
pub fn trigger_idle() -> IslandTrigger {
  Idle
}

///|
/// Create a Visible trigger (hydrate when element becomes visible)
pub fn trigger_visible() -> IslandTrigger {
  Visible
}

///|
/// Create a Media trigger (hydrate when media query matches)
pub fn trigger_media(query : String) -> IslandTrigger {
  Media(query)
}

///|
/// Virtual Island node - serializable hydration unit
pub struct VIsland {
  id : String // Unique identifier (kg:id)
  url : String // Script URL for loading implementation (kg:url)
  state : String // Serialized state JSON (kg:state)
  trigger : IslandTrigger // Hydration trigger (kg:trigger)
  children : Array[Node] // SSR-rendered content (can contain nested Islands)
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
  Island(VIsland) // Hydration boundary for partial hydration
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
pub fn h(
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
/// Create an island VNode for partial hydration
pub fn visland(
  id : String,
  url : String,
  state : String,
  children : Array[Node],
  trigger? : IslandTrigger = Load,
) -> Node {
  Island({ id, url, state, trigger, children })
}

///|
/// Convert IslandTrigger to string for kg:trigger attribute
pub fn trigger_to_string(trigger : IslandTrigger) -> String {
  match trigger {
    Load => "load"
    Idle => "idle"
    Visible => "visible"
    Media(query) => "media:" + query
  }
}

///|
/// Check if element has dynamic content that needs hydration
pub fn has_dynamic_content(attrs : Array[(String, Attr)]) -> Bool {
  for attr in attrs {
    let (_, value) = attr
    match value {
      VDynamic(_) | VHandler(_) | VAction(_) => return true
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

///|
/// Create an action attribute value - dispatches named action on event
/// Used for declarative event handling: ("onclick", action("increment"))
pub fn action(name : String) -> Attr {
  VAction(name)
}
