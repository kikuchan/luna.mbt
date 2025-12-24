// Directory Scanner for Pages
//
// Scans src/pages/ directory to generate RouteManifest

// =============================================================================
// Main Scanner
// =============================================================================

///|
/// Scan pages directory and generate RouteManifest
pub fn[FS : @env.FileSystem] scan_pages_dir(
  fs : FS,
  pages_dir : String,
  cwd : String,
) -> RouteManifest {
  let full_path = join_path(cwd, pages_dir)

  // Check if directory exists
  if not(fs.exists_sync(full_path)) {
    return RouteManifest::empty()
  }

  // Scan recursively
  let routes : Array[RouteEntry] = []
  let root_config = PageConfig::default()
  scan_recursive(fs, full_path, pages_dir, "", root_config, routes)
  RouteManifest::{ routes, fallback: FallbackConfig::default() }
}

///|
/// Recursively scan directory
fn[FS : @env.FileSystem] scan_recursive(
  fs : FS,
  abs_path : String,
  pages_dir : String,
  rel_path : String,
  parent_config : PageConfig,
  routes : Array[RouteEntry],
) -> Unit {
  // Read directory entries
  let entries : Array[String] = try {
    fs.readdir_sync(abs_path)
  } catch {
    _ => []
  }

  // Load page.json if exists
  let page_json_path = join_path(abs_path, "page.json")
  let config = if fs.exists_sync(page_json_path) {
    let content : String = try {
      fs.read_file_sync(page_json_path)
    } catch {
      _ => ""
    }
    match parse_page_config(content) {
      Some(cfg) => PageConfig::merge(parent_config, cfg)
      None => parent_config
    }
  } else {
    parent_config
  }

  // Process entries
  for entry in entries {
    let entry_path = join_path(abs_path, entry)
    let entry_rel = if rel_path.is_empty() { entry } else { rel_path + "/" + entry }

    if is_directory(fs, entry_path) {
      // Check if it's a dynamic segment
      match extract_param_name(entry) {
        Some(param) => {
          // Dynamic or catch-all route
          scan_dynamic_dir(fs, entry_path, pages_dir, entry_rel, param, config, routes)
        }
        None => {
          // Regular directory
          scan_recursive(fs, entry_path, pages_dir, entry_rel, config, routes)
        }
      }
    } else {
      // Regular file
      process_page_file(fs, entry_path, pages_dir, entry_rel, entry, config, routes)
    }
  }
}

///|
/// Scan dynamic directory (_name_/ or _catchall_/)
fn[FS : @env.FileSystem] scan_dynamic_dir(
  fs : FS,
  abs_path : String,
  _pages_dir : String,
  rel_path : String,
  param_name : String,
  config : PageConfig,
  routes : Array[RouteEntry],
) -> Unit {
  let is_catch_all = param_name == "catchall"

  // Read directory entries
  let entries : Array[String] = try {
    fs.readdir_sync(abs_path)
  } catch {
    _ => []
  }

  // Look for index file
  for entry in entries {
    let file_type = FileType::from_extension(get_extension(entry))

    if file_type.is_page() && is_index_file(entry) {
      // Build dynamic route
      let url_pattern = build_dynamic_url_pattern(rel_path, param_name, is_catch_all)
      let regex_pattern = build_regex_pattern(url_pattern)

      let catch_all_info = if is_catch_all {
        Some(CatchAllInfo::{ name: param_name, optional: false })
      } else {
        None
      }

      if config.is_static() && config.generate_params {
        // Static generation with params - will be filled later
        let entry = RouteEntry::Static(
          StaticRouteEntry::{
            path: url_pattern,
            source: rel_path + "/" + entry,
            output: "", // Filled during generation
            layout: config.layout,
            title: config.title,
            description: config.description,
            islands: config.islands,
            locale: "en",
            generated_params: [], // Filled by getStaticParams
          },
        )
        routes.push(entry)
      } else {
        // Dynamic route
        let entry = RouteEntry::Dynamic(
          DynamicRouteEntry::{
            path: url_pattern,
            pattern: regex_pattern,
            param_names: [param_name],
            source: rel_path + "/" + entry,
            mode: config.to_render_mode(),
            layout: config.layout,
            catch_all: catch_all_info,
            title: config.title,
            islands: config.islands,
          },
        )
        routes.push(entry)
      }
    }
  }
}

