import { describe, test, expect } from "vitest";

import { text, createElement } from "../index.js";

describe("DOM API", () => {
  test("text creates a node", () => {
    const node = text("hello");
    expect(node).toBeDefined();
  });

  test("createElement creates a node", () => {
    const node = createElement("div", [], []);
    expect(node).toBeDefined();
  });
});
