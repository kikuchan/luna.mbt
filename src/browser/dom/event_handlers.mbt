///| Event Handler Types - Type-safe event handlers for Luna DOM
///|
///| This module provides typed event handler aliases similar to React's event handler types.
///| Each handler type is parameterized by the target element type for type safety.
///|
///| Usage:
///|   let handler : MouseEventHandler = fn(e) { e.preventDefault() }
///|   div(on=on(click=Some(handler)), [text("Click me")])

// =============================================================================
// Event Handler Type Aliases
// =============================================================================

///|
/// MouseEventHandler - Handler for mouse events (click, dblclick, mouseenter, etc.)
/// The event provides clientX, clientY, button, ctrlKey, etc.
pub type MouseEventHandler = (@js_dom.MouseEvent) -> Unit

///|
/// KeyboardEventHandler - Handler for keyboard events (keydown, keyup, keypress)
/// The event provides key, code, ctrlKey, shiftKey, etc.
pub type KeyboardEventHandler = (@js_dom.KeyboardEvent) -> Unit

///|
/// InputEventHandler - Handler for input events on form elements
/// The event provides inputType, data, isComposing, etc.
pub type InputEventHandler = (@js_dom.InputEvent) -> Unit

///|
/// ChangeEventHandler - Handler for change events on form elements
pub type ChangeEventHandler = (@js_dom.ChangeEvent) -> Unit

///|
/// FocusEventHandler - Handler for focus/blur events
/// The event provides relatedTarget for focus transitions
pub type FocusEventHandler = (@js_dom.FocusEvent) -> Unit

///|
/// FormEventHandler - Handler for form submission events
/// Call preventDefault() to prevent default form submission
pub type FormEventHandler = (@js_dom.FormEvent) -> Unit

///|
/// DragEventHandler - Handler for drag and drop events
/// The event provides dataTransfer for drag data
pub type DragEventHandler = (@js_dom.DragEvent) -> Unit

///|
/// WheelEventHandler - Handler for wheel/scroll events
/// The event provides deltaX, deltaY, deltaZ, deltaMode
pub type WheelEventHandler = (@js_dom.WheelEvent) -> Unit

///|
/// TouchEventHandler - Handler for touch events on touch devices
/// The event provides touches, targetTouches, changedTouches arrays
pub type TouchEventHandler = (@js_dom.TouchEvent) -> Unit

///|
/// PointerEventHandler - Handler for pointer events (unified mouse/touch/pen)
/// The event provides pointerId, pointerType, pressure, etc.
pub type PointerEventHandler = (@js_dom.PointerEvent) -> Unit

///|
/// AnimationEventHandler - Handler for CSS animation events
/// The event provides animationName, elapsedTime, pseudoElement
pub type AnimationEventHandler = (@js_dom.AnimationEvent) -> Unit

///|
/// TransitionEventHandler - Handler for CSS transition events
/// The event provides propertyName, elapsedTime, pseudoElement
pub type TransitionEventHandler = (@js_dom.TransitionEvent) -> Unit

///|
/// ClipboardEventHandler - Handler for clipboard events (copy, cut, paste)
/// The event provides clipboardData
pub type ClipboardEventHandler = (@js_dom.ClipboardEvent) -> Unit

///|
/// ScrollEventHandler - Handler for scroll events
pub type ScrollEventHandler = (@js_dom.ScrollEvent) -> Unit

// =============================================================================
// Generic Event Handler
// =============================================================================

///|
/// GenericEventHandler - Handler for any DOM event
/// Use when you need to handle an event type not covered above
pub type GenericEventHandler = (@js_dom.Event) -> Unit
