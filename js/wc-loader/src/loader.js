/*! wc-loader v1 - Web Components Hydration Loader */
((d, w) => {
  const loaded = new Set();
  const Q = s => d.querySelectorAll(s);

  /**
   * Parse state from data-state attribute
   */
  const parseState = el => {
    const s = el.dataset.state;
    if (!s) return {};
    try {
      // Unescape JSON
      const unescaped = s
        .replace(/\\u003c/g, '<')
        .replace(/\\u003e/g, '>')
        .replace(/\\u0026/g, '&');
      return JSON.parse(unescaped);
    } catch { return {}; }
  };

  /**
   * Hydrate a Web Component element
   */
  const hydrate = async el => {
    const name = el.tagName.toLowerCase();
    if (loaded.has(name)) return;

    const url = el.dataset.wcUrl;
    if (!url) return;
    loaded.add(name);

    try {
      // Load the component module
      const mod = await import(url);
      const def = mod.default ?? mod[name];

      if (def && typeof def === 'object') {
        // Use wcssr's registerComponent if available
        if (w.__WCSSR__?.registerComponent) {
          w.__WCSSR__.registerComponent(def);
        } else {
          // Fallback: dynamic import wcssr client
          const { registerComponent } = await import('@mizchi/wcssr/client');
          registerComponent(def);
        }
      }
    } catch (err) {
      console.error(`[wc-loader] Failed to hydrate ${name}:`, err);
    }
  };

  /**
   * Setup hydration trigger for an element
   */
  const setup = el => {
    const t = el.dataset.trigger ?? 'load';

    if (t === 'load') {
      if (d.readyState === 'loading') {
        d.addEventListener('DOMContentLoaded', () => hydrate(el), { once: true });
      } else {
        hydrate(el);
      }
    } else if (t === 'idle') {
      requestIdleCallback(() => hydrate(el));
    } else if (t === 'visible') {
      new IntersectionObserver((entries, obs) => {
        if (entries.some(e => e.isIntersecting)) {
          obs.disconnect();
          hydrate(el);
        }
      }, { rootMargin: '50px' }).observe(el);
    } else if (t.startsWith('media:')) {
      const query = t.slice(6);
      const mq = w.matchMedia(query);
      const handler = () => {
        if (mq.matches) {
          mq.removeEventListener('change', handler);
          hydrate(el);
        }
      };
      if (mq.matches) {
        hydrate(el);
      } else {
        mq.addEventListener('change', handler);
      }
    }
  };

  /**
   * Scan for Web Components with data-wc-url and setup hydration
   */
  const scan = () => {
    Q('[data-wc-url]').forEach(setup);
  };

  // Initial scan
  if (d.readyState === 'loading') {
    d.addEventListener('DOMContentLoaded', scan, { once: true });
  } else {
    scan();
  }

  // Watch for dynamically added Web Components
  new MutationObserver(mutations => {
    mutations.forEach(m => {
      m.addedNodes.forEach(n => {
        if (n.nodeType === 1 && n.dataset?.wcUrl) {
          setup(n);
        }
      });
    });
  }).observe(d.body ?? d.documentElement, { childList: true, subtree: true });

  // Unload specific component
  const unload = name => loaded.delete(name);

  // Clear all loaded components
  const clearLoaded = () => loaded.clear();

  // Global API
  w.__WC_SCAN__ = scan;
  w.__WC_HYDRATE__ = hydrate;
  w.__WC_UNLOAD__ = unload;
  w.__WC_CLEAR_LOADED__ = clearLoaded;
})(document, window);
