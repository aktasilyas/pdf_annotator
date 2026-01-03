/// LRU Cache
///
/// Least Recently Used (LRU) cache implementation.
/// Otomatik olarak en az kullanılan item'ları temizler.
/// DrawingPage cache'i için kullanılır.
library;

import 'package:flutter/foundation.dart';

/// LRU Cache with automatic cleanup
class LRUCache<K, V extends ChangeNotifier> {
  final int _maxSize;
  final Map<K, V> _cache = {};
  final List<K> _accessOrder = [];

  LRUCache(this._maxSize);

  /// Get item from cache
  V? get(K key) {
    if (!_cache.containsKey(key)) {
      return null;
    }

    // Move to end (most recently used)
    _accessOrder.remove(key);
    _accessOrder.add(key);

    return _cache[key];
  }

  /// Put item in cache
  void put(K key, V value) {
    // If already exists, update access order
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
      _accessOrder.add(key);
      _cache[key] = value;
      return;
    }

    // Add new item
    _cache[key] = value;
    _accessOrder.add(key);

    // Evict if over capacity
    _evictIfNecessary();
  }

  /// Remove item from cache
  V? remove(K key) {
    _accessOrder.remove(key);
    return _cache.remove(key);
  }

  /// Check if key exists
  bool containsKey(K key) {
    return _cache.containsKey(key);
  }

  /// Get current size
  int get size => _cache.length;

  /// Get max size
  int get maxSize => _maxSize;

  /// Clear all items
  void clear() {
    // Dispose all items if they're ChangeNotifiers
    for (final item in _cache.values) {
      item.dispose();
    }
    _cache.clear();
    _accessOrder.clear();
  }

  /// Get all keys
  Iterable<K> get keys => _cache.keys;

  /// Get all values
  Iterable<V> get values => _cache.values;

  /// Evict least recently used items
  void _evictIfNecessary() {
    while (_cache.length > _maxSize && _accessOrder.isNotEmpty) {
      final lruKey = _accessOrder.removeAt(0);
      final removed = _cache.remove(lruKey);

      // Dispose the removed item
      removed?.dispose();

      debugPrint('LRU Cache: Evicted $lruKey (size: ${_cache.length})');
    }
  }

  /// Manually evict items until size is under threshold
  void evictUntil(int targetSize) {
    while (_cache.length > targetSize && _accessOrder.isNotEmpty) {
      final lruKey = _accessOrder.removeAt(0);
      final removed = _cache.remove(lruKey);
      removed?.dispose();
    }
  }

  /// Get least recently used key
  K? get leastRecentlyUsed {
    return _accessOrder.isEmpty ? null : _accessOrder.first;
  }

  /// Get most recently used key
  K? get mostRecentlyUsed {
    return _accessOrder.isEmpty ? null : _accessOrder.last;
  }
}
