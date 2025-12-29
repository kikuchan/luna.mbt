/**
 * Issue #5: For component causes infinite loop inside nested Show components
 * https://github.com/mizchi/luna.mbt/issues/5
 *
 * This test reproduces the bug where For inside nested Show components
 * causes "Maximum call stack size exceeded" when a signal is updated
 * in a ref callback.
 */
import { describe, test, expect, beforeEach, vi } from "vitest";
import {
  text,
  createElement,
  render,
  mount,
  For,
  Show,
  createSignal,
  createMemo,
  createRenderEffect,
} from "../src/index";

function attr(name: string, value: unknown) {
  return { _0: name, _1: value };
}

const AttrValue = {
  Static: (value: string) => ({ $tag: 0, _0: value }),
  Dynamic: (getter: () => string) => ({ $tag: 1, _0: getter }),
  Handler: (handler: (e: unknown) => void) => ({ $tag: 2, _0: handler }),
};

describe("Issue #5: For infinite loop in nested Show", () => {
  let container: HTMLElement;

  beforeEach(() => {
    container = document.createElement("div");
    document.body.appendChild(container);
  });

  test("WORKING: simple For usage", () => {
    const [count] = createSignal(3);
    const items = createMemo(() =>
      Array.from({ length: count() }, (_, i) => i + 1)
    );

    const node = For({
      each: items,
      children: (item: number) => createElement("div", [], [text(`Item ${item}`)]),
    });

    mount(container, node);
    expect(container.querySelectorAll("div").length).toBe(3);
    expect(container.textContent).toBe("Item 1Item 2Item 3");
  });

  test("WORKING: For inside single Show", () => {
    const [isInit] = createSignal(true);
    const [count] = createSignal(3);
    const items = createMemo(() =>
      Array.from({ length: count() }, (_, i) => i + 1)
    );

    const node = Show({
      when: isInit,
      children: () =>
        For({
          each: items,
          children: (item: number) =>
            createElement("div", [], [text(`Item ${item}`)]),
        }),
    });

    mount(container, node);
    expect(container.querySelectorAll("div").length).toBe(3);
  });

  test("WORKING: For inside nested Show (no ref callback)", () => {
    const [isInit] = createSignal(true);
    const [count] = createSignal(3);
    const items = createMemo(() =>
      Array.from({ length: count() }, (_, i) => i + 1)
    );

    const node = Show({
      when: isInit,
      children: () =>
        Show({
          when: () => true,
          children: () =>
            For({
              each: items,
              children: (item: number) =>
                createElement("div", [], [text(`Item ${item}`)]),
            }),
        }),
    });

    mount(container, node);
    expect(container.querySelectorAll("div").length).toBe(3);
  });

  test("VERIFY: For with ref callback signal update inside nested Show", () => {
    // Based on issue #5 - test if ref callback can update signal without infinite loop

    const [lineCount, setLineCount] = createSignal(1);
    const lineNumbers = createMemo(() =>
      Array.from({ length: lineCount() }, (_, i) => i + 1)
    );

    const setupEditor = (el: HTMLTextAreaElement) => {
      const lines = el.value.split("\n").length;
      setLineCount(lines); // Signal update in ref callback
    };

    const node = Show({
      when: () => true,
      children: () =>
        Show({
          when: () => true,
          children: () =>
            createElement("div", [], [
              createElement("div", [attr("class", AttrValue.Static("line-numbers"))], [
                For({
                  each: lineNumbers,
                  children: (num: number) =>
                    createElement("div", [], [text(`${num}`)]),
                }),
              ]),
              createElement(
                "textarea",
                [
                  attr("value", AttrValue.Static("line1\nline2\nline3")),
                  attr("__ref", AttrValue.Handler(setupEditor)),
                ],
                []
              ),
            ]),
        }),
    });

    // This should not throw
    mount(container, node);

    // Verify correct rendering
    expect(container.querySelectorAll(".line-numbers div").length).toBe(3);
  });

  test("VERIFY: Deferred Show with For and signal update in ref", async () => {
    // More realistic reproduction: Show with setTimeout-deferred condition
    const [isInit, setIsInit] = createSignal(false);
    const [lineCount, setLineCount] = createSignal(1);
    const lineNumbers = createMemo(() =>
      Array.from({ length: lineCount() }, (_, i) => i + 1)
    );

    const setupEditor = (el: HTMLTextAreaElement) => {
      const lines = el.value.split("\n").length;
      setLineCount(lines);
    };

    const node = Show({
      when: isInit,
      children: () =>
        Show({
          when: () => true,
          children: () =>
            createElement("div", [], [
              createElement("div", [attr("class", AttrValue.Static("line-numbers"))], [
                For({
                  each: lineNumbers,
                  children: (num: number) =>
                    createElement("div", [], [text(`${num}`)]),
                }),
              ]),
              createElement(
                "textarea",
                [
                  attr("value", AttrValue.Static("line1\nline2\nline3")),
                  attr("__ref", AttrValue.Handler(setupEditor)),
                ],
                []
              ),
            ]),
        }),
    });

    mount(container, node);

    // Initially hidden
    expect(container.querySelectorAll(".line-numbers div").length).toBe(0);

    // Trigger show after delay (simulating setTimeout)
    await new Promise(resolve => setTimeout(resolve, 10));
    setIsInit(true);

    // Wait for effects to process
    await new Promise(resolve => setTimeout(resolve, 10));

    // Should render correctly without infinite loop
    expect(container.querySelectorAll(".line-numbers div").length).toBe(3);
  });

  test("BUG: Simplified reproduction - For + createRenderEffect with signal update", () => {
    // Simplified version that demonstrates the core issue
    const renderCount = { value: 0 };
    const [count, setCount] = createSignal(1);
    const items = createMemo(() => {
      renderCount.value++;
      if (renderCount.value > 100) {
        throw new Error("Infinite loop detected: render count exceeded 100");
      }
      return Array.from({ length: count() }, (_, i) => i + 1);
    });

    const node = Show({
      when: () => true,
      children: () =>
        Show({
          when: () => true,
          children: () =>
            createElement("div", [], [
              For({
                each: items,
                children: (item: number) =>
                  createElement("div", [], [text(`${item}`)]),
              }),
            ]),
        }),
    });

    mount(container, node);

    // Initial render should not trigger infinite loop
    expect(renderCount.value).toBeLessThan(10);

    // Signal update should not trigger infinite loop
    renderCount.value = 0;
    setCount(3);
    expect(renderCount.value).toBeLessThan(10);
  });

  test("BUG: Effect firing multiple times inside Show", () => {
    const effectRunCount = { value: 0 };
    const [visible, setVisible] = createSignal(true);

    const node = Show({
      when: visible,
      children: () => {
        // Track how many times this child function is called
        createRenderEffect(() => {
          effectRunCount.value++;
        });
        return createElement("div", [], [text("content")]);
      },
    });

    mount(container, node);

    // Effect should only run once on mount
    // If it runs multiple times (2-3x), this indicates the bug reported in issue #5
    expect(effectRunCount.value).toBe(1);
  });

  test("BUG: Show instantiates nodes multiple times", () => {
    const instanceCount = { value: 0 };
    const [visible] = createSignal(true);

    const node = Show({
      when: visible,
      children: () => {
        instanceCount.value++;
        return createElement("div", [], [text("content")]);
      },
    });

    mount(container, node);

    // Child function should only be called once
    // Multiple calls indicate the root cause of the infinite loop issue
    expect(instanceCount.value).toBe(1);
  });

  test("BUG: Nested Show instantiates nodes multiple times", () => {
    const outerCount = { value: 0 };
    const innerCount = { value: 0 };

    const node = Show({
      when: () => true,
      children: () => {
        outerCount.value++;
        return Show({
          when: () => true,
          children: () => {
            innerCount.value++;
            return createElement("div", [], [text("nested")]);
          },
        });
      },
    });

    mount(container, node);

    // Each child function should only be called once
    expect(outerCount.value).toBe(1);
    expect(innerCount.value).toBe(1);
  });
});
