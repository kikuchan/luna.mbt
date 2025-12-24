// Astra Lint - Check documentation for common issues
//

///|
/// Lint issue severity
pub(all) enum LintSeverity {
  Error
  Warning
  Info
}

///|
/// Lint issue
pub(all) struct LintIssue {
  severity : LintSeverity
  file : String
  line : Int?
  message : String
  rule : String
}

///|
/// Lint result
pub(all) struct LintResult {
  issues : Array[LintIssue]
  files_checked : Int
  errors : Int
  warnings : Int
}

///|
/// Run lint command
pub fn run_lint_command(args : Array[String]) -> Unit {
  // Parse options
  let mut fix = false
  for arg in args {
    if arg == "--fix" {
      fix = arg == "--fix"
    }
  }
  let _ = fix // TODO: implement fix mode

  // Load config
  let cwd = @process.cwd()
  let config = load_config(cwd)

  println(@colorette.cyan("Linting documentation..."))
  println("")

  // Run linter
  let result = lint_docs(config, cwd)

  // Print results
  print_lint_results(result)

  // Exit with error if any errors found
  if result.errors > 0 {
    @process.exit(1)
  }
}

///|
/// Load configuration
fn load_config(cwd : String) -> @astra.SsgConfig {
  let config_path = @path.join2(cwd, "astra.json")
  if @fs.existsSync(config_path) {
    let content : String = @fs.readFileSync(config_path).to_string() catch {
      _ => return @astra.SsgConfig::default()
    }
    @astra.parse_ssg_config(content).unwrap_or(@astra.SsgConfig::default())
  } else {
    @astra.SsgConfig::default()
  }
}

///|
/// Main lint function
pub fn lint_docs(config : @astra.SsgConfig, cwd : String) -> LintResult {
  let issues : Array[LintIssue] = []

  // Scan docs directory
  let pages = @routes.scan_docs_dir(
    config.docs_dir,
    cwd,
    i18n=config.i18n,
    exclude=config.exclude,
    trailing_slash=config.trailing_slash,
  )

  // Build URL set for dead link detection
  let valid_urls : Map[String, Bool] = {}
  for page in pages {
    valid_urls[page.url_path] = true
    // Also add without trailing slash
    let without_slash = page.url_path.trim_end(chars="/").to_string()
    if not(without_slash.is_empty()) {
      valid_urls[without_slash] = true
    }
  }

  // Check each page
  for page in pages {
    let source_path = @path.join2(
      @path.join2(cwd, config.docs_dir),
      page.source_path,
    )

    // Read file content
    let content : String = @fs.readFileSync(source_path).to_string() catch {
      _ => continue
    }

    // Parse markdown
    let (frontmatter, nodes) = @markdown.parse_markdown(content)

    // Check frontmatter
    check_frontmatter(page.source_path, frontmatter, issues)

    // Check links
    check_links(page.source_path, page.url_path, nodes, valid_urls, issues)

    // Check images
    check_images(page.source_path, nodes, issues)
  }

  // Count by severity
  let mut errors = 0
  let mut warnings = 0
  for issue in issues {
    match issue.severity {
      Error => errors = errors + 1
      Warning => warnings = warnings + 1
      Info => ()
    }
  }

  LintResult::{
    issues,
    files_checked: pages.length(),
    errors,
    warnings,
  }
}

///|
/// Check frontmatter for issues
fn check_frontmatter(
  file : String,
  fm : @astra.Frontmatter,
  issues : Array[LintIssue],
) -> Unit {
  // Check title
  if fm.title is None {
    issues.push(LintIssue::{
      severity: Warning,
      file,
      line: None,
      message: "Missing 'title' in frontmatter",
      rule: "missing-title",
    })
  }

  // Check description (warning only since we auto-generate)
  if fm.description is None {
    issues.push(LintIssue::{
      severity: Info,
      file,
      line: None,
      message: "Missing 'description' in frontmatter (will be auto-generated from content)",
      rule: "missing-description",
    })
  }
}

///|
/// Check links in markdown content
fn check_links(
  file : String,
  current_url : String,
  nodes : Array[@astra.MdNode],
  valid_urls : Map[String, Bool],
  issues : Array[LintIssue],
) -> Unit {
  check_links_recursive(file, current_url, nodes, valid_urls, issues)
}

///|
/// Recursively check links in nodes
fn check_links_recursive(
  file : String,
  current_url : String,
  nodes : Array[@astra.MdNode],
  valid_urls : Map[String, Bool],
  issues : Array[LintIssue],
) -> Unit {
  for node in nodes {
    match node {
      @astra.MdNode::Link(href~, children~, ..) => {
        // Check if internal link
        if is_internal_link(href) {
          let resolved = resolve_link(current_url, href)
          if not(is_valid_internal_link(resolved, valid_urls)) {
            issues.push(LintIssue::{
              severity: Error,
              file,
              line: None,
              message: "Dead link: '\{href}' (resolved to '\{resolved}')",
              rule: "dead-link",
            })
          }
        }
        // Check children
        check_links_recursive(file, current_url, children, valid_urls, issues)
      }
      @astra.MdNode::Paragraph(children~) =>
        check_links_recursive(file, current_url, children, valid_urls, issues)
      @astra.MdNode::Heading(children~, ..) =>
        check_links_recursive(file, current_url, children, valid_urls, issues)
      @astra.MdNode::Bold(children~) =>
        check_links_recursive(file, current_url, children, valid_urls, issues)
      @astra.MdNode::Italic(children~) =>
        check_links_recursive(file, current_url, children, valid_urls, issues)
      @astra.MdNode::Blockquote(children~) =>
        check_links_recursive(file, current_url, children, valid_urls, issues)
      @astra.MdNode::List(items~, ..) =>
        for item in items {
          check_links_recursive(file, current_url, item, valid_urls, issues)
        }
      _ => ()
    }
  }
}

