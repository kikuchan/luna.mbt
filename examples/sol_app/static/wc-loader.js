/*! wc-loader v1 - Simple Web Components Hydration Loader */
((d, w) => {
  const loaded = new Set();
  const Q = s => d.querySelectorAll(s);

  // Parse state from data-state attribute
  const parseState = el => {
    const s = el.dataset.state;
    if (!s) return {};
    try {
      const unescaped = s
        .replace(/\\u003c/g, '<')
        .replace(/\\u003e/g, '>')
        .replace(/\\u0026/g, '&');
      return JSON.parse(unescaped);
    } catch { return {}; }
  };

  // Hydrate a Web Component element
  const hydrate = async el => {
    const name = el.tagName.toLowerCase();
    if (loaded.has(el)) return;

    const url = el.dataset.wcUrl;
    if (!url) return;
    loaded.add(el);

    try {
      const mod = await import(url);
      // Call hydrate function with element and parsed state
      const hydrateFn = mod.hydrate ?? mod.default?.hydrate ?? mod.default;
      if (typeof hydrateFn === 'function') {
        const state = parseState(el);
        hydrateFn(el, state);
      }
    } catch (err) {
      console.error(`[wc-loader] Failed to hydrate ${name}:`, err);
    }
  };

  // Setup hydration trigger for an element
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

  // Scan for Web Components with data-wc-url and setup hydration
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

  // Global API
  w.__WC_SCAN__ = scan;
  w.__WC_HYDRATE__ = hydrate;
})(document, window);
