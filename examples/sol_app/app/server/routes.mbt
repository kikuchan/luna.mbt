///| Route Definitions using SolRoutes

///|

///| This is the single source of truth for all routes.

///| Uses typed handlers instead of string-based component IDs.

///|
/// Application routes - defines all pages and API endpoints
pub fn routes() -> Array[@router.SolRoutes] {
  [
    // Home page with counter island
    @router.SolRoutes::Page(
      path="/",
      handler=@router.PageHandler(home),
      title="Home",
      meta=[],
    ),
    // About page (static, no hydration)
    @router.SolRoutes::Page(
      path="/about",
      handler=@router.PageHandler(about),
      title="About",
      meta=[],
    ),
    // Contact form page with contact_form island
    @router.SolRoutes::Page(
      path="/form",
      handler=@router.PageHandler(form_page),
      title="Contact Form",
      meta=[],
    ),
    // WC Counter page - Web Components based island
    @router.SolRoutes::Page(
      path="/wc-counter",
      handler=@router.PageHandler(wc_counter),
      title="WC Counter",
      meta=[],
    ),
    // WC Multiple page - multiple instances of same component
    @router.SolRoutes::Page(
      path="/wc-multiple",
      handler=@router.PageHandler(wc_multiple),
      title="WC Multiple",
      meta=[],
    ),
    // API endpoint
    @router.SolRoutes::Get(
      path="/api/health",
      handler=@router.ApiHandler(api_health),
    ),
  ]
}

///|
/// API handler: health check
async fn api_health(_props : @router.PageProps) -> @core.Any {
  @sol.json_obj([("status", @core.any("ok"))])
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
