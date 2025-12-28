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

### API一覧

| 関数 | 用途 | 例 |
|------|------|-----|
| `css(prop, val)` | 基本スタイル | `css("display", "flex")` |
| `styles(pairs)` | 複数スタイル | `styles([("display", "flex"), ...])` |
| `on(pseudo, prop, val)` | 擬似セレクタ | `on(":hover", "color", "red")` |
| `hover(prop, val)` | :hover | `hover("background", "#eee")` |
| `focus(prop, val)` | :focus | `focus("outline", "2px solid blue")` |
| `active(prop, val)` | :active | `active("transform", "scale(0.98)")` |
| `media(cond, prop, val)` | メディアクエリ | `media("min-width: 768px", "padding", "2rem")` |
| `at_sm/md/lg/xl(prop, val)` | ブレークポイント | `at_md("font-size", "1.25rem")` |
| `dark(prop, val)` | ダークモード | `dark("background", "#1a1a1a")` |

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

**設計方針**: CSSセレクタ名をそのまま露出

#### 汎用API: `on()`

```moonbit
// 擬似クラス
on(":hover", "background", "#2563eb")
on(":focus", "outline", "2px solid blue")
on(":active", "transform", "scale(0.98)")

// 擬似要素
on("::before", "content", "\"→\"")
on("::after", "content", "\"\"")
```

出力:
```css
._h1:hover{background:#2563eb}
._f1:focus{outline:2px solid blue}
._ac1:active{transform:scale(0.98)}
```

#### 便利ラッパー

```moonbit
// よく使う擬似クラス用
hover("background", "#2563eb")   // on(":hover", ...) のショートカット
focus("outline", "2px solid blue")
active("transform", "scale(0.98)")
```

#### メディアクエリ: `media()`

```moonbit
// 汎用
media("min-width: 768px", "padding", "2rem")
media("prefers-color-scheme: dark", "background", "#1a1a1a")

// ブレークポイント便利ラッパー
at_sm("padding", "1rem")    // 640px
at_md("padding", "1.5rem")  // 768px
at_lg("padding", "2rem")    // 1024px
at_xl("padding", "2.5rem")  // 1280px

// ダークモード
dark("background", "#1a1a1a")
dark("color", "white")
```

出力:
```css
@media(min-width:768px){._m0{padding:2rem}}
@media(prefers-color-scheme:dark){._m1{background:#1a1a1a}}
```

#### 使用例: インタラクティブボタン

```moonbit
fn button() -> @luna.Node {
  @luna.h("button", [
    // ベーススタイル
    css("display", "inline-flex"),
    css("padding", "0.5rem 1rem"),
    css("background", "#3b82f6"),
    css("color", "white"),
    css("border-radius", "0.375rem"),

    // インタラクション
    hover("background", "#2563eb"),
    focus("outline", "2px solid #93c5fd"),
    active("transform", "scale(0.98)"),

    // レスポンシブ
    at_md("padding", "0.75rem 1.5rem"),
    at_lg("font-size", "1.125rem"),
  ], [...])
}
```

#### 使用例: ダークモード対応カード

```moonbit
fn card() -> @luna.Node {
  @luna.h("div", [
    css("background", "white"),
    css("color", "#1a1a1a"),
    dark("background", "#1a1a1a"),
    dark("color", "white"),
  ], [...])
}
```

### 4. Shadow DOM境界

**問題**: Shadow DOM内では外部CSSが適用されない

```
Document
├── <style>._a{display:flex}</style>    ← グローバルCSS
├── <div class="_a">✓</div>              ← 適用される
└── <wc-counter>
    └── #shadow-root
        └── <div class="_a">✗</div>      ← 適用されない
```

**対策案**:

#### 案1: コンポーネント単位のスタイル追跡

各コンポーネントで使用するスタイル宣言を追跡し、Shadow Root生成時に注入:

```moonbit
// ビルド時に収集
fn counter_styles() -> String {
  // このコンポーネントで使用される宣言のみ
  "._a{display:flex}._b{align-items:center}"
}

fn counter() -> @luna.Node {
  wc_island("wc-counter", "/counter.js", [
    // 子要素
  ], styles=counter_styles())
}
```

#### 案2: Adoptable Stylesheets (推奨)

ブラウザのCSSStyleSheet APIを使用して、複数のShadow Rootでスタイルシートを共有:

```javascript
// グローバルに1つのスタイルシートを作成
const globalSheet = new CSSStyleSheet();
globalSheet.replaceSync("._a{display:flex}._b{align-items:center}...");

// 各Shadow Rootで採用
shadowRoot.adoptedStyleSheets = [globalSheet];
```

MoonBit側:
```moonbit
// 初期化時にグローバルシートを登録
fn init_global_styles() -> Unit {
  let css = generate_css()
  register_adoptable_sheet(css)
}

// Shadow Root作成時に採用
fn hydrate_wc(element : @js_dom.Element) -> Unit {
  let shadow = get_shadow_root(element)
  adopt_global_styles(shadow)
}
```

利点:
- メモリ効率（シート共有）
- スタイル更新が全Shadow Rootに反映
- パースコスト削減

#### 案3: ハイドレーション単位でのスタイル分割

ビルド時にハイドレーション境界を検出し、スタイルを分割:

```
build output:
├── global.css        # Document用
├── counter.css       # wc-counter Shadow Root用
└── modal.css         # wc-modal Shadow Root用
```

### 5. デバッグの困難さ

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
- [x] 疑似クラス対応 (`on()`, `hover()`, `focus()`, `active()`)
- [x] メディアクエリ対応 (`media()`, `at_sm()`, `at_md()`, `at_lg()`, `at_xl()`)
- [x] ダークモード対応 (`dark()`)
- [ ] CSS変数連携
- [ ] 動的スタイルの自動判別
- [ ] Shadow DOM対応 (Adoptable Stylesheets)

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
