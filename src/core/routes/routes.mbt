///| Routes - Core route definitions (target-independent)
///|
///| This module provides the fundamental route definition types and
///| matching logic that works across all targets (js, wasm-gc, native).

///|
/// Route定義 - コンポーネントIDを持つツリー構造
pub(all) enum Routes {
  /// サーバーコンポーネントページ
  /// - path: パス (e.g., "/", "/about")
  /// - component: コンポーネントID (resolver で解決)
  /// - title: ページタイトル
  /// - meta: メタ情報
  Page(
    path~ : String,
    component~ : String,
    title~ : String,
    meta~ : Array[(String, String)]
  )
  /// クライアントコンポーネントページ (Island)
  /// - path: パス
  /// - component: コンポーネントID
  /// - url: Hydration用スクリプトURL
  /// - trigger: Hydrationトリガー
  /// - title: ページタイトル
  /// - meta: メタ情報
  Island(
    path~ : String,
    component~ : String,
    url~ : String,
    trigger~ : @luna.IslandTrigger,
    title~ : String,
    meta~ : Array[(String, String)]
  )
  /// 動的パラメータセグメント
  /// - key: パラメータ名 (e.g., "id" for ":id")
  /// - children: 子ルート
  Param(key~ : String, children~ : Array[Routes])
  /// パスグループ (共通プレフィックス + レイアウト)
  /// - segment: パスセグメント (e.g., "/user", "/api")
  /// - children: 子ルート
  /// - layout: レイアウトコンポーネントID
  Layout(segment~ : String, children~ : Array[Routes], layout~ : String)
  /// パスグループ (レイアウトなし)
  Group(segment~ : String, children~ : Array[Routes])
  /// APIルート (GET)
  Get(path~ : String, handler~ : String)
  /// APIルート (POST)
  Post(path~ : String, handler~ : String)
}

///|
/// コンパイル済みルート (マッチング用)
pub struct CompiledRoutes {
  /// フルパスパターン
  pattern : String
  /// パラメータ名のリスト (順序付き)
  param_names : Array[String]
  /// コンポーネントID
  component : String
  /// 適用されるレイアウトID (ネストした順)
  layouts : Array[String]
  /// ルートの種類
  kind : RoutesKind
  /// タイトル
  title : String
  /// メタ情報
  meta : Array[(String, String)]
  /// Island情報 (ClientComponentの場合)
  island : IslandInfo?
}

///|
/// Island情報
pub struct IslandInfo {
  /// Hydration用スクリプトURL
  url : String
  /// Hydrationトリガー
  trigger : @luna.IslandTrigger
}

///|
/// ルートの種類
pub enum RoutesKind {
  /// サーバーコンポーネントページ
  Page
  /// クライアントコンポーネントページ (Island)
  IslandPage
  /// GET API
  GetApi
  /// POST API
  PostApi
} derive(Eq, Show)

///|
/// マッチ結果
pub struct RoutesMatch {
  route : CompiledRoutes
  params : Array[(String, String)]
  query : Array[(String, String)]
  path : String
}
