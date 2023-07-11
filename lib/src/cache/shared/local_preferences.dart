import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:vexana/src/interface/IFileManager.dart';
import 'package:vexana/src/model/local_data.dart';
import 'package:vexana/src/utility/json_encode_util.dart';

part 'preferences.dart';

class LocalPreferences extends IFileManager {
  LocalPreferences();
  final _LocalManager manager = _LocalManager.instance;

  @override
  Future<String?> getUserRequestDataOnString(String key) async {
    return manager.getModelString(key);
  }

  @override
  Future<bool> removeUserRequestCache(String key) async {
    return manager.removeAllLocalData(key);
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key) async {
    return manager.removeModel(key);
  }

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
