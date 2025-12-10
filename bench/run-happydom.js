/**
 * JS Benchmark runner with happy-dom
 * Usage: node bench/run-happydom.js
 *
 * happy-dom is supposed to be faster than jsdom for DOM operations
 */

import { Window } from "happy-dom";

// Setup happy-dom global environment
const window = new Window();
globalThis.window = window;
globalThis.document = window.document;
globalThis.HTMLElement = window.HTMLElement;
globalThis.Element = window.Element;
globalThis.Node = window.Node;
globalThis.Text = window.Text;
globalThis.Comment = window.Comment;
globalThis.DocumentFragment = window.DocumentFragment;

import {
  createSignal,
  get,
  set,
  effect,
  batch,
  createMemo,
  createRoot,
} from "../target/js/release/build/js/api/api.js";
import {
  div,
  span,
  text,
  render,
  mount,
  className,
} from "../target/js/release/build/js/dom/dom.js";

// Configuration
const ITERATIONS = 1000;
const WARMUP = 100;

// Create a container for DOM rendering
const container = document.createElement("div");
document.body.appendChild(container);

function bench(name, fn) {
  // Warmup
  for (let i = 0; i < WARMUP; i++) {
    fn();
  }

  // Actual run
  const start = performance.now();
  for (let i = 0; i < ITERATIONS; i++) {
    fn();
  }
  const elapsed = performance.now() - start;
  console.log(
    `${name}: ${elapsed.toFixed(2)}ms total, ${(elapsed / ITERATIONS).toFixed(4)}ms/op`
  );
}

function createListNode(count) {
  const items = [];
  for (let i = 0; i < count; i++) {
    items.push(div([], [text(`Item ${i}`)]));
  }
  return div([], items);
}

function createNestedNode(depth) {
  let node = text("leaf");
  for (let i = 0; i < depth; i++) {
    node = div([], [node]);
  }
  return node;
}

function createListNodeWithAttrs(count) {
  const items = [];
  for (let i = 0; i < count; i++) {
    items.push(div([className(`item-${i}`)], [text(`Item ${i}`)]));
  }
  return div([className("list")], items);
}

console.log("=== MoonBit UI JS Benchmarks (happy-dom) ===");
console.log(`Iterations: ${ITERATIONS}, Warmup: ${WARMUP}`);
console.log("");

// Signal benchmarks
console.log("--- Signal Operations ---");

bench("createSignal", () => {
  createSignal(0);
});

bench("signal_get_10x", () => {
  createRoot(() => {
    const sig = createSignal(0);
    for (let i = 0; i < 10; i++) {
      get(sig);
    }
  });
});

bench("signal_set_10x", () => {
  createRoot(() => {
    const sig = createSignal(0);
    for (let i = 0; i < 10; i++) {
      set(sig, i);
    }
  });
});

bench("effect_creation", () => {
  createRoot(() => {
    const sig = createSignal(0);
    effect(() => {
      get(sig);
    });
  });
});

bench("effect_trigger_10x", () => {
  createRoot(() => {
    const sig = createSignal(0);
    let count = 0;
    effect(() => {
      get(sig);
      count++;
    });
    for (let i = 0; i < 10; i++) {
      set(sig, i);
    }
  });
});

bench("batch_updates", () => {
  createRoot(() => {
    const sig1 = createSignal(0);
    const sig2 = createSignal(0);
    const sig3 = createSignal(0);
    let count = 0;
    effect(() => {
      get(sig1);
      get(sig2);
      get(sig3);
      count++;
    });
    batch(() => {
      set(sig1, 1);
      set(sig2, 2);
      set(sig3, 3);
    });
  });
});

bench("memo_creation", () => {
  createRoot(() => {
    const sig = createSignal(0);
    createMemo(() => get(sig) * 2);
  });
});

bench("memo_chain_5", () => {
  createRoot(() => {
    const sig = createSignal(0);
    const m1 = createMemo(() => get(sig) + 1);
    const m2 = createMemo(() => m1() * 2);
    const m3 = createMemo(() => m2() + 1);
    const m4 = createMemo(() => m3() * 2);
    const m5 = createMemo(() => m4() + 1);
    m5();
  });
});

// VNode creation benchmarks
console.log("");
console.log("--- VNode Creation ---");

bench("vnode_simple", () => {
  div([], [text("Hello")]);
});

bench("vnode_with_attrs", () => {
  div([className("container")], [text("Hello")]);
});

bench("vnode_list_10", () => {
  createListNode(10);
});

bench("vnode_list_50", () => {
  createListNode(50);
});

bench("vnode_list_100", () => {
  createListNode(100);
});

bench("vnode_list_with_attrs_50", () => {
  createListNodeWithAttrs(50);
});

bench("vnode_nested_10", () => {
  createNestedNode(10);
});

bench("vnode_nested_50", () => {
  createNestedNode(50);
});

// DOM rendering benchmarks
console.log("");
console.log("--- DOM Rendering ---");

bench("render_simple", () => {
  const node = div([], [text("Hello")]);
  render(container, node);
});

bench("render_with_attrs", () => {
  const node = div([className("container")], [text("Hello")]);
  render(container, node);
});

bench("render_list_10", () => {
  const node = createListNode(10);
  render(container, node);
});

bench("render_list_50", () => {
  const node = createListNode(50);
  render(container, node);
});

bench("render_list_100", () => {
  const node = createListNode(100);
  render(container, node);
});

bench("render_nested_10", () => {
  const node = createNestedNode(10);
  render(container, node);
});

// Mount only (no clear) benchmarks
console.log("");
console.log("--- DOM Mount (no clear) ---");

bench("mount_simple", () => {
  const node = div([], [text("Hello")]);
  mount(container, node);
  container.innerHTML = "";
});

bench("mount_list_50", () => {
  const node = createListNode(50);
  mount(container, node);
  container.innerHTML = "";
});

console.log("");
console.log("=== Benchmark Complete ===");

// Cleanup
await window.happyDOM.close();
