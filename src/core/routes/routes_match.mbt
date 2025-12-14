///| RoutesMatch accessor methods

///|
/// コンポーネントIDを取得
pub fn RoutesMatch::component(self : RoutesMatch) -> String {
  self.route.component
}

///|
/// レイアウトIDリストを取得
pub fn RoutesMatch::layouts(self : RoutesMatch) -> Array[String] {
  self.route.layouts
}

///|
/// パラメータを取得
pub fn RoutesMatch::get_param(self : RoutesMatch, key : String) -> String? {
  for pair in self.params {
    if pair.0 == key {
      return Some(pair.1)
    }
  }
  None
}

///|
/// クエリパラメータを取得
pub fn RoutesMatch::get_query(self : RoutesMatch, key : String) -> String? {
  for pair in self.query {
    if pair.0 == key {
      return Some(pair.1)
    }
  }
  None
}

///|
/// Islandページかどうか
pub fn RoutesMatch::is_island(self : RoutesMatch) -> Bool {
  self.route.kind == IslandPage
}

///|
/// Island情報を取得
pub fn RoutesMatch::island_info(self : RoutesMatch) -> IslandInfo? {
  self.route.island
}

///|
/// ルートの種類を取得
pub fn RoutesMatch::kind(self : RoutesMatch) -> RoutesKind {
  self.route.kind
}

///|
/// タイトルを取得
pub fn RoutesMatch::title(self : RoutesMatch) -> String {
  self.route.title
}

///|
/// メタ情報を取得
pub fn RoutesMatch::meta(self : RoutesMatch) -> Array[(String, String)] {
  self.route.meta
}
