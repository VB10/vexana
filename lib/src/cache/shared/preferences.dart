part of 'local_preferences.dart';

class _LocalManager {
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

  _LocalManager._init();

  Future<bool> writeModelInJson(dynamic body, String url, Duration? duration) async {
    final _pref = await preferences;

    if (duration == null) {
      return false;
    } else {
      final local = LocalModel(model: body, time: DateTime.now().add(duration));
      final json = jsonEncode(local.toJson());
      if (body != null && json.isNotEmpty) {
        return await _pref.setString(url, json);
      }
      return false;
    }
  }

  Future<String?> getModelString(String url) async {
    final _pref = await preferences;

    final jsonString = _pref.getString(url);
    if (jsonString != null) {
      final jsonModel = jsonDecode(jsonString);
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
    final _pref = await preferences;

    _pref.getKeys().where((element) => element.contains(url)).forEach((element) async {
      await removeModel(element);
    });
    return true;
  }

  Future<bool> removeModel(String url) async {
    final _pref = await preferences;
    return await _pref.remove(url);
  }
}
