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
  __WC_STATE__: Record<string, unknown>;
  __WC_SCAN__: () => void;
  __WC_HYDRATE__: (el: Element) => Promise<void>;
  __WC_UNLOAD__: (name: string) => boolean;
  __WC_CLEAR_LOADED__: () => void;
}

interface WCElement extends HTMLElement {
  dataset: DOMStringMap & {
    state?: string;
    wcUrl?: string;
    trigger?: string;
  };
}

const d = document;
const w = window as unknown as WCWindow;
const S: Record<string, unknown> = {};
const { loaded, unload, clear } = createLoadedTracker();

const parseState = async (el: WCElement): Promise<unknown> => {
  const s = el.dataset.state;
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

const hydrate = async (el: WCElement): Promise<void> => {
  const name = el.tagName.toLowerCase();
  if (loaded.has(name)) return;

  const url = el.dataset.wcUrl;
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

const setup = (el: WCElement): void => {
  const t = el.dataset.trigger ?? 'load';
  setupTrigger(el, t, () => hydrate(el));
};

const scan = (): void => {
  d.querySelectorAll<WCElement>('[data-wc-url]').forEach(setup);
};

onReady(scan);

// Watch for dynamically added Web Components
observeAdditions(
  el => !!(el as WCElement).dataset?.wcUrl,
  el => setup(el as WCElement)
);

w.__WC_STATE__ = S;
w.__WC_SCAN__ = scan;
w.__WC_HYDRATE__ = hydrate;
w.__WC_UNLOAD__ = unload;
w.__WC_CLEAR_LOADED__ = clear;
