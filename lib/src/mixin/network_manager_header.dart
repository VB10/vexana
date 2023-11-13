import 'package:vexana/src/mixin/network_manager_parameters.dart';

mixin NetworkManagerOperation {
  NetworkManagerParameters get parameters;

  /// This method will add your [MapEntry] to header
  void addBaseHeader(MapEntry<String, String> mapEntry) {
    parameters.baseOptions.headers.addAll({mapEntry.key: mapEntry.value});
  }

  /// Clear all headers value
  void clearHeader() {
    parameters.baseOptions.headers.clear();
  }

  /// Remove header value with [key]
  void removeHeader(String key) {
    parameters.baseOptions.headers.remove(key);
  }

  /// Get all headers value
  Map<String, dynamic> get allHeaders => parameters.baseOptions.headers;
}
