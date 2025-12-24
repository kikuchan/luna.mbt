// Route Manifest - Implementation-independent route representation
//
// This module provides a unified intermediate representation for routes
// that can be used by both Astra (SSG) and Sol (SSR).

// =============================================================================
// Core Types
// =============================================================================

///|
/// The route manifest contains all routes and fallback configuration
pub(all) struct RouteManifest {
  /// All route entries
  routes : Array[RouteEntry]
  /// Fallback configuration for unmatched routes
  fallback : FallbackConfig
}

///|
/// Create an empty route manifest
pub fn RouteManifest::empty() -> RouteManifest {
  { routes: [], fallback: FallbackConfig::NotFound(path="/404.html") }
}

///|
/// A single route entry - can be static, dynamic, or API
pub(all) enum RouteEntry {
  /// Static page (HTML generated at build time)
  Static(StaticRouteEntry)
  /// Dynamic page (generated at request time)
  Dynamic(DynamicRouteEntry)
  /// API endpoint
  Api(ApiRouteEntry)
}

// =============================================================================
// Static Route
// =============================================================================

///|
/// A static route that is pre-rendered at build time
pub(all) struct StaticRouteEntry {
  /// URL path (e.g., "/about")
  path : String
  /// Source file path relative to pages directory (e.g., "about/index.mbt")
  source : String
  /// Output file path (e.g., "about/index.html")
  output : String
  /// Layout identifier
  layout : String?
  /// Page title
  title : String?
  /// Page description
  description : String?
  /// Islands to hydrate on client
  islands : Array[String]
  /// Locale code
  locale : String
  /// Generated parameters for dynamic static pages
  generated_params : Array[Map[String, String]]
}

///|
/// Create a static route entry with minimal required fields
pub fn StaticRouteEntry::new(
  path~ : String,
  source~ : String,
  output~ : String,
) -> StaticRouteEntry {
  {
    path,
    source,
    output,
    layout: None,
    title: None,
    description: None,
    islands: [],
    locale: "en",
    generated_params: [],
  }
}

// =============================================================================
// Dynamic Route
// =============================================================================

///|
/// A dynamic route that is rendered at request time
pub(all) struct DynamicRouteEntry {
  /// Path pattern (e.g., "/blog/:slug")
  path : String
  /// Regex pattern for matching
  pattern : String
  /// Extracted parameter names
  param_names : Array[String]
  /// Source file path
  source : String
  /// Rendering mode (SSR or ISR)
  mode : RenderMode
  /// Layout identifier
  layout : String?
  /// Catch-all information if applicable
  catch_all : CatchAllInfo?
  /// Page title template
  title : String?
  /// Islands to hydrate
  islands : Array[String]
}

///|
/// Create a dynamic route entry
pub fn DynamicRouteEntry::new(
  path~ : String,
  pattern~ : String,
  param_names~ : Array[String],
  source~ : String,
  mode~ : RenderMode,
) -> DynamicRouteEntry {
  {
    path,
    pattern,
    param_names,
    source,
    mode,
    layout: None,
    catch_all: None,
    title: None,
    islands: [],
  }
}

///|
/// Information about catch-all segments
pub(all) struct CatchAllInfo {
  /// Parameter name
  name : String
  /// Whether it's optional (matches zero or more segments)
  optional : Bool
}

// =============================================================================
// API Route
// =============================================================================

///|
/// An API route endpoint
pub(all) struct ApiRouteEntry {
  /// Path pattern (e.g., "/api/posts/:id")
  path : String
  /// Regex pattern for matching
  pattern : String
  /// Extracted parameter names
  param_names : Array[String]
  /// HTTP method
  http_method : HttpMethod
  /// Source file path
  source : String
}

///|
/// Create an API route entry
pub fn ApiRouteEntry::new(
  path~ : String,
  pattern~ : String,
  http_method~ : HttpMethod,
  source~ : String,
) -> ApiRouteEntry {
  { path, pattern, param_names: [], http_method, source }
}

// =============================================================================
// Helper Functions
// =============================================================================

///|
/// Get the path from a route entry
pub fn RouteEntry::path(self : RouteEntry) -> String {
  match self {
    Static(r) => r.path
    Dynamic(r) => r.path
    Api(r) => r.path
  }
}

///|
/// Get the source from a route entry
pub fn RouteEntry::source(self : RouteEntry) -> String {
  match self {
    Static(r) => r.source
    Dynamic(r) => r.source
    Api(r) => r.source
  }
}

///|
/// Check if this is a static route
pub fn RouteEntry::is_static(self : RouteEntry) -> Bool {
  match self {
    Static(_) => true
    _ => false
  }
}

///|
/// Check if this is a dynamic route
pub fn RouteEntry::is_dynamic(self : RouteEntry) -> Bool {
  match self {
    Dynamic(_) => true
    _ => false
  }
}

///|
/// Check if this is an API route
pub fn RouteEntry::is_api(self : RouteEntry) -> Bool {
  match self {
    Api(_) => true
    _ => false
  }
}
