// Re-export from MoonBit build output (api_js)
// This file wraps MoonBit APIs to provide SolidJS-compatible interface

import {
  // Signal API (internal)
  createSignal as _createSignal,
  get as _get,
  set as _set,
  update as _update,
  peek as _peek,
  subscribe as _subscribe,
  map as _map,
  createMemo as _createMemo,
  combine as _combine,
  effect as _effect,
  batchStart,
  batchEnd,
  runUntracked,
  batch,
  onCleanup,
  createRoot,
  getOwner,
  runWithOwner,
  hasOwner,
  onMount,
  // DOM API
  text,
  textDyn,
  render,
  mount,
  show,
  jsx,
  jsxs,
  Fragment,
  createElement,
  events,
  forEach,
  // Timer utilities
  debounced as _debounced,
  // Route definitions
  routePage,
  routePageTitled,
  routePageFull,
  routeGroup,
  routeParam,
  createRouter,
  routerNavigate,
  routerReplace,
  routerGetPath,
  routerGetMatch,
  routerGetBase,
  // Context API
  createContext,
  provide,
  useContext,
  // Resource API
  createResource as _createResource,
  createDeferred as _createDeferred,
  resourceGet,
  resourcePeek,
  resourceRefetch,
  resourceIsPending,
  resourceIsSuccess,
  resourceIsFailure,
  resourceValue,
  resourceError,
  stateIsPending,
  stateIsSuccess,
  stateIsFailure,
  stateValue,
  stateError,
} from "../../target/js/release/build/platform/js/api/api.js";

// ============================================================================
// SolidJS-compatible Signal API
// ============================================================================

/**
 * Creates a reactive signal (SolidJS-style)
 * @template T
 * @param {T} initialValue
 * @returns {[() => T, (value: T | ((prev: T) => T)) => void]}
 */
export function createSignal(initialValue) {
  const signal = _createSignal(initialValue);

  const getter = () => _get(signal);

  const setter = (valueOrUpdater) => {
    if (typeof valueOrUpdater === "function") {
      _update(signal, valueOrUpdater);
    } else {
      _set(signal, valueOrUpdater);
    }
  };

  return [getter, setter];
}

/**
 * Creates a reactive effect (SolidJS-style alias)
 */
export function createEffect(fn) {
  return _effect(fn);
}

/**
 * Creates a memoized computed value (SolidJS-style)
 * @template T
 * @param {() => T} fn
 * @returns {() => T}
 */
export function createMemo(fn) {
  return _createMemo(fn);
}

/**
 * Runs a function without tracking dependencies (SolidJS-style alias)
 */
export { runUntracked as untrack };

/**
 * Explicit dependency tracking helper (SolidJS-style)
 * Wraps a function to explicitly specify which signals to track
 *
 * @template T
 * @template U
 * @param {(() => T) | Array<() => any>} deps - Signal accessor(s) to track
 * @param {(input: T, prevInput?: T, prevValue?: U) => U} fn - Function to run with dependency values
 * @param {{ defer?: boolean }} [options] - Options (defer: don't run on initial)
 * @returns {(prevValue?: U) => U | undefined}
 */
export function on(deps, fn, options = {}) {
  const { defer = false } = options;
  const isArray = Array.isArray(deps);

  let prevInput;
  let prevValue;
  let isFirst = true;

  return (injectedPrevValue) => {
    // Get current dependency values
    const input = isArray ? deps.map((d) => d()) : deps();

    // Handle deferred execution
    if (defer && isFirst) {
      isFirst = false;
      prevInput = input;
      return undefined;
    }

    // Run the function with current and previous values
    const result = fn(input, prevInput, injectedPrevValue ?? prevValue);

    // Store for next run
    prevInput = input;
    prevValue = result;
    isFirst = false;

    return result;
  };
}

/**
 * Merge multiple props objects, with later objects taking precedence (SolidJS-style)
 * Event handlers and refs are merged, other props are overwritten
 *
 * @template T
 * @param {...T} sources - Props objects to merge
 * @returns {T}
 */