///|
/// Check if href is an internal link
fn is_internal_link(href : String) -> Bool {
  // External links
  if href.has_prefix("http://") || href.has_prefix("https://") {
    return false
  }
  // Mailto links
  if href.has_prefix("mailto:") {
    return false
  }
  // Hash-only links (anchors)
  if href.has_prefix("#") {
    return false
  }
  // JavaScript links
  if href.has_prefix("javascript:") {
    return false
  }
  true
}

///|
/// Resolve relative link to absolute path
fn resolve_link(current_url : String, href : String) -> String {
  // Already absolute
  if href.has_prefix("/") {
    return normalize_url(href)
  }

  // Relative link - resolve from current URL
  let base = if current_url.has_suffix("/") {
    current_url
  } else {
    // Get directory part
    let parts = current_url.to_array()
    let mut last_slash = 0
    for i = 0; i < parts.length(); i = i + 1 {
      if parts[i] == '/' {
        last_slash = i
      }
    }
    if last_slash > 0 {
      String::from_array(parts[:last_slash + 1].to_array())
    } else {
      "/"
    }
  }

  normalize_url(base + href)
}

///|
/// Normalize URL path
fn normalize_url(url : String) -> String {
  // Handle ./ and ../
  let mut result = url

  // Remove ./
  result = result.replace(old="/./", new="/")
  if result.has_prefix("./") {
    result = result.replace(old="./", new="/")
  }

  // Simple normalization - ensure ends with / or has extension
  if not(result.has_suffix("/")) && not(has_extension(result)) {
    result = result + "/"
  }

  result
}

///|
/// Check if URL has a file extension
fn has_extension(url : String) -> Bool {
  let parts = url.to_array()
  let mut last_dot = -1
  let mut last_slash = -1
  for i = 0; i < parts.length(); i = i + 1 {
    if parts[i] == '.' {
      last_dot = i
    }
    if parts[i] == '/' {
      last_slash = i
    }
  }
  last_dot > last_slash && last_dot > 0
}

///|
/// Check if resolved URL is valid
fn is_valid_internal_link(url : String, valid_urls : Map[String, Bool]) -> Bool {
  // Direct match
  if valid_urls.contains(url) {
    return true
  }

  // Try with trailing slash
  if not(url.has_suffix("/")) {
    if valid_urls.contains(url + "/") {
      return true
    }
  }

  // Try without trailing slash
  if url.has_suffix("/") {
    let without = url.trim_end(chars="/").to_string()
    if valid_urls.contains(without) {
      return true
    }
  }

  false
}

///|
/// Check images for alt text
fn check_images(
  file : String,
  nodes : Array[@astra.MdNode],
  issues : Array[LintIssue],
) -> Unit {
  check_images_recursive(file, nodes, issues)
}

///|
/// Recursively check images
fn check_images_recursive(
  file : String,
  nodes : Array[@astra.MdNode],
  issues : Array[LintIssue],
) -> Unit {
  for node in nodes {
    match node {
      @astra.MdNode::Image(src~, alt~, ..) => {
        if alt.is_empty() {
          issues.push(LintIssue::{
            severity: Warning,
            file,
            line: None,
            message: "Image missing alt text: '\{src}'",
            rule: "missing-alt",
          })
        }
      }
      @astra.MdNode::Paragraph(children~) =>
        check_images_recursive(file, children, issues)
      @astra.MdNode::Heading(children~, ..) =>
        check_images_recursive(file, children, issues)
      @astra.MdNode::Bold(children~) =>
        check_images_recursive(file, children, issues)
      @astra.MdNode::Italic(children~) =>
        check_images_recursive(file, children, issues)
      @astra.MdNode::Blockquote(children~) =>
        check_images_recursive(file, children, issues)
      @astra.MdNode::List(items~, ..) =>
        for item in items {
          check_images_recursive(file, item, issues)
        }
      _ => ()
    }
  }
}

///|
/// Print lint results
fn print_lint_results(result : LintResult) -> Unit {
  // Group issues by file
  let by_file : Map[String, Array[LintIssue]] = {}
  for issue in result.issues {
    match by_file.get(issue.file) {
      Some(arr) => arr.push(issue)
      None => by_file[issue.file] = [issue]
    }
  }

  // Print issues by file
  for file in by_file.keys() {
    let issues = by_file.get(file).unwrap()
    println(@colorette.bold(file))
    for issue in issues {
      let severity_str = match issue.severity {
        Error => @colorette.red("error")
        Warning => @colorette.yellow("warning")
        Info => @colorette.blue("info")
      }
      let line_str = match issue.line {
        Some(n) => ":\{n}"
        None => ""
      }
      println("  \{severity_str}\{line_str}: \{issue.message} [\{issue.rule}]")
    }
    println("")
  }

  // Print summary
  println(@colorette.bold("Summary:"))
  println("  Files checked: \{result.files_checked}")
  if result.errors > 0 {
    println("  Errors: \{@colorette.red(result.errors.to_string())}")
  }
  if result.warnings > 0 {
    println("  Warnings: \{@colorette.yellow(result.warnings.to_string())}")
  }
  if result.errors == 0 && result.warnings == 0 {
    let msg = @colorette.green("No issues found!")
    println("  \{msg}")
  }
}
