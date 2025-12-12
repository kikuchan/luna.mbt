///| Element factories for server-side rendering
///|
///| Provides html, head, body and common HTML elements.
///| No event handlers - use islands for interactivity.

// =============================================================================
// Helper functions
// =============================================================================

///|
/// Create a server-side element
fn create_element(
  tag : String,
  attrs : Array[(String, @luna.Attr[Unit])],
  children : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  @luna.h(tag, attrs, children)
}

///|
/// Create a static attribute
fn static_attr(value : String) -> @luna.Attr[Unit] {
  @luna.attr_static(value)
}

///|
/// Build attribute array from common properties
fn build_attrs(
  id : String?,
  class : String?,
  style : String?,
  attrs : Array[(String, @luna.Attr[Unit])]?
) -> Array[(String, @luna.Attr[Unit])] {
  let result : Array[(String, @luna.Attr[Unit])] = []
  match id {
    Some(v) => result.push(("id", static_attr(v)))
    None => ()
  }
  match class {
    Some(v) => result.push(("class", static_attr(v)))
    None => ()
  }
  match style {
    Some(v) => result.push(("style", static_attr(v)))
    None => ()
  }
  match attrs {
    Some(extra) =>
      for attr in extra {
        result.push(attr)
      }
    None => ()
  }
  result
}

// =============================================================================
// Document structure elements
// =============================================================================

///|
/// Create an html element
pub fn html(
  lang? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  let props = build_attrs(None, None, None, attrs)
  match lang {
    Some(v) => props.push(("lang", static_attr(v)))
    None => ()
  }
  create_element("html", props, children)
}

///|
/// Create a head element
pub fn head(
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("head", build_attrs(None, None, None, attrs), children)
}

///|
/// Create a body element
pub fn body(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("body", build_attrs(id, class, style, attrs), children)
}

///|
/// Create a title element
pub fn title(content : String) -> @luna.Node[Unit] {
  create_element("title", [], [text(content)])
}

///|
/// Create a meta element
pub fn meta(
  charset? : String,
  name? : String,
  content? : String,
  http_equiv? : String,
  attrs? : Array[(String, @luna.Attr[Unit])]
) -> @luna.Node[Unit] {
  let props = build_attrs(None, None, None, attrs)
  match charset {
    Some(v) => props.push(("charset", static_attr(v)))
    None => ()
  }
  match name {
    Some(v) => props.push(("name", static_attr(v)))
    None => ()
  }
  match content {
    Some(v) => props.push(("content", static_attr(v)))
    None => ()
  }
  match http_equiv {
    Some(v) => props.push(("http-equiv", static_attr(v)))
    None => ()
  }
  create_element("meta", props, [])
}

///|
/// Create a link element
pub fn link(
  rel? : String,
  href? : String,
  type_? : String,
  attrs? : Array[(String, @luna.Attr[Unit])]
) -> @luna.Node[Unit] {
  let props = build_attrs(None, None, None, attrs)
  match rel {
    Some(v) => props.push(("rel", static_attr(v)))
    None => ()
  }
  match href {
    Some(v) => props.push(("href", static_attr(v)))
    None => ()
  }
  match type_ {
    Some(v) => props.push(("type", static_attr(v)))
    None => ()
  }
  create_element("link", props, [])
}

///|
/// Create a script element
pub fn script(
  src? : String,
  type_? : String,
  defer_? : Bool,
  async_? : Bool,
  content? : String,
  attrs? : Array[(String, @luna.Attr[Unit])]
) -> @luna.Node[Unit] {
  let props = build_attrs(None, None, None, attrs)
  match src {
    Some(v) => props.push(("src", static_attr(v)))
    None => ()
  }
  match type_ {
    Some(v) => props.push(("type", static_attr(v)))
    None => ()
  }
  match defer_ {
    Some(true) => props.push(("defer", static_attr("")))
    _ => ()
  }
  match async_ {
    Some(true) => props.push(("async", static_attr("")))
    _ => ()
  }
  let script_children : Array[@luna.Node[Unit]] = match content {
    Some(c) => [text(c)]
    None => []
  }
  create_element("script", props, script_children)
}

///|
/// Create a style element
pub fn style_(
  content : String,
  type_? : String,
  attrs? : Array[(String, @luna.Attr[Unit])]
) -> @luna.Node[Unit] {
  let props = build_attrs(None, None, None, attrs)
  match type_ {
    Some(v) => props.push(("type", static_attr(v)))
    None => ()
  }
  create_element("style", props, [text(content)])
}

