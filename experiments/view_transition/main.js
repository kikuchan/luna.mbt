// View Transition API - MPA Demo
// For cross-document transitions, the @view-transition CSS rule handles most of the work.
// This JS file is for additional customization and debugging.

// Log view transition events for debugging
window.addEventListener('pageswap', (event) => {
  console.log('[pageswap] Leaving page:', location.pathname);
  if (event.viewTransition) {
    console.log('[pageswap] View transition available');
    // You can customize the outgoing transition here
    // event.viewTransition.types.add('slide-left');
  }
});

window.addEventListener('pagereveal', (event) => {
  console.log('[pagereveal] Entering page:', location.pathname);
  if (event.viewTransition) {
    console.log('[pagereveal] View transition available');
    // You can customize the incoming transition here
    // For example, different animation based on navigation direction
  }
});

// Feature detection
if (!document.startViewTransition) {
  console.log('View Transitions API (SPA) not supported');
}

// Check for cross-document support (Chrome 126+)
if (!('CSSViewTransitionRule' in window)) {
  console.log('Cross-document View Transitions may not be fully supported');
  // Add a notice to the page
  document.addEventListener('DOMContentLoaded', () => {
    const notice = document.createElement('div');
    notice.style.cssText = `
      position: fixed;
      bottom: 1rem;
      left: 1rem;
      right: 1rem;
      padding: 1rem;
      background: #fff3cd;
      border: 1px solid #ffc107;
      border-radius: 8px;
      font-size: 0.875rem;
      z-index: 1000;
    `;
    notice.innerHTML = `
      <strong>Note:</strong> Cross-document View Transitions require Chrome 126+.
      <a href="https://caniuse.com/view-transitions" target="_blank">Check browser support</a>
    `;
    document.body.appendChild(notice);
  });
}

// Optional: Add transition type based on navigation history
// This allows different animations for back vs forward navigation
window.addEventListener('pagereveal', (event) => {
  if (!event.viewTransition) return;

  const navigation = performance.getEntriesByType('navigation')[0];
  if (navigation) {
    const isBackNavigation = navigation.type === 'back_forward';
    if (isBackNavigation) {
      // Could add different styling for back navigation
      document.documentElement.dataset.navDirection = 'back';
    } else {
      document.documentElement.dataset.navDirection = 'forward';
    }
  }
});

// Clean up nav direction after transition
window.addEventListener('pagereveal', (event) => {
  if (event.viewTransition) {
    event.viewTransition.finished.then(() => {
      delete document.documentElement.dataset.navDirection;
    });
  }
});
