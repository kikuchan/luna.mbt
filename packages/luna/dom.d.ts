/**
 * Type-safe TypeScript definitions for MoonBit DOM API
 */

/** Opaque Node type */
export interface Node {
  readonly __brand: unique symbol;
}

/** Event handler types */
export type MouseEventHandler = (event: MouseEvent) => void;
export type InputEventHandler = (event: InputEvent) => void;
export type KeyboardEventHandler = (event: KeyboardEvent) => void;
export type FocusEventHandler = (event: FocusEvent) => void;
export type FormEventHandler = (event: Event) => void;
export type ChangeEventHandler = (event: Event) => void;

/** HandlerMap type for event handlers */
export interface HandlerMap {
  click?: MouseEventHandler;
  dblclick?: MouseEventHandler;
  input?: InputEventHandler;
  change?: ChangeEventHandler;
  submit?: FormEventHandler;
  keydown?: KeyboardEventHandler;
  keyup?: KeyboardEventHandler;
  keypress?: KeyboardEventHandler;
  focus?: FocusEventHandler;
  blur?: FocusEventHandler;
  mouseenter?: MouseEventHandler;
  mouseleave?: MouseEventHandler;
  mouseover?: MouseEventHandler;
  mouseout?: MouseEventHandler;
  mousedown?: MouseEventHandler;
  mouseup?: MouseEventHandler;
}

/** Create event handler map */
export function on(handlers: HandlerMap): HandlerMap;

// Text
export function text(content: string): Node;
export function textDyn(getter: () => string): Node;

// Rendering
export function render(container: Element, node: Node): void;
export function mount(container: Element, node: Node): void;
export function show(
  condition: () => boolean,
  thenNode: () => Node,
  elseNode?: () => Node
): Node;

// JSX support
export function jsx(
  type: string | ((props: any) => Node),
  props: Record<string, any> | null
): Node;
export function jsxs(
  type: string | ((props: any) => Node),
  props: Record<string, any> | null
): Node;
export const Fragment: unique symbol;

// Element creation (low-level)
export function createElement(
  tag: string,
  attrs: [string, unknown][],
  children: Node[]
): Node;
