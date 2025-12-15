///| HTML/Attribute/JS String Escaping Utilities

///| Pure MoonBit - works on all targets (js, wasm-gc, native)

// =============================================================================
// HTML Escaping
// =============================================================================

///|
/// Check if string needs HTML escaping
pub fn needs_html_escape(s : String) -> Bool {
  for char in s {
    match char {
      '&' | '<' | '>' | '"' | '\'' => return true
      _ => ()
    }
  }
  false
}

///|
/// Escape HTML special characters and write to StringBuilder
pub fn escape_html_to(sb : StringBuilder, s : String) -> Unit {
  // Fast path: most strings don't need escaping
  if not(needs_html_escape(s)) {
    sb.write_string(s)
    return
  }
  // Slow path: escape character by character
  for char in s {
    match char {
      '&' => sb.write_string("&amp;")
      '<' => sb.write_string("&lt;")
      '>' => sb.write_string("&gt;")
      '"' => sb.write_string("&quot;")
      '\'' => sb.write_string("&#39;")
      _ => sb.write_char(char)
    }
  }
}

///|
/// Escape HTML and return new string
pub fn escape_html(s : String) -> String {
  if not(needs_html_escape(s)) {
    return s
  }
  let sb = StringBuilder::new(size_hint=s.length() + 16)
  escape_html_to(sb, s)
  sb.to_string()
}

// =============================================================================
// Attribute Escaping
// =============================================================================

///|
/// Check if string needs attribute escaping (subset of HTML)
pub fn needs_attr_escape(s : String) -> Bool {
  for char in s {
    match char {
      '&' | '"' => return true
      _ => ()
    }
  }
  false
}

///|
/// Escape attribute value and write to StringBuilder
pub fn escape_attr_to(sb : StringBuilder, s : String) -> Unit {
  // Fast path: most attribute values don't need escaping
  if not(needs_attr_escape(s)) {
    sb.write_string(s)
    return
  }
  // Slow path: escape character by character
  for char in s {
    match char {
      '&' => sb.write_string("&amp;")
      '"' => sb.write_string("&quot;")
      _ => sb.write_char(char)
    }
  }
}

///|
/// Escape attribute and return new string
pub fn escape_attr(s : String) -> String {
  if not(needs_attr_escape(s)) {
    return s
  }
  let sb = StringBuilder::new(size_hint=s.length() + 8)
  escape_attr_to(sb, s)
  sb.to_string()
}

// =============================================================================
// JavaScript String Escaping
// =============================================================================

///|
/// Escape JS string for embedding in script tags
/// Handles </script> injection prevention
pub fn escape_js_string(s : String) -> String {
  let sb = StringBuilder::new(size_hint=s.length() + 16)
  escape_js_string_to(sb, s)
  sb.to_string()
}

///|
/// Escape JS string and write to StringBuilder
pub fn escape_js_string_to(sb : StringBuilder, s : String) -> Unit {
  for char in s {
    match char {
      '\\' => sb.write_string("\\\\")
      '"' => sb.write_string("\\\"")
      '\n' => sb.write_string("\\n")
      '\r' => sb.write_string("\\r")
      '\t' => sb.write_string("\\t")
      '<' => sb.write_string("\\u003c") // Prevent </script> injection
      '>' => sb.write_string("\\u003e")
      _ => sb.write_char(char)
    }
  }
}

// =============================================================================
// Void Element Check
// =============================================================================

///|
/// Check if HTML tag is a void (self-closing) element
/// Optimized with length check and first char dispatch
pub fn is_void_element(tag : String) -> Bool {
  let len = tag.length()
  // Fast reject: most common tags are not void elements
  // void elements have length 2-6
  if len < 2 || len > 6 {
    return false
  }
  // Check by length first, then by content
  match len {
    2 => tag == "br" || tag == "hr"
    3 => tag == "img" || tag == "col" || tag == "wbr"
    4 => tag == "area" || tag == "base" || tag == "link" || tag == "meta"
    5 => tag == "embed" || tag == "input" || tag == "track" || tag == "param"
    6 => tag == "source" || tag == "keygen"
    _ => false
  }
}
