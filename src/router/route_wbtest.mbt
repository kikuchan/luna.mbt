///| Tests for Route compilation

test "compile simple page routes" {
  let routes : Array[Route] = [
    Page(path="/", title="Home", meta=[]),
    Page(path="/about", title="About", meta=[]),
  ]
  let compiled = compile_routes(routes)
  assert_eq!(compiled.length(), 2)
  assert_eq!(compiled[0].pattern, "/")
  assert_eq!(compiled[0].title, "Home")
  assert_eq!(compiled[1].pattern, "/about")
  assert_eq!(compiled[1].title, "About")
}

test "compile nested path routes" {
  let routes : Array[Route] = [
    Path("/api", [
      Get(path="/posts", title="", meta=[]),
      Post(path="/posts", title="", meta=[]),
    ], title="", meta=[]),
  ]
  let compiled = compile_routes(routes)
  assert_eq!(compiled.length(), 2)
  assert_eq!(compiled[0].pattern, "/api/posts")
  assert_eq!(compiled[0].kind, GetApi)
  assert_eq!(compiled[1].pattern, "/api/posts")
  assert_eq!(compiled[1].kind, PostApi)
}

test "compile param routes" {
  let routes : Array[Route] = [
    Path("/posts", [
      Param("id", key="id", title="", meta=[]),
      Page(path="", title="Post Detail", meta=[]),
    ], title="", meta=[]),
  ]
  let compiled = compile_routes(routes)
  assert_eq!(compiled.length(), 1)
  // パターンには :id プレースホルダーが含まれる
  assert_eq!(compiled[0].pattern, "/posts/:id")
  assert_eq!(compiled[0].param_names, ["id"])
  assert_eq!(compiled[0].title, "Post Detail")
}

test "compile deeply nested routes" {
  let routes : Array[Route] = [
    Path("/api", [
      Path("/v1", [
        Path("/users", [
          Param("user_id", key="user_id", title="", meta=[]),
          Get(path="", title="", meta=[]),
          Path("/posts", [
            Param("post_id", key="post_id", title="", meta=[]),
            Get(path="", title="", meta=[]),
          ], title="", meta=[]),
        ], title="", meta=[]),
      ], title="", meta=[]),
    ], title="", meta=[]),
  ]
  let compiled = compile_routes(routes)
  assert_eq!(compiled.length(), 2)
  // パターンには :param プレースホルダーが含まれる
  assert_eq!(compiled[0].pattern, "/api/v1/users/:user_id")
  assert_eq!(compiled[0].param_names, ["user_id"])
  assert_eq!(compiled[1].pattern, "/api/v1/users/:user_id/posts/:post_id")
  assert_eq!(compiled[1].param_names, ["user_id", "post_id"])
}

test "normalize_path removes duplicate slashes" {
  assert_eq!(normalize_path("//"), "/")
  assert_eq!(normalize_path("/api//posts"), "/api/posts")
  assert_eq!(normalize_path("/a///b"), "/a/b")
}

test "normalize_path removes trailing slash" {
  assert_eq!(normalize_path("/about/"), "/about")
  assert_eq!(normalize_path("/api/posts/"), "/api/posts")
}

test "normalize_path keeps root" {
  assert_eq!(normalize_path("/"), "/")
  assert_eq!(normalize_path(""), "/")
}

test "RouteProps::get_param" {
  let props : RouteProps = {
    is_client: false,
    params: [("id", "123"), ("slug", "hello")],
    query: [],
    path: "/posts/123",
  }
  assert_eq!(props.get_param("id"), Some("123"))
  assert_eq!(props.get_param("slug"), Some("hello"))
  assert_eq!(props.get_param("unknown"), None)
}

test "RouteProps::get_query" {
  let props : RouteProps = {
    is_client: false,
    params: [],
    query: [("page", "2"), ("sort", "asc")],
    path: "/posts",
  }
  assert_eq!(props.get_query("page"), Some("2"))
  assert_eq!(props.get_query("sort"), Some("asc"))
  assert_eq!(props.get_query("unknown"), None)
}

// =============================================================================
// URL Matching Tests
// =============================================================================

test "parse_url without query" {
  let (path, query) = parse_url("/posts/123")
  assert_eq!(path, "/posts/123")
  assert_eq!(query.length(), 0)
}

test "parse_url with query" {
  let (path, query) = parse_url("/posts?page=1&sort=asc")
  assert_eq!(path, "/posts")
  assert_eq!(query.length(), 2)
  assert_eq!(query[0], ("page", "1"))
  assert_eq!(query[1], ("sort", "asc"))
}

test "split_string" {
  let parts = split_string("a/b/c", '/')
  assert_eq!(parts, ["a", "b", "c"])

  let empty = split_string("", '/')
  assert_eq!(empty, [""])

  let single = split_string("abc", '/')
  assert_eq!(single, ["abc"])
}

test "split_path" {
  let segments = split_path("/api/posts/123")
  assert_eq!(segments, ["api", "posts", "123"])

  let root = split_path("/")
  assert_eq!(root.length(), 0)
}

test "match_route static path" {
  let routes : Array[Route] = [
    Page(path="/", title="Home", meta=[]),
    Page(path="/about", title="About", meta=[]),
  ]
  let compiled = compile_routes(routes)

  let result = match_route("/", compiled, false)
  assert_true!(result.is_some())
  assert_eq!(result.unwrap().route.title, "Home")

  let result2 = match_route("/about", compiled, false)
  assert_true!(result2.is_some())
  assert_eq!(result2.unwrap().route.title, "About")

  let result3 = match_route("/unknown", compiled, false)
  assert_true!(result3.is_none())
}

