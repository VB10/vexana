import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexana_core/internal.dart';
import 'package:vexana_core/vexana_core.dart';

part 'preferences.dart';

/// Manage cache with shared package
final class LocalPreferences extends IFileManager {
  final _LocalManager _manager = _LocalManager.instance;

  /// The `getUserRequestDataOnString` method is used to retrieve
  /// user request data from
  /// local storage as a string. It takes a `key` parameter,
  ///  which is used to identify
  /// the specific data entry to retrieve. The method returns a
  /// `Future<String?>`, which
  /// represents the retrieved data as a string. If the data
  ///  is not found or an error
  /// occurs, it returns `null`.
  @override
  Future<String?> getUserRequestDataOnString(String key) async {
    return _manager.getModelString(key);
  }

  /// The `removeUserRequestCache` method is used to remove
  ///  all user request data from
  /// local storage. It takes a `key` parameter, which is used
  /// to identify the specific
  /// data entry to remove. The method returns a `Future<bool>`,
  ///  which indicates whether
  /// the removal operation was successful (`true`) or not (`false`).
  @override
  Future<bool> removeUserRequestCache(String key) async {
    return _manager.removeAllLocalData(key);
  }

  /// The `removeUserRequestSingleCache` method is used to remove
  /// a single data entry from
  /// local storage. It takes a `key` parameter, which is used
  ///  to identify the specific
  /// data entry to remove. The method returns a `Future<bool>`,
  ///  which indicates whether
  /// the removal operation was successful (`true`) or not (`false`).
  @override
  Future<bool> removeUserRequestSingleCache(String key) async {
    return _manager.removeModel(key);
  }

  /// The `writeUserRequestDataWithTime` method is used to write user request
  ///  data to local
  /// storage with an optional expiration time. It takes three parameters:
  ///  `key`, `model`,
  /// and `time`.
  @override
  Future<bool> writeUserRequestDataWithTime(
    String key,
    Object model,
    Duration? time,
  ) async {
    if (time == null) {
      return false;
    } else {
      return _manager.writeModelInJson(model, key, time);
    }
  }
}
