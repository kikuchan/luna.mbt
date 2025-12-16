/*! sol-nav v1 - CSR Navigation for Sol Framework */
((d, w) => {
  let isNavigating = false;
  const cache = new Map();

  // Navigate to URL with CSR
  const navigate = async (url, replace = false) => {
    if (isNavigating) return;
    isNavigating = true;

    try {
      // Check cache first
      let html = cache.get(url);
      if (!html) {
        const res = await fetch(url, {
          headers: { 'X-Sol-Fragment': 'true' }
        });
        html = await res.text();

        // Only cache if fragment response
        if (res.headers.get('X-Sol-Fragment-Response')) {
          cache.set(url, html);
          // Clear cache after 5 minutes
          setTimeout(() => cache.delete(url), 5 * 60 * 1000);
        }
      }

      // Parse response
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');

      // Check if this is a fragment response (has template elements)
      const templates = doc.querySelectorAll('template[data-sol-outlet]');

      if (templates.length > 0) {
        // Fragment response - update outlets
        templates.forEach(tpl => {
          const name = tpl.dataset.solOutlet;
          const target = d.querySelector(`[data-sol-outlet="${name}"]`);
          if (target) {
            target.innerHTML = tpl.innerHTML;
          }
        });

        // Update title
        const titleTpl = doc.querySelector('template[data-sol-title]');
        if (titleTpl) {
          d.title = titleTpl.textContent;
        }
      } else {
        // Full page response - extract #app content
        const app = doc.querySelector('#app');
        const target = d.querySelector('#app');
        if (app && target) {
          target.innerHTML = app.innerHTML;
        }

        // Update title from full page
        const title = doc.querySelector('title');
        if (title) {
          d.title = title.textContent;
        }
      }

      // Update history
      if (replace) {
        w.history.replaceState({ sol: true }, '', url);
      } else {
        w.history.pushState({ sol: true }, '', url);
      }

      // Scroll to top
      w.scrollTo(0, 0);

      // Re-scan for islands (if loader is available)
      w.__LN_SCAN__?.();

    } catch (e) {
      console.error('Sol navigation failed:', e);
      // Fallback to full page load
      w.location.href = url;
    } finally {
      isNavigating = false;
    }
  };

  // Prefetch URL
  const prefetch = (url) => {
    if (cache.has(url)) return;
    fetch(url, {
      headers: { 'X-Sol-Fragment': 'true' }
    }).then(res => res.text()).then(html => {
      cache.set(url, html);
      setTimeout(() => cache.delete(url), 5 * 60 * 1000);
    }).catch(() => {});
  };

  // Click handler for sol-link elements
  d.addEventListener('click', e => {
    const link = e.target.closest('[data-sol-link]');
    if (!link) return;

    const href = link.getAttribute('href');
    if (!href) return;

    // Skip external links
    if (href.startsWith('http') || href.startsWith('//')) return;

    // Skip if modifier key pressed (allow new tab)
    if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;

    e.preventDefault();
    const replace = link.hasAttribute('data-sol-replace');
    navigate(href, replace);
  });

  // Hover prefetch
  d.addEventListener('mouseenter', e => {
    const link = e.target.closest('[data-sol-link][data-sol-prefetch]');
    if (link) {
      const href = link.getAttribute('href');
      if (href && !href.startsWith('http') && !href.startsWith('//')) {
        prefetch(href);
      }
    }
  }, { capture: true });

  // Handle browser back/forward
  w.addEventListener('popstate', (e) => {
    // Only handle our own history entries or if no state
    if (e.state?.sol || !e.state) {
      navigate(w.location.href, true);
    }
  });

  // Global API
  w.__SOL_NAVIGATE__ = navigate;
  w.__SOL_PREFETCH__ = prefetch;
  w.__SOL_CACHE__ = cache;

})(document, window);
