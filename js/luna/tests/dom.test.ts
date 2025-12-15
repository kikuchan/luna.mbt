import { describe, test, expect, beforeEach } from "vitest";
import {
  text,
  textDyn,
  createElement,
  render,
  mount,
  show,
  jsx,
  jsxs,
  Fragment,
  events,
  forEach,
  createSignal,
  get,
  set,
  effect,
} from "../index.js";

// MoonBit tuple representation for attrs: [name, value] -> { _0: name, _1: value }
// AttrValue constructors: $tag: 0 = Static, 1 = Dynamic, 2 = Handler
function attr(name: string, value: unknown) {
  return { _0: name, _1: value };
}

const AttrValue = {
  Static: (value: string) => ({ $tag: 0, _0: value }),
  Dynamic: (getter: () => string) => ({ $tag: 1, _0: getter }),
  Handler: (handler: (e: unknown) => void) => ({ $tag: 2, _0: handler }),
};

describe("DOM API", () => {
  let container: HTMLElement;

  beforeEach(() => {
    container = document.createElement("div");
    document.body.appendChild(container);
  });

  describe("text nodes", () => {
    test("text creates a text node", () => {
      const node = text("hello");
      expect(node).toBeDefined();
    });

    test("text node renders to DOM", () => {
      const node = text("hello world");
      render(container, node);
      expect(container.textContent).toBe("hello world");
    });

    test("textDyn creates reactive text node", () => {
      const signal = createSignal("initial");
      const node = textDyn(() => get(signal));
      render(container, node);
      expect(container.textContent).toBe("initial");

      set(signal, "updated");
      expect(container.textContent).toBe("updated");
    });
  });

  describe("createElement", () => {
    test("createElement creates element with no attrs", () => {
      const node = createElement("div", [], []);
      expect(node).toBeDefined();
    });

    test("createElement renders to DOM", () => {
      const node = createElement("div", [], [text("content")]);
      render(container, node);
      expect(container.innerHTML).toBe("<div>content</div>");
    });

    test("createElement with static attributes", () => {
      const node = createElement(
        "div",
        [
          attr("id", AttrValue.Static("my-id")),
          attr("className", AttrValue.Static("my-class")),
        ],
        []
      );
      render(container, node);
      const div = container.querySelector("div");
      expect(div?.id).toBe("my-id");
      expect(div?.className).toBe("my-class");
    });

    test("createElement with style attribute", () => {
      const node = createElement(
        "div",
        [attr("style", AttrValue.Static("color: red; margin: 10px"))],
        []
      );
      render(container, node);
      const div = container.querySelector("div");
      expect(div?.getAttribute("style")).toBe("color: red; margin: 10px");
    });

    test("createElement with nested children", () => {
      const node = createElement("div", [], [
        createElement("span", [], [text("child1")]),
        createElement("span", [], [text("child2")]),
      ]);
      render(container, node);
      expect(container.querySelectorAll("span").length).toBe(2);
    });

    test("createElement with dynamic attribute", () => {
      const signal = createSignal("initial-class");
      const node = createElement(
        "div",
        [attr("className", AttrValue.Dynamic(() => get(signal)))],
        []
      );
      render(container, node);
      const div = container.querySelector("div");
      expect(div?.className).toBe("initial-class");

      set(signal, "updated-class");
      expect(div?.className).toBe("updated-class");
    });

    test("createElement with event handler", () => {
      let clicked = false;
      const node = createElement(
        "button",
        [attr("click", AttrValue.Handler(() => { clicked = true; }))],
        [text("Click me")]
      );
      render(container, node);
      const button = container.querySelector("button");
      button?.click();
      expect(clicked).toBe(true);
    });

    test("createElement with value attribute (input)", () => {
      const node = createElement(
        "input",
        [attr("value", AttrValue.Static("test-value"))],
        []
      );
      render(container, node);
      const input = container.querySelector("input") as HTMLInputElement;
      expect(input?.value).toBe("test-value");
    });

    test("createElement with checked attribute", () => {
      const node = createElement(
        "input",
        [
          attr("type", AttrValue.Static("checkbox")),
          attr("checked", AttrValue.Static("true")),
        ],
        []
      );
      render(container, node);
      const input = container.querySelector("input") as HTMLInputElement;
      expect(input?.checked).toBe(true);
    });

    test("createElement with disabled attribute true", () => {
      const nodeDisabled = createElement(
        "button",
        [attr("disabled", AttrValue.Static("true"))],
        []
      );
      render(container, nodeDisabled);
      const btn = container.querySelector("button");
      expect(btn?.hasAttribute("disabled")).toBe(true);
    });

    test("createElement with disabled attribute false", () => {
      const nodeEnabled = createElement(
        "button",
        [attr("disabled", AttrValue.Static("false"))],
        []
      );
      render(container, nodeEnabled);
      const btn = container.querySelector("button");
      expect(btn?.hasAttribute("disabled")).toBe(false);
    });

    test("createElement with dynamic style", () => {
      const signal = createSignal("color: blue");
      const node = createElement(
        "div",
        [attr("style", AttrValue.Dynamic(() => get(signal)))],
        []
      );
      render(container, node);
      const div = container.querySelector("div");
      expect(div?.getAttribute("style")).toBe("color: blue");

      set(signal, "color: green");
      expect(div?.getAttribute("style")).toBe("color: green");
    });
  });

  describe("jsx/jsxs", () => {
    test("jsx creates element", () => {
      const node = jsx("div", [], [text("jsx content")]);
      render(container, node);
      expect(container.innerHTML).toBe("<div>jsx content</div>");
    });

    test("jsxs creates element with multiple children", () => {
      const node = jsxs("div", [], [text("child1"), text("child2")]);
      render(container, node);
      expect(container.textContent).toBe("child1child2");
    });
  });

  describe("Fragment", () => {
    test("Fragment wraps multiple children", () => {
      const node = Fragment([text("a"), text("b"), text("c")]);
      render(container, node);
      expect(container.textContent).toBe("abc");
    });
  });

  describe("render and mount", () => {
    test("render clears container first", () => {
      container.innerHTML = "<p>existing</p>";
      const node = text("new content");
      render(container, node);
      expect(container.textContent).toBe("new content");
      expect(container.querySelector("p")).toBeNull();
    });

    test("mount appends without clearing", () => {
      container.innerHTML = "<p>existing</p>";
      const node = text("appended");
      mount(container, node);
      expect(container.textContent).toBe("existingappended");
    });
  });

  describe("show (conditional rendering)", () => {
    test("show creates a node", () => {
      const visible = createSignal(true);
      const node = show(
        () => get(visible),
        () => createElement("div", [attr("id", AttrValue.Static("shown"))], [text("visible")])
      );
      expect(node).toBeDefined();
    });

    test("show with false condition creates placeholder", () => {
      const visible = createSignal(false);
      const node = show(
        () => get(visible),
        () => createElement("div", [], [text("hidden")])
      );
      mount(container, node);
      // When false, only a comment placeholder is rendered
      expect(container.childNodes.length).toBeGreaterThanOrEqual(1);
    });
  });

  describe("forEach (list rendering)", () => {
    test("forEach renders initial list", () => {
      const items = createSignal(["a", "b", "c"]);
      const node = forEach(
        () => get(items),
        (item: string, _index: number) =>
          createElement("span", [], [text(item)])
      );
      mount(container, node);
      expect(container.querySelectorAll("span").length).toBe(3);
      expect(container.textContent).toBe("abc");
    });

    test("forEach updates when items change", () => {
      const items = createSignal(["x", "y"]);
      const node = forEach(
        () => get(items),
        (item: string, _index: number) =>
          createElement("span", [], [text(item)])
      );
      mount(container, node);
      expect(container.textContent).toBe("xy");

      set(items, ["x", "y", "z"]);
      expect(container.querySelectorAll("span").length).toBe(3);
      expect(container.textContent).toBe("xyz");
    });

    test("forEach removes items", () => {
      const items = createSignal(["1", "2", "3"]);
      const node = forEach(
        () => get(items),
        (item: string, _index: number) =>
          createElement("span", [], [text(item)])
      );
      mount(container, node);
      expect(container.querySelectorAll("span").length).toBe(3);

      set(items, ["1"]);
      expect(container.querySelectorAll("span").length).toBe(1);
      expect(container.textContent).toBe("1");
    });

    test("forEach handles empty array", () => {
      const items = createSignal<string[]>([]);
      const node = forEach(
        () => get(items),
        (item: string, _index: number) =>
          createElement("span", [], [text(item)])
      );
      mount(container, node);
      expect(container.querySelectorAll("span").length).toBe(0);
    });

    test("forEach handles clear to empty", () => {
      const items = createSignal(["a", "b"]);
      const node = forEach(
        () => get(items),
        (item: string, _index: number) =>
          createElement("span", [], [text(item)])
      );
      mount(container, node);
      expect(container.querySelectorAll("span").length).toBe(2);

      set(items, []);
      expect(container.querySelectorAll("span").length).toBe(0);
    });
  });

  describe("events helper", () => {
    test("events returns handler map", () => {
      const handlers = events();
      expect(handlers).toBeDefined();
    });
  });

  describe("effect with DOM", () => {
    test("effect tracks signal changes", () => {
      const count = createSignal(0);
      const log: number[] = [];

      effect(() => {
        log.push(get(count));
      });

      expect(log).toEqual([0]);
      set(count, 1);
      expect(log).toEqual([0, 1]);
    });
  });
});
