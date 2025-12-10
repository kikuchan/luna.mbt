///| E2E Test Server for MoonBit UI
///| Provides Hono app for Playwright E2E tests

///|
type Ctx = @hono.Context[Unit, Unit]

///|
type App = @hono.Hono[Unit, Unit]

///|
/// Create the main E2E test server app
/// Exports a Hono app that can be used from JavaScript
pub async fn create_app() -> App {
  let app : App = @hono.Hono::new()

  // Health check
  let _ = app.get(
    "/",
    async fn(c : Ctx) -> @http.Response { c.text("ok") },
  )

  // Mount loader test routes
  let loader_app = create_loader_app()
  let _ = app.route("/loader", loader_app)

  // Mount embedding test routes
  let embedding_app = create_embedding_app()
  let _ = app.route("/embedding", embedding_app)

  app
}

///|
/// Create loader test routes
async fn create_loader_app() -> App {
  let app : App = @hono.Hono::new()

  // Basic hydration test - trigger: load
  let _ = app.get(
    "/basic",
    async fn(c : Ctx) -> @http.Response {
      let html =
        #|<!DOCTYPE html>
        #|<html>
        #|<head>
        #|  <title>Basic Hydration Test</title>
        #|  <script type="module" src="/kg-loader-v1.js"></script>
        #|</head>
        #|<body>
        #|  <div kg:id="counter-1"
        #|       kg:url="/components/counter.js"
        #|       kg:state='{"count":5}'>
        #|    <span data-count>5</span>
        #|    <button data-inc>+1</button>
        #|    <button data-dec>-1</button>
        #|  </div>
        #|</body>
        #|</html>
      c.html(html)
    },
  )

  // Visible trigger test
  let _ = app.get(
    "/visible",
    async fn(c : Ctx) -> @http.Response {
      let html =
        #|<!DOCTYPE html>
        #|<html>
        #|<head>
        #|  <title>Visible Trigger Test</title>
        #|  <script type="module" src="/kg-loader-v1.js"></script>
        #|  <style>
        #|    .spacer { height: 150vh; background: linear-gradient(#eee, #ccc); }
        #|    .lazy-component { padding: 20px; background: #f0f0f0; }
        #|  </style>
        #|</head>
        #|<body>
        #|  <div class="spacer">Scroll down to trigger hydration</div>
        #|  <div kg:id="lazy-1"
        #|       kg:url="/components/lazy.js"
        #|       kg:trigger="visible"
        #|       kg:state='{"message":"Hello from state!"}'>
        #|    <div data-content class="lazy-component">Not hydrated yet</div>
        #|  </div>
        #|</body>
        #|</html>
      c.html(html)
    },
  )

  // Idle trigger test
  let _ = app.get(
    "/idle",
    async fn(c : Ctx) -> @http.Response {
      let html =
        #|<!DOCTYPE html>
        #|<html>
        #|<head>
        #|  <title>Idle Trigger Test</title>
        #|  <script type="module" src="/kg-loader-v1.js"></script>
        #|</head>
        #|<body>
        #|  <div kg:id="idle-1"
        #|       kg:url="/components/lazy.js"
        #|       kg:trigger="idle"
        #|       kg:state='{"message":"Loaded on idle"}'>
        #|    <div data-content>Waiting for idle...</div>
        #|  </div>
        #|</body>
        #|</html>
      c.html(html)
    },
  )

  // Script reference state test
  let _ = app.get(
    "/script-ref",
    async fn(c : Ctx) -> @http.Response {
      let html =
        #|<!DOCTYPE html>
        #|<html>
        #|<head>
        #|  <title>Script Reference State Test</title>
        #|  <script type="module" src="/kg-loader-v1.js"></script>
        #|</head>
        #|<body>
        #|  <div kg:id="counter-ref"
        #|       kg:url="/components/counter.js"
        #|       kg:state="#kg-state-counter-ref">
        #|    <span data-count>10</span>
        #|    <button data-inc>+1</button>
        #|    <button data-dec>-1</button>
        #|  </div>
        #|  <script id="kg-state-counter-ref" type="kg/json">{"count":10}</script>
        #|</body>
        #|</html>
      c.html(html)
    },
  )

  // Multiple components test
  let _ = app.get(
    "/multiple",
    async fn(c : Ctx) -> @http.Response {
      let html =
        #|<!DOCTYPE html>
        #|<html>
        #|<head>
        #|  <title>Multiple Components Test</title>
        #|  <script type="module" src="/kg-loader-v1.js"></script>
        #|</head>
        #|<body>
        #|  <div kg:id="counter-a"
        #|       kg:url="/components/counter.js"
        #|       kg:state='{"count":1}'>
        #|    <span data-count>1</span>
        #|    <button data-inc>+1</button>
        #|    <button data-dec>-1</button>
        #|  </div>
        #|
        #|  <div kg:id="counter-b"
        #|       kg:url="/components/counter.js"
        #|       kg:state='{"count":100}'>
        #|    <span data-count>100</span>
        #|    <button data-inc>+1</button>
        #|    <button data-dec>-1</button>
        #|  </div>
        #|</body>
        #|</html>
      c.html(html)
    },
  )

  // Manual trigger test
  let _ = app.get(
    "/manual",
    async fn(c : Ctx) -> @http.Response {
      let html =
        #|<!DOCTYPE html>
        #|<html>
        #|<head>
        #|  <title>Manual Trigger Test</title>
        #|  <script type="module" src="/kg-loader-v1.js"></script>
        #|</head>
        #|<body>
        #|  <div kg:id="manual-1"
        #|       kg:url="/components/lazy.js"
        #|       kg:trigger="none"
        #|       kg:state='{"message":"Manually triggered"}'>
        #|    <div data-content>Should not auto-hydrate</div>
        #|  </div>
        #|  <button id="trigger-btn" onclick="window.__KG_HYDRATE__(document.querySelector('[kg\\:id=manual-1]'))">
        #|    Trigger Hydration
        #|  </button>
        #|</body>
        #|</html>
      c.html(html)
    },
  )

  // URL state test
  let _ = app.get(
    "/url-state",
    async fn(c : Ctx) -> @http.Response {
      let html =
        #|<!DOCTYPE html>
        #|<html>
        #|<head>
        #|  <title>URL State Test</title>
        #|  <script type="module" src="/kg-loader-v1.js"></script>
        #|</head>
        #|<body>
        #|  <div kg:id="user-1"
        #|       kg:url="/components/user.js"
        #|       kg:state="url:/api/state/user">
        #|    <div data-name>Loading...</div>
        #|    <div data-email></div>
        #|  </div>
        #|</body>
        #|</html>
      c.html(html)
    },
  )

  app
}

