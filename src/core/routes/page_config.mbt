// Page Configuration (page.json)
//
// Defines the configuration schema for page.json files.

// =============================================================================
// Page Config
// =============================================================================

///|
/// Configuration from page.json
pub(all) struct PageConfig {
  /// Rendering mode: "static" | "ssr" | "isr" | "spa"
  mode : String?
  /// ISR revalidation interval in seconds
  revalidate : Int?
  /// Page title
  title : String?
  /// Page description
  description : String?
  /// Layout identifier
  layout : String?
  /// Islands to hydrate on client
  islands : Array[String]
  /// Generate static params for dynamic routes
  generate_params : Bool
  /// Enable SPA fallback for this route
  fallback : Bool
  /// Parent config to extend
  extends : String?
  /// File type specific handlers
  handlers : Map[String, FileHandlerConfig]
}

///|
/// File handler configuration
pub(all) struct FileHandlerConfig {
  /// Layout for this file type
  layout : String?
  /// Islands for this file type
  islands : Array[String]
  /// Pass through without processing
  passthrough : Bool
}

// =============================================================================
// Defaults
// =============================================================================

///|
/// Default page config
pub fn PageConfig::default() -> PageConfig {
  {
    mode: None,
    revalidate: None,
    title: None,
    description: None,
    layout: None,
    islands: [],
    generate_params: false,
    fallback: false,
    extends: None,
    handlers: {},
  }
}

///|
/// Default file handler config
pub fn FileHandlerConfig::default() -> FileHandlerConfig {
  { layout: None, islands: [], passthrough: false }
}

// =============================================================================
// Parsing
// =============================================================================

///|
/// Parse page.json content
pub fn parse_page_config(json_str : String) -> PageConfig? {
  try {
    let json = @json.parse(json_str.view())
    guard json is Object(obj) else { return None }
    parse_page_config_object(obj)
  } catch {
    _ => None
  }
}

///|
/// Parse page config from JSON object
fn parse_page_config_object(obj : Map[String, Json]) -> PageConfig? {
  let mode = @json_utils.extract_string_opt(obj, "mode")
  let revalidate = @json_utils.extract_int_opt(obj, "revalidate")
  let title = @json_utils.extract_string_opt(obj, "title")
  let description = @json_utils.extract_string_opt(obj, "description")
  let layout = @json_utils.extract_string_opt(obj, "layout")
  let islands = @json_utils.extract_string_array(obj, "islands")
  let generate_params = @json_utils.extract_bool(obj, "generateParams", false)
  let fallback = @json_utils.extract_bool(obj, "fallback", false)
  let extends = @json_utils.extract_string_opt(obj, "extends")
  let handlers = parse_handlers(obj)
  Some(
    PageConfig::{
      mode,
      revalidate,
      title,
      description,
      layout,
      islands,
      generate_params,
      fallback,
      extends,
      handlers,
    },
  )
}

///|
/// Parse file handlers from config
fn parse_handlers(obj : Map[String, Json]) -> Map[String, FileHandlerConfig] {
  let result : Map[String, FileHandlerConfig] = {}
  match obj.get("handlers") {
    Some(Object(handlers_obj)) => {
      for k, v in handlers_obj {
        if v is Object(handler_obj) {
          let config = FileHandlerConfig::{
            layout: @json_utils.extract_string_opt(handler_obj, "layout"),
            islands: @json_utils.extract_string_array(handler_obj, "islands"),
            passthrough: @json_utils.extract_bool(handler_obj, "passthrough", false),
          }
          result[k] = config
        }
      }
    }
    _ => ()
  }
  result
}

// =============================================================================
// Merging
// =============================================================================

///|
/// Merge two page configs (child overrides base)
pub fn PageConfig::merge(base : PageConfig, child : PageConfig) -> PageConfig {
  // Child values override base values
  let mode = match child.mode {
    Some(_) => child.mode
    None => base.mode
  }
  let revalidate = match child.revalidate {
    Some(_) => child.revalidate
    None => base.revalidate
  }
  let title = match child.title {
    Some(_) => child.title
    None => base.title
  }
  let description = match child.description {
    Some(_) => child.description
    None => base.description
  }
  let layout = match child.layout {
    Some(_) => child.layout
    None => base.layout
  }

  // Arrays: if child has items, use child's; otherwise use base's
  let islands = if child.islands.is_empty() {
    base.islands
  } else {
    child.islands
  }

  // Booleans: child values if true, otherwise base
  let generate_params = child.generate_params || base.generate_params
  let fallback = child.fallback || base.fallback

  // extends is not inherited
  let extends = child.extends

  // Merge handlers (child overrides)
  let handlers : Map[String, FileHandlerConfig] = {}
  for k, v in base.handlers {
    handlers[k] = v
  }
  for k, v in child.handlers {
    handlers[k] = v
  }
  PageConfig::{
    mode,
    revalidate,
    title,
    description,
    layout,
    islands,
    generate_params,
    fallback,
    extends,
    handlers,
  }
}

// =============================================================================
// Conversion
// =============================================================================

///|
/// Convert page config mode string to RenderMode
pub fn PageConfig::to_render_mode(self : PageConfig) -> RenderMode {
  match self.mode {
    Some("ssr") => RenderMode::Ssr
    Some("isr") =>
      RenderMode::Isr(revalidate=self.revalidate.unwrap_or(3600))
    Some("spa") => RenderMode::Spa
    Some("static") | _ =>
      // Static mode doesn't use RenderMode (it's pre-rendered)
      // Default to SSR for dynamic routes
      RenderMode::Ssr
  }
}

///|
/// Check if this config represents a static page
pub fn PageConfig::is_static(self : PageConfig) -> Bool {
  match self.mode {
    Some("static") | None => true
    _ => false
  }
}

///|
/// Check if this config represents a dynamic page
pub fn PageConfig::is_dynamic(self : PageConfig) -> Bool {
  match self.mode {
    Some("ssr") | Some("isr") => true
    _ => false
  }
}

///|
/// Check if this config represents a SPA page
pub fn PageConfig::is_spa(self : PageConfig) -> Bool {
  match self.mode {
    Some("spa") => true
    _ => false
  }
}
