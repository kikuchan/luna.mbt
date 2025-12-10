import { describe, test, expect } from "vitest";

import {
  div,
  span,
  text,
  className,
  id,
  onClick,
} from "./dom.js";

describe("DOM API", () => {
  test("div creates a node", () => {
    const node = div([], []);
    expect(node).toBeDefined();
  });

  test("span creates a node", () => {
    const node = span([], []);
    expect(node).toBeDefined();
  });

  test("text creates a node", () => {
    const node = text("hello");
    expect(node).toBeDefined();
  });

  test("className creates an attribute", () => {
    const attr = className("my-class");
    expect(attr).toBeDefined();
  });

  test("id creates an attribute", () => {
    const attr = id("my-id");
    expect(attr).toBeDefined();
  });

  test("onClick creates an attribute", () => {
    const attr = onClick(() => {});
    expect(attr).toBeDefined();
  });

  test("nested elements", () => {
    const node = div([className("container")], [
      span([id("title")], [text("Hello")]),
      div([], [text("World")]),
    ]);
    expect(node).toBeDefined();
  });
});
