# Unified Progressive Architecture - 完了

完了日: 2024-12

設計ドキュメント: `docs/internal/unified-progressive-arch.md`

## Phase 1: 型定義

| タスク | ファイル |
|--------|----------|
| RouteManifest 拡張 | `src/core/routes/manifest.mbt` |
| ComponentRouteEntry 追加 | `src/core/routes/manifest.mbt` |
| ComponentType enum 追加 | `src/core/routes/manifest.mbt` |
| StaticPathEntry 追加 | `src/core/routes/manifest.mbt` |
| PageConfig.staticParams | `src/core/routes/page_config.mbt` |
| PageConfig.component | `src/core/routes/page_config.mbt` |
| ComponentConfig 型 | `src/core/routes/page_config.mbt` |
| LunaConfig 型 | `src/core/config/config.mbt` |
| E2E ハイドレーションテスト | `e2e/sol-app/navigation-hydration.test.ts` (10件) |

## Phase 2: ディレクトリスキャナー

`moon.pkg.json` ディレクトリを検出し、ComponentRoute を生成する。

| タスク | ファイル |
|--------|----------|
| moon.pkg.json 検出 | `src/core/routes/scanner.mbt` |
| client/server 構造判定 | `src/core/routes/scanner.mbt` |
| ComponentType 決定ロジック | `src/core/routes/scanner.mbt` |
| staticParams → StaticPathEntry 変換 | `src/core/routes/scanner.mbt` |
| page.json 継承マージ | `src/core/routes/merge.mbt` |
| スキャナーテスト | `src/core/routes/scanner_test.mbt` (9件) |

**スキャナーのルール:**
```
counter/                      # moon.pkg.json ディレクトリ
├── moon.pkg.json            # ← これがあればコンポーネント
├── page.json                # ページ設定 (mode, staticParams)
├── client/                  # ← あれば Hydration
└── server/                  # ← あれば SSR
```

| 構造 | ComponentType | 動作 |
|------|--------------|------|
| `client/` + `server/` | SsrComponent | SSR + Hydration |
| `client/` のみ | ClientOnlyComponent | Hydration のみ |
| `server/` のみ | ServerOnlyComponent | SSR のみ |

## Phase 3: クライアントランタイム

| タスク | ファイル |
|--------|----------|
| boot/loader.ts (チャンクローダー) | `js/loader/src/boot/loader.ts` |
| boot/router.ts (最小ルーター) | `js/loader/src/boot/router.ts` |
| boot/index.ts (エントリ) | `js/loader/src/boot/index.ts` |
| ChunkManifest 型 | `src/core/routes/client_manifest.mbt` |
| manifest.json 生成 | `src/astra/generator/static_render.mbt` |

**実装済み機能:**
- `ChunkLoader`: manifest.json ベースのチャンクロード
- `MinimalRouter`: リンクインターセプト、prefetch、History API
- `ChunkManifest`: RouteManifest → クライアント向けマニフェスト変換
- ビルド時に `_luna/manifest.json` を自動生成

## Phase 4: ビルドパイプライン

| タスク | ファイル |
|--------|----------|
| Rolldown boot エントリ | `rolldown.config.mjs` |
| boot ランタイムコピー | `src/astra/generator/static_render.mbt` |
| manifest.json 生成 | `src/astra/generator/static_render.mbt` |

## Phase 5: SSR コンポーネント (Astra側)

| タスク | ファイル |
|--------|----------|
| Component ContentType 追加 | `src/astra/types.mbt` |
| moon.pkg.json ディレクトリ検出 | `src/astra/routes/file_router.mbt` |
| page.json パース | `src/astra/routes/file_router.mbt` |
| Component ページ生成 | `src/astra/generator/static_render.mbt` |

## Phase 6: CFW デプロイ

| タスク | ファイル |
|--------|----------|
| DeployTarget enum | `src/astra/types.mbt` |
| deploy 設定パース | `src/astra/config.mbt` |
| _routes.json 生成 | `src/astra/generator/cloudflare.mbt` |
| E2E テスト (Playwright) | `e2e/astra/deploy-target.test.ts` (8件) |
| Vitest ルーティングテスト | `tests/cloudflare/routes.test.ts` (21件) |

**Note:** `@cloudflare/vitest-pool-workers` は vitest 2.x-3.x 必須。
vitest 4.x 環境では Worker ランタイムなしでルーティングロジックをテスト。

## Phase 7: 拡張ルーター

| タスク | ファイル |
|--------|----------|
| HybridRouter (fetch+swap) | `js/loader/src/router/hybrid.ts` |
| SpaRouter (CSR) | `js/loader/src/router/spa.ts` |
| ScrollManager | `js/loader/src/router/scroll.ts` |
| Rolldown エントリ追加 | `rolldown.config.mjs` |
| package.json exports | `js/loader/package.json` |

**実装済み機能:**
- `HybridRouter`: Turbo/HTMX スタイルの fetch + swap ナビゲーション
- `SpaRouter`: クライアントサイドレンダリングルーター、動的ルート対応
- `ScrollManager`: スクロール位置の保存・復元、sessionStorage 永続化

**サイズ:**
- `router/hybrid.js`: 4.1KB
- `router/spa.js`: 3.8KB
- `router/scroll.js`: 3.8KB

## Phase 8: Lint & DX

| タスク | ファイル |
|--------|----------|
| orphan-client 警告 | `src/astra/cli/lint.mbt` |
| orphan-server 通知 | `src/astra/cli/lint.mbt` |
| missing-props 警告 | `src/astra/cli/lint.mbt` |
| empty-static-params 警告 | `src/astra/cli/lint.mbt` |
| page.json JSON Schema | `schemas/page.schema.json` |
| astra.json Schema | `schemas/astra.schema.json` |

**Lintルール:**
- `orphan-client`: client/ のみで server/ がない (Warning)
- `orphan-server`: server/ のみで client/ がない (Info)
- `missing-props`: client/ があるが props_type 未定義 (Warning)
- `empty-static-params`: 動的ルートで staticParams 未定義 (Warning)
