///| Element helpers - HTML element factory functions

///|

///| This module provides convenient factory functions for creating HTML elements.

///| Separated from core vnode for smaller bundle size when not needed.

// Element helpers

///|
/// Create a div VNode
pub fn div(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("div", attrs, children)
}

///|
/// Create a span VNode
pub fn span(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("span", attrs, children)
}

///|
/// Create a p VNode
pub fn p(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("p", attrs, children)
}

///|
/// Create a button VNode
pub fn button(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("button", attrs, children)
}

///|
/// Create an a VNode
pub fn a(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("a", attrs, children)
}

///|
/// Create an input VNode
pub fn input(attrs : Array[(String, @ui.Attr)]) -> @ui.Node {
  @ui.vnode("input", attrs, [])
}

///|
/// Create a form VNode
pub fn form(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("form", attrs, children)
}

///|
/// Create a label VNode
pub fn label(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("label", attrs, children)
}

///|
/// Create h1 VNode
pub fn h1(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("h1", attrs, children)
}

///|
/// Create h2 VNode
pub fn h2(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("h2", attrs, children)
}

///|
/// Create h3 VNode
pub fn h3(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("h3", attrs, children)
}

///|
/// Create ul VNode
pub fn ul(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("ul", attrs, children)
}

///|
/// Create ol VNode
pub fn ol(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("ol", attrs, children)
}

///|
/// Create li VNode
pub fn li(
  attrs : Array[(String, @ui.Attr)],
  children : Array[@ui.Node],
) -> @ui.Node {
  @ui.vnode("li", attrs, children)
}

///|
/// Create img VNode
pub fn img(attrs : Array[(String, @ui.Attr)]) -> @ui.Node {
  @ui.vnode("img", attrs, [])
}

///|
/// Create br VNode
pub fn br() -> @ui.Node {
  @ui.vnode("br", [], [])
}

///|
/// Create hr VNode
pub fn hr() -> @ui.Node {
  @ui.vnode("hr", [], [])
}
