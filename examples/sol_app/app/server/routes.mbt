///| Route Definitions

///|

///| This is the single source of truth for all routes.

///| Both server (SSR) and client (CSR) use these definitions.

///|

///| IMPORTANT: This is a magic file - sol generate reads this to:

///| - Generate server entry point

///| - Generate client hydration router

///| - Setup route handlers

///|
/// Application routes - defines all pages and API endpoints
pub fn routes() -> Array[@routes.Routes] {
  [
    // Home page with counter island
    @routes.Page(path="/", component="home", title="Home", meta=[]),
    // About page (static, no hydration)
    @routes.Page(path="/about", component="about", title="About", meta=[]),
    // Contact form page with contact_form island
    @routes.Page(path="/form", component="form_page", title="Contact Form", meta=[]),
    // WC Counter page - Web Components based island (Declarative Shadow DOM)
    @routes.Page(
      path="/wc-counter",
      component="wc_counter",
      title="WC Counter",
      meta=[],
    ),
    // API endpoint
    @routes.Get(path="/api/health", handler="health"),
  ]
}

///|
/// Root HTML template - customize the document structure
// Available placeholders:
// - __LUNA_TITLE__ : Page title
// - __LUNA_PRELOAD__ : Modulepreload tags
// - __LUNA_HEAD__ : Custom head HTML (styles, meta, etc.)
// - __LUNA_MAIN__ : Main content

const ROOT : String =
  #|<!DOCTYPE html>
  #|<html lang="en">
  #|<head>
  #|  <meta charset="UTF-8">
  #|  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  #|  <title>__LUNA_TITLE__</title>
  #|  __LUNA_PRELOAD__
  #|  __LUNA_HEAD__
  #|</head>
  #|<body>
  #|  <div id="__sol__">__LUNA_MAIN__</div>
  #|</body>
  #|</html>

///|
/// Router configuration
pub fn config() -> @router.RouterConfig {
  @router.RouterConfig::default()
  .with_root_template(ROOT)
  .with_default_head(head())
  .with_loader_url("/static/loader.js")
}

///|
/// API handler: health check
pub fn api_health(_props : @router.PageProps) -> @core.Any {
  @sol.json_obj([("status", @core.any("ok"))])
}
