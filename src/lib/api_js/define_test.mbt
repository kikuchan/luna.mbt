///| WebComponents tests

test "register: basic custom element" {
  @global_jsdom.register()

  // Register a simple counter component
  register("test-counter-1", fn(_host) {
    let count = @signal.signal(0)
    @kaguya.vnode(
      "div",
      [],
      [
        @kaguya.vnode(
          "span",
          [],
          [@kaguya.text_dyn(fn() { count.get().to_string() })],
        ),
        @kaguya.vnode(
          "button",
          [("id", @kaguya.attr_static("inc"))],
          [@kaguya.vtext("+")],
        ),
      ],
    )
  })

  // Create and attach element
  let doc = @js_dom.document()
  let container = doc.createElement("div")
  match doc.body() {
    Some(body) => body.appendChild(container.as_node()) |> ignore
    None => ()
  }
  js_set_inner_html(container, "<test-counter-1></test-counter-1>")

  // Verify element was created
  let counter = container.querySelector("test-counter-1")
  assert_true(counter is Some(_))
}

test "register_with_attrs: observed attributes become signals" {
  @global_jsdom.register()

  // Register component with observed attributes
  register_with_attrs("test-greeter-1", ["name"], fn(_host, attrs) {
    let name_sig = match attrs.get("name") {
      Some(s) => s
      None => @signal.signal("")
    }
    @kaguya.vnode(
      "div",
      [],
      [
        @kaguya.vnode(
          "span",
          [("id", @kaguya.attr_static("greeting"))],
          [@kaguya.text_dyn(fn() { "Hello, " + name_sig.get() + "!" })],
        ),
      ],
    )
  })

  let doc = @js_dom.document()
  let container = doc.createElement("div")
  match doc.body() {
    Some(body) => body.appendChild(container.as_node()) |> ignore
    None => ()
  }
  js_set_inner_html(container, "<test-greeter-1 name=\"World\"></test-greeter-1>")

  let greeter = container.querySelector("test-greeter-1")
  assert_true(greeter is Some(_))
}

///|
extern "js" fn js_set_inner_html(elem : @js_dom.Element, html : String) -> Unit =
  #| (elem, html) => { elem.innerHTML = html; }
