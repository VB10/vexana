import 'package:vexana_jaspr/src/cache/storage_backend.dart';
import 'package:web/web.dart' as web;

/// Browser web default backend.
IStorageBackend createDefaultStorageBackend() => const WebLocalStorageBackend();

/// Browser `window.localStorage` implementation of [IStorageBackend].
final class WebLocalStorageBackend implements IStorageBackend {
  /// Default const constructor for [WebLocalStorageBackend].
  const WebLocalStorageBackend();

  web.Storage get _storage => web.window.localStorage;

  @override
  String? getItem(String key) => _storage.getItem(key);

  @override
  void setItem(String key, String value) => _storage.setItem(key, value);

  @override
  void removeItem(String key) => _storage.removeItem(key);

  @override
  void clear() => _storage.clear();

  @override
  Iterable<String> get keys {
    final length = _storage.length;
    final result = <String>[];
    for (var i = 0; i < length; i++) {
      final key = _storage.key(i);
      if (key != null) result.add(key);
    }
    return result;
  }
}