test "match_route with params" {
  let routes : Array[Route] = [
    Path("/posts", [
      Param("id", key="id", title="", meta=[]),
      Page(path="", title="Post", meta=[]),
    ], title="", meta=[]),
  ]
  let compiled = compile_routes(routes)

  let result = match_route("/posts/123", compiled, false)
  assert_true!(result.is_some())
  let m = result.unwrap()
  assert_eq!(m.route.title, "Post")
  assert_eq!(m.props.get_param("id"), Some("123"))
}

test "match_route with query string" {
  let routes : Array[Route] = [
    Page(path="/search", title="Search", meta=[]),
  ]
  let compiled = compile_routes(routes)

  let result = match_route("/search?q=hello&page=2", compiled, false)
  assert_true!(result.is_some())
  let m = result.unwrap()
  assert_eq!(m.props.path, "/search")
  assert_eq!(m.props.get_query("q"), Some("hello"))
  assert_eq!(m.props.get_query("page"), Some("2"))
}

test "match_route is_client flag" {
  let routes : Array[Route] = [
    Page(path="/", title="Home", meta=[]),
  ]
  let compiled = compile_routes(routes)

  let server = match_route("/", compiled, false)
  assert_eq!(server.unwrap().props.is_client, false)

  let client = match_route("/", compiled, true)
  assert_eq!(client.unwrap().props.is_client, true)
}

test "match_route deeply nested with params" {
  let routes : Array[Route] = [
    Path("/api", [
      Path("/v1", [
        Path("/users", [
          Param("user_id", key="user_id", title="", meta=[]),
          Path("/posts", [
            Param("post_id", key="post_id", title="", meta=[]),
            Get(path="", title="Get Post", meta=[]),
          ], title="", meta=[]),
        ], title="", meta=[]),
      ], title="", meta=[]),
    ], title="", meta=[]),
  ]
  let compiled = compile_routes(routes)

  // パターンには :param プレースホルダーが含まれる
  assert_eq!(compiled.length(), 1)
  assert_eq!(compiled[0].pattern, "/api/v1/users/:user_id/posts/:post_id")
  assert_eq!(compiled[0].param_names, ["user_id", "post_id"])

  // URLマッチング
  let result = match_route("/api/v1/users/123/posts/456", compiled, false)
  assert_true!(result.is_some())
  let m = result.unwrap()
  assert_eq!(m.route.title, "Get Post")
  assert_eq!(m.props.get_param("user_id"), Some("123"))
  assert_eq!(m.props.get_param("post_id"), Some("456"))
}

// =============================================================================
// ServerRouter Tests
// =============================================================================

test "ServerRouter basic" {
  let routes : Array[Route] = [
    Page(path="/", title="Home", meta=[]),
    Page(path="/about", title="About", meta=[]),
    Path("/posts", [
      Param("id", key="id", title="", meta=[]),
      Page(path="", title="Post Detail", meta=[]),
    ], title="", meta=[]),
  ]
  let router = ServerRouter::new(routes)

  // ルート数
  assert_eq!(router.length(), 3)

  // マッチング
  let home = router.match_url("/")
  assert_true!(home.is_some())
  assert_eq!(home.unwrap().route.title, "Home")

  let about = router.match_url("/about")
  assert_true!(about.is_some())
  assert_eq!(about.unwrap().route.title, "About")

  // 404
  let not_found = router.match_url("/not-exist")
  assert_true!(not_found.is_none())
}

test "ServerRouter resolve returns RouterContext" {
  let routes : Array[Route] = [
    Page(path="/", title="Home", meta=[("description", "Home page")]),
    Path("/posts", [
      Param("id", key="id", title="", meta=[]),
      Page(path="", title="Post", meta=[]),
    ], title="", meta=[]),
  ]
  let router = ServerRouter::new(routes)

  // Home
  let ctx = router.resolve("/")
  assert_true!(ctx.is_some())
  let home_ctx = ctx.unwrap()
  assert_eq!(home_ctx.path, "/")
  assert_eq!(home_ctx.route_meta.title, "Home")
  assert_eq!(home_ctx.kind, Page)

  // Post with param
  let post_ctx = router.resolve("/posts/123")
  assert_true!(post_ctx.is_some())
  let p = post_ctx.unwrap()
  assert_eq!(p.path, "/posts/123")
  assert_eq!(p.get_param("id"), Some("123"))

  // 404
  let not_found = router.resolve("/not-exist")
  assert_true!(not_found.is_none())
}

test "ServerRouter with query params" {
  let routes : Array[Route] = [
    Page(path="/search", title="Search", meta=[]),
  ]
  let router = ServerRouter::new(routes)

  let ctx = router.resolve("/search?q=hello&page=2")
  assert_true!(ctx.is_some())
  let c = ctx.unwrap()
  assert_eq!(c.path, "/search")
  assert_eq!(c.get_query("q"), Some("hello"))
  assert_eq!(c.get_query("page"), Some("2"))
}

test "RouterContext::not_found" {
  let ctx = RouterContext::not_found("/some/path")
  assert_eq!(ctx.path, "/some/path")
  assert_eq!(ctx.route_meta.title, "Not Found")
  assert_eq!(ctx.params.length(), 0)
}
