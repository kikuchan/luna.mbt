///| Routes Compiler - Compile route definitions to optimized format

///|
/// パスを正規化（重複スラッシュ除去、末尾スラッシュ除去）
fn normalize_path(path : String) -> String {
  if path == "" || path == "/" {
    return "/"
  }
  let chars = path.to_array()
  let result : Array[Char] = []
  let mut prev_slash = false
  for c in chars {
    if c == '/' {
      if not(prev_slash) {
        result.push(c)
      }
      prev_slash = true
    } else {
      result.push(c)
      prev_slash = false
    }
  }
  // 末尾スラッシュを除去（ルート以外）
  let len = result.length()
  if len > 1 && result[len - 1] == '/' {
    let _ = result.pop()

  }
  String::from_array(result)
}

///|
/// Routes を CompiledRoutes にコンパイル
pub fn compile(
  routes : Array[Routes],
  base? : String = "",
) -> Array[CompiledRoutes] {
  let result : Array[CompiledRoutes] = []
  compile_inner(routes, base, [], [], result)
  result
}

///|
fn compile_inner(
  routes : Array[Routes],
  prefix : String,
  inherited_params : Array[String],
  inherited_layouts : Array[String],
  result : Array[CompiledRoutes],
) -> Unit {
  for route in routes {
    match route {
      Page(path~, component~, title~, meta~) => {
        let full_path = normalize_path(prefix + path)
        result.push({
          pattern: full_path,
          param_names: inherited_params.copy(),
          component,
          layouts: inherited_layouts.copy(),
          kind: Page,
          title,
          meta,
        })
      }
      Get(path~, handler~) => {
        let full_path = normalize_path(prefix + path)
        result.push({
          pattern: full_path,
          param_names: inherited_params.copy(),
          component: handler,
          layouts: [],
          kind: GetApi,
          title: "",
          meta: [],
        })
      }
      Post(path~, handler~) => {
        let full_path = normalize_path(prefix + path)
        result.push({
          pattern: full_path,
          param_names: inherited_params.copy(),
          component: handler,
          layouts: [],
          kind: PostApi,
          title: "",
          meta: [],
        })
      }
      Param(key~, children~) => {
        // Param adds :key to the prefix and passes it to children
        let new_prefix = normalize_path(prefix + "/:" + key)
        let new_params = inherited_params.copy()
        new_params.push(key)
        compile_inner(
          children, new_prefix, new_params, inherited_layouts, result,
        )
      }
      Layout(segment~, children~, layout~) => {
        let new_prefix = normalize_path(prefix + segment)
        let new_layouts = inherited_layouts.copy()
        new_layouts.push(layout)
        compile_inner(
          children, new_prefix, inherited_params, new_layouts, result,
        )
      }
      Group(segment~, children~) => {
        let new_prefix = normalize_path(prefix + segment)
        compile_inner(
          children, new_prefix, inherited_params, inherited_layouts, result,
        )
      }
    }
  }
}