///|
/// Create embedding test routes using MoonBit embedding module
async fn create_embedding_app() -> App {
  let app : App = @hono.Hono::new()

  // Minimal embed test
  let _ = app.get(
    "/minimal",
    async fn(c : Ctx) -> @http.Response {
      let embed_html = @embedding.generate_minimal_embed(
        "counter-1",
        "/components/counter.js",
        "{\"count\":42}",
        "<span data-count>42</span><button data-inc>+</button><button data-dec>-</button>",
      )
      let html =
        "<!DOCTYPE html>\n<html>\n<head>\n  <title>Minimal Embed Test</title>\n  <script type=\"module\" src=\"/kg-loader-v1.js\"></script>\n</head>\n<body>\n  " +
        embed_html +
        "\n</body>\n</html>"
      c.html(html)
    },
  )

  // Standalone embed test (includes loader)
  let _ = app.get(
    "/standalone",
    async fn(c : Ctx) -> @http.Response {
      let embed_html = @embedding.generate_standalone_embed(
        "greeting-1",
        "/components/greeting.js",
        "/kg-loader-v1.js",
        "{\"name\":\"World\"}",
        "<p>Hello, <span data-name>World</span>!</p>",
      )
      let html =
        "<!DOCTYPE html>\n<html>\n<head>\n  <title>Standalone Embed Test</title>\n</head>\n<body>\n  " +
        embed_html +
        "\n</body>\n</html>"
      c.html(html)
    },
  )

  // Lazy embed test (visible trigger)
  let _ = app.get(
    "/lazy",
    async fn(c : Ctx) -> @http.Response {
      let embed_html = @embedding.generate_lazy_embed(
        "lazy-counter",
        "/components/counter.js",
        "{\"count\":100}",
        "<span data-count>100</span><button data-inc>+</button><button data-dec>-</button>",
      )
      let html =
        "<!DOCTYPE html>\n<html>\n<head>\n  <title>Lazy Embed Test</title>\n  <script type=\"module\" src=\"/kg-loader-v1.js\"></script>\n  <style>\n    .spacer { height: 150vh; background: linear-gradient(#eee, #ccc); }\n  </style>\n</head>\n<body>\n  <div class=\"spacer\">Scroll down to trigger hydration</div>\n  " +
        embed_html +
        "\n</body>\n</html>"
      c.html(html)
    },
  )

  // XSS safety test
  let _ = app.get(
    "/xss-safety",
    async fn(c : Ctx) -> @http.Response {
      let dangerous_state = "{\"message\":\"<script>alert(1)</script>\",\"html\":\"</script><script>\"}"
      let embed_html = @embedding.generate_minimal_embed(
        "xss-test",
        "/components/greeting.js",
        dangerous_state,
        "<p data-name>Safe content</p>",
      )
      let html =
        "<!DOCTYPE html>\n<html>\n<head>\n  <title>XSS Safety Test</title>\n  <script type=\"module\" src=\"/kg-loader-v1.js\"></script>\n</head>\n<body>\n  " +
        embed_html +
        "\n  <script>\n    window.xssTriggered = false;\n    window.alert = () => { window.xssTriggered = true; };\n  </script>\n</body>\n</html>"
      c.html(html)
    },
  )

  // State script test
  let _ = app.get(
    "/state-script",
    async fn(c : Ctx) -> @http.Response {
      let state_script = @embedding.generate_state_script(
        "counter-state",
        "{\"count\":999}",
      )
      let html =
        "<!DOCTYPE html>\n<html>\n<head>\n  <title>State Script Test</title>\n  <script type=\"module\" src=\"/kg-loader-v1.js\"></script>\n</head>\n<body>\n  <div kg:id=\"counter-script\"\n       kg:url=\"/components/counter.js\"\n       kg:state=\"#counter-state\">\n    <span data-count>999</span>\n    <button data-inc>+</button>\n    <button data-dec>-</button>\n  </div>\n  " +
        state_script +
        "\n</body>\n</html>"
      c.html(html)
    },
  )

  app
}
