import 'dart:js_interop';

import 'package:vexana/src/feature/network_check/custom_network_check.dart';

/// Web için bağlantı kontrolü.
CustomNetworkCheck createNetworkCheckAdapter() => _WebNetworkCheck();

@JS('navigator.onLine')
external bool get _navigatorOnLine;

final class _WebNetworkCheck with CustomNetworkCheck {
  /// Tarayıcıda ağ kontrolü senkron ve bedava: `navigator.onLine`.
  ///
  /// [host] burada kullanılmaz — tarayıcı sandbox'ı DNS çözümlemesine izin
  /// vermez ve deneme isteği CORS'a takılır. `onLine` yanlış pozitif verebilir
  /// (arayüz var ama internet yok), ancak `false` döndüğünde kesin olarak
  /// bağlantı yoktur; kullanıldığı yer olan "bağlantı yok" akışı için doğru
  /// olan taraf budur.
  @override
  Future<bool> isReachable({
    required Duration timeout,
    String? host,
  }) async =>
      _navigatorOnLine;
}
