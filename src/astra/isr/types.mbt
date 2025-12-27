// Astra ISR Metadata Types
//
// Types for ISR (Incremental Static Regeneration) metadata.
// Generated at build time and used by Sol at runtime.

// =============================================================================
// ISR Page Entry
// =============================================================================

///|
/// ISR metadata for a single page
pub(all) struct ISRPageEntry {
  /// Revalidation interval in seconds
  revalidate : Int
  /// Renderer type (markdown, html, luna, react)
  renderer : String
  /// Source file path relative to docs directory
  source : String
}

// =============================================================================
// ISR Manifest
// =============================================================================

///|
/// Complete ISR manifest containing all ISR-enabled pages
pub(all) struct ISRManifest {
  /// Manifest version
  version : Int
  /// Map of URL path to ISR entry
  pages : Map[String, ISRPageEntry]
}

///|
/// Create a new empty ISR manifest
pub fn ISRManifest::new() -> ISRManifest {
  { version: 1, pages: {} }
}

///|
/// Add a page to the manifest
pub fn ISRManifest::add(
  self : ISRManifest,
  url_path : String,
  entry : ISRPageEntry,
) -> Unit {
  self.pages[url_path] = entry
}

///|
/// Check if manifest has any ISR pages
pub fn ISRManifest::is_empty(self : ISRManifest) -> Bool {
  self.pages.is_empty()
}

///|
/// Get number of ISR pages
pub fn ISRManifest::len(self : ISRManifest) -> Int {
  self.pages.length()
}
