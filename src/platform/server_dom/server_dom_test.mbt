///|
/// Tests for server_dom module
test "render simple div" {
  let node = div(children=[text("Hello")])
  let html = render(node)
  assert_eq(html, "<div>Hello</div>")
}

///|
test "render div with attributes" {
  let node = div(id="main", class="container", children=[text("Content")])
  let html = render(node)
  assert_true(html.contains("id=\"main\""))
  assert_true(html.contains("class=\"container\""))
  assert_true(html.contains("Content"))
}

///|
test "render nested elements" {
  let node = div(children=[
    h1(children=[text("Title")]),
    p(children=[text("Paragraph")]),
  ])
  let html = render(node)
  assert_true(html.contains("<h1>Title</h1>"))
  assert_true(html.contains("<p>Paragraph</p>"))
}

///|
test "render html document structure" {
  let node = html(lang="en", children=[
    head(children=[title("My Page")]),
    body(children=[h1(children=[text("Hello")])]),
  ])
  let html_str = render(node)
  assert_true(html_str.contains("<html lang=\"en\">"))
  assert_true(html_str.contains("<title>My Page</title>"))
  assert_true(html_str.contains("<h1>Hello</h1>"))
}

///|
test "render document helper" {
  let node = document(
    lang="ja",
    head_children=[title("Test"), meta(charset="UTF-8")],
    body_children=[p(children=[text("Hello World")])],
  )
  let html = render_document(node)
  assert_true(html.has_prefix("<!DOCTYPE html>"))
  assert_true(html.contains("<html lang=\"ja\">"))
  assert_true(html.contains("<meta charset=\"UTF-8\" />"))
}

///|
test "render void elements" {
  let node = div(children=[img(src="/image.png", alt="test"), br(), hr()])
  let html = render(node)
  assert_true(html.contains("<img"))
  assert_true(html.contains("src=\"/image.png\""))
  assert_true(html.contains("<br />"))
  assert_true(html.contains("<hr />"))
}

///|
test "render list elements" {
  let node = ul(children=[
    li(children=[text("Item 1")]),
    li(children=[text("Item 2")]),
  ])
  let html = render(node)
  assert_true(html.contains("<ul>"))
  assert_true(html.contains("<li>Item 1</li>"))
  assert_true(html.contains("<li>Item 2</li>"))
}

///|
test "render anchor with href" {
  let node = a(href="https://example.com", target="_blank", children=[
    text("Link"),
  ])
  let html = render(node)
  assert_true(html.contains("href=\"https://example.com\""))
  assert_true(html.contains("target=\"_blank\""))
}

///|
test "render script element" {
  let node = script(src="/app.js", type_="module", defer_=true)
  let html = render(node)
  assert_true(html.contains("src=\"/app.js\""))
  assert_true(html.contains("type=\"module\""))
  assert_true(html.contains("defer"))
}

///|
test "render style element" {
  let node = style_("body { margin: 0; }")
  let html = render(node)
  assert_true(html.contains("<style>body { margin: 0; }</style>"))
}

///|
test "render island" {
  let node = island(
    "counter",
    "/components/counter.js",
    state="{\"count\":0}",
    children=[text("Loading...")],
  )
  let html = render(node)
  assert_true(html.contains("ln:id=\"counter\""))
  assert_true(html.contains("ln:url=\"/components/counter.js\""))
  assert_true(html.contains("Loading..."))
}

///|
test "render island with visible trigger" {
  let node = island_visible("lazy", "/components/lazy.js", "{}", children=[
    text("Lazy content"),
  ])
  let html = render(node)
  assert_true(html.contains("ln:trigger=\"visible\""))
}

///|
test "render_with_preloads collects island URLs" {
  let node = div(children=[
    island("a", "/a.js", children=[text("A")]),
    island("b", "/b.js", children=[text("B")]),
  ])
  let result = render_with_preloads(node)
  assert_eq(result.preload_urls.length(), 2)
  assert_true(result.preload_urls.contains("/a.js"))
  assert_true(result.preload_urls.contains("/b.js"))
}

///|
test "render fragment" {
  let node = fragment([text("A"), text("B"), text("C")])
  let html = render(node)
  assert_eq(html, "ABC")
}

///|
test "render semantic elements" {
  let node = main_(children=[
    header_(children=[nav(children=[text("Nav")])]),
    section(children=[article(children=[text("Content")])]),
    footer_(children=[text("Footer")]),
  ])
  let html = render(node)
  assert_true(html.contains("<main>"))
  assert_true(html.contains("<header>"))
  assert_true(html.contains("<nav>"))
  assert_true(html.contains("<section>"))
  assert_true(html.contains("<article>"))
  assert_true(html.contains("<footer>"))
}

///|
test "html escaping in text" {
  let node = p(children=[text("<script>alert('xss')</script>")])
  let html = render(node)
  assert_true(html.contains("&lt;script&gt;"))
  assert_false(html.contains("<script>alert"))
}
