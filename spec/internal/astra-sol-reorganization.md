# Astra/Sol 責務再編成

## 完了した作業

### 1. browser_router の移動

```
移動前: src/luna/dom/router/
移動後: src/sol/browser_router/
```

理由: ブラウザルーターは sol のフレームワーク機能であり、luna のコアUI機能ではない。

依存関係:
- `luna/routes` (ルートマッチングのコア型)
- `luna/signal` (リアクティブ状態管理)

### 2. core/isr を sol/isr にマージ

```
削除: src/core/isr/
統合先: src/sol/isr/
```

変更内容:
- `ISRPageEntry` → `ISRPageMeta` に統一（sol/isr/handler.mbt の型を採用）
- `ISRManifest` を `pub(all)` に変更（astra から構築可能に）
- parser.mbt は handler.mbt の `parse_manifest()` と重複のため削除
- utils.mbt は cache.mbt と重複のため削除
- serializer.mbt は sol/isr に移動（astra がビルド時に使用）

astra/isr の変更:
- `@core_isr` → `@sol_isr` に変更
- `ISRPageEntry` → `ISRPageMeta` に変更

## 決定事項

### 1. Routes モジュール

**決定: パターン A を採用**
- `luna/routes` をそのまま保持（ターゲット非依存: js, wasm-gc, native）
- ルートマッチングのコア型として維持

### 2. Astra/Sol 間のルーティング統合

**方針:**
- `astra/routes` のファイルスキャン部分を sol の基本機能として移動
- markdown 処理は astra が sol のルート定義に「注入」する形
- `sol/router` は routes 定義にハンドラをアタッチ可能にする

### 3. ISR

**決定: sol/isr を正とし、astra は利用者となる**
- ISR は sol の責務
- astra/isr は sol/isr の型を使用してマニフェストを生成

## 今後の作業

### 優先度: 高
- `astra/routes` のファイルスキャン機能を sol に移動
  - ファイルスキャン: sol へ
  - markdown パーサー: astra のまま
  - ルート定義への注入メカニズムを設計

### 優先度: 中
- `core/routes` の整理
  - sol/routes へのマージを検討
  - SSG メタデータ型の配置を決定

### 優先度: 低
- `sol/cli` と `astra/cli` の統合検討
- `core/cache` の sol への移動検討
