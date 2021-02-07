part of '../network_manager.dart';

extension _CoreServiceCacheExtension on NetworkManager {
  String urlKeyOnLocalData(RequestType type, String path) => '${options.baseUrl}-$path-${type.stringValue}';

  Future<void> writeCache(Duration expiration, dynamic body, RequestType type, String path) async {
    if (expiration == null) return;
    if (fileManager == null) throw FileManagerNotFound();
    final _stringValues = jsonEncode(body);
    await fileManager.writeUserRequestDataWithTime(urlKeyOnLocalData(type, path), _stringValues, expiration);
  }

  Future<String> getLocalData(RequestType type, String path) async {
    if (fileManager == null) return null;

    final data = await fileManager.getUserRequestDataOnString(urlKeyOnLocalData(type, path));
    if (data is String && data.isNotEmpty) {
      return data;
    } else {
      return null;
    }
  }

  Future<bool> _removeAllCache() async {
    if (fileManager == null) return false;
    return await fileManager.removeUserRequestCache(options.baseUrl);
  }
}
