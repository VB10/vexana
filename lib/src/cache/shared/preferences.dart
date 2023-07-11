part of 'local_preferences.dart';

class _LocalManager {
  _LocalManager._init();
  static _LocalManager get instance {
    _instance ??= _LocalManager._init();
    return _instance!;
  }

  static _LocalManager? _instance;
  SharedPreferences? _preferences;

  Future<SharedPreferences> get preferences async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<bool> writeModelInJson(
    dynamic body,
    String url,
    Duration? duration,
  ) async {
    if (body is! String) return false;
    final localPreferences = await preferences;

    if (duration == null) {
      return false;
    } else {
      final local = LocalModel(model: body, time: DateTime.now().add(duration));
      final json = jsonEncode(local.toJson());
      if (json.isNotEmpty) {
        return localPreferences.setString(url, json);
      }
      return false;
    }
  }

  Future<String?> getModelString(String url) async {
    final localPreferences = await preferences;

    final jsonString = localPreferences.getString(url);
    if (jsonString != null) {
      final jsonModel = await JsonDecodeUtil.safeJsonDecodeCompute(jsonString);

      if (jsonModel == null) return null;
      if (jsonModel is! Map<String, dynamic>) return null;
      final data = LocalModel.fromJson(jsonModel);
      final time = data.time;
      if (time != null && DateTime.now().isBefore(time)) {
        return data.model;
      } else {
        await removeModel(url);
      }
    }

    return null;
  }

  Future<bool> removeAllLocalData(String url) async {
    final pref = await preferences;

    pref
        .getKeys()
        .where((element) => element.contains(url))
        .forEach((element) async {
      await removeModel(element);
    });
    return true;
  }

  Future<bool> removeModel(String url) async {
    final pref = await preferences;
    return await pref.remove(url);
  }
}
