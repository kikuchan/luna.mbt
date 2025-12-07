# MoonBit UI Library

純粋なMoonBitで実装された、React風のVirtual DOMライブラリです。

## 機能

- ✅ **Virtual DOM** - 効率的なDOM更新
- ✅ **Hooks API** - `useState`, `useEffect`, `useMemo`, `useCallback`, `useRef`
- ✅ **Component System** - 関数コンポーネントとHooksサポート
- ✅ **SSR (Server-Side Rendering)** - HTML文字列生成
- ✅ **Hydration** - SSRコンテンツのクライアント側復元
- ✅ **State Serialization** - Qwik風の状態シリアライズ（JS特化）
- ✅ **Type-safe Props** - 型安全なプロパティ

## インストール

```bash
# moon.mod.jsonに依存関係を追加
{
  "deps": {
    "mizchi/ui": "0.1.0",
    "mizchi/js": "0.8.5"
  }
}
```

## 対応ターゲット

**JavaScript (Browser) のみ**

このライブラリはブラウザDOM専用です。

## テスト実行

```bash
moon test --target js --package mizchi/ui
```

## 使用例

### 基本的なコンポーネント

```moonbit
// カウンターコンポーネント
fn Counter() -> JSVNode {
  let (count, set_count) = use_state(0)

  div(
    [class_name("counter")],
    [
      text("Count: " + count.to_string()),
      button(
        [on_click(fn(_) { set_count(count + 1) })],
        [text("Increment")]
      )
    ]
  )
}

// レンダリング
let hooks_state = HooksState::new()
let vnode = component(Counter, None, hooks_state)
let rendered = render_component(vnode)

let renderer = DomRenderer::new(container_element)
renderer.render(rendered)
```

## ドキュメント

詳細なドキュメントは [src/ui/](./src/ui/) を参照してください：

- [RESUMABLE_STATE.md](./src/ui/RESUMABLE_STATE.md) - 状態シリアライズの使い方
- [BACKEND_DEPENDENCY_ANALYSIS.md](./src/ui/BACKEND_DEPENDENCY_ANALYSIS.md) - バックエンド依存性分析
- [TARGET_SUPPORT.md](./src/ui/TARGET_SUPPORT.md) - ターゲットサポート情報
- [ARCHITECTURE.md](./src/ui/ARCHITECTURE.md) - アーキテクチャ設計

## ライセンス

MIT
