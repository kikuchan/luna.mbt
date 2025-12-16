これは開発者が次にやりたいことをメモとして残していく場所だから、AIは言われるまで修正しない。

- [ ] sol 中間生成ファイルを見直す
- [ ] sol: hot reload
- [ ] sol generate で `.sol/client/exports.mbt` を削除して直接 moon.pkg.json の link を更新する
- [ ] Prototype: src/platform/native/server
- [ ] Prototype: ViewTransition
  - [ ] BF Cache 最適化
  - [ ] MPA Mode
  - [ ] SSR Stream が機能しているかテスト
- [ ] sol dev コード監視を最適化を追加
- [ ] src/sol/ssg で、静的サイト生成に対応
- [ ] mizchi/luna から mizchi/luna のコアAPIを再 export
- [ ] src/platform/dom/portal
- [ ] virtual package を導入してクロスプラットフォーム化の基盤を作る
  - https://www.moonbitlang.com/blog/virtual-package
- [ ] v0.1.0 ドキュメントの英語化
- [ ] client trigger を astro と互換にする
  - https://r4ai.dev/posts/astro_hydration/

## UserReview

ユーザー視点で優先度が高いもの：

### 最優先（開発体験に直結）
- [ ] sol: hot reload - 開発効率に直結
- [ ] v0.1.0 ドキュメントの英語化 - 海外ユーザーの参入障壁

### 高優先（実用性向上）
- [ ] src/sol/ssg で静的サイト生成に対応 - ブログ/静的サイトの需要
- [ ] client trigger を astro と互換にする - 学習コスト低減
- [ ] ViewTransition - モダンなページ遷移UX

### 中優先（機能拡充）
- [ ] src/platform/dom/portal - モーダル等の実装に必須

## Icebox

- [ ] shadcn
- [ ] Vite Enviroment Apiに対応? -> やらない。やるにしても最後
- [ ] Inline Editor: dev の時、Monaco を利用して、
- [ ] react-hook-form 相当のものを試作する
  - valibot を使うか、自前のバリデータを作るか
  - standard schema 相当のものを作るといいのでは
- [ ] marimo notebook
- [ ] sol/test_utils
  - playwright テストをビルトインできないか
- [ ] Async Server Function
  - [ ] src/sol/rpc: capnweb を参考に、リクエストをバッチ化する
  - [ ] Prototype: 内部的に cbor encoder を使う
- [ ] sol build: --prod と --dev に分割して、デバッグ用のビルドを注入する
- [ ] src/integration
  - [ ] src/platform/dom/integrations/react
  - [ ] src/platform/dom/integrations/preact
- [ ] sol validate
  - client/*.mbt の link.js.exports で、Generic パラメータを持つものを警告する
- [ ] WASM/Native 向け escape 関数の最適化
  - JS は FFI で高速化済み (18-22倍)
  - WASM: SIMD 的なバッチ処理、または extern "wasm" で最適化
  - Native: extern "C" で C 実装を検討

## Done

- [x] 再 export するのに、moonbitlang/parser を使用する
- [x] js/cli を src/eclipse/cli で、CLIをMoonbitで書き直す
- [x] data 属性を修正する
  `luna:*` と `sol:*` にする
- [x] webcomponents SSR を試す
- [x] Sol ServerComponent PageProps
  - Server Route から Client を Route に登録するとき、 Props を取らないといけない
  - Server Component 同士は呼び出せる。
  - `__gen__/types` には Client/Server 共に使える Opaque Type を定義して、それを呼び出す
