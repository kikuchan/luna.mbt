// Astra ISR Metadata Generator
//
// Generates ISR manifest at build time.

// =============================================================================
// Manifest Generation
// =============================================================================

///|
/// Build ISR manifest from pages
pub fn build_manifest(pages : Array[@astra.PageMeta]) -> ISRManifest {
  let manifest = ISRManifest::new()
  for page in pages {
    // Only include pages with revalidate set
    match page.frontmatter.revalidate {
      Some(revalidate) =>
        if revalidate > 0 {
          let renderer = match page.renderer_type {
            @ssg.MarkdownRenderer => "markdown"
            @ssg.HtmlRenderer => "html"
            @ssg.LunaRenderer => "luna"
            @ssg.ReactRenderer => "react"
            @ssg.ClientOnlyRenderer => "client"
          }
          let entry = ISRPageEntry::{
            revalidate,
            renderer,
            source: page.source_path,
          }
          manifest.add(page.url_path, entry)
        }
      None => ()
    }
  }
  manifest
}

///|
/// Serialize manifest to JSON string
pub fn ISRManifest::to_json(self : ISRManifest) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\n")
  buf.write_string("  \"version\": \{self.version},\n")
  buf.write_string("  \"pages\": {")
  let mut first = true
  for url_path, entry in self.pages {
    if not(first) {
      buf.write_string(",")
    }
    first = false
    buf.write_string("\n    \"")
    buf.write_string(escape_json(url_path))
    buf.write_string("\": {")
    buf.write_string("\"revalidate\": \{entry.revalidate}, ")
    buf.write_string("\"renderer\": \"")
    buf.write_string(entry.renderer)
    buf.write_string("\", \"source\": \"")
    buf.write_string(escape_json(entry.source))
    buf.write_string("\"}")
  }
  if not(self.pages.is_empty()) {
    buf.write_string("\n  ")
  }
  buf.write_string("}\n}")
  buf.to_string()
}

///|
/// Escape special characters for JSON string
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
/// Write ISR manifest to file
pub fn write_manifest(manifest : ISRManifest, output_dir : String) -> Unit {
  // Only write if there are ISR pages
  if manifest.is_empty() {
    return
  }

  // Create _luna directory
  let luna_dir = @path.join2(output_dir, "_luna")
  @fs.mkdirSync(luna_dir, recursive=true) catch {
    _ => ()
  }

  // Write manifest
  let manifest_path = @path.join2(luna_dir, "isr.json")
  let json = manifest.to_json()
  @fs.writeFileSync(manifest_path, @js.any(json)) catch {
    e => println("  Warning: Failed to write isr.json: \{e}")
  }
  println("  Generated: /_luna/isr.json (\{manifest.len()} ISR pages)")
}
