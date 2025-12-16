///| Web Components Island helpers for server_dom
///|
///| Provides integration with Web Components based client-side components.
///| Uses Declarative Shadow DOM for SSR.

///|
/// Create a Web Components island for client-side hydration
///
/// Example:
/// ```moonbit
/// wc_island(
///   name="wc-counter",
///   styles=":host { display: block; }",
///   state="{\"count\":0}",
///   children=[text("Loading...")],
/// )
/// ```
pub fn wc_island(
  name : String,
  styles? : String,
  state? : String,
  trigger? : @luna.IslandTrigger,
  children~ : Array[@luna.Node[Unit]],
) -> @luna.Node[Unit] {
  let styles_value = match styles {
    Some(s) => s
    None => ""
  }
  let state_value = match state {
    Some(s) => s
    None => "{}"
  }
  let trigger_value = match trigger {
    Some(t) => t
    None => @luna.Load
  }
  @luna.vwc_island(name, styles_value, state_value, children, trigger=trigger_value)
}

///|
/// Create a Web Components island with load trigger (hydrates immediately)
pub fn wc_island_load(
  name : String,
  styles : String,
  state : String,
  children~ : Array[@luna.Node[Unit]],
) -> @luna.Node[Unit] {
  wc_island(name, styles~, state~, trigger=@luna.Load, children~)
}

///|
/// Create a Web Components island with idle trigger (hydrates when browser is idle)
pub fn wc_island_idle(
  name : String,
  styles : String,
  state : String,
  children~ : Array[@luna.Node[Unit]],
) -> @luna.Node[Unit] {
  wc_island(name, styles~, state~, trigger=@luna.Idle, children~)
}

///|
/// Create a Web Components island with visible trigger (hydrates when visible)
pub fn wc_island_visible(
  name : String,
  styles : String,
  state : String,
  children~ : Array[@luna.Node[Unit]],
) -> @luna.Node[Unit] {
  wc_island(name, styles~, state~, trigger=@luna.Visible, children~)
}

///|
/// Create a Web Components island with media trigger
pub fn wc_island_media(
  name : String,
  styles : String,
  state : String,
  media_query : String,
  children~ : Array[@luna.Node[Unit]],
) -> @luna.Node[Unit] {
  wc_island(name, styles~, state~, trigger=@luna.Media(media_query), children~)
}
