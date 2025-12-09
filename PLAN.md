# Signal-based Fine-Grained Reactivity 実装計画

## 概要

SolidJS/Preact Signalsを参考に、Fine-Grained Reactivity を実現する Signal ベースの UI ライブラリを `src/signals` に新規作成する。既存の `src/ui`（Virtual DOM版）とは独立して動作する。

## 設計方針

### Virtual DOM vs Fine-Grained Reactivity

| 特徴 | Virtual DOM (既存) | Fine-Grained (新規) |
|------|-------------------|---------------------|
| 更新単位 | コンポーネント全体を再レンダリング | 変更されたバインディングのみ |
| 差分計算 | diff/patch アルゴリズム | 不要（直接DOM更新） |
| メモリ | VNode ツリーを保持 | Signal グラフのみ |
| パフォーマンス | O(tree size) | O(changed nodes) |

### コアプリミティブ

```
Signal[T]  ─────► Effect
    │              │
    └──► Memo ─────┘
```

1. **Signal[T]**: リアクティブな値のコンテナ
2. **Effect**: Signal変更時に自動実行される副作用
3. **Memo**: 依存Signalから計算される派生値（キャッシュ付き）

## パッケージ構造

```
src/
├── signals/           # 新規: Signal版UIライブラリ
│   ├── signal.mbt     # Signal[T] コア実装
│   ├── effect.mbt     # Effect 実装
│   ├── memo.mbt       # Memo 実装
│   ├── context.mbt    # リアクティブコンテキスト（依存追跡）
│   ├── render.mbt     # DOM レンダリング（Signal → DOM バインディング）
│   ├── elements.mbt   # HTML要素作成ヘルパー
│   └── moon.pkg.json
└── ui/                # 既存: Virtual DOM版（変更なし）
```

## 実装計画

### Phase 1: Signal コア実装

#### 1.1 Signal[T] 型
```moonbit
pub struct Signal[T] {
  mut value : T
  subscribers : Array[() -> Unit]
}

pub fn Signal::new[T](initial : T) -> Signal[T]
pub fn Signal::get[T](self : Signal[T]) -> T        // 読み取り（依存追跡）
pub fn Signal::set[T](self : Signal[T], value : T)  // 書き込み（購読者に通知）
pub fn Signal::update[T](self : Signal[T], f : (T) -> T)
```

#### 1.2 Effect 実装
```moonbit
pub fn effect(fn : () -> Unit) -> () -> Unit  // cleanup関数を返す

// 内部: 実行中のEffectを追跡して自動購読
```

#### 1.3 Memo 実装
```moonbit
pub fn memo[T](compute : () -> T) -> () -> T  // getter関数を返す
```

#### 1.4 ReactiveContext（グローバル状態）
```moonbit
// 現在実行中のEffect/Memoを追跡
// Signal読み取り時に自動でサブスクライブ
```

### Phase 2: DOM バインディング

#### 2.1 基本的なDOM作成
```moonbit
// Signal値をDOMにバインド
pub fn text_node(content : () -> String) -> @dom.Text
pub fn create_element(
  tag : String,
  props : Array[(String, () -> String)],  // リアクティブな属性
  children : Array[@dom.Node]
) -> @dom.Element
```

#### 2.2 HTML要素ヘルパー
```moonbit
pub fn div(props : SignalProps, children : Array[@dom.Node]) -> @dom.Element
pub fn span(props : SignalProps, children : Array[@dom.Node]) -> @dom.Element
// ...
```

#### 2.3 条件付きレンダリング
```moonbit
pub fn show[T](
  when : () -> Bool,
  render : () -> @dom.Node
) -> @dom.Node
```

#### 2.4 リストレンダリング
```moonbit
pub fn for_each[T](
  items : () -> Array[T],
  render : (T, Int) -> @dom.Node
) -> @dom.Node
```

### Phase 3: ベンチマーク

#### 3.1 共通シナリオの実装
1. **カウンター**: 単純なSignal更新
2. **リスト操作**: 1000件のアイテム追加/削除/更新
3. **深いツリー更新**: ネストしたコンポーネントの部分更新
4. **大量のSignal**: 多数のSignal同時更新

#### 3.2 比較項目
- 初期レンダリング時間
- 更新時間（単一要素、複数要素）
- メモリ使用量
- GC発生頻度

## 使用例（完成イメージ）

```moonbit
fn counter_app() -> @dom.Element {
  let count = Signal::new(0)

  div([], [
    h1([], [text(fn() { "Count: " + count.get().to_string() })]),
    button(
      [on_click(fn(_) { count.update(fn(n) { n + 1 }) })],
      [text(fn() { "Increment" })]
    ),
  ])
}

fn main {
  let app = counter_app()
  let container = @dom.document().get_element_by_id("app").unwrap()
  container.append_child(app)
}
```

## 既存コードからの共通化（検討事項）

現時点では共通化せず、独立して実装する。理由：
- VNode型がHooksStateに依存しており、分離が複雑
- Signal版はVNodeを使用しない（直接DOM操作）
- 将来的に安定したら共通部分を抽出

## 次のステップ

1. [ ] `src/signals/moon.pkg.json` 作成
2. [ ] `src/signals/context.mbt` - ReactiveContext実装
3. [ ] `src/signals/signal.mbt` - Signal[T]実装
4. [ ] `src/signals/effect.mbt` - Effect実装
5. [ ] `src/signals/memo.mbt` - Memo実装
6. [ ] `src/signals/render.mbt` - DOM バインディング
7. [ ] `src/signals/elements.mbt` - HTML要素ヘルパー
8. [ ] テスト作成
9. [ ] ベンチマーク作成・比較
