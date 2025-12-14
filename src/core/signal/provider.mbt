///| Context Provider - Component-level value sharing (Solid.js style)
///|
///| Unlike ReactiveContext (internal effect tracking), this provides
///| application-level context for sharing values across component trees.

///|
/// Context type with typed getter
/// Each context instance stores values in its own stack
pub struct Context[T] {
  id : Int
  default_value : () -> T
  // Internal: getter function for current value
  mut current_getter : () -> T
}

///|
/// Global context ID counter
let context_id_counter : Ref[Int] = { val: 0 }

///|
/// Create a new context with a default value
/// Similar to Solid.js createContext
pub fn[T] create_context(default_value : T) -> Context[T] {
  let id = context_id_counter.val
  context_id_counter.val = id + 1
  let default_fn = fn() { default_value }
  { id, default_value: default_fn, current_getter: default_fn }
}

///|
/// Provide a context value for the duration of a function
/// Values are scoped to the current Owner and its children
///
/// Example:
/// ```
/// let theme_ctx = create_context("light")
/// provide(theme_ctx, "dark", fn() {
///   // All components here will see "dark"
///   my_component()
/// })
/// ```
pub fn[T, R] provide(ctx : Context[T], value : T, f : () -> R) -> R {
  // Save previous getter
  let prev_getter = ctx.current_getter

  // Set new getter
  ctx.current_getter = fn() { value }

  // Run the function
  let result = f()

  // Restore previous getter
  ctx.current_getter = prev_getter
  result
}

///|
/// Use a context value - returns the current provided value or default
/// Similar to Solid.js useContext
///
/// Example:
/// ```
/// let theme = use_context(theme_ctx) // Returns "dark" or default
/// ```
pub fn[T] use_context(ctx : Context[T]) -> T {
  (ctx.current_getter)()
}
