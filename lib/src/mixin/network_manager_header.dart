import 'package:vexana/src/mixin/network_manager_paramaters.dart';

mixin NetworkManagerOperation on NetworkManagerParameters {
  void addBaseHeader(MapEntry<String, String> mapEntry) {
    baseOptions.headers[mapEntry.key] = mapEntry.value;
  }

  void clearHeader() {
    baseOptions.headers.clear();
  }

  void removeHeader(String key) {
    baseOptions.headers.remove(key);
  }

  Map<String, dynamic> get allHeaders => baseOptions.headers;
}
