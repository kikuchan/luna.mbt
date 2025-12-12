# Luna Architecture

## src/ 構造

```
src/
├── core/                      # ターゲット非依存
│   ├── signal/                # Signalプリミティブ
│   ├── vnode.mbt              # VNode定義
│   └── serialize/             # 状態シリアライズ
│
├── renderer/                  # VNode → 文字列 (純粋、DOM非依存)
│   ├── render_to_string.mbt   # HTML文字列生成
│   ├── stream_render.mbt      # ストリーミング対応
│   └── shard/                 # Island埋め込み
│
├── platform/                  # プラットフォーム固有
│   └── dom/                   # ブラウザ DOM API
│       ├── element/           # 低レベルDOM操作 (render, diff, reconcile)
│       ├── hydrate.mbt        # Hydration
│       ├── island.mbt         # Island hydration
│       └── repair/            # 実験的Hydration
│
├── router/                    # ルーティング
│
├── sol/                       # SSRフレームワーク (将来分離候補)
│
├── lib/                       # 公開API
│   └── api_js/
│
├── examples/
└── tests/
```

## モジュール責務

| モジュール | 責務 | DOM依存 | 実行環境 |
|-----------|------|---------|----------|
| `core/` | Signal, VNode, serialize | なし | どこでも |
| `renderer/` | VNode → HTML文字列 | なし | どこでも |
| `platform/dom/` | VNode → 実DOM | あり | ブラウザ |
| `platform/dom/element/` | 低レベルDOM操作 | あり | ブラウザ |
| `router/` | ルーティング定義 | なし | どこでも |
| `sol/` | Honoベースのフレームワーク | renderer利用 | サーバー |

## 依存関係

```
core/signal  ←  core/  ←  renderer/
                  ↑           ↑
         platform/dom/element renderer/shard/
                  ↑
            platform/dom/
                  ↑
            platform/dom/repair/

                  ↓
                sol/  (renderer, shard を利用)
```

## 将来の拡張

```
platform/
├── dom/           # ブラウザ
├── server_dom/    # jsdom/happy-dom (未実装)
├── terminal/      # Terminal UI (将来)
└── canvas/        # Canvas 2D (将来)
```
