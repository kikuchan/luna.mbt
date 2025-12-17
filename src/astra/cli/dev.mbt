///| Astra dev command - Development server with watch mode (planned)

///|
fn show_dev_help() -> Unit {
  let help =
    #|Usage: astra dev [options]
    #|
    #|Start development server with file watching
    #|
    #|Options:
    #|  -p, --port <port>    Port to listen on (default: 3000)
    #|  -c, --config <path>  Config file path
    #|  -h, --help           Show help
    #|
    #|Note: This feature is not yet implemented.
    #|For now, use:
    #|  astra build && npx serve dist
  println(help)
}

///|
fn run_dev_command(args : Array[String]) -> Unit {
  let result = @util.parseArgs(
    args~,
    options=[
      @util.String(key="port", short="p", multiple=false, default=Some("3000")),
      @util.String(key="config", short="c", multiple=false, default=None),
      @util.Boolean(key="help", short="h"),
    ],
    allow_positionals=false,
  )
  if result.values.contains("help") && result.values["help"].cast() {
    show_dev_help()
    return
  }

  // Not yet implemented
  println(@colorette.yellow("⚠ astra dev is not yet implemented"))
  println("")
  println("For now, use:")
  println(@colorette.cyan("  astra build && npx serve dist"))
  println("")
  println("Or with file watching:")
  println(@colorette.cyan("  nodemon --watch docs -e md --exec 'astra build'"))
}
