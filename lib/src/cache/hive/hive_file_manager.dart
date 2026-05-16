import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';
import 'package:vexana/src/interface/i_file_manager.dart';

/// Manage cache with Hive Community Edition. Call [init] before use.
final class HiveFileManager extends IFileManager {
  /// Private constructor
  HiveFileManager({this.boxName = 'vexana_cache'});

  /// The box name to store the data
  final String boxName;

  /// Hive initialized or not
  bool _isInitialized = false;

  /// Initialize Hive with box
  Future<void> init({String? path}) async {
    if (_isInitialized) return;
    if (path != null) {
      Hive.init(path);
    }
    await Hive.openBox<String>(boxName);
    _isInitialized = true;
  }

  /// Get the Hive box safely
  Box<String> get _box {
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError('Hive box $boxName is not opened. Call init() first.');
    }
    return Hive.box<String>(boxName);
  }

  @override
  Future<String?> getUserRequestDataOnString(String key) async {
    try {
      final data = _box.get(key);
      if (data == null) return null;

      final decoded = jsonDecode(data) as Map<String, dynamic>;

      // Check expiration
      final expirationMs = decoded['expirationMs'] as int?;
      if (expirationMs != null) {
        final expirationDate =
            DateTime.fromMillisecondsSinceEpoch(expirationMs);
        if (DateTime.now().isAfter(expirationDate)) {
          await removeUserRequestSingleCache(key);
          return null;
        }
      }

      return decoded['data'] as String;
    } on Object {
      return null;
    }
  }

  @override
  Future<bool> removeUserRequestCache(String key) async {
    try {
      // Find keys that start with the base URL (key)
      final keysToDelete = _box.keys.where((k) {
        if (k is String) {
          return k.startsWith(key);
        }
        return false;
      }).toList();

      for (final k in keysToDelete) {
        await _box.delete(k);
      }
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key) async {
    try {
      await _box.delete(key);
      return true;
    } on Object {
      return false;
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

      final dataToStore = jsonEncode({
        'data': model,
        'expirationMs': expirationDate.millisecondsSinceEpoch,
      });

      await _box.put(key, dataToStore);
      return true;
    } on Object {
      return false;
    }
  }

  /// Clear all cache in the box
  Future<bool> clearAll() async {
    try {
      await _box.clear();
      return true;
    } on Object {
      return false;
    }
  }
}
