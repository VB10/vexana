part of "../network_manager.dart";

extension _CoreServiceCacheExtension on NetworkManager {
  String urlKeyOnLocalData(RequestType type) =>
      "${options.baseUrl}-${type.stringValue}";

  Future<void> writeCache(
      Duration expiration, dynamic body, RequestType type) async {
    if (expiration == null) return;
    if (fileManager == null) throw FileManagerNotFound();
    final _stringValues = jsonEncode(body);
    await fileManager.writeUserRequestDataWithTime(
        urlKeyOnLocalData(type), _stringValues, expiration);
  }

  Future<String> getLocalData(RequestType type) async {
    if (fileManager == null) return null;

    final data =
        await fileManager.getUserRequestDataOnString(urlKeyOnLocalData(type));
    if (data is String && data.isNotEmpty)
      return data;
    else
      return null;
  }
}
