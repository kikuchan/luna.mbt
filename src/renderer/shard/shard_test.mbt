///|
/// Tests for shard module
test "escape_json_for_html - safe string passes through" {
  let safe = "{\"count\":0}"
  let result = @shard.escape_json_for_html(safe)
  assert_eq(result, safe)
}

///|
test "escape_json_for_html - escapes script closing tag" {
  let dangerous = "{\"html\":\"</script><script>alert(1)</script>\"}"
  let result = @shard.escape_json_for_html(dangerous)
  assert_true(result.contains("<\\/script>"))
  assert_true(not(result.contains("</script>")))
}

///|
test "escape_json_for_html - escapes lowercase script tag" {
  let dangerous = "<script>alert(1)</script>"
  let result = @shard.escape_json_for_html(dangerous)
  assert_true(result.contains("<\\u0073cript>"))
}

///|
test "escape_json_for_html - escapes uppercase Script tag" {
  let dangerous = "<Script>alert(1)</Script>"
  let result = @shard.escape_json_for_html(dangerous)
  assert_true(result.contains("<\\u0053cript>"))
}

///|
test "generate_state_script - generates script element" {
  let result = @shard.generate_state_script("my-state", "{\"count\":42}")
  assert_true(result.has_prefix("<script id=\"my-state\""))
  assert_true(result.contains("type=\"ln/json\""))
  assert_true(result.contains("{\"count\":42}"))
  assert_true(result.has_suffix("</script>"))
}

///|
test "TriggerType::to_string - converts to string" {
  assert_eq(@shard.TriggerType::Load.to_string(), "load")
  assert_eq(@shard.TriggerType::Idle.to_string(), "idle")
  assert_eq(@shard.TriggerType::Visible.to_string(), "visible")
  assert_eq(@shard.TriggerType::None.to_string(), "none")
  assert_eq(
    @shard.TriggerType::Media("(min-width: 768px)").to_string(),
    "media:(min-width: 768px)",
  )
}

///|
test "TriggerType::parse - parses from string" {
  assert_true(
    match @shard.TriggerType::parse("load") {
      Load => true
      _ => false
    },
  )
  assert_true(
    match @shard.TriggerType::parse("idle") {
      Idle => true
      _ => false
    },
  )
  assert_true(
    match @shard.TriggerType::parse("visible") {
      Visible => true
      _ => false
    },
  )
  assert_true(
    match @shard.TriggerType::parse("none") {
      None => true
      _ => false
    },
  )
  assert_true(
    match @shard.TriggerType::parse("media:(min-width: 768px)") {
      Media(_) => true
      _ => false
    },
  )
}

///|
test "format_state_attr - inline JSON" {
  let result = @shard.format_state_attr(@shard.StateConfig::Inline("{\"x\":1}"))
  // " is escaped as &quot; for HTML attribute safety
  assert_eq(result, Some("{&quot;x&quot;:1}"))
}

///|
test "format_state_attr - script reference" {
  let result = @shard.format_state_attr(
    @shard.StateConfig::ScriptRef("my-state"),
  )
  assert_eq(result, Some("#my-state"))
}

///|
test "format_state_attr - URL reference" {
  let result = @shard.format_state_attr(
    @shard.StateConfig::Url("https://api.example.com/state"),
  )
  assert_eq(result, Some("url:https://api.example.com/state"))
}

///|
test "format_state_attr - empty returns None" {
  let result = @shard.format_state_attr(@shard.StateConfig::Empty)
  assert_eq(result, None)
}

///|
test "generate_shard - minimal config" {
  let config = @shard.ShardConfig::new("counter-1", "./counter.js")
  let output = @shard.generate_shard(config)
  assert_true(output.html.contains("ln:id=\"counter-1\""))
  assert_true(output.html.contains("ln:url=\"./counter.js\""))
  // load is default, should not be included
  assert_true(not(output.html.contains("ln:trigger")))
}

///|
test "generate_shard - with visible trigger" {
  let config = @shard.ShardConfig::new("lazy-1", "./lazy.js").with_trigger(
    @shard.TriggerType::Visible,
  )
  let output = @shard.generate_shard(config)
  assert_true(output.html.contains("ln:trigger=\"visible\""))
}

///|
test "generate_shard - with inline state" {
  let config = @shard.ShardConfig::new("stateful-1", "./stateful.js").with_state(
    "{\"count\":0}",
  )
  let output = @shard.generate_shard(config)
  // State is HTML-escaped for attribute safety
  assert_true(output.html.contains("ln:state=\"{&quot;count&quot;:0}\""))
}

///|
test "generate_shard - with SSR content" {
  let config = @shard.ShardConfig::new("ssr-1", "./ssr.js").with_ssr_content(
    "<span>Hello</span>",
  )
  let output = @shard.generate_shard(config)
  assert_true(output.html.contains("<span>Hello</span>"))
}

