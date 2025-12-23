/*! luna loader v1 */
import { setupTrigger, onReady, observeAdditions, createLoadedTracker } from './lib';

type StateMap = Record<string, unknown>;
type HydrateFn = (el: Element, state: unknown, id: string, isRerender?: boolean) => void;

interface LunaWindow extends Window {
  __LUNA_STATE__: StateMap;
  __LUNA_HYDRATE__: (el: Element, isRerender?: boolean) => Promise<void>;
  __LUNA_SCAN__: () => void;
  __LUNA_UNLOAD__: (id: string) => boolean;
  __LUNA_UNLOAD_ALL__: (root?: Element) => void;
  __LUNA_CLEAR_LOADED__: () => void;
  __LUNA_RERENDER_ALL__: (root?: Element) => void;
}

const d = document;
const w = window as unknown as LunaWindow;
const S: StateMap = {};
const { loaded, unload, clear } = createLoadedTracker();

const parseState = async (el: Element): Promise<unknown> => {
  const a = el.getAttribute('luna:state');
  if (!a) return;
  if (a[0] === '#') return JSON.parse(d.getElementById(a.slice(1))?.textContent ?? 'null');
  try { return JSON.parse(a); } catch { /* ignore */ }
};

const hydrate = async (el: Element, isRerender = false): Promise<void> => {
  const id = el.getAttribute('luna:id');
  if (!id) return;
  // Skip if already loaded (unless rerendering)
  if (!isRerender && loaded.has(id)) return;
  loaded.add(id);
  const url = el.getAttribute('luna:url');
  if (!url) return;
  S[id] = await parseState(el);
  const mod = await import(url) as Record<string, HydrateFn>;
  const ex = el.getAttribute('luna:export');
  // Pass isRerender flag to hydrate function
  (ex ? mod[ex] : mod.hydrate ?? mod.default)?.(el, S[id], id, isRerender);
};

const setup = (el: Element): void => {
  const t = el.getAttribute('luna:client-trigger') ?? 'load';
  setupTrigger(el, t, () => hydrate(el));
};

const scan = (): void => {
  d.querySelectorAll('[luna\\:id]').forEach(setup);
};

// Preload state from luna/json scripts
d.querySelectorAll('script[type="luna/json"]').forEach(s => {
  if (s.id) S[s.id] = JSON.parse(s.textContent ?? '{}');
});

onReady(scan);

// Watch for dynamically added islands
observeAdditions(
  el => el.hasAttribute('luna:id'),
  setup
);

// Unload all islands within an element (for CSR navigation)
const unloadAll = (root: Element = d.body): void => {
  root.querySelectorAll('[luna\\:id]').forEach(el => {
    const id = el.getAttribute('luna:id');
    if (id) loaded.delete(id);
  });
};

// Rerender all islands within an element (for CSR navigation with updated data)
const rerenderAll = (root: Element = d.body): void => {
  root.querySelectorAll('[luna\\:id]').forEach(el => hydrate(el, true));
};

w.__LUNA_STATE__ = S;
w.__LUNA_HYDRATE__ = hydrate;
w.__LUNA_SCAN__ = scan;
w.__LUNA_UNLOAD__ = unload;
w.__LUNA_UNLOAD_ALL__ = unloadAll;
w.__LUNA_CLEAR_LOADED__ = clear;
w.__LUNA_RERENDER_ALL__ = rerenderAll;
