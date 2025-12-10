///|
///| Experimental Hydration (Fixable) Benchmarks
///| Measures performance of morphdom-like DOM diffing/patching during hydration

// =============================================================================
// Helper Functions
// =============================================================================

// Global container reused across benchmarks to prevent memory leak
let fixable_bench_container : Ref[@js_dom.Element?] = { val: None }

///|
fn get_or_create_fixable_container() -> @js_dom.Element {
  match fixable_bench_container.val {
    Some(c) => c
    None => {
      let doc = @js_dom.document()
      let container = doc.createElement("div")
      container.setAttribute("id", "fixable-bench-container")
      match doc.body() {
        Some(body) => body.appendChild(container.as_node()) |> ignore
        None => ()
      }
      fixable_bench_container.val = Some(container)
      container
    }
  }
}

///|
fn setup_fixable_container(html : String) -> @js_dom.Element {
  let container = get_or_create_fixable_container()
  fixable_set_inner_html(container, html)
  container
}

///|
extern "js" fn fixable_set_inner_html(elem : @js_dom.Element, html : String) -> Unit =
  #| (elem, html) => { elem.innerHTML = html; }

// =============================================================================
// Clean Hydration (No Repairs Needed)
// =============================================================================

///|
test "fixable_clean_simple" (b : @bench.T) {
  @global_jsdom.register()
  let node = @ui.vnode("div", [], [@ui.vtext("Hello")])
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="fixable_clean_simple", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "fixable_clean_nested" (b : @bench.T) {
  @global_jsdom.register()
  let node = @ui.vnode(
    "div",
    [],
    [
      @ui.vnode(
        "section",
        [],
        [@ui.vnode("p", [], [@ui.vtext("Nested content")])],
      ),
    ],
  )
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="fixable_clean_nested", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
fn create_fixable_list_node(count : Int) -> @ui.Node {
  let items : Array[@ui.Node] = []
  for i = 0; i < count; i = i + 1 {
    items.push(@ui.vnode("li", [], [@ui.vtext("Item " + i.to_string())]))
  }
  @ui.vnode("ul", [], items)
}

///|
test "fixable_clean_list_50" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_fixable_list_node(50)
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="fixable_clean_list_50", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// =============================================================================
// Repair: Text Mismatch
// =============================================================================

///|
test "fixable_repair_text_mismatch" (b : @bench.T) {
  @global_jsdom.register()
  let node = @ui.vnode("div", [], [@ui.vtext("Expected Text")])
  // Simulate server HTML with different text
  let html = "<div>Different Text</div>"
  let logger = StringBuilder::new()
  b.bench(name="fixable_repair_text_mismatch", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "fixable_repair_text_missing" (b : @bench.T) {
  @global_jsdom.register()
  let node = @ui.vnode("div", [], [@ui.vtext("Expected Text")])
  // Simulate server HTML with empty element
  let html = "<div></div>"
  let logger = StringBuilder::new()
  b.bench(name="fixable_repair_text_missing", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// =============================================================================
// Repair: Element Missing
// =============================================================================

///|
test "fixable_repair_element_missing" (b : @bench.T) {
  @global_jsdom.register()
  let node = @ui.vnode(
    "div",
    [],
    [@ui.vnode("span", [], [@ui.vtext("Child")])],
  )
  // Empty container
  let html = ""
  let logger = StringBuilder::new()
  b.bench(name="fixable_repair_element_missing", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// =============================================================================
// Repair: Attribute Mismatch
// =============================================================================

///|
test "fixable_repair_attr_mismatch" (b : @bench.T) {
  @global_jsdom.register()
  let node = @ui.vnode(
    "div",
    [("class", @ui.attr_static("expected-class"))],
    [@ui.vtext("Content")],
  )
  // Simulate server HTML with different class
  let html = "<div class=\"wrong-class\">Content</div>"
  let logger = StringBuilder::new()
  b.bench(name="fixable_repair_attr_mismatch", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// =============================================================================
// Repair: Dynamic Content Markers Missing
// =============================================================================

///|
test "fixable_repair_dynamic_text_marker" (b : @bench.T) {
  @global_jsdom.register()
  let count = @ui.signal(42)
  let node = @ui.text_dyn(fn() { "Count: " + count.get().to_string() })
  // Simulate server HTML without markers
  let html = "Count: 42"
  let logger = StringBuilder::new()
  b.bench(name="fixable_repair_dynamic_text_marker", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// =============================================================================
// Repair: Show Markers Missing
// =============================================================================

///|
test "fixable_repair_show_marker" (b : @bench.T) {
  @global_jsdom.register()
  let visible = @ui.signal(true)
  let node = @ui.vshow(
    fn() { visible.get() },
    fn() { @ui.vnode("div", [], [@ui.vtext("Visible")]) },
  )
  // Simulate server HTML without show markers
  let html = "<div>Visible</div>"
  let logger = StringBuilder::new()
  b.bench(name="fixable_repair_show_marker", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// =============================================================================
// Repair: For Markers Missing
// =============================================================================

///|
test "fixable_repair_for_marker" (b : @bench.T) {
  @global_jsdom.register()
  let items_sig = @ui.signal(["a", "b", "c"])
  let node = @ui.vfor(fn() {
    items_sig.get().map(fn(item) { @ui.vnode("li", [], [@ui.vtext(item)]) })
  })
  // Simulate server HTML without for markers
  let html = "<li>a</li><li>b</li><li>c</li>"
  let logger = StringBuilder::new()
  b.bench(name="fixable_repair_for_marker", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// =============================================================================
// Repair: For Item Count Mismatch
// =============================================================================

///|
test "fixable_repair_for_item_count" (b : @bench.T) {
  @global_jsdom.register()
  let items_sig = @ui.signal(["a", "b", "c", "d", "e"])
  let node = @ui.vfor(fn() {
    items_sig.get().map(fn(item) { @ui.vnode("li", [], [@ui.vtext(item)]) })
  })
  // Simulate server HTML with fewer items
  let html = "<!--f:0--><li>a</li><li>b</li><!--/f-->"
  let logger = StringBuilder::new()
  b.bench(name="fixable_repair_for_item_count", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// =============================================================================
// Complex Repair Scenarios
// =============================================================================

///|
fn create_fixable_card(title : String, content : String) -> @ui.Node {
  @ui.vnode(
    "div",
    [("class", @ui.attr_static("card"))],
    [
      @ui.vnode(
        "h3",
        [("class", @ui.attr_static("card-title"))],
        [@ui.vtext(title)],
      ),
      @ui.vnode(
        "p",
        [("class", @ui.attr_static("card-content"))],
        [@ui.vtext(content)],
      ),
    ],
  )
}

///|
test "fixable_repair_multiple_cards" (b : @bench.T) {
  @global_jsdom.register()
  let cards : Array[@ui.Node] = []
  for i = 0; i < 5; i = i + 1 {
    cards.push(create_fixable_card("Card " + i.to_string(), "Content " + i.to_string()))
  }
  let node = @ui.vnode("div", [("class", @ui.attr_static("container"))], cards)
  // Simulate partial server HTML (fewer cards, wrong classes)
  let html = "<div class=\"wrong-container\"><div class=\"card\"><h3>Card 0</h3><p>Old Content</p></div></div>"
  let logger = StringBuilder::new()
  b.bench(name="fixable_repair_multiple_cards", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// =============================================================================
// Detailed Report Benchmarks
// =============================================================================

///|
test "fixable_with_report_clean" (b : @bench.T) {
  @global_jsdom.register()
  let node = @ui.vnode("div", [], [@ui.vtext("Hello")])
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="fixable_with_report_clean", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate_with_report(container, node, logger=logger))
  })
}

///|
test "fixable_with_report_repairs" (b : @bench.T) {
  @global_jsdom.register()
  let node = @ui.vnode(
    "div",
    [("class", @ui.attr_static("expected"))],
    [@ui.vtext("Expected")],
  )
  let html = "<div class=\"wrong\">Wrong</div>"
  let logger = StringBuilder::new()
  b.bench(name="fixable_with_report_repairs", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate_with_report(container, node, logger=logger))
  })
}

// =============================================================================
// Fallback Strategy Benchmark
// =============================================================================

///|
test "fixable_hydrate_with_fallback" (b : @bench.T) {
  @global_jsdom.register()
  let node = @ui.vnode("div", [], [@ui.vtext("Content")])
  // Intentionally mismatched HTML to trigger fallback
  let html = "<span>Wrong tag</span>"
  let logger = StringBuilder::new()
  b.bench(name="fixable_hydrate_with_fallback", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.hydrate_with_fallback(container, node, logger=logger))
  })
}

// =============================================================================
// Distance-based Benchmarks: How repair cost scales with mismatch severity
// =============================================================================

// -----------------------------------------------------------------------------
// Distance 0: Clean match (baseline)
// -----------------------------------------------------------------------------

///|
test "distance_0_clean_10_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(10)
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="distance_0_clean_10_nodes", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "distance_0_clean_50_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="distance_0_clean_50_nodes", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "distance_0_clean_100_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(100)
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="distance_0_clean_100_nodes", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// -----------------------------------------------------------------------------
// Distance 1: Single text mismatch (lightest repair)
// -----------------------------------------------------------------------------

///|
test "distance_1_text_10_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(10)
  // Only first text differs
  let html = create_distance_html_text_diff(10, 1)
  let logger = StringBuilder::new()
  b.bench(name="distance_1_text_10_nodes", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "distance_1_text_50_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  let html = create_distance_html_text_diff(50, 1)
  let logger = StringBuilder::new()
  b.bench(name="distance_1_text_50_nodes", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// -----------------------------------------------------------------------------
// Distance 10%: 10% of texts differ
// -----------------------------------------------------------------------------

///|
test "distance_10pct_text_50_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  let html = create_distance_html_text_diff(50, 5) // 10% of 50
  let logger = StringBuilder::new()
  b.bench(name="distance_10pct_text_50_nodes", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "distance_10pct_text_100_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(100)
  let html = create_distance_html_text_diff(100, 10)
  let logger = StringBuilder::new()
  b.bench(name="distance_10pct_text_100_nodes", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// -----------------------------------------------------------------------------
// Distance 50%: Half of texts differ
// -----------------------------------------------------------------------------

///|
test "distance_50pct_text_50_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  let html = create_distance_html_text_diff(50, 25)
  let logger = StringBuilder::new()
  b.bench(name="distance_50pct_text_50_nodes", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "distance_50pct_text_100_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(100)
  let html = create_distance_html_text_diff(100, 50)
  let logger = StringBuilder::new()
  b.bench(name="distance_50pct_text_100_nodes", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// -----------------------------------------------------------------------------
// Distance 100%: All texts differ
// -----------------------------------------------------------------------------

///|
test "distance_100pct_text_50_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  let html = create_distance_html_text_diff(50, 50)
  let logger = StringBuilder::new()
  b.bench(name="distance_100pct_text_50_nodes", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// -----------------------------------------------------------------------------
// Attribute mismatches only
// -----------------------------------------------------------------------------

///|
test "distance_attr_1_of_50" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree_with_attrs(50)
  let html = create_distance_html_attr_diff(50, 1)
  let logger = StringBuilder::new()
  b.bench(name="distance_attr_1_of_50", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "distance_attr_25_of_50" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree_with_attrs(50)
  let html = create_distance_html_attr_diff(50, 25)
  let logger = StringBuilder::new()
  b.bench(name="distance_attr_25_of_50", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// -----------------------------------------------------------------------------
// Missing elements (structural repair)
// -----------------------------------------------------------------------------

///|
test "distance_missing_1_of_50" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  let html = create_distance_html_missing_elements(50, 1)
  let logger = StringBuilder::new()
  b.bench(name="distance_missing_1_of_50", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "distance_missing_10_of_50" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  let html = create_distance_html_missing_elements(50, 10)
  let logger = StringBuilder::new()
  b.bench(name="distance_missing_10_of_50", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "distance_missing_25_of_50" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  let html = create_distance_html_missing_elements(50, 25)
  let logger = StringBuilder::new()
  b.bench(name="distance_missing_25_of_50", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// -----------------------------------------------------------------------------
// Complete mismatch (worst case - should consider full re-render)
// -----------------------------------------------------------------------------

///|
test "distance_complete_mismatch_10" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(10)
  // Completely different structure
  let html = "<span>Wrong</span><p>Content</p>"
  let logger = StringBuilder::new()
  b.bench(name="distance_complete_mismatch_10", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

///|
test "distance_complete_mismatch_50" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  let html = "<span>Wrong</span><p>Content</p>"
  let logger = StringBuilder::new()
  b.bench(name="distance_complete_mismatch_50", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.experimental_hydrate(container, node, logger=logger))
  })
}

// -----------------------------------------------------------------------------
// Comparison: Full re-render vs repair
// -----------------------------------------------------------------------------

///|
test "baseline_full_render_10_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(10)
  b.bench(name="baseline_full_render_10_nodes", fn() {
    b.keep(@dom.render_vnode_to_dom(node))
  })
}

///|
test "baseline_full_render_50_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  b.bench(name="baseline_full_render_50_nodes", fn() {
    b.keep(@dom.render_vnode_to_dom(node))
  })
}

///|
test "baseline_full_render_100_nodes" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(100)
  b.bench(name="baseline_full_render_100_nodes", fn() {
    b.keep(@dom.render_vnode_to_dom(node))
  })
}

// =============================================================================
// Smart Hydrate Benchmarks (with heuristics)
// =============================================================================

///|
test "smart_hydrate_10_nodes_clean" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(10)
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="smart_hydrate_10_nodes_clean", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.smart_hydrate(container, node, logger=logger))
  })
}

///|
test "smart_hydrate_50_nodes_clean" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="smart_hydrate_50_nodes_clean", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.smart_hydrate(container, node, logger=logger))
  })
}

///|
test "smart_hydrate_60_nodes_fallback" (b : @bench.T) {
  @global_jsdom.register()
  // This will trigger fallback due to max_hydration_nodes = 50
  let node = create_distance_tree(60)
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="smart_hydrate_60_nodes_fallback", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.smart_hydrate(container, node, logger=logger))
  })
}

///|
test "smart_hydrate_100_nodes_fallback" (b : @bench.T) {
  @global_jsdom.register()
  // This will trigger fallback due to max_hydration_nodes = 50
  let node = create_distance_tree(100)
  let html = @ssr.render_to_string(node)
  let logger = StringBuilder::new()
  b.bench(name="smart_hydrate_100_nodes_fallback", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.smart_hydrate(container, node, logger=logger))
  })
}

///|
test "smart_hydrate_50_nodes_low_ratio" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  // Only 10% of expected nodes - should trigger fallback
  let html = create_distance_html_missing_elements(50, 45)
  let logger = StringBuilder::new()
  b.bench(name="smart_hydrate_50_nodes_low_ratio", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.smart_hydrate(container, node, logger=logger))
  })
}

///|
test "smart_hydrate_50_nodes_mismatch" (b : @bench.T) {
  @global_jsdom.register()
  let node = create_distance_tree(50)
  // Complete mismatch
  let html = "<span>Wrong</span>"
  let logger = StringBuilder::new()
  b.bench(name="smart_hydrate_50_nodes_mismatch", fn() {
    let container = setup_fixable_container(html)
    b.keep(@fixable.smart_hydrate(container, node, logger=logger))
  })
}

// =============================================================================
// Helper Functions for Distance Benchmarks
// =============================================================================

///|
fn create_distance_tree(count : Int) -> @ui.Node {
  let items : Array[@ui.Node] = []
  for i in 0..<count {
    items.push(@ui.vnode("li", [], [@ui.vtext("Item " + i.to_string())]))
  }
  @ui.vnode("ul", [], items)
}

///|
fn create_distance_tree_with_attrs(count : Int) -> @ui.Node {
  let items : Array[@ui.Node] = []
  for i in 0..<count {
    items.push(
      @ui.vnode(
        "li",
        [("class", @ui.attr_static("item-" + i.to_string()))],
        [@ui.vtext("Item " + i.to_string())],
      ),
    )
  }
  @ui.vnode("ul", [], items)
}

///|
fn create_distance_html_text_diff(count : Int, diff_count : Int) -> String {
  let sb = StringBuilder::new()
  sb.write_string("<ul>")
  for i in 0..<count {
    if i < diff_count {
      // Different text
      sb.write_string("<li>WRONG " + i.to_string() + "</li>")
    } else {
      // Same text
      sb.write_string("<li>Item " + i.to_string() + "</li>")
    }
  }
  sb.write_string("</ul>")
  sb.to_string()
}

///|
fn create_distance_html_attr_diff(count : Int, diff_count : Int) -> String {
  let sb = StringBuilder::new()
  sb.write_string("<ul>")
  for i in 0..<count {
    if i < diff_count {
      // Different class
      sb.write_string("<li class=\"wrong-" + i.to_string() + "\">")
    } else {
      // Same class
      sb.write_string("<li class=\"item-" + i.to_string() + "\">")
    }
    sb.write_string("Item " + i.to_string() + "</li>")
  }
  sb.write_string("</ul>")
  sb.to_string()
}

///|
fn create_distance_html_missing_elements(count : Int, missing : Int) -> String {
  let sb = StringBuilder::new()
  sb.write_string("<ul>")
  // Only render (count - missing) elements
  for i in 0..<(count - missing) {
    sb.write_string("<li>Item " + i.to_string() + "</li>")
  }
  sb.write_string("</ul>")
  sb.to_string()
}
