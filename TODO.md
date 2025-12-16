これは開発者が次にやりたいことをメモとして残していく場所だから、AIは言われるまで修正しない。

- data 属性を修正する
  `luna:*` と `sol:*` にする
- [ ] Sol PageProps
  - Server Route から Client を Route に登録するとき、 Props を取らないといけない
  - Server Component 同士は呼び出せる。
  - `__gen__/types` には Client/Server 共に使える Opaque Type を定義して、それを呼び出す
- [ ] Async Server Function
  - [ ] src/sol/rpc: capnweb
  - [ ] -prod と --dev に分割して、デバッグ用のビルドを注入する
- [ ] Prototype: src/platform/native/server
- [ ] Prototype: ViewTransition
  - [ ] BF Cache 最適化
- [ ] Prototype: 内部的に cbor encoder を使う
- [ ] sol/test_utils
  - playwright テストをビルトインできないか
- [ ] sol dev コード監視を最適化を追加
- [ ] src/sol/ssg で、静的サイト生成に対応
- [ ] react-hook-form 相当のものを試作する
  - valibot を使うか、自前のバリデータを作るか
- [ ] src/platform/dom/portal
- [ ] src/integrations
  - [ ] src/platform/dom/integrations/react
  - [ ] src/platform/dom/integrations/preact
- [ ] sol validate
  - client/*.mbt の link.js.exports で、Generic パラメータを持つものを警告する
- [ ] webcomponents SSR を試す
- [ ] WASM/Native 向け escape 関数の最適化
  - JS は FFI で高速化済み (18-22倍)
  - WASM: SIMD 的なバッチ処理、または extern "wasm" で最適化
  - Native: extern "C" で C 実装を検討
- [ ] virtual package を導入してクロスプラットフォーム化の基盤を作る
  - https://www.moonbitlang.com/blog/virtual-package
- [ ] Inline Editor
- [ ] ドキュメントの英語化

## Icebox

- [ ] portal
- [ ] preact
- [ ] shadcn
- [ ] React Bridge
- [ ] Fix playwright
- [ ] Vite Enviroment Apiに対応? -> やらない。やるにしても最後

## Done

- [x] 再 export するのに、moonbitlang/parser を使用する
- [x] js/cli を src/eclipse/cli で、CLIをMoonbitで書き直す
