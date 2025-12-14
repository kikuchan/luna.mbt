///| Routes Matcher - URL pattern matching

///|
/// URLをルートにマッチング
pub fn match_url(url : String, routes : Array[CompiledRoutes]) -> RoutesMatch? {
  let (path, query) = parse_url_parts(url)
  for route in routes {
    if try_match_pattern(path, route) is Some(params) {
      return Some({ route, params, query, path })
    }
  }
  None
}

///|
fn parse_url_parts(url : String) -> (String, Array[(String, String)]) {
  let chars = url.to_array()
  let mut query_start = -1
  for i, c in chars {
    if c == '?' {
      query_start = i
      break
    }
  }
  if query_start == -1 {
    return (url, [])
  }
  let path = String::from_array(chars[0:query_start])
  let query_str = String::from_array(chars[query_start + 1:])
  let query = parse_query(query_str)
  (path, query)
}

///|
fn parse_query(query : String) -> Array[(String, String)] {
  guard query != "" else { return [] }
  let result : Array[(String, String)] = []
  for pair in split_by(query, '&') {
    let kv = split_by(pair, '=')
    if kv.length() == 2 {
      result.push((kv[0], kv[1]))
    } else if kv.length() == 1 && kv[0] != "" {
      result.push((kv[0], ""))
    }
  }
  result
}

///|
fn split_by(s : String, sep : Char) -> Array[String] {
  let result : Array[String] = []
  let chars = s.to_array()
  let current : Array[Char] = []
  for c in chars {
    if c == sep {
      result.push(String::from_array(current))
      current.clear()
    } else {
      current.push(c)
    }
  }
  result.push(String::from_array(current))
  result
}

///|
fn try_match_pattern(
  path : String,
  route : CompiledRoutes,
) -> Array[(String, String)]? {
  let pattern_segments = split_path_segments(route.pattern)
  let path_segments = split_path_segments(path)
  if pattern_segments.length() != path_segments.length() {
    return None
  }
  let params : Array[(String, String)] = []
  let mut param_idx = 0
  for i, pattern_seg in pattern_segments {
    let path_seg = path_segments[i]
    if starts_with_char(pattern_seg, ':') {
      if param_idx < route.param_names.length() {
        params.push((route.param_names[param_idx], path_seg))
        param_idx += 1
      } else {
        return None
      }
    } else if pattern_seg != path_seg {
      return None
    }
  }
  Some(params)
}

///|
fn starts_with_char(s : String, c : Char) -> Bool {
  s.has_prefix(c.to_string())
}

///|
fn split_path_segments(path : String) -> Array[String] {
  split_by(path, '/').filter(fn(s) { s != "" })
}
