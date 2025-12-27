///|
/// Cache Manager for Disk-based Build Cache
///
/// Manages cached rendered HTML to skip unchanged pages

///|
/// Cache entry for a single page
pub(all) struct PageCacheEntry {
  source_hash : String
  cached_at : String
}

///|
/// Cache metadata
pub(all) struct CacheMeta {
  version : Int
  config_hash : String
  pages : Map[String, PageCacheEntry]
}

///|
/// Cache manager
pub(all) struct CacheManager {
  cache_dir : String
  pages_dir : String
  meta : CacheMeta
  config_hash : String
  enabled : Bool
}

///|
/// Default cache directory name
let default_cache_dir : String = ".astra-cache"

///|
/// Current cache version (increment to invalidate all caches)
let cache_version : Int = 1

///|
/// Create a new cache manager
pub fn CacheManager::new(
  cwd : String,
  config : @astra.SsgConfig,
  enabled? : Bool = true,
) -> CacheManager {
  let cache_dir = @path.join2(cwd, default_cache_dir)
  let pages_dir = @path.join2(cache_dir, "pages")
  let config_hash = compute_config_hash(config)

  // Load existing meta or create new
  let meta = if enabled {
    load_meta(cache_dir, config_hash)
  } else {
    CacheMeta::{ version: cache_version, config_hash, pages: {} }
  }
  CacheManager::{ cache_dir, pages_dir, meta, config_hash, enabled }
}

///|
/// Load cache metadata from disk
fn load_meta(cache_dir : String, current_config_hash : String) -> CacheMeta {
  let meta_path = @path.join2(cache_dir, "meta.json")

  // Try to read existing meta
  let content : String = @fs.readFileSync(meta_path).to_string() catch {
    _ =>
      return CacheMeta::{
        version: cache_version,
        config_hash: current_config_hash,
        pages: {},
      }
  }

  // Parse JSON
  let json : Json = @json.parse(content) catch {
    _ =>
      return CacheMeta::{
        version: cache_version,
        config_hash: current_config_hash,
        pages: {},
      }
  }

  // Extract fields
  let obj = match json {
    Object(o) => o
    _ =>
      return CacheMeta::{
        version: cache_version,
        config_hash: current_config_hash,
        pages: {},
      }
  }

  // Check version
  let version = match obj.get("version") {
    Some(Number(n, ..)) => n.to_int()
    _ => 0
  }
  if version != cache_version {
    return CacheMeta::{
      version: cache_version,
      config_hash: current_config_hash,
      pages: {},
    }
  }

  // Check config hash
  let stored_config_hash = match obj.get("configHash") {
    Some(String(s)) => s
    _ => ""
  }
  if stored_config_hash != current_config_hash {
    // Config changed, invalidate all
    return CacheMeta::{
      version: cache_version,
      config_hash: current_config_hash,
      pages: {},
    }
  }

  // Parse pages
  let pages : Map[String, PageCacheEntry] = {}
  match obj.get("pages") {
    Some(Object(pages_obj)) =>
      for url_path, page_json in pages_obj {
        match parse_page_entry(page_json) {
          Some(page_entry) => pages[url_path] = page_entry
          None => ()
        }
      }
    _ => ()
  }
  CacheMeta::{ version: cache_version, config_hash: current_config_hash, pages }
}

///|
fn parse_page_entry(json : Json) -> PageCacheEntry? {
  let obj = match json {
    Object(o) => o
    _ => return None
  }
  let source_hash = match obj.get("sourceHash") {
    Some(String(s)) => s
    _ => return None
  }
  let cached_at = match obj.get("cachedAt") {
    Some(String(s)) => s
    _ => ""
  }
  Some(PageCacheEntry::{ source_hash, cached_at })
}

///|
/// Get cached HTML if available and valid
pub fn CacheManager::get(
  self : CacheManager,
  url_path : String,
  source_hash : String,
) -> String? {
  if not(self.enabled) {
    return None
  }

  // Check if we have a cache entry
  let entry = match self.meta.pages.get(url_path) {
    Some(e) => e
    None => return None
  }

  // Check if hash matches
  if entry.source_hash != source_hash {
    return None
  }

  // Try to read cached HTML
  let cache_file = @path.join2(self.pages_dir, source_hash + ".html")
  let content : String = @fs.readFileSync(cache_file).to_string() catch {
    _ => return None
  }
  Some(content)
}

///|
/// Store rendered HTML in cache
pub fn CacheManager::set(
  self : CacheManager,
  url_path : String,
  source_hash : String,
  html : String,
) -> Unit {
  if not(self.enabled) {
    return
  }

  // Ensure cache directories exist
  ensure_dir(self.cache_dir)
  ensure_dir(self.pages_dir)

  // Write HTML file
  let cache_file = @path.join2(self.pages_dir, source_hash + ".html")
  @fs.writeFileSync(cache_file, @js.any(html)) catch {
    _ => return
  }

  // Update meta
  let now = get_iso_timestamp()
  self.meta.pages[url_path] = PageCacheEntry::{ source_hash, cached_at: now }
}

///|
/// Save cache metadata to disk
pub fn CacheManager::save(self : CacheManager) -> Unit {
  if not(self.enabled) {
    return
  }
  ensure_dir(self.cache_dir)

  // Build JSON
  let pages_json = StringBuilder::new()
  pages_json.write_string("{")
  let mut first = true
  for url_path, entry in self.meta.pages {
    if not(first) {
      pages_json.write_string(",")
    }
    first = false
    pages_json.write_string("\n    \"")
    pages_json.write_string(escape_json(url_path))
    pages_json.write_string("\": {\"sourceHash\": \"")
    pages_json.write_string(entry.source_hash)
    pages_json.write_string("\", \"cachedAt\": \"")
    pages_json.write_string(entry.cached_at)
    pages_json.write_string("\"}")
  }
  pages_json.write_string("\n  }")
  let json = "{\n  \"version\": \{self.meta.version},\n  \"configHash\": \"\{self.meta.config_hash}\",\n  \"pages\": " +
    pages_json.to_string() +
    "\n}\n"
  let meta_path = @path.join2(self.cache_dir, "meta.json")
  @fs.writeFileSync(meta_path, @js.any(json)) catch {
    err => println("Warning: Failed to save cache meta: \{err}")
  }
}

///|
/// Clear all cache
pub fn CacheManager::clear(self : CacheManager) -> Unit {
  // Remove cache directory
  @fs.rmSync(self.cache_dir, recursive=true, force=true) catch {
    _ => ()
  }
  self.meta.pages.clear()
}

///|
/// Get cache statistics
pub fn CacheManager::stats(self : CacheManager) -> (Int, Int) {
  // Returns (cached_count, total_count)
  (self.meta.pages.length(), 0)
}

///|
fn ensure_dir(path : String) -> Unit {
  @fs.mkdirSync(path, recursive=true) catch {
    _ => ()
  }
}

///|
fn escape_json(s : String) -> String {
  let buf = StringBuilder::new()
  for c in s {
    if c == '\\' {
      buf.write_string("\\\\")
    } else if c == '"' {
      buf.write_string("\\\"")
    } else if c == '\n' {
      buf.write_string("\\n")
    } else {
      buf.write_char(c)
    }
  }
  buf.to_string()
}

///|
extern "js" fn get_iso_timestamp() -> String =
  #| () => new Date().toISOString()
