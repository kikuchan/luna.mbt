///| SSR - Re-exports from core/render for backward compatibility
///| Stream rendering functionality remains in this module (JS-only)
///|
///| NOTE: This file is kept for backward compatibility.
///| New code should import from @render (mizchi/luna/core/render) directly.

// Re-export using statement for backward compatibility
pub using @render {
  type SSRResult,
  render_to_string,
  render_to_string_with_hydration,
  generate_preload_tags,
  escape_html,
  escape_attr,
  escape_js_string,
  escape_html_to,
  escape_attr_to,
  is_void_element,
  needs_html_escape,
  needs_attr_escape,
}
