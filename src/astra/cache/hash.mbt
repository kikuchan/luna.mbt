///|
/// FNV-1a Hash Implementation for Cache Keys
///
/// Fast, simple hash with good distribution for cache keys

///|
/// FNV-1a 32-bit hash
pub fn fnv1a(data : String) -> String {
  let fnv_offset_basis : UInt = 2166136261
  let fnv_prime : UInt = 16777619
  let mut hash = fnv_offset_basis
  for c in data {
    hash = hash ^ c.to_uint()
    hash = hash * fnv_prime
  }
  uint_to_hex(hash)
}

///|
/// Convert UInt to hexadecimal string
fn uint_to_hex(n : UInt) -> String {
  let hex_chars = "0123456789abcdef"
  let chars = hex_chars.to_array()
  let buf = StringBuilder::new()

  // Process 8 hex digits (32 bits)
  for i = 7; i >= 0; i = i - 1 {
    let shift = i * 4
    let nibble = (n >> shift) & 0xF
    buf.write_char(chars[nibble.reinterpret_as_int()])
  }
  buf.to_string()
}

///|
/// Compute hash for a page's cache key
pub fn compute_page_hash(
  source_content : String,
  frontmatter_json : String,
  config_hash : String,
) -> String {
  fnv1a(source_content + "\u0000" + frontmatter_json + "\u0000" + config_hash)
}

///|
/// Compute hash for config (used to invalidate all caches on config change)
pub fn compute_config_hash(config : @astra.SsgConfig) -> String {
  // Hash key config fields that affect rendering
  let parts = [
    config.title,
    config.base_url,
    if config.trailing_slash {
      "true"
    } else {
      "false"
    },
    config.theme.primary_color.unwrap_or(""),
  ]
  fnv1a(parts.join("\u0000"))
}
