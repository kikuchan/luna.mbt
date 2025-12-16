# レンダリングベンチマーク結果

`render_to_string` の全体パフォーマンス計測。

## 実行方法

```bash
# JS ターゲット
moon bench --target js -p mizchi/luna/core/render

# WASM-GC ターゲット
moon bench --target wasm-gc -p mizchi/luna/core/render
```

---

## ベースライン (2024-12-16)

escape 関数のクロスターゲット最適化後の初回計測。

### JS ターゲット (FFI escape)

| ベンチマーク | 時間 | 備考 |
|-------------|------|------|
| render: text | 0.08 µs | エスケープ不要 |
| render: text_escape | 0.68 µs | HTML エスケープあり |
| render: simple_element | 0.14 µs | 単純な div |
| render: with_attrs | 0.78 µs | JSON 属性含む |
| render: nested | 0.99 µs | 典型的なカード構造 |
| render: list (10 items) | 2.40 µs | リスト 10 件 |
| render: large_list (100 items) | 54.60 µs | 100 件 + エスケープ |
| render: page | 1.99 µs | 典型的なページ構造 |

### WASM-GC ターゲット (純粋 MoonBit escape)

| ベンチマーク | 時間 | 備考 |
|-------------|------|------|
| render: text | 0.08 µs | エスケープ不要 |
| render: text_escape | 0.43 µs | HTML エスケープあり |
| render: simple_element | 0.12 µs | 単純な div |
| render: with_attrs | 0.58 µs | JSON 属性含む |
| render: nested | 0.93 µs | 典型的なカード構造 |
| render: list (10 items) | 1.95 µs | リスト 10 件 |
| render: large_list (100 items) | 59.25 µs | 100 件 + エスケープ |
| render: page | 2.08 µs | 典型的なページ構造 |

### 比較サマリー

| ベンチマーク | JS | WASM-GC | 勝者 |
|-------------|-----|---------|------|
| text | 0.08µs | 0.08µs | 同等 |
| text_escape | 0.68µs | **0.43µs** | WASM 1.6x |
| simple_element | 0.14µs | **0.12µs** | WASM 1.2x |
| with_attrs | 0.78µs | **0.58µs** | WASM 1.3x |
| nested | 0.99µs | **0.93µs** | WASM 1.1x |
| list (10) | 2.40µs | **1.95µs** | WASM 1.2x |
| large_list (100) | **54.60µs** | 59.25µs | JS 1.1x |
| page | 1.99µs | 2.08µs | 同等 |

### 発見

1. **escape 単体 vs 全体**: escape 単体では JS FFI が 18-22x 速いが、全体では WASM-GC が速い
2. **ボトルネック**: escape 以外の処理（VNode 走査、パターンマッチング、StringBuilder）が支配的
3. **large_list でのみ JS が有利**: escape 処理の割合が高いケースで JS FFI の効果が出る

---

## 最適化実験ログ

### 実験 1: StringBuilder size_hint を 256 → 4096 に変更

**結果**: 逆効果

| ベンチマーク | Before | After | 変化 |
|-------------|--------|-------|------|
| text | 0.08µs | 0.07µs | -13% |
| text_escape | 0.68µs | 1.42µs | +109% (悪化) |
| simple_element | 0.14µs | 0.19µs | +36% (悪化) |
| nested | 0.99µs | 1.19µs | +20% (悪化) |

**考察**: 小さなレンダリングでは StringBuilder 初期化コストが支配的。size_hint は小さいままが良い。

---

## 最適化 TODO

### 短期 (効果大)

- [x] StringBuilder の事前確保サイズを最適化 → 逆効果、256 のまま
- [ ] VNode パターンマッチングの最適化
- [ ] 属性レンダリングのインライン化

### 中期

- [ ] VNode 構造の簡素化（メモリ効率）
- [ ] 文字列連結の最適化
- [ ] WASM-GC 向け escape の最適化

### 長期

- [ ] ストリーミングレンダリングとの統合
- [ ] 部分レンダリング（差分）

---

## 関連ファイル

- `src/core/render/render_bench.mbt` - ベンチマークコード
- `src/core/render/render_to_string.mbt` - レンダリング実装
- `src/core/render/escape.mbt` - エスケープ API
- `src/core/render/escape_js.mbt` - JS FFI エスケープ
- `src/core/render/escape_non_js.mbt` - 純粋 MoonBit エスケープ
