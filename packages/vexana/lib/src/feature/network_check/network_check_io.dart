import 'dart:async';
import 'dart:io';

import 'package:vexana/src/feature/network_check/custom_network_check.dart';

/// IO platformları için bağlantı kontrolü.
CustomNetworkCheck createNetworkCheckAdapter() => _IoNetworkCheck();

final class _IoNetworkCheck with CustomNetworkCheck {
  @override
  Future<bool> isReachable({
    required Duration timeout,
    String? host,
  }) async {
    if (host != null && host.isNotEmpty) return _canResolve(host, timeout);
    return _hasActiveInterface(timeout);
  }

  /// Sunucu adının çözümlenebilmesi, o sunucuya erişilebilirliğin HTTP isteği
  /// atmadan alınabilecek en yakın göstergesidir.
  Future<bool> _canResolve(String host, Duration timeout) async {
    try {
      final addresses = await InternetAddress.lookup(host).timeout(timeout);
      return addresses.any((address) => address.rawAddress.isNotEmpty);
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  /// Hedef bilinmiyorsa cihazda loopback olmayan bir ağ arayüzü var mı diye
  /// bakılır. Captive portal'ı yakalamaz ama üçüncü bir sunucuya istek
  /// atmadan verilebilecek en dürüst yanıt budur.
  Future<bool> _hasActiveInterface(Duration timeout) async {
    try {
      final interfaces = await NetworkInterface.list().timeout(timeout);
      return interfaces.any((interface) => interface.addresses.isNotEmpty);
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}
