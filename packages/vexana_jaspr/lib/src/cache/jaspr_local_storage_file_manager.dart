import 'dart:convert';
import 'package:vexana_core/internal.dart';
import 'package:vexana_core/vexana_core.dart';
import 'package:vexana_jaspr/src/cache/storage_backend.dart';

/// An [IFileManager] implementation backed by browser localStorage
/// or Jaspr storage.
final class JasprLocalStorageFileManager extends IFileManager {
  /// Creates a Jaspr localStorage file manager with an optional backend.
  JasprLocalStorageFileManager({IStorageBackend? storageBackend})
      : _backend = storageBackend ?? createDefaultStorageBackend();

  final IStorageBackend _backend;

  @override
  Future<String?> getUserRequestDataOnString(String key) async {
    final raw = _backend.getItem(key);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final local = LocalModel.fromJson(map);

      final expirationTime = local.time;
      if (expirationTime != null && DateTime.now().isAfter(expirationTime)) {
        _backend.removeItem(key);
        return null;
      }
      return local.model;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> writeUserRequestDataWithTime(
    String key,
    String model,
    Duration? time,
  ) async {
    if (time == null) return false;

    try {
      final expirationDate = DateTime.now().add(time);
      final local = LocalModel(
        model: model,
        time: expirationDate,
      );
      _backend.setItem(key, jsonEncode(local.toJson()));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key) async {
    try {
      _backend.removeItem(key);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> removeUserRequestCache(String key) async {
    try {
      final matchingKeys =
          _backend.keys.where((k) => k.startsWith(key)).toList();
      for (final k in matchingKeys) {
        _backend.removeItem(k);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
