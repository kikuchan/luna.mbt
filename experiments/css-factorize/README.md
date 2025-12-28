# CSS Factorization & Compression

CSSルールセットを集合として扱い、最小のユーティリティクラスを自動導出する実験。

## コンセプト

### 問題: BEM/コンポーネントCSSの冗長性

```css
/* 154 bytes - 同じプロパティが繰り返される */
.card__header { display: flex; align-items: center; padding: 1rem; }
.modal__footer { display: flex; align-items: center; padding: 1rem; }
.sidebar__nav { display: flex; align-items: center; }
```

### 解決: CSS因数分解

CSSを集合として扱い、共通部分を抽出:

```
R1 = {display:flex, align-items:center, padding:1rem}
R2 = {display:flex, align-items:center, padding:1rem}
R3 = {display:flex, align-items:center}

共通部分: {display:flex, align-items:center} → ._a
残り: {padding:1rem} → ._b
```

結果:
```css
/* 89 bytes - 42%削減 */
._a{display:flex;align-items:center}
._b{padding:1rem}
```

## ベンチマーク結果

| CSS | Before | After | 削減率 |
|-----|--------|-------|--------|
| BEM test (2KB) | 2,172 | 932 | **57%** |
| Astra main.css (43KB) | 43,164 | 20,480 | **53%** |
| Bootstrap 5.3 (232KB) | 232,911 | 108,382 | **53%** |
| Bulma 0.9 (207KB) | 207,302 | 43,124 | **79%** |
| Tailwind Preflight (8KB) | 7,695 | 6,556 | 15% |

**観察**: コンポーネントベースCSS (BEM, Bulma) は大幅削減。ユーティリティファースト (Tailwind) は既に最適化済み。

## アプローチ比較

### 1. 既存CSS因数分解 (factorize.js)

既存のCSSを後処理で最適化。

```bash
node factorize.js input.css
```

**課題**:
- HTMLのクラス参照も変換が必要
- 外部CSSとの衝突リスク
- 動的クラス名の追跡が困難

### 2. 圧縮前提の専用ユーティリティ (推奨)

最初から圧縮を前提としたCSSシステムを設計。

#### Tailwind風API (luna-utilities-concept.mbt)

```moonbit
h("div", [
  flex(),
  items_center(),
  p(S4),
], [...])
```

- ✅ 型安全
- ❌ CSS語彙を隠蔽 (新しい命名規則の学習が必要)

#### Direct CSS API (css-direct-api.mbt) ← 推奨

```moonbit
h("div", [
  css("display", "flex"),
  css("align-items", "center"),
  css("padding", "1rem"),
], [...])
```

- ✅ CSSプロパティ名をそのまま使用
- ✅ 既存のCSS知識がそのまま活きる
- ✅ 自動重複排除・圧縮
- ✅ `_`プレフィックスで外部CSS衝突回避

## Direct CSS API 詳細

### 基本使用

```moonbit
fn card() -> Node {
  h("div", [
    css("display", "flex"),
    css("align-items", "center"),
    css("padding", "1rem"),
    css("border-radius", "0.5rem"),
  ], [
    text("Card content")
  ])
}
```

### 出力

HTML:
```html
<div class="_a _b _c _d">Card content</div>
```

CSS (使用分のみ):
```css
._a{display:flex}._b{align-items:center}._c{padding:1rem}._d{border-radius:0.5rem}
```

### 一括指定

```moonbit
fn button() -> Node {
  h("button", [
    styles([
      ("display", "inline-flex"),
      ("padding", "0.5rem 1rem"),
      ("cursor", "pointer"),
    ]),
  ], [...])
}
```

### 共通スタイルの再利用

```moonbit
// 共通パターンを関数化
fn flex_center() -> Array[(String, String)] {
  [("display", "flex"), ("align-items", "center"), ("justify-content", "center")]
}

// 複数箇所で使用 → 同じクラスが再利用される
fn modal_overlay() -> Node {
  h("div", [styles(flex_center())], [...])
}

fn dialog() -> Node {
  h("div", [styles(flex_center())], [...])  // 同じ ._a ._b ._c が出力
}
```

## 懸念点と対策

### 1. 外部CSSとの衝突

**問題**: 生成クラス名が外部ライブラリと衝突する可能性

**対策**: `_`プレフィックス付与
```css
._a{display:flex}  /* 衝突しにくい */
```

### 2. 動的スタイル (Signal連動)

**問題**: Signalで値が変わるスタイルは静的最適化できない

```moonbit
// 静的 → 最適化対象
css("color", "red")

// 動的 → 最適化スコープ外
css("color", color_signal.get())  // ← 値が実行時に決まる
```

**対策**: 動的スタイルは別扱い

```moonbit
// 静的スタイル → クラス化
css("display", "flex")  // → class="_a"

// 動的スタイル → inline style
dynamic_css("color", color_signal)  // → style="color: ${value}"
```

または、動的部分のみCSS変数化:

```moonbit
// 静的部分
css("color", "var(--dynamic-color)")  // → class="_a" (._a{color:var(--dynamic-color)})

// 動的部分はCSS変数で注入
style("--dynamic-color", color_signal.get())
```

### 3. 疑似クラス・メディアクエリ

**対策**: 専用ラッパー

```moonbit
hover("background", "#2563eb")
// → ._h1:hover{background:#2563eb}

at_md("padding", "2rem")
// → @media(min-width:768px){._m1{padding:2rem}}
```

### 4. デバッグの困難さ

**問題**: `._a ._b ._c` だと何のスタイルか分からない

**対策**: 開発モードで元の宣言をコメント出力

```css
/* dev mode */
._a{display:flex}/* display:flex */
._b{align-items:center}/* align-items:center */

/* prod mode */
._a{display:flex}._b{align-items:center}
```

## 実装ロードマップ

### Phase 1: プロトタイプ (現在)
- [x] CSS因数分解アルゴリズム (factorize.js)
- [x] ベンチマーク検証
- [x] API設計案

### Phase 2: Luna統合
- [ ] `css()` / `styles()` 関数実装
- [ ] StyleRegistry (使用スタイル追跡)
- [ ] ビルド時CSS生成

### Phase 3: 高度な機能
- [ ] 疑似クラス対応 (`hover()`, `focus()`)
- [ ] メディアクエリ対応 (`at_md()`, `at_lg()`)
- [ ] CSS変数連携
- [ ] 動的スタイルの自動判別

### Phase 4: 最適化
- [ ] 宣言の出現順最適化 (gzip効率)
- [ ] クリティカルCSS抽出
- [ ] 未使用スタイルの警告

## ファイル構成

```
experiments/css-factorize/
├── README.md                    # このファイル
├── factorize.js                 # CSS因数分解アルゴリズム
├── runtime.js                   # ランタイム展開 (実験的)
├── test.css                     # テスト用BEM CSS
├── luna-utilities-concept.mbt   # Tailwind風API案
├── css-direct-api.mbt           # Direct CSS API案 (推奨)
└── luna-integration.md          # Luna統合戦略
```

## 使い方

```bash
# 既存CSSの因数分解テスト
node factorize.js test.css

# 詳細表示
node factorize.js input.css -v

# クラスマッピング出力
node factorize.js input.css --mapping

# ランタイム形式出力
node factorize.js input.css --runtime
```

## 結論

1. **既存CSS最適化**: factorize.jsで50-80%削減可能
2. **新規開発**: Direct CSS API (`css("property", "value")`) を推奨
3. **動的スタイル**: inline styleまたはCSS変数で分離
4. **外部CSS**: `_`プレフィックスで衝突回避
