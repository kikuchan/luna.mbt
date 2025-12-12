// JSX Runtime for @mizchi/ui
// Usage: Configure tsconfig.json with:
//   "jsx": "react-jsx",
//   "jsxImportSource": "@mizchi/ui"

import { text, createElement } from "./dom.js";

// Convert JSX props to createElement attrs format
function convertProps(props) {
  if (!props) return [];
  const attrs = [];
  for (const [key, value] of Object.entries(props)) {
    if (key === "children") continue;

    // Map JSX prop names to DOM attribute format
    let attrName = key;
    let attrValue;

    // Handle className -> class
    if (key === "className") {
      attrName = "class";
    }

    // Handle event handlers (onClick -> onclick for DOM)
    if (key.startsWith("on") && typeof value === "function") {
      attrName = key.toLowerCase();
      attrValue = { $tag: 2, _0: value }; // AttrValue.Handler
      attrs.push({ _0: attrName, _1: attrValue });
      continue;
    }

    // Handle dynamic values (functions)
    if (typeof value === "function") {
      attrValue = { $tag: 1, _0: value }; // AttrValue.Dynamic
    } else {
      attrValue = { $tag: 0, _0: String(value) }; // AttrValue.Static
    }

    attrs.push({ _0: attrName, _1: attrValue });
  }
  return attrs;
}

function convertChildren(children) {
  if (!children) return [];
  if (!Array.isArray(children)) {
    children = [children];
  }
  return children.flat().map((child) => {
    if (typeof child === "string") {
      return text(child);
    }
    if (typeof child === "number") {
      return text(String(child));
    }
    return child;
  }).filter(Boolean);
}

// JSX factory function
export function jsx(type, props) {
  const { children, ...rest } = props || {};
  const attrs = convertProps(rest);
  const childNodes = convertChildren(children);

  if (typeof type === "string") {
    return createElement(type, attrs, childNodes);
  }

  // Function component
  if (typeof type === "function") {
    return type({ ...rest, children });
  }

  throw new Error(`Invalid JSX type: ${type}`);
}

// jsxs is the same as jsx for our implementation
export const jsxs = jsx;

// Fragment just returns children as-is (flattened)
export function Fragment({ children }) {
  return convertChildren(children);
}

// Export jsxDEV for development mode
export const jsxDEV = jsx;