export function mergeProps(...sources) {
  const result = {};

  for (const source of sources) {
    if (!source) continue;

    for (const key of Object.keys(source)) {
      const value = source[key];

      // Merge event handlers (on* props)
      if (key.startsWith("on") && typeof value === "function") {
        const existing = result[key];
        if (typeof existing === "function") {
          result[key] = (...args) => {
            existing(...args);
            value(...args);
          };
        } else {
          result[key] = value;
        }
      }
      // Merge ref callbacks
      else if (key === "ref" && typeof value === "function") {
        const existing = result[key];
        if (typeof existing === "function") {
          result[key] = (el) => {
            existing(el);
            value(el);
          };
        } else {
          result[key] = value;
        }
      }
      // Merge class/className
      else if (key === "class" || key === "className") {
        const existing = result[key];
        if (existing) {
          result[key] = `${existing} ${value}`;
        } else {
          result[key] = value;
        }
      }
      // Merge style objects
      else if (key === "style" && typeof value === "object" && typeof result[key] === "object") {
        result[key] = { ...result[key], ...value };
      }
      // Default: overwrite
      else {
        result[key] = value;
      }
    }
  }

  return result;
}

/**
 * Split props into multiple objects based on key lists (SolidJS-style)
 *
 * @template T
 * @template K
 * @param {T} props - Props object to split
 * @param {...K[]} keys - Arrays of keys to extract
 * @returns {[Pick<T, K>, Omit<T, K>]}
 */
export function splitProps(props, ...keys) {
  const result = [];
  const remaining = { ...props };

  for (const keyList of keys) {
    const extracted = {};
    for (const key of keyList) {
      if (key in remaining) {
        extracted[key] = remaining[key];
        delete remaining[key];
      }
    }
    result.push(extracted);
  }

  result.push(remaining);
  return result;
}

/**
 * Creates a resource for async data (SolidJS-style)
 * @template T
 * @param {(resolve: (v: T) => void, reject: (e: string) => void) => void} fetcher
 * @returns {[ResourceAccessor<T>, { refetch: () => void }]}
 */
export function createResource(fetcher) {
  const resource = _createResource(fetcher);

  // Use resourceGet for tracking dependencies, stateValue for actual value
  const accessor = () => stateValue(resourceGet(resource));
  Object.defineProperties(accessor, {
    loading: { get: () => resourceIsPending(resource) },
    error: { get: () => resourceError(resource) },
    state: {
      get: () => {
        if (resourceIsPending(resource)) return "pending";
        if (resourceIsSuccess(resource)) return "ready";
        if (resourceIsFailure(resource)) return "errored";
        return "unresolved";
      },
    },
    latest: { get: () => resourcePeek(resource) },
  });

  return [accessor, { refetch: () => resourceRefetch(resource) }];
}

/**
 * Creates a deferred resource (SolidJS-style)
 */
export function createDeferred() {
  const result = _createDeferred();
  const resource = result._0;
  const resolve = result._1;
  const reject = result._2;

  // Use resourceGet for tracking dependencies, stateValue for actual value
  const accessor = () => stateValue(resourceGet(resource));
  Object.defineProperties(accessor, {
    loading: { get: () => resourceIsPending(resource) },
    error: { get: () => resourceError(resource) },
  });

  return [accessor, resolve, reject];
}

/**
 * Debounces a signal (returns SolidJS-style signal)
 */
export function debounced(signal, delayMs) {
  const [getter] = signal;
  const innerSignal = _createSignal(getter());
  const debouncedInner = _debounced(innerSignal, delayMs);
  return [() => _get(debouncedInner), (v) => _set(innerSignal, v)];
}

// ============================================================================
// SolidJS-compatible Component API
// ============================================================================

/**
 * For component for list rendering (SolidJS-style)
 * @template T
 * @param {{ each: () => T[], fallback?: any, children: (item: T, index: () => number) => any }} props
 * @returns {any}
 */
export function For(props) {
  const { each, fallback, children } = props;

  // If each is not provided or is falsy, show fallback
  if (!each) {
    return fallback ?? null;
  }

  // each should be a getter function
  const getter = typeof each === "function" ? each : () => each;

  return forEach(getter, (item, index) => {
    // Wrap index in a getter for SolidJS compatibility
    return children(item, () => index);
  });
}

/**
 * Show component for conditional rendering (SolidJS-style)
 * Note: fallback prop is not yet supported (Luna limitation)
 * @template T
 * @param {{ when: T | (() => T), fallback?: any, children: any | ((item: T) => any) }} props
 * @returns {any}
 */
