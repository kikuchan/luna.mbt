// ISR Utility Functions
//
// Cache key generation and status checking.

// =============================================================================
// Cache Key Generation
// =============================================================================

///|
/// Generate cache key from path and query params
pub fn cache_key(path : String, params : Array[(String, String)]) -> String {
  if params.is_empty() {
    path
  } else {
    let sorted = params.copy()
    sorted.sort_by(fn(a, b) { a.0.compare(b.0) })
    let query_parts : Array[String] = []
    for pair in sorted {
      query_parts.push("\{pair.0}=\{pair.1}")
    }
    let joined = query_parts.join("&")
    "\{path}?\{joined}"
  }
}

// =============================================================================
// Cache Status Checking
// =============================================================================

///|
/// Check cache status based on entry and current time
pub fn check_status(entry : CacheEntry?, now : Int64) -> CacheStatus {
  match entry {
    None => Miss
    Some(e) => {
      let age_ms = now - e.generated_at
      let ttl_ms = e.revalidate.to_int64() * 1000L
      if age_ms < ttl_ms {
        Fresh
      } else {
        Stale
      }
    }
  }
}

// =============================================================================
// Time Utilities
// =============================================================================

///|
/// Get current timestamp in milliseconds
pub fn now_ms() -> Int64 {
  ffi_now_ms()
}

///|
extern "js" fn ffi_now_ms() -> Int64 =
  #| () => BigInt(Date.now())
