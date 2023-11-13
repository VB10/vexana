import 'package:vexana/src/mixin/network_manager_parameters.dart';

mixin NetworkManagerOperation on NetworkManagerParameters {
  /// This method will add your [MapEntry] to header
  void addBaseHeader(MapEntry<String, String> mapEntry) {
    baseOptions.headers.addAll({mapEntry.key: mapEntry.value});
  }

  /// Clear all headers value
  void clearHeader() {
    baseOptions.headers.clear();
  }

  /// Remove header value with [key]
  void removeHeader(String key) {
    baseOptions.headers.remove(key);
  }

  /// Get all headers value
  Map<String, dynamic> get allHeaders => baseOptions.headers;
}
