// Astra ISR Types
//
// Types are now defined in src/core/isr/ for sharing between Astra and Sol.
// This file is kept for backwards compatibility but delegates to core types.

// Re-export core manifest with additional builder function
pub fn new_manifest() -> @core_isr.ISRManifest {
  @core_isr.ISRManifest::new()
}

pub fn new_entry(
  revalidate : Int,
  renderer : String,
  source : String,
) -> @core_isr.ISRPageEntry {
  { revalidate, renderer, source }
}
