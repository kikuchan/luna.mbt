///| Unit tests for sol/router pure functions

// =============================================================================
// RouteParams Tests
// =============================================================================

test "RouteParams::empty: creates empty params" {
  let params = RouteParams::empty()
  assert_eq!(params.params.length(), 0)
  assert_eq!(params.query.length(), 0)
  assert_eq!(params.path, "")
}

test "RouteParams::get_param: empty params returns None" {
  let params = RouteParams::empty()
  assert_eq!(params.get_param("any"), None)
}

test "RouteParams::get_query: empty params returns None" {
  let params = RouteParams::empty()
  assert_eq!(params.get_query("any"), None)
}
