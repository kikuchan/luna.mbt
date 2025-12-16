/*! wc-loader v1 - Web Components Hydration Loader for Luna */
import { setupTrigger, onReady, observeAdditions, createLoadedTracker } from './lib';

// Luna hydrate function signature
type HydrateFn = (el: Element, state: unknown, id: string) => void;

interface WCModule {
  hydrate?: HydrateFn;
  default?: HydrateFn;
  [key: string]: unknown;
}

interface WCWindow extends Window {
  __LUNA_WC_STATE__: Record<string, unknown>;
  __LUNA_WC_SCAN__: () => void;
  __LUNA_WC_HYDRATE__: (el: Element) => Promise<void>;
  __LUNA_WC_UNLOAD__: (name: string) => boolean;
  __LUNA_WC_CLEAR_LOADED__: () => void;
}

const d = document;
const w = window as unknown as WCWindow;
const S: Record<string, unknown> = {};
const { loaded, unload, clear } = createLoadedTracker();

const parseState = async (el: Element): Promise<unknown> => {
  const s = el.getAttribute('luna:wc-state');
  if (!s) return {};
  // Handle script ref (starts with #)
  if (s.startsWith('#')) {
    const scriptEl = d.getElementById(s.slice(1));
    if (scriptEl?.textContent) {
      try { return JSON.parse(scriptEl.textContent); } catch { return {}; }
    }
    return {};
  }
  try {
    // Unescape JSON
    const unescaped = s
      .replace(/\\u003c/g, '<')
      .replace(/\\u003e/g, '>')
      .replace(/\\u0026/g, '&');
    return JSON.parse(unescaped);
  } catch {
    return {};
  }
};

const hydrate = async (el: Element): Promise<void> => {
  const name = el.tagName.toLowerCase();
  if (loaded.has(name)) return;

  const url = el.getAttribute('luna:wc-url');
  if (!url) return;
  loaded.add(name);

  // Parse state and store
  S[name] = await parseState(el);

  try {
    const mod = await import(url) as WCModule;
    // Get hydrate function (same pattern as Luna loader)
    const hydrateFn = mod.hydrate ?? mod.default;

    if (typeof hydrateFn === 'function') {
      // Call Luna-style hydrate: (element, state, id)
      hydrateFn(el, S[name], name);
    } else {
      console.warn(`[wc-loader] No hydrate function found in ${url}`);
    }
  } catch (err) {
    console.error(`[wc-loader] Failed to hydrate ${name}:`, err);
  }
};

const setup = (el: Element): void => {
  const t = el.getAttribute('luna:wc-trigger') ?? 'load';
  setupTrigger(el, t, () => hydrate(el));
};

const scan = (): void => {
  d.querySelectorAll('[luna\\:wc-url]').forEach(setup);
};

onReady(scan);

// Watch for dynamically added Web Components
observeAdditions(
  el => el.hasAttribute('luna:wc-url'),
  setup
);

w.__LUNA_WC_STATE__ = S;
w.__LUNA_WC_SCAN__ = scan;
w.__LUNA_WC_HYDRATE__ = hydrate;
w.__LUNA_WC_UNLOAD__ = unload;
w.__LUNA_WC_CLEAR_LOADED__ = clear;
