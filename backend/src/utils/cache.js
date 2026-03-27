/**
 * Simple in-memory response cache for read-heavy endpoints
 * Reduces DB/IO load under scale. Only active when config.features.caching is true.
 */

const { config } = require('../config');

const cache = new Map();

function isEnabled() {
  return config.features?.caching === true;
}

/**
 * Get cached value if not expired
 * @param {string} key - Cache key
 * @returns {*} Cached value or undefined
 */
function get(key) {
  if (!isEnabled()) return undefined;
  const entry = cache.get(key);
  if (!entry) return undefined;
  if (Date.now() > entry.expiresAt) {
    cache.delete(key);
    return undefined;
  }
  return entry.value;
}

/**
 * Set cache value with TTL
 * @param {string} key - Cache key
 * @param {*} value - Value to cache
 * @param {number} ttlSeconds - TTL in seconds (default 300 = 5 min)
 */
function set(key, value, ttlSeconds = 300) {
  if (!isEnabled()) return;
  cache.set(key, {
    value,
    expiresAt: Date.now() + ttlSeconds * 1000,
  });
}

/**
 * Invalidate cache by key or prefix
 * @param {string} keyOrPrefix - Exact key or prefix (invalidates all keys starting with prefix)
 */
function invalidate(keyOrPrefix) {
  if (cache.has(keyOrPrefix)) {
    cache.delete(keyOrPrefix);
  } else {
    for (const key of cache.keys()) {
      if (key.startsWith(keyOrPrefix)) {
        cache.delete(key);
      }
    }
  }
}

/**
 * Wrap an async handler to use cache for GET requests
 * @param {string} cacheKey - Unique key
 * @param {number} ttlSeconds - TTL in seconds
 * @param {Function} handler - Route handler (req, res, next)
 */
function withCache(cacheKey, ttlSeconds, handler) {
  return async (req, res, next) => {
    if (req.method !== 'GET') {
      return handler(req, res, next);
    }

    const cached = get(cacheKey);
    if (cached !== undefined) {
      return res.status(200).json(cached);
    }

    const _next = next;
    const originalJson = res.json.bind(res);
    res.json = (body) => {
      set(cacheKey, body, ttlSeconds);
      originalJson(body);
    };
    return handler(req, res, _next);
  };
}

module.exports = {
  get,
  set,
  invalidate,
  withCache,
};
