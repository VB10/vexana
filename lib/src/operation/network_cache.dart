part of '../network_manager.dart';

extension _CoreServiceCacheExtension on NetworkManager {
  String _urlKeyOnLocalData(RequestType type) => '${options.baseUrl}-${type.stringValue}';

  /// The `writeCacheAll` method is responsible for writing cache data to the local storage. It takes
  /// three parameters:
  /// - `expiration`: The expiration time for the cache data.
  /// - `body`: The cache data to write.
  /// - `type`: The type of request.
  Future<void> writeCacheAll(
    Duration? expiration,
    dynamic body,
    RequestType type,
  ) async {
    if (expiration == null) return;
    if (fileManager == null) throw FileManagerNotFound();
    final stringValues = jsonEncode(body);
    await fileManager!.writeUserRequestDataWithTime(_urlKeyOnLocalData(type), stringValues, expiration);
  }

  /// The function `getLocalData` is a Dart asynchronous function that returns a `Future` of type
  /// `String?` and takes a parameter of type `RequestType`.
  ///
  /// Args:
  ///   type (RequestType): The `type` parameter is of type `RequestType`.
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
    return fileManager!.removeUserRequestCache(options.baseUrl);
  }
}
