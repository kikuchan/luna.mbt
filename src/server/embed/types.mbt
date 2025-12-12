///| Embedding Types
///| Types for generating portable, resumable UI snippets

/// When to hydrate the component
pub(all) enum TriggerType {
  /// Hydrate on page load (DOMContentLoaded)
  Load
  /// Hydrate when browser is idle (requestIdleCallback)
  Idle
  /// Hydrate when element enters viewport (IntersectionObserver)
  Visible
  /// Hydrate when media query matches
  Media(String)
  /// Never auto-hydrate (manual only)
  None
}

/// How state is provided
pub(all) enum StateConfig {
  /// No state
  Empty
  /// Inline JSON in ln:state attribute
  Inline(String)
  /// Reference to a <script id="..."> element
  ScriptRef(String)
  /// URL to fetch state from
  Url(String)
}

/// Configuration for generating an embed snippet
pub struct EmbedConfig {
  /// Unique identifier for the component
  id : String
  /// ES module URL to load for hydration
  script_url : String
  /// When to trigger hydration
  trigger : TriggerType
  /// Initial state configuration
  state : StateConfig
  /// Pre-rendered HTML content (SSR output)
  ssr_content : String?
  /// Whether to include the loader script tag
  include_loader : Bool
  /// URL for the loader script
  loader_url : String
}

/// Output from embed generation
pub struct EmbedOutput {
  /// Complete HTML snippet
  html : String
  /// Scripts to inject in <head> (for SSR environments)
  head_scripts : Array[String]
  /// State <script> tags (when using ScriptRef)
  state_scripts : Array[String]
}

/// Default loader URL
pub let default_loader_url : String = "kg-loader-v1.js"

/// Create a minimal embed config
pub fn EmbedConfig::new(id : String, script_url : String) -> EmbedConfig {
  {
    id,
    script_url,
    trigger: Load,
    state: Empty,
    ssr_content: None,
    include_loader: false,
    loader_url: default_loader_url,
  }
}

/// Builder pattern: set trigger
pub fn EmbedConfig::with_trigger(self : EmbedConfig, trigger : TriggerType) -> EmbedConfig {
  { ..self, trigger }
}

/// Builder pattern: set inline state from JSON string
pub fn EmbedConfig::with_state(self : EmbedConfig, json : String) -> EmbedConfig {
  { ..self, state: Inline(json) }
}

/// Builder pattern: set state from script reference
pub fn EmbedConfig::with_state_ref(self : EmbedConfig, script_id : String) -> EmbedConfig {
  { ..self, state: ScriptRef(script_id) }
}

/// Builder pattern: set state from URL
pub fn EmbedConfig::with_state_url(self : EmbedConfig, url : String) -> EmbedConfig {
  { ..self, state: Url(url) }
}

/// Builder pattern: set SSR content
pub fn EmbedConfig::with_ssr_content(self : EmbedConfig, content : String) -> EmbedConfig {
  { ..self, ssr_content: Some(content) }
}

/// Builder pattern: include loader script
pub fn EmbedConfig::with_loader(self : EmbedConfig, url : String) -> EmbedConfig {
  { ..self, include_loader: true, loader_url: url }
}

/// Builder pattern: include loader script with default URL
pub fn EmbedConfig::with_default_loader(self : EmbedConfig) -> EmbedConfig {
  { ..self, include_loader: true }
}

/// Convert TriggerType to attribute value
pub fn TriggerType::to_string(self : TriggerType) -> String {
  match self {
    Load => "load"
    Idle => "idle"
    Visible => "visible"
    Media(query) => "media:" + query
    None => "none"
  }
}

/// Parse TriggerType from string
pub fn TriggerType::parse(s : String) -> TriggerType {
  match s {
    "load" => Load
    "idle" => Idle
    "visible" => Visible
    "none" => None
    _ =>
      if s.has_prefix("media:") {
        // Extract substring after "media:" prefix
        let sb = StringBuilder::new()
        for i = 6; i < s.length(); i = i + 1 {
          sb.write_char(s.iter().nth(i).unwrap())
        }
        Media(sb.to_string())
      } else {
        Load // default
      }
  }
}
