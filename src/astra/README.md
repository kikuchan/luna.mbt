# Astra

静的サイトジェネレーター (SSG)。Markdown → HTML 変換。

## 概要

ドキュメントサイト生成に特化したSSG。
Markdownファイルから多言語対応の静的サイトを生成する。

## モジュール構成

| サブモジュール | 責務 |
|---------------|------|
| `cli/` | CLIエントリポイント |
| `generator/` | HTML生成ロジック |
| `markdown/` | Markdown解析 |
| `routes/` | ルート生成 |
| `shiki/` | シンタックスハイライト (Shiki統合) |
| `config.mbt` | 設定パーサー |
| `types.mbt` | 型定義 |

## 設定ファイル (astra.json)

```json
{
  "docs": "docs",
  "output": "dist",
  "title": "My Site",
  "base": "/",
  "trailingSlash": true,
  "i18n": {
    "defaultLocale": "en",
    "locales": [
      { "code": "en", "label": "English", "path": "" },
      { "code": "ja", "label": "日本語", "path": "ja" }
    ]
  },
  "nav": [...],
  "sidebar": "auto"
}
```

## 主要な型

### SsgConfig

```moonbit
pub struct SsgConfig {
  docs_dir : String       // ソースディレクトリ
  output_dir : String     // 出力ディレクトリ
  title : String          // サイトタイトル
  base_url : String       // ベースURL
  nav : Array[NavItem]    // ナビゲーション
  sidebar : SidebarConfig // サイドバー設定
  i18n : I18nConfig       // 多言語設定
  // ...
}
```

## 機能

- Markdownからの静的HTML生成
- 多言語サポート (i18n)
- 自動サイドバー生成
- シンタックスハイライト (Shiki)
- OGP対応

## 使用方法

```bash
# CLIから実行
moon run src/astra/cli -- build
```

## 参照

- [Luna Core](../core/README.md) - VNode生成
- [Sol](../sol/README.md) - SSRフレームワーク
