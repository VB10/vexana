import 'package:vexana_jaspr/src/cache/storage_backend_io.dart'
    if (dart.library.js_interop) 'package:vexana_jaspr/src/cache/storage_backend_web.dart'
    as platform;

/// An abstraction for key-value string storage (localStorage on web,
/// in-memory on VM/SSR).
abstract interface class IStorageBackend {
  /// Gets a value by [key].
  String? getItem(String key);

  /// Sets a [value] for [key].
  void setItem(String key, String value);

  /// Removes the item with [key].
  void removeItem(String key);

  /// Removes all items matching the prefix or cleared entirely.
  void clear();

  /// Returns all stored keys.
  Iterable<String> get keys;
}

/// Creates the platform default storage backend (WebLocalStorageBackend on web,
/// InMemory on VM).
IStorageBackend createDefaultStorageBackend() =>
    platform.createDefaultStorageBackend();

/// In-memory implementation of [IStorageBackend] for testing or SSR.
final class InMemoryStorageBackend implements IStorageBackend {
  /// Creates an in-memory storage backend.
  InMemoryStorageBackend([Map<String, String>? initialData])
      : _map = initialData ?? <String, String>{};

  final Map<String, String> _map;

  @override
  String? getItem(String key) => _map[key];

  @override
  void setItem(String key, String value) => _map[key] = value;

  @override
  void removeItem(String key) => _map.remove(key);

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;
}