///|
/// Process a regular page file
fn[FS : @env.FileSystem] process_page_file(
  _fs : FS,
  _abs_path : String,
  _pages_dir : String,
  rel_path : String,
  filename : String,
  config : PageConfig,
  routes : Array[RouteEntry],
) -> Unit {
  let file_type = FileType::from_extension(get_extension(filename))

  if not(file_type.is_page()) {
    return
  }

  // Skip non-index files in dynamic directories
  // (they're handled by scan_dynamic_dir)

  // Build URL path
  let url_path = file_to_url_path(rel_path)

  // Build output path
  let output_path = @ssg.url_to_output_path(url_path)

  // Check file-type specific config
  let ext = get_extension(filename)
  let effective_config = match config.handlers.get(ext) {
    Some(handler_config) => {
      // Merge handler config
      let layout = match handler_config.layout {
        Some(l) => Some(l)
        None => config.layout
      }
      let islands = if handler_config.islands.is_empty() {
        config.islands
      } else {
        handler_config.islands
      }
      PageConfig::{ ..config, layout, islands }
    }
    None => config
  }

  // Create route entry
  if effective_config.is_static() {
    let entry = RouteEntry::Static(
      StaticRouteEntry::{
        path: url_path,
        source: rel_path,
        output: output_path,
        layout: effective_config.layout,
        title: effective_config.title,
        description: effective_config.description,
        islands: effective_config.islands,
        locale: "en",
        generated_params: [],
      },
    )
    routes.push(entry)
  } else {
    let entry = RouteEntry::Dynamic(
      DynamicRouteEntry::{
        path: url_path,
        pattern: "^" + url_path + "$",
        param_names: [],
        source: rel_path,
        mode: effective_config.to_render_mode(),
        layout: effective_config.layout,
        catch_all: None,
        title: effective_config.title,
        islands: effective_config.islands,
      },
    )
    routes.push(entry)
  }
}

// =============================================================================
// Helper Functions
// =============================================================================

///|
/// Extract parameter name from directory name
/// _slug_ -> Some("slug")
/// _catchall_ -> Some("catchall")
/// regular -> None
fn extract_param_name(dir_name : String) -> String? {
  let len = dir_name.length()
  if dir_name.has_prefix("_") && dir_name.has_suffix("_") && len > 2 {
    // Extract name between underscores
    let name = @ssg.extract_substring(dir_name, 1, len - 1)
    Some(name)
  } else {
    None
  }
}

///|
/// Check if a file is an index file
fn is_index_file(filename : String) -> Bool {
  filename.has_prefix("index.")
}

///|
/// Build URL pattern for dynamic route
fn build_dynamic_url_pattern(
  rel_path : String,
  param_name : String,
  is_catch_all : Bool,
) -> String {
  // Convert _slug_/index.mbt to /:slug
  // Convert _catchall_/index.mbt to /*
  let dir_path = get_parent_path(rel_path)
  let base = if dir_path.is_empty() { "/" } else { "/" + dir_path + "/" }

  if is_catch_all {
    base + "*"
  } else {
    base + ":" + param_name
  }
}

///|
/// Build regex pattern from URL pattern
fn build_regex_pattern(url_pattern : String) -> String {
  // Simple conversion - in production would need proper escaping
  let pattern = url_pattern
    .replace_all(old="*", new="(.*)")
    .replace_all(old=":([a-zA-Z0-9_]+)", new="([^/]+)")
  "^" + pattern + "$"
}

///|
/// Convert file path to URL path
fn file_to_url_path(rel_path : String) -> String {
  // Strip numeric prefixes and convert to URL
  let url = @ssg.file_to_url_path(rel_path, trailing_slash=true)
  if url.is_empty() { "/" } else { url }
}

///|
/// Get file extension including dot
fn get_extension(filename : String) -> String {
  let dot_idx = find_last_char(filename, '.')
  if dot_idx >= 0 {
    @ssg.extract_substring(filename, dot_idx, filename.length())
  } else {
    ""
  }
}

///|
/// Get parent directory path
fn get_parent_path(path : String) -> String {
  let slash_idx = find_last_char(path, '/')
  if slash_idx >= 0 {
    @ssg.extract_substring(path, 0, slash_idx)
  } else {
    ""
  }
}

///|
/// Find last occurrence of character in string
fn find_last_char(s : String, ch : Char) -> Int {
  let mut idx = 0
  let mut last_idx = -1
  for c in s {
    if c == ch {
      last_idx = idx
    }
    idx = idx + 1
  }
  last_idx
}

///|
/// Join two path segments
fn join_path(a : String, b : String) -> String {
  if a.is_empty() {
    b
  } else if b.is_empty() {
    a
  } else if a.has_suffix("/") {
    a + b
  } else {
    a + "/" + b
  }
}

///|
/// Check if path is a directory
fn[FS : @env.FileSystem] is_directory(fs : FS, path : String) -> Bool {
  try {
    fs.is_directory_sync(path)
  } catch {
    _ => false
  }
}
