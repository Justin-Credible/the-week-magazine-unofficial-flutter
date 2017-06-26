import "dart:core";

enum CacheBehavior {

    /// The default caching behavior; allows the data provider to determine
    /// if a cached entry should be used or if fresh data should be retrieved.
    Default,

    /// Indicates that the cached content should be ignored and a fresh data
    /// retrieve should be forced.
    InvalidateCache,

    /// Indicates that the cached content should can be used even if it is stale.
    AllowStale,
}

class CacheEntry<T> {

    T _item;
    Duration _lifespan;
    DateTime _createdAt;

    CacheEntry(T item, [Duration lifespan]) {
        _item = item;
        _lifespan = lifespan;
        _createdAt = new DateTime.now();
    }

    T get item => _item;

    Duration get lifespan => _lifespan;

    DateTime get createdAt => _createdAt;

    /// Used to check if the this cache entry has expired.
    bool get hasExpired {

        // If there is no lifespan set, then this entry will never expire.
        if (_lifespan == null) {
            return false;
        }

        var expiresAt = _createdAt.add(_lifespan);
        var now = new DateTime.now();

        return now.isAfter(expiresAt);
    }

    /// Used to immediately mark this cache entry as expired.
    void expire() {
        _lifespan = new Duration(seconds: 0);
    }

    /// Used to immediately update the expiration time of this cache entry.
    void touch() {
        _createdAt = new DateTime.now();
    }
}

// TODO: Implement optional file system backed cache.

/// An in-memory cache.
class Cache {

    static Map<String, CacheEntry> _cache = new Map();

    /// Used to set an entry into the cache.
    static void set(String key, CacheEntry cacheEntry) {
        _cache[key] = cacheEntry;
    }

    /// Used to retrieve an entry from the cache.
    static CacheEntry<T> get<T>(String key, [CacheBehavior cacheBehavior = CacheBehavior.Default]) {

        if (cacheBehavior == null) {
            cacheBehavior = CacheBehavior.Default;
        }

        if (cacheBehavior == CacheBehavior.Default) {
            var entry = _cache[key];

            if (entry != null && !entry.hasExpired) {
                return entry;
            }
        }
        else if (cacheBehavior == CacheBehavior.AllowStale) {
            var entry = _cache[key];

            if (entry != null) {
                return entry;
            }
        }

        return null;
    }
}
