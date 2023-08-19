part of 'local_preferences.dart';

class _LocalManager {
  _LocalManager._init();

  /// The `static _LocalManager get instance` method is a getter method that returns an instance of the
  /// `_LocalManager` class. It follows the singleton design pattern, which ensures that only one
  /// instance of the class is created and shared across the application.
  static _LocalManager get instance {
    _instance ??= _LocalManager._init();
    return _instance!;
  }

  static _LocalManager? _instance;
  SharedPreferences? _preferences;

  /// The `Future<SharedPreferences> get preferences async` method is a getter method that returns a
  /// `Future` object representing the preferences stored in the local storage. It is marked as `async`
  /// because it performs an asynchronous operation, which is retrieving the `SharedPreferences`
  /// instance using `SharedPreferences.getInstance()`.
  Future<SharedPreferences> get preferences async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  /// The `writeModelInJson` method is responsible for writing a model object in JSON
  /// format to the local storage using the `SharedPreferences` class.
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

  /// The function `getModelString` is a Dart asynchronous function that takes a URL as a parameter and
  /// returns a Future that resolves to a nullable String.
  ///
  /// Args:
  ///   url (String): A string representing the URL of the model.
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

  /// The function removes all local data associated with a given URL.
  ///
  /// Args:
  ///   url (String): The URL is a string that represents the location or address of a resource on the
  /// internet. In this case, it is used as a parameter for the `removeAllLocalData` function.
  Future<bool> removeAllLocalData(String url) async {
    final pref = await preferences;

    pref.getKeys().where((element) => element.contains(url)).forEach((element) async {
      await removeModel(element);
    });
    return true;
  }

  /// The removeModel function is a Dart asynchronous function that takes a URL as a parameter and
  /// returns a Future<bool> indicating whether the model was successfully removed.
  ///
  /// Args:
  ///   url (String): The `url` parameter is a string that represents the URL of the model that you want
  /// to remove.
  Future<bool> removeModel(String url) async {
    final pref = await preferences;
    return pref.remove(url);
  }
}
