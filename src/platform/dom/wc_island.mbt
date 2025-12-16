///| Web Components Island Hydration API
///|
///| Provides integration with Web Components based islands.
///| Uses DOM Parts for efficient partial updates.

// =============================================================================
// WcIsland Context - For Web Components based islands
// =============================================================================

///|
/// Web Components Island context for hydration
/// Provides access to shadow DOM, parts, and framework utilities
pub struct WcIslandContext {
  /// The custom element
  element : @js_dom.Element
  /// Shadow root of the element
  shadow_root : @js.Any
  /// Map of DOM Parts by name (from wcssr)
  parts : @js.Any
  /// Parsed state from data-state attribute
  priv state_json : String
}

// =============================================================================
// FFI Functions for wcssr integration
// =============================================================================

///|
extern "js" fn get_shadow_root(element : @js_dom.Element) -> @js.Any =
  #| (element) => element.shadowRoot

///|
extern "js" fn hydrate_parts_ffi(shadow_root : @js.Any) -> @js.Any =
  #| (root) => {
  #|   if (window.__WCSSR__?.hydratePartsFromElement) {
  #|     return window.__WCSSR__.hydratePartsFromElement(root);
  #|   }
  #|   // Fallback: return empty Map
  #|   return new Map();
  #| }

///|
extern "js" fn set_part_value(parts : @js.Any, name : String, value : String) -> Unit =
  #| (parts, name, value) => {
  #|   const part = parts.get(name);
  #|   if (part) part.value = value;
  #| }

///|
extern "js" fn commit_part(parts : @js.Any, name : String) -> Unit =
  #| (parts, name) => {
  #|   const part = parts.get(name);
  #|   if (part) part.commit();
  #| }

///|
extern "js" fn parse_data_state(element : @js_dom.Element) -> String =
  #| (element) => {
  #|   const s = element.dataset.state || '{}';
  #|   try {
  #|     return s
  #|       .replace(/\\u003c/g, '<')
  #|       .replace(/\\u003e/g, '>')
  #|       .replace(/\\u0026/g, '&');
  #|   } catch { return '{}'; }
  #| }

///|
extern "js" fn parse_state_int(json_str : String, key : String) -> Int =
  #| (json, key) => { try { return JSON.parse(json)[key] ?? 0; } catch { return 0; } }

///|
extern "js" fn bind_event_handler(
  shadow_root : @js.Any,
  selector : String,
  event_type : String,
  handler : () -> Unit,
) -> Unit =
  #| (root, selector, eventType, handler) => {
  #|   const el = root.querySelector(selector);
  #|   if (el) el.addEventListener(eventType, () => handler());
  #| }

///|
extern "js" fn bind_on_handlers(
  shadow_root : @js.Any,
  event_type : String,
  callback : (String) -> Unit,
) -> Unit =
  #| (root, eventType, callback) => {
  #|   const attr = `data-on-${eventType}`;
  #|   root.querySelectorAll(`[${attr}]`).forEach(el => {
  #|     const handlerName = el.getAttribute(attr);
  #|     if (handlerName) {
  #|       el.addEventListener(eventType, () => callback(handlerName));
  #|     }
  #|   });
  #| }

///|
extern "js" fn console_log_wc(msg : String) -> Unit =
  #| (msg) => console.log(msg)

// =============================================================================
// WcIslandContext Methods
// =============================================================================

///|
/// Create WcIslandContext from a custom element
pub fn WcIslandContext::new(element : @js_dom.Element) -> WcIslandContext? {
  let shadow_root = get_shadow_root(element)

  // Check if shadow root exists
  if is_null_or_undefined(shadow_root) {
    return None
  }

  // Hydrate DOM Parts from the shadow root
  let parts = hydrate_parts_ffi(shadow_root)

  // Parse state from data-state attribute
  let state_json = parse_data_state(element)

  Some({ element, shadow_root, parts, state_json })
}

///|
extern "js" fn is_null_or_undefined(value : @js.Any) -> Bool =
  #| (v) => v == null || v === undefined

///|
/// Get the DOM element
pub fn WcIslandContext::get_element(self : WcIslandContext) -> @js_dom.Element {
  self.element
}

///|
/// Get the shadow root
pub fn WcIslandContext::get_shadow_root(self : WcIslandContext) -> @js.Any {
  self.shadow_root
}

///|
/// Get the raw state JSON string
pub fn WcIslandContext::get_state_json(self : WcIslandContext) -> String {
  self.state_json
}

///|
/// Create a signal from state with a specific key
pub fn WcIslandContext::signal_int(
  self : WcIslandContext,
  key : String,
  default_value : Int,
) -> @signal.Signal[Int] {
  let value = if self.state_json == "" || self.state_json == "{}" {
    default_value
  } else {
    parse_state_int(self.state_json, key)
  }
  @signal.signal(value)
}

///|
/// Bind a Signal to a DOM Part by name
/// When the signal changes, the part is automatically updated
pub fn[T : Show] WcIslandContext::bind_signal(
  self : WcIslandContext,
  part_name : String,
  signal : @signal.Signal[T],
) -> Unit {
  let parts = self.parts
  let _ = @signal.effect(fn() {
    let value = signal.get().to_string()
    set_part_value(parts, part_name, value)
    commit_part(parts, part_name)
  })
}

///|
/// Bind event handlers using data-on-* attributes
pub fn WcIslandContext::bind_actions(
  self : WcIslandContext,
  dispatch : (String) -> Unit,
) -> Unit {
  // Bind common event types
  bind_on_handlers(self.shadow_root, "click", dispatch)
  bind_on_handlers(self.shadow_root, "input", dispatch)
  bind_on_handlers(self.shadow_root, "change", dispatch)
}

///|
/// Bind a specific event handler by selector
pub fn WcIslandContext::on(
  self : WcIslandContext,
  selector : String,
  event_type : String,
  handler : () -> Unit,
) -> Unit {
  bind_event_handler(self.shadow_root, selector, event_type, handler)
}

// =============================================================================
// High-Level Hydration Helper
// =============================================================================

///|
/// Hydrate a Web Components island
///
/// Usage in component:
/// ```moonbit
/// pub fn hydrate(element : @js.Any) -> Unit {
///   @dom.hydrate_wc_island(element, fn(ctx) {
///     let count = ctx.signal_int("count", 0)
///
///     // Bind signal to DOM Part
///     ctx.bind_signal("count", count)
///
///     // Bind action handlers
///     ctx.bind_actions(fn(action) {
///       match action {
///         "increment" => count.set(count.get() + 1)
///         "decrement" => count.set(count.get() - 1)
///         _ => ()
///       }
///     })
///   })
/// }
/// ```
pub fn hydrate_wc_island(
  element : @js.Any,
  setup : (WcIslandContext) -> Unit,
) -> Unit {
  // Cast element to DOM Element
  let elem : @js_dom.Element = element.cast()
  let name = elem.tagName()

  console_log_wc("[" + name + "] hydrating...")

  // Create context
  match WcIslandContext::new(elem) {
    Some(ctx) => {
      // Run component setup
      setup(ctx)
      console_log_wc("[" + name + "] hydration complete")
    }
    None => console_log_wc("[" + name + "] no shadow root found, skipping hydration")
  }
}
