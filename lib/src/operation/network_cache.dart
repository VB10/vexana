part of "../network_manager.dart";

extension _CoreServiceWrapperExtension on NetworkManager {
  String urlKeyOnLocalData(RequestType type) =>
      "${options.baseUrl}-${type.stringValue}";

  Future writeCache(String body, RequestType type) async {
    if (fileManager == null) return;
  }
}
