// wc-counter.js - Client-side hydration for WC Counter
export function hydrate(element, state) {
  const shadow = element.shadowRoot;
  if (!shadow) {
    console.error('[wc-counter] No shadow root found');
    return;
  }

  // Get initial count from state
  let count = state.initial_count ?? 0;

  // Get DOM elements from shadow root
  const countDisplay = shadow.querySelector('.count-display');
  const decButton = shadow.querySelector('.dec');
  const incButton = shadow.querySelector('.inc');

  if (!countDisplay || !decButton || !incButton) {
    console.error('[wc-counter] Required elements not found in shadow root');
    return;
  }

  // Update display function
  const updateDisplay = () => {
    countDisplay.textContent = count.toString();
  };

  // Event handlers
  decButton.addEventListener('click', () => {
    count--;
    updateDisplay();
  });

  incButton.addEventListener('click', () => {
    count++;
    updateDisplay();
  });

  console.log('[wc-counter] Hydrated with initial count:', count);
}

export default { hydrate };
