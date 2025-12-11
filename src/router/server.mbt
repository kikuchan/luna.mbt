///| Server-Side Router - SSR用ルーター

///|
/// サーバーサイドルーター
/// コンパイル済みルートを保持し、URLマッチングを行う
pub struct ServerRouter {
  routes : Array[CompiledRoute]
}

///|
/// ServerRouter を作成
pub fn ServerRouter::new(routes : Array[Route]) -> ServerRouter {
  { routes: compile_routes(routes) }
}

///|
/// コンパイル済みルートから ServerRouter を作成
pub fn ServerRouter::from_compiled(routes : Array[CompiledRoute]) -> ServerRouter {
  { routes, }
}

///|
/// URLに対してルートをマッチング
pub fn ServerRouter::match_url(
  self : ServerRouter,
  url : String
) -> MatchResult? {
  match_route(url, self.routes, false)
}

///|
/// URLに対してルートをマッチングし、RouterContext を返す
pub fn ServerRouter::resolve(
  self : ServerRouter,
  url : String
) -> RouterContext? {
  match self.match_url(url) {
    Some(m) => Some(RouterContext::from_match(m))
    None => None
  }
}

///|
/// コンパイル済みルート一覧を取得
pub fn ServerRouter::get_routes(self : ServerRouter) -> Array[CompiledRoute] {
  self.routes
}

///|
/// ルート数を取得
pub fn ServerRouter::length(self : ServerRouter) -> Int {
  self.routes.length()
}
