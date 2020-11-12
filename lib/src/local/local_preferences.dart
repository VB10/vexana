import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/local_data.dart';
import 'IFileManager.dart';

part 'core/preferences.dart';

class LocalPreferences implements IFileManager {
  _LocalManager manager = _LocalManager.instance;
  @override
  Future<String> getUserRequestDataOnString(String key) async {
    return await manager.getModelString(key);
  }

  @override
  Future<bool> removeUserRequestCache(String key) async {
    return await manager.removeAllLocalData(key);
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key) async {
    return await manager.removeModel(key);
  }

  @override
  Future<bool> writeUserRequestDataWithTime(
      String key, Object model, Duration time) async {
    if (time == null)
      return false;
    else
      return await manager.writeModelInJson(model, key, time);
  }
}
