/**
 * Web Components SSR - Client Entry
 *
 * ブラウザ専用。Hydration とイベント処理。
 */

// Types (クライアントで必要なもののみ)
export type {
  State,
  EventPayload,
  Handler,
  RenderFn,
  ComponentDef,
  RegisterOptions,
  CSSStrategy,
} from './types.js';

// Client functions
export {
  registerComponent,
  registerComponents,
  defineComponent,
  hydrateElement,
  clearStyleSheetCache,
  getRegisteredComponents,
} from './client.js';
