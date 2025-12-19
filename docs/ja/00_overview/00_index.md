---
title: 概要
---

# Luna エコシステム概要

Luna は MoonBit と JavaScript でモダンな Web アプリケーションを構築するためのツール群です。このドキュメントでは4つの連携するプロジェクトを解説します。

## アーキテクチャ

```
┌─────────────────────────────────────────────────────────────┐
│                     あなたのアプリケーション                    │
├─────────────────────────────────────────────────────────────┤
│  Astra (SSG)          │  Sol (SSR フレームワーク)              │
│  静的ドキュメントサイト   │  Islands を使ったフルスタックアプリ     │
├─────────────────────────────────────────────────────────────┤
│                       Luna (コア)                            │
│           Signals, Islands, Hydration, Components            │
├─────────────────────────────────────────────────────────────┤
│                      MoonBit / JavaScript                    │
└─────────────────────────────────────────────────────────────┘
```

## プロジェクト

### [Luna](/ja/luna/) - コア UI ライブラリ

すべての基盤となるライブラリ。Luna が提供する機能：

- **Signals** - きめ細かいリアクティブプリミティブ
- **Islands** - 最適なパフォーマンスのための部分的 Hydration
- **Components** - 宣言的構文による Web Components
- **Hydration** - スマートなローディング戦略 (load, idle, visible, media)

```typescript
import { createSignal, createEffect } from '@mizchi/luna';

const [count, setCount] = createSignal(0);
createEffect(() => console.log(count()));
setCount(1);  // Logs: 1
```

### [Astra](/ja/astra/) - 静的サイトジェネレーター

Markdown からドキュメントサイトやブログを構築。機能：

- Frontmatter 対応の Markdown
- ナビゲーションとサイドバーの自動生成
- i18n（国際化）サポート
- Shiki によるシンタックスハイライト
- View Transitions を使った SPA ナビゲーション

このドキュメントサイトは Astra で構築されています。

### [Sol](/ja/sol/) - フルスタックフレームワーク

Hono 統合によるサーバーサイドレンダリングフレームワーク：

- SSR + 部分的 Hydration のための Island Architecture
- ファイルベースルーティング
- Edge 対応デプロイ
- 状態のシリアライズと復元

### [Stella](/ja/stella/) - 開発ツール

開発ユーティリティと実験的機能：

- ホットリロード付き開発サーバー
- ビルドツール統合
- テストユーティリティ

## 学習パス

### JavaScript 開発者向け

1. [チュートリアル (JavaScript)](/ja/tutorial-js/) から始める
2. [Signals](/ja/luna/signals/) と [Islands](/ja/luna/islands/) を学ぶ
3. [Astra](/ja/astra/) でサイトを、または [Sol](/ja/sol/) でアプリを構築

### MoonBit 開発者向け

1. [チュートリアル (MoonBit)](/ja/tutorial-moonbit/) から始める
2. MoonBit でのコア Luna API を探索
3. サーバーサイドコンポーネントを構築

## 機能比較

| 機能 | Astra | Sol |
|------|-------|-----|
| ユースケース | ドキュメント、ブログ | Web アプリケーション |
| レンダリング | 静的（ビルド時） | 動的（リクエスト時） |
| ルーティング | ファイルベース | ファイルベース + API ルート |
| Islands | Markdown 埋め込み | コンポーネントベース |
| デプロイ | 静的ホスティング | Edge ランタイム / Node.js |

## はじめに

目的に応じて選択：

- **ドキュメントを作成？** → [Astra クイックスタート](/ja/astra/)
- **アプリを構築？** → [Sol クイックスタート](/ja/sol/)
- **リアクティビティだけ必要？** → [Luna Signals](/ja/luna/signals/)

## ステータス

> **実験的** - すべてのプロジェクトは活発に開発中です。API は変更される可能性があります。

[MoonBit](https://www.moonbitlang.com/) で構築 - クラウドとエッジコンピューティングのための高速で安全な言語。