// =============================================================================
// Semantic layout elements
// =============================================================================

///|
/// Create a main element (named main_ to avoid keyword conflict)
pub fn main_(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("main", build_attrs(id, class, style, attrs), children)
}

///|
/// Create a nav element
pub fn nav(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("nav", build_attrs(id, class, style, attrs), children)
}

///|
/// Create a header element (named header_ to avoid potential conflicts)
pub fn header_(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("header", build_attrs(id, class, style, attrs), children)
}

///|
/// Create a footer element (named footer_ to avoid potential conflicts)
pub fn footer_(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("footer", build_attrs(id, class, style, attrs), children)
}

///|
/// Create a section element
pub fn section(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("section", build_attrs(id, class, style, attrs), children)
}

///|
/// Create an article element
pub fn article(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("article", build_attrs(id, class, style, attrs), children)
}

///|
/// Create an aside element
pub fn aside(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("aside", build_attrs(id, class, style, attrs), children)
}

// =============================================================================
// Common content elements
// =============================================================================

///|
/// Create a div element
pub fn div(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("div", build_attrs(id, class, style, attrs), children)
}

///|
/// Create a span element
pub fn span(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("span", build_attrs(id, class, style, attrs), children)
}

///|
/// Create a p element
pub fn p(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("p", build_attrs(id, class, style, attrs), children)
}

///|
/// Create an anchor element
pub fn a(
  href? : String,
  target? : String,
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  let props = build_attrs(id, class, style, attrs)
  match href {
    Some(v) => props.push(("href", static_attr(v)))
    None => ()
  }
  match target {
    Some(v) => props.push(("target", static_attr(v)))
    None => ()
  }
  create_element("a", props, children)
}

// =============================================================================
// Heading elements
// =============================================================================

///|
/// Create h1 element
pub fn h1(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("h1", build_attrs(id, class, style, attrs), children)
}

///|
/// Create h2 element
pub fn h2(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("h2", build_attrs(id, class, style, attrs), children)
}

///|
/// Create h3 element
pub fn h3(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("h3", build_attrs(id, class, style, attrs), children)
}

///|
/// Create h4 element
pub fn h4(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("h4", build_attrs(id, class, style, attrs), children)
}

///|
/// Create h5 element
pub fn h5(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("h5", build_attrs(id, class, style, attrs), children)
}

///|
/// Create h6 element
pub fn h6(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("h6", build_attrs(id, class, style, attrs), children)
}

// =============================================================================
// List elements
// =============================================================================

///|
/// Create ul element
pub fn ul(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("ul", build_attrs(id, class, style, attrs), children)
}

///|
/// Create ol element
pub fn ol(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("ol", build_attrs(id, class, style, attrs), children)
}

///|
/// Create li element
pub fn li(
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])],
  children~ : Array[@luna.Node[Unit]]
) -> @luna.Node[Unit] {
  create_element("li", build_attrs(id, class, style, attrs), children)
}

// =============================================================================
// Media elements
// =============================================================================

///|
/// Create img element
pub fn img(
  src? : String,
  alt? : String,
  width? : String,
  height? : String,
  id? : String,
  class? : String,
  style? : String,
  attrs? : Array[(String, @luna.Attr[Unit])]
) -> @luna.Node[Unit] {
  let props = build_attrs(id, class, style, attrs)
  match src {
    Some(v) => props.push(("src", static_attr(v)))
    None => ()
  }
  match alt {
    Some(v) => props.push(("alt", static_attr(v)))
    None => ()
  }
  match width {
    Some(v) => props.push(("width", static_attr(v)))
    None => ()
  }
  match height {
    Some(v) => props.push(("height", static_attr(v)))
    None => ()
  }
  create_element("img", props, [])
}

///|
/// Create br element
pub fn br() -> @luna.Node[Unit] {
  create_element("br", [], [])
}

///|
/// Create hr element
pub fn hr() -> @luna.Node[Unit] {
  create_element("hr", [], [])
}

// =============================================================================
// Text and Fragment helpers
// =============================================================================

///|
/// Create a text node
pub fn text(content : String) -> @luna.Node[Unit] {
  @luna.vtext(content)
}

///|
/// Create a fragment (multiple nodes without wrapper)
pub fn fragment(children : Array[@luna.Node[Unit]]) -> @luna.Node[Unit] {
  @luna.vfragment(children)
}

///|
/// Create static attribute
pub fn attr(value : String) -> @luna.Attr[Unit] {
  @luna.attr_static(value)
}
