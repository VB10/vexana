import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexana/src/interface/i_file_manager.dart';
import 'package:vexana/src/model/local_data.dart';
import 'package:vexana/src/utility/json_encode_util.dart';

part 'preferences.dart';

class LocalPreferences extends IFileManager {
  LocalPreferences();

  /// The `manager` is an instance of the `_LocalManager` class, which is
  /// responsible for handling the local data storage and retrieval operations using
  /// shared preferences. It provides methods like `getModelString`,
  /// `removeAllLocalData`, `removeModel`, and `writeModelInJson` to interact with
  /// the shared preferences and perform operations such as getting data as a
  /// string, removing all data, removing a single data entry, and writing data in
  /// JSON format with an optional expiration time.
  final _LocalManager manager = _LocalManager.instance;

  /// The `getUserRequestDataOnString` method is used to retrieve user request data from
  /// local storage as a string. It takes a `key` parameter, which is used to identify
  /// the specific data entry to retrieve. The method returns a `Future<String?>`, which
  /// represents the retrieved data as a string. If the data is not found or an error
  /// occurs, it returns `null`.
  @override
  Future<String?> getUserRequestDataOnString(String key) async {
    return manager.getModelString(key);
  }

  /// The `removeUserRequestCache` method is used to remove all user request data from
  /// local storage. It takes a `key` parameter, which is used to identify the specific
  /// data entry to remove. The method returns a `Future<bool>`, which indicates whether
  /// the removal operation was successful (`true`) or not (`false`).
  @override
  Future<bool> removeUserRequestCache(String key) async {
    return manager.removeAllLocalData(key);
  }

  /// The `removeUserRequestSingleCache` method is used to remove a single data entry from
  /// local storage. It takes a `key` parameter, which is used to identify the specific
  /// data entry to remove. The method returns a `Future<bool>`, which indicates whether
  /// the removal operation was successful (`true`) or not (`false`).
  @override
  Future<bool> removeUserRequestSingleCache(String key) async {
    return manager.removeModel(key);
  }

  /// The `writeUserRequestDataWithTime` method is used to write user request data to local
  /// storage with an optional expiration time. It takes three parameters: `key`, `model`,
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
      return manager.writeModelInJson(model, key, time);
    }
  }
}
