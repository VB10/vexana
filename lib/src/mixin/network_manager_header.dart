import 'package:vexana/src/mixin/network_manager_parameters.dart';

mixin NetworkManagerOperation on NetworkManagerParameters {
  void addBaseHeader(MapEntry<String, String> mapEntry) {
    baseOptions.headers.addAll({mapEntry.key: mapEntry.value});
    print(baseOptions.headers);
  }

  void clearHeader() {
    baseOptions.headers.clear();
  }

  void removeHeader(String key) {
    baseOptions.headers.remove(key);
  }

  Map<String, dynamic> get allHeaders => baseOptions.headers;
}
