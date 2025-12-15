///| Tests for mbti_utils

///|
test "parse simple function" {
  let content =
    #|// Generated using `moon info`, DON'T EDIT IT
    #|package "example/sol-app/client"
    #|
    #|// Values
    #|fn counter(CounterProps) -> @element.DomNode
    #|
    #|// Types and methods
    #|pub(all) struct CounterProps {
    #|  initial_count : Int
    #|}
  let funcs = parse_pub_funcs(content, "test.mbti")
  assert_eq(funcs.length(), 1)
  assert_eq(funcs[0].name, "counter")
  assert_true(funcs[0].type_name is None)
}

///|
test "parse function with type" {
  let content =
    #|package "test"
    #|
    #|fn[A, B] List::map(Self[A], (A) -> B) -> Self[B]
    #|fn[A] empty() -> List[A]
  let funcs = parse_pub_funcs(content, "test.mbti")
  assert_eq(funcs.length(), 2)
  // Method
  assert_eq(funcs[0].name, "map")
  assert_eq(funcs[0].type_name, Some("List"))
  // Standalone function
  assert_eq(funcs[1].name, "empty")
  assert_true(funcs[1].type_name is None)
}

///|
test "get standalone funcs" {
  let content =
    #|package "test"
    #|
    #|fn[A, B] List::map(Self[A], (A) -> B) -> Self[B]
    #|fn counter(Props) -> Node
    #|fn render(State) -> Node
  let funcs = parse_pub_funcs(content, "test.mbti")
  let standalone = get_standalone_funcs(funcs)
  assert_eq(standalone.length(), 2)
  assert_eq(standalone[0], "counter")
  assert_eq(standalone[1], "render")
}
