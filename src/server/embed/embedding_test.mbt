///|
/// Tests for embedding module
test "escape_json_for_html - safe string passes through" {
  let safe = "{\"count\":0}"
  let result = @embed.escape_json_for_html(safe)
  assert_eq(result, safe)
}

///|
test "escape_json_for_html - escapes script closing tag" {
  let dangerous = "{\"html\":\"</script><script>alert(1)</script>\"}"
  let result = @embed.escape_json_for_html(dangerous)
  assert_true(result.contains("<\\/script>"))
  assert_true(not(result.contains("</script>")))
}

///|
test "escape_json_for_html - escapes lowercase script tag" {
  let dangerous = "<script>alert(1)</script>"
  let result = @embed.escape_json_for_html(dangerous)
  assert_true(result.contains("<\\u0073cript>"))
}

///|
test "escape_json_for_html - escapes uppercase Script tag" {
  let dangerous = "<Script>alert(1)</Script>"
  let result = @embed.escape_json_for_html(dangerous)
  assert_true(result.contains("<\\u0053cript>"))
}

///|
test "generate_state_script - generates script element" {
  let result = @embed.generate_state_script("my-state", "{\"count\":42}")
  assert_true(result.has_prefix("<script id=\"my-state\""))
  assert_true(result.contains("type=\"kg/json\""))
  assert_true(result.contains("{\"count\":42}"))
  assert_true(result.has_suffix("</script>"))
}

///|
test "TriggerType::to_string - converts to string" {
  assert_eq(@embed.TriggerType::Load.to_string(), "load")
  assert_eq(@embed.TriggerType::Idle.to_string(), "idle")
  assert_eq(@embed.TriggerType::Visible.to_string(), "visible")
  assert_eq(@embed.TriggerType::None.to_string(), "none")
  assert_eq(
    @embed.TriggerType::Media("(min-width: 768px)").to_string(),
    "media:(min-width: 768px)",
  )
}

///|
test "TriggerType::parse - parses from string" {
  assert_true(
    match @embed.TriggerType::parse("load") {
      Load => true
      _ => false
    },
  )
  assert_true(
    match @embed.TriggerType::parse("idle") {
      Idle => true
      _ => false
    },
  )
  assert_true(
    match @embed.TriggerType::parse("visible") {
      Visible => true
      _ => false
    },
  )
  assert_true(
    match @embed.TriggerType::parse("none") {
      None => true
      _ => false
    },
  )
  assert_true(
    match @embed.TriggerType::parse("media:(min-width: 768px)") {
      Media(_) => true
      _ => false
    },
  )
}

///|
test "format_state_attr - inline JSON" {
  let result = @embed.format_state_attr(
    @embed.StateConfig::Inline("{\"x\":1}"),
  )
  // " is escaped as &quot; for HTML attribute safety
  assert_eq(result, Some("{&quot;x&quot;:1}"))
}

///|
test "format_state_attr - script reference" {
  let result = @embed.format_state_attr(
    @embed.StateConfig::ScriptRef("my-state"),
  )
  assert_eq(result, Some("#my-state"))
}

///|
test "format_state_attr - URL reference" {
  let result = @embed.format_state_attr(
    @embed.StateConfig::Url("https://api.example.com/state"),
  )
  assert_eq(result, Some("url:https://api.example.com/state"))
}

///|
test "format_state_attr - empty returns None" {
  let result = @embed.format_state_attr(@embed.StateConfig::Empty)
  assert_eq(result, None)
}

///|
test "generate_embed - minimal config" {
  let config = @embed.EmbedConfig::new("counter-1", "./counter.js")
  let output = @embed.generate_embed(config)
  assert_true(output.html.contains("kg:id=\"counter-1\""))
  assert_true(output.html.contains("kg:url=\"./counter.js\""))
  // load is default, should not be included
  assert_true(not(output.html.contains("kg:trigger")))
}

///|
test "generate_embed - with visible trigger" {
  let config = @embed.EmbedConfig::new("lazy-1", "./lazy.js").with_trigger(
    @embed.TriggerType::Visible,
  )
  let output = @embed.generate_embed(config)
  assert_true(output.html.contains("kg:trigger=\"visible\""))
}

///|
test "generate_embed - with inline state" {
  let config = @embed.EmbedConfig::new("stateful-1", "./stateful.js").with_state(
    "{\"count\":0}",
  )
  let output = @embed.generate_embed(config)
  // State is HTML-escaped for attribute safety
  assert_true(output.html.contains("kg:state=\"{&quot;count&quot;:0}\""))
}

///|
test "generate_embed - with SSR content" {
  let config = @embed.EmbedConfig::new("ssr-1", "./ssr.js").with_ssr_content(
    "<span>Hello</span>",
  )
  let output = @embed.generate_embed(config)
  assert_true(output.html.contains("<span>Hello</span>"))
}

///|
test "generate_embed - with loader" {
  let config = @embed.EmbedConfig::new("standalone-1", "./standalone.js").with_loader(
    "https://cdn.example.com/kg-loader-v1.js",
  )
  let output = @embed.generate_embed(config)
  assert_true(
    output.html.contains(
      "<script type=\"module\" src=\"https://cdn.example.com/kg-loader-v1.js\">",
    ),
  )
  assert_eq(output.head_scripts.length(), 1)
}

///|
test "recommend_state_format - small state" {
  assert_eq(@embed.recommend_state_format(500), "inline")
}

///|
test "recommend_state_format - medium state" {
  assert_eq(@embed.recommend_state_format(5000), "script_ref")
}

///|
test "recommend_state_format - large state" {
  assert_eq(@embed.recommend_state_format(200000), "url")
}
