// Astra ISR Metadata Generator
//
// Generates ISR manifest at build time.
// Uses shared types from src/core/isr/.

// =============================================================================
// Manifest Generation
// =============================================================================

///|
/// Build ISR manifest from pages
pub fn build_manifest(pages : Array[@astra.PageMeta]) -> @core_isr.ISRManifest {
  let manifest = @core_isr.ISRManifest::new()
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
          let entry : @core_isr.ISRPageEntry = { revalidate, renderer, source: page.source_path }
          manifest.add(page.url_path, entry)
        }
      None => ()
    }
  }
  manifest
}

///|
/// Write ISR manifest to file
pub fn write_manifest(manifest : @core_isr.ISRManifest, output_dir : String) -> Unit {
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