export function Show(props) {
  const { when, children } = props;
  // TODO: fallback support requires MoonBit-side changes

  // Convert when to a getter if it's not already
  const condition = typeof when === "function" ? when : () => when;

  // If children is a function, we need to call it with the truthy value
  const renderChildren =
    typeof children === "function" ? () => children(condition()) : () => children;

  return show(() => Boolean(condition()), renderChildren);
}

/**
 * Index component for index-based list rendering (SolidJS-style)
 * Unlike For which tracks items by reference, Index tracks by index position
 * Item signals update in place when values change at the same index
 *
 * @template T
 * @param {{ each: () => T[], fallback?: any, children: (item: () => T, index: number) => any }} props
 * @returns {any}
 */
export function Index(props) {
  const { each, fallback, children } = props;

  if (!each) {
    return fallback ?? null;
  }

  const getter = typeof each === "function" ? each : () => each;
  const items = getter();

  if (items.length === 0 && fallback) {
    return fallback;
  }

  // Use index_each from MoonBit if available, otherwise simulate with forEach
  // For now, we'll use forEach with index-based tracking
  return forEach(getter, (_item, index) => {
    // Provide item as a getter for reactivity at that index
    const itemGetter = () => getter()[index];
    return children(itemGetter, index);
  });
}

/**
 * Provider component for Context (SolidJS-style)
 * Provides a context value to all descendants
 *
 * @template T
 * @param {{ context: Context<T>, value: T, children: any | (() => any) }} props
 * @returns {any}
 */
export function Provider(props) {
  const { context, value, children } = props;

  return provide(context, value, () => {
    return typeof children === "function" ? children() : children;
  });
}

/**
 * Switch component for conditional rendering with multiple branches (SolidJS-style)
 * Renders the first Match that evaluates to true
 *
 * @param {{ fallback?: any, children: any[] }} props
 * @returns {any}
 */
export function Switch(props) {
  const { fallback, children } = props;

  // children should be Match components, each with { when, children }
  // Since we don't have compile-time JSX, children is an array of Match results

  if (!Array.isArray(children)) {
    return fallback ?? null;
  }

  // Find first truthy match
  for (const child of children) {
    if (child && child.__isMatch && child.when()) {
      return typeof child.children === "function" ? child.children() : child.children;
    }
  }

  return fallback ?? null;
}

/**
 * Match component for use inside Switch (SolidJS-style)
 *
 * @template T
 * @param {{ when: T | (() => T), children: any | ((item: T) => any) }} props
 * @returns {{ __isMatch: true, when: () => boolean, children: any }}
 */
export function Match(props) {
  const { when, children } = props;
  const condition = typeof when === "function" ? when : () => when;

  return {
    __isMatch: true,
    when: () => Boolean(condition()),
    children:
      typeof children === "function"
        ? () => children(condition())
        : children,
  };
}

// Re-export unchanged APIs
export {
  // Batch control
  batchStart,
  batchEnd,
  batch,
  // Cleanup
  onCleanup,
  // Owner/Root
  createRoot,
  getOwner,
  runWithOwner,
  hasOwner,
  onMount,
  // DOM API
  text,
  textDyn,
  render,
  mount,
  show,
  jsx,
  jsxs,
  Fragment,
  createElement,
  events,
  forEach,
  // Route definitions
  routePage,
  routePageTitled,
  routePageFull,
  routeGroup,
  routeParam,
  createRouter,
  routerNavigate,
  routerReplace,
  routerGetPath,
  routerGetMatch,
  routerGetBase,
  // Context API
  createContext,
  provide,
  useContext,
  // Resource helpers (for direct access)
  resourceGet,
  resourcePeek,
  resourceRefetch,
  resourceIsPending,
  resourceIsSuccess,
  resourceIsFailure,
  resourceValue,
  resourceError,
  stateIsPending,
  stateIsSuccess,
  stateIsFailure,
  stateValue,
  stateError,
};

// Legacy API exports (for backwards compatibility during migration)
export {
  _get as get,
  _set as set,
  _update as update,
  _peek as peek,
  _subscribe as subscribe,
  _map as map,
  _combine as combine,
  _effect as effect,
  runUntracked,
};
