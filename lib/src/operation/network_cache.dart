part of '../network_manager.dart';

extension _CoreServiceCacheExtension on NetworkManager {
  String _urlKeyOnLocalData(RequestType type) => '${options.baseUrl}-${type.stringValue}';

  Future<void> writeCacheAll(Duration? expiration, dynamic body, RequestType type) async {
    if (expiration == null) return;
    if (fileManager == null) throw FileManagerNotFound();
    final _stringValues = jsonEncode(body);
    await fileManager!.writeUserRequestDataWithTime(_urlKeyOnLocalData(type), _stringValues, expiration);
  }

  Future<String?> getLocalData(RequestType type) async {
    if (fileManager == null) return null;

    final data = await fileManager!.getUserRequestDataOnString(_urlKeyOnLocalData(type));
    if (data is String && data.isNotEmpty) {
      return data;
    } else {
      return null;
    }
  }

  Future<bool> _removeAllCache() async {
    if (fileManager == null) {
      return false;
    }
    return await fileManager!.removeUserRequestCache(options.baseUrl);
  }
}
