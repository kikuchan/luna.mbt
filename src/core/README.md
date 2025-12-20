# Luna Core

Luna UIライブラリのコア機能。プラットフォーム非依存。

## モジュール構成

| サブモジュール | 責務 |
|---------------|------|
| `signal/` | リアクティブプリミティブ (Signal, Effect, Computed) |
| `render/` | VNode → HTML文字列レンダリング |
| `routes/` | 型安全ルーティング |
| `serialize/` | 状態のシリアライズ/デシリアライズ |
| `vnode.mbt` | VNode型定義 |

## VNode

仮想DOMノード。型パラメータ `E` はイベント型を表す。

```moonbit
pub enum Node[E] {
  Element(VElement[E])      // HTML要素
  Text(String)              // 静的テキスト
  DynamicText(() -> String) // 動的テキスト
  Fragment(Array[Node[E]])  // フラグメント
  Show(...)                 // 条件付きレンダリング
  For(...)                  // リストレンダリング
  Island(VIsland[E])        // Hydration境界
  WcIsland(VWcIsland[E])    // Web Components Island
  Async(VAsync[E])          // 非同期ノード
  // ...
}
```

## Signal

リアクティブな値コンテナ。

```moonbit
let count = @signal.signal(0)
count.get()        // 0
count.set(1)       // 値を設定
count.update(fn(n) { n + 1 })  // 更新関数

// 派生値
let doubled = @signal.computed(fn() { count.get() * 2 })

// 副作用
@signal.effect(fn() {
  println(count.get())
})
```

## Attr

属性値。静的/動的/イベントハンドラをサポート。

```moonbit
pub enum Attr[E] {
  VStatic(String)           // 静的値
  VDynamic(() -> String)    // Signal連動
  VHandler(EventHandler[E]) // イベントハンドラ
  VAction(String)           // 宣言的アクション
}
```

## TriggerType

Hydrationトリガー。

```moonbit
pub enum TriggerType {
  Load      // ページロード時
  Idle      // requestIdleCallback時
  Visible   // IntersectionObserver検知時
  Media(String)  // メディアクエリマッチ時
  None      // 手動トリガー
}
```

## 参照

- [Signal実装](./signal/) - リアクティブシステムの詳細
- [Routes実装](./routes/) - ルーティングの詳細
