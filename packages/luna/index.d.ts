/**
 * Type-safe TypeScript definitions for MoonBit signals
 */

/** Reactive signal container */
export interface Signal<T> {
  readonly __brand: unique symbol;
  readonly __type: T;
}

/** Create a reactive signal with an initial value */
export function createSignal<T>(initial: T): Signal<T>;

/** Get the current value of a signal (tracks dependency) */
export function get<T>(signal: Signal<T>): T;

/** Set a new value for a signal */
export function set<T>(signal: Signal<T>, value: T): void;

/** Update a signal's value using a function */
export function update<T>(signal: Signal<T>, fn: (current: T) => T): void;

/** Get the current value without tracking (won't create dependency) */
export function peek<T>(signal: Signal<T>): T;

/** Subscribe to signal changes. Returns unsubscribe function */
export function subscribe<T>(
  signal: Signal<T>,
  callback: (value: T) => void
): () => void;

/** Map a signal to a derived getter */
export function map<T, U>(signal: Signal<T>, fn: (value: T) => U): () => U;

/** Create a memoized computed value */
export function createMemo<T>(compute: () => T): () => T;

/** Combine two signals into a derived getter */
export function combine<A, B, R>(
  a: Signal<A>,
  b: Signal<B>,
  fn: (a: A, b: B) => R
): () => R;

/** Create a reactive effect. Returns cleanup function */
export function effect(fn: () => void): () => void;

/** Start a batch update */
export function batchStart(): void;

/** End a batch update and run pending effects */
export function batchEnd(): void;

/** Run a function without tracking dependencies */
export function runUntracked<T>(fn: () => T): T;

/** Run a function in a batch - all signal updates are batched */
export function batch<T>(fn: () => T): T;

/** Register a cleanup function inside an effect */
export function onCleanup(cleanup: () => void): void;

// ============================================================================
// Owner-based scope management (Solid.js style)
// ============================================================================

/** Opaque Owner type */
export interface Owner {
  readonly __brand: unique symbol;
}

/** Create a new reactive root scope. The function receives a dispose callback */
export function createRoot<T>(fn: (dispose: () => void) => T): T;

/** Get the current owner (if any) */
export function getOwner(): Owner | undefined;

/** Run a function with a specific owner as current */
export function runWithOwner<T>(owner: Owner, fn: () => T): T;

/** Check if currently inside an owner scope */
export function hasOwner(): boolean;

/** Run a function once (Solid.js style onMount) */
export function onMount(fn: () => void): void;

// ============================================================================
// DOM API
// ============================================================================

/** Opaque DOM Node type */
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

/** HandlerMap builder for event handlers (method chaining) */
export interface HandlerMap {
  click(handler: MouseEventHandler): HandlerMap;
  dblclick(handler: MouseEventHandler): HandlerMap;
  input(handler: InputEventHandler): HandlerMap;
  change(handler: ChangeEventHandler): HandlerMap;
  submit(handler: FormEventHandler): HandlerMap;
  keydown(handler: KeyboardEventHandler): HandlerMap;
  keyup(handler: KeyboardEventHandler): HandlerMap;
  keypress(handler: KeyboardEventHandler): HandlerMap;
  focus(handler: FocusEventHandler): HandlerMap;
  blur(handler: FocusEventHandler): HandlerMap;
  mouseenter(handler: MouseEventHandler): HandlerMap;
  mouseleave(handler: MouseEventHandler): HandlerMap;
  mouseover(handler: MouseEventHandler): HandlerMap;
  mouseout(handler: MouseEventHandler): HandlerMap;
  mousedown(handler: MouseEventHandler): HandlerMap;
  mouseup(handler: MouseEventHandler): HandlerMap;
}

/** Create event handler map builder */
export function events(): HandlerMap;

// Text
export function text(content: string): Node;
export function textDyn(getter: () => string): Node;

// Rendering
export function render(container: Element, node: Node): void;
export function mount(container: Element, node: Node): void;
export function show(condition: () => boolean, render: () => Node): Node;

// List rendering
export function forEach<T>(
  items: () => T[],
  renderItem: (item: T, index: number) => Node
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
