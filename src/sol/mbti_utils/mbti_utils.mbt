///| MBTI Parser Utilities
///|
///| Extracts public function signatures from .mbti files

///|
/// Represents a public function extracted from mbti
pub(all) struct PubFunc {
  name : String
  type_name : String? // Method receiver type (e.g., "Counter" for Counter::new)
}

///|
/// Parse mbti content and extract public functions
pub fn parse_pub_funcs(content : String, filename : String) -> Array[PubFunc] raise {
  // Tokenize
  let lex_result = @lexer.tokens_from_string(name=filename, content, comment=false)
  // Filter out newlines and comments
  let tokens = lex_result.tokens.filter(fn(triple) {
    not(triple.0 is (NEWLINE | COMMENT(_)))
  })
  // Parse
  let mbti = @mbti_parser.mbti(
    tokens,
    initial_pos=@basic.Position::{ fname: filename, lnum: 1, bol: 0, cnum: 0 },
  )
  // Extract function signatures
  let funcs : Array[PubFunc] = []
  for item in mbti.sigs {
    let (sig, _loc) = item
    match sig {
      Func(func_sig) => {
        let name = func_sig.name.name
        let type_name : String? = match func_sig.type_name {
          Some(tn) => Some(tn.name)
          None => None
        }
        funcs.push({ name, type_name })
      }
      _ => ()
    }
  }
  funcs
}

///|
/// Extract only standalone functions (not methods)
pub fn get_standalone_funcs(funcs : Array[PubFunc]) -> Array[String] {
  funcs
  .filter(fn(f) { f.type_name is None })
  .map(fn(f) { f.name })
}

///|
/// Extract methods for a specific type
pub fn get_methods_for_type(
  funcs : Array[PubFunc],
  type_name : String
) -> Array[String] {
  funcs
  .filter(fn(f) {
    match f.type_name {
      Some(tn) => tn == type_name
      None => false
    }
  })
  .map(fn(f) { f.name })
}
