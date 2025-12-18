// CLI Console Utilities
//

///|
/// Log error message to console.error
pub extern "js" fn console_error(msg : String) -> Unit =
  #| (msg) => console.error(msg)