///|
test "generate_shard - with loader" {
  let config = @shard.ShardConfig::new("standalone-1", "./standalone.js").with_loader(
    "https://cdn.example.com/ln-loader-v1.js",
  )
  let output = @shard.generate_shard(config)
  assert_true(
    output.html.contains(
      "<script type=\"module\" src=\"https://cdn.example.com/ln-loader-v1.js\">",
    ),
  )
  assert_eq(output.head_scripts.length(), 1)
}

///|
test "recommend_state_format - small state" {
  assert_eq(@shard.recommend_state_format(500), "inline")
}

///|
test "recommend_state_format - medium state" {
  assert_eq(@shard.recommend_state_format(5000), "script_ref")
}

///|
test "recommend_state_format - large state" {
  assert_eq(@shard.recommend_state_format(200000), "url")
}

// ============================================================================
// html_builder.mbt tests
// ============================================================================

///|
test "generate_shard_with_state_script - creates script and reference" {
  let config = @shard.ShardConfig::new("big-1", "./big.js")
  let output = @shard.generate_shard_with_state_script(config, "{\"data\":[1,2,3]}")
  // Should have script reference in attributes
  assert_true(output.html.contains("ln:state=\"#ln-state-big-1\""))
  // Should have state script element
  assert_true(output.html.contains("<script id=\"ln-state-big-1\""))
  assert_true(output.html.contains("type=\"ln/json\""))
  assert_true(output.state_scripts.length() == 1)
}

///|
test "generate_minimal_shard - creates minimal HTML" {
  let html = @shard.generate_minimal_shard(
    "min-1",
    "./min.js",
    "{\"x\":1}",
    "<span>Content</span>",
  )
  assert_true(html.contains("ln:id=\"min-1\""))
  assert_true(html.contains("ln:url=\"./min.js\""))
  assert_true(html.contains("<span>Content</span>"))
  // Should not have trigger (default load is omitted)
  assert_true(not(html.contains("ln:trigger")))
  // Should not have loader script
  assert_true(not(html.contains("<script type=\"module\"")))
}

///|
test "generate_standalone_shard - includes loader" {
  let html = @shard.generate_standalone_shard(
    "standalone-1",
    "./standalone.js",
    "https://cdn.example.com/loader.js",
    "{\"y\":2}",
    "<div>SSR</div>",
  )
  assert_true(html.contains("<script type=\"module\" src=\"https://cdn.example.com/loader.js\">"))
  assert_true(html.contains("ln:id=\"standalone-1\""))
  assert_true(html.contains("<div>SSR</div>"))
}

///|
test "generate_lazy_shard - uses visible trigger" {
  let html = @shard.generate_lazy_shard(
    "lazy-1",
    "./lazy.js",
    "{\"z\":3}",
    "<p>Lazy</p>",
  )
  assert_true(html.contains("ln:trigger=\"visible\""))
  assert_true(html.contains("<p>Lazy</p>"))
}

///|
test "generate_shard_group - single loader for multiple shards" {
  let configs = [
    @shard.ShardConfig::new("s1", "./s1.js"),
    @shard.ShardConfig::new("s2", "./s2.js"),
  ]
  let html = @shard.generate_shard_group("https://cdn.example.com/loader.js", configs)
  // Should have single loader script at start
  assert_true(html.has_prefix("<script type=\"module\" src=\"https://cdn.example.com/loader.js\">"))
  // Should have both shards
  assert_true(html.contains("ln:id=\"s1\""))
  assert_true(html.contains("ln:id=\"s2\""))
}

///|
test "auto_select_state_format - small state uses inline" {
  let base = @shard.ShardConfig::new("test-1", "./test.js")
  let small_json = "{\"x\":1}"
  let config = @shard.auto_select_state_format(small_json, base)
  match config.state {
    Inline(json) => assert_eq(json, small_json)
    _ => fail("Expected Inline for small state")
  }
}

///|
test "auto_select_state_format - medium state uses script ref" {
  let base = @shard.ShardConfig::new("test-2", "./test.js")
  // Create a string larger than 1KB but smaller than 100KB
  let sb = StringBuilder::new()
  sb.write_string("{\"data\":\"")
  for _ in 0..<2000 {
    sb.write_char('x')
  }
  sb.write_string("\"}")
  let medium_json = sb.to_string()
  let config = @shard.auto_select_state_format(medium_json, base)
  match config.state {
    ScriptRef(id) => assert_eq(id, "ln-state-test-2")
    _ => fail("Expected ScriptRef for medium state")
  }
}

///|
test "generate_shard - with media trigger" {
  let config = @shard.ShardConfig::new("media-1", "./media.js").with_trigger(
    @shard.TriggerType::Media("(min-width: 768px)"),
  )
  let output = @shard.generate_shard(config)
  assert_true(output.html.contains("ln:trigger=\"media:(min-width: 768px)\""))
}
