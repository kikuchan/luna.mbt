// ISR Manifest Parsing
//
// JSON parsing for ISR manifest (used by Sol at runtime).

// =============================================================================
// JSON Parsing
// =============================================================================

///|
/// Parse ISR manifest from JSON string
pub fn ISRManifest::from_json(content : String) -> ISRManifest {
  let json : Json = @json.parse(content) catch {
    _ => return ISRManifest::empty()
  }
  let obj = match json {
    Object(o) => o
    _ => return ISRManifest::empty()
  }
  let version = match obj.get("version") {
    Some(Number(n, ..)) => n.to_int()
    _ => 1
  }
  let pages : Map[String, ISRPageEntry] = {}
  match obj.get("pages") {
    Some(Object(pages_obj)) =>
      for path, page_json in pages_obj {
        match parse_page_entry(page_json) {
          Some(entry) => pages[path] = entry
          None => ()
        }
      }
    _ => ()
  }
  { version, pages }
}

///|
/// Parse a single page entry from JSON
fn parse_page_entry(json : Json) -> ISRPageEntry? {
  let obj = match json {
    Object(o) => o
    _ => return None
  }
  let revalidate = match obj.get("revalidate") {
    Some(Number(n, ..)) => n.to_int()
    _ => return None
  }
  let renderer = match obj.get("renderer") {
    Some(String(s)) => s
    _ => "markdown"
  }
  let source = match obj.get("source") {
    Some(String(s)) => s
    _ => ""
  }
  Some({ revalidate, renderer, source })
}
