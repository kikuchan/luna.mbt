/**
 * Type-safe TypeScript definitions for MoonBit signals/dom
 */

/** Opaque Node type */
export interface Node {
  readonly __brand: unique symbol;
}

/** Attribute value type */
export type AttrValue = [string, unknown];

/** Event handler types */
export type MouseEventHandler = (event: MouseEvent) => void;
export type InputEventHandler = (event: InputEvent) => void;
export type KeyboardEventHandler = (event: KeyboardEvent) => void;
export type FocusEventHandler = (event: FocusEvent) => void;
export type FormEventHandler = (event: Event) => void;
export type ChangeEventHandler = (event: Event) => void;

// Elements
export function div(attrs: AttrValue[], children: Node[]): Node;
export function span(attrs: AttrValue[], children: Node[]): Node;
export function p(attrs: AttrValue[], children: Node[]): Node;
export function button(attrs: AttrValue[], children: Node[]): Node;
export function a(attrs: AttrValue[], children: Node[]): Node;
export function input(attrs: AttrValue[]): Node;
export function textarea(attrs: AttrValue[], children: Node[]): Node;
export function form(attrs: AttrValue[], children: Node[]): Node;
export function label(attrs: AttrValue[], children: Node[]): Node;
export function h1(attrs: AttrValue[], children: Node[]): Node;
export function h2(attrs: AttrValue[], children: Node[]): Node;
export function h3(attrs: AttrValue[], children: Node[]): Node;
export function ul(attrs: AttrValue[], children: Node[]): Node;
export function ol(attrs: AttrValue[], children: Node[]): Node;
export function li(attrs: AttrValue[], children: Node[]): Node;
export function img(attrs: AttrValue[]): Node;
export function br(): Node;
export function hr(): Node;

// Text
export function text(content: string): Node;
export function textDyn(getter: () => string): Node;

// Rendering
export function render(container: Element, node: Node): void;
export function mount(container: Element, node: Node): void;
export function show(condition: () => boolean, thenNode: () => Node, elseNode?: () => Node): Node;

// Attributes
export function className(value: string): AttrValue;
export function classNameDyn(getter: () => string): AttrValue;
export function id(value: string): AttrValue;
export function type(value: string): AttrValue;
export function placeholder(value: string): AttrValue;
export function value(value: string): AttrValue;
export function valueDyn(getter: () => string): AttrValue;
export function href(value: string): AttrValue;
export function src(value: string): AttrValue;
export function alt(value: string): AttrValue;
export function disabled(value: boolean): AttrValue;
export function disabledDyn(getter: () => boolean): AttrValue;

// Event handlers
export function onClick(handler: MouseEventHandler): AttrValue;
export function onInput(handler: InputEventHandler): AttrValue;
export function onChange(handler: ChangeEventHandler): AttrValue;
export function onSubmit(handler: FormEventHandler): AttrValue;
export function onKeyDown(handler: KeyboardEventHandler): AttrValue;
export function onKeyUp(handler: KeyboardEventHandler): AttrValue;
export function onFocus(handler: FocusEventHandler): AttrValue;
export function onBlur(handler: FocusEventHandler): AttrValue;
export function onMouseEnter(handler: MouseEventHandler): AttrValue;
export function onMouseLeave(handler: MouseEventHandler): AttrValue;

// Style
export function style(styles: [string, string][]): AttrValue;
export function styleDyn(getter: () => [string, string][]): AttrValue;

// Generic attributes
export function attr(key: string, value: string): AttrValue;
export function attrDyn(key: string, getter: () => string): AttrValue;
