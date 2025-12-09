///| Attribute helpers - HTML attribute factory functions

///|

///| This module provides convenient factory functions for creating HTML attributes.

///| Separated from core vnode for smaller bundle size when not needed.

// Attribute helpers

///|
/// Create a static attribute
pub fn attr(key : String, value : String) -> (String, @ui.Attr) {
  (key, @ui.attr_static(value))
}

///|
/// Create a dynamic attribute
pub fn attr_dyn(key : String, getter : () -> String) -> (String, @ui.Attr) {
  (key, @ui.attr_dynamic(getter))
}

///|
/// Create a className attribute
pub fn class(value : String) -> (String, @ui.Attr) {
  ("class", @ui.attr_static(value))
}

///|
/// Create a dynamic className attribute
pub fn class_dyn(getter : () -> String) -> (String, @ui.Attr) {
  ("class", @ui.attr_dynamic(getter))
}

///|
/// Create an id attribute
pub fn id(value : String) -> (String, @ui.Attr) {
  ("id", @ui.attr_static(value))
}

///|
/// Create a href attribute
pub fn href(value : String) -> (String, @ui.Attr) {
  ("href", @ui.attr_static(value))
}

///|
/// Create a src attribute
pub fn src(value : String) -> (String, @ui.Attr) {
  ("src", @ui.attr_static(value))
}

///|
/// Create an alt attribute
pub fn alt(value : String) -> (String, @ui.Attr) {
  ("alt", @ui.attr_static(value))
}

///|
/// Create a type attribute
pub fn type_(value : String) -> (String, @ui.Attr) {
  ("type", @ui.attr_static(value))
}

///|
/// Create a value attribute
pub fn value(value : String) -> (String, @ui.Attr) {
  ("value", @ui.attr_static(value))
}

///|
/// Create a dynamic value attribute
pub fn value_dyn(getter : () -> String) -> (String, @ui.Attr) {
  ("value", @ui.attr_dynamic(getter))
}

///|
/// Create a placeholder attribute
pub fn placeholder(value : String) -> (String, @ui.Attr) {
  ("placeholder", @ui.attr_static(value))
}

///|
/// Create a disabled attribute
pub fn disabled(value : Bool) -> (String, @ui.Attr) {
  if value {
    ("disabled", @ui.attr_static(""))
  } else {
    ("disabled", @ui.attr_static("__remove__"))
  }
}

///|
/// Create an onClick handler (placeholder for SSR, actual handler set in DOM)
pub fn on_click(handler : @ui.EventHandler) -> (String, @ui.Attr) {
  ("onClick", @ui.attr_handler(handler))
}

///|
/// Create an onInput handler
pub fn on_input(handler : @ui.EventHandler) -> (String, @ui.Attr) {
  ("onInput", @ui.attr_handler(handler))
}

///|
/// Create an onChange handler
pub fn on_change(handler : @ui.EventHandler) -> (String, @ui.Attr) {
  ("onChange", @ui.attr_handler(handler))
}

///|
/// Create an onSubmit handler
pub fn on_submit(handler : @ui.EventHandler) -> (String, @ui.Attr) {
  ("onSubmit", @ui.attr_handler(handler))
}

///|
/// Create a style attribute
pub fn style(styles : Array[(String, String)]) -> (String, @ui.Attr) {
  ("style", @ui.attr_style(styles))
}

///|
/// Create a dynamic style attribute
pub fn style_dyn(getter : () -> Array[(String, String)]) -> (String, @ui.Attr) {
  ("style", @ui.attr_dynamic_style(getter))
}
