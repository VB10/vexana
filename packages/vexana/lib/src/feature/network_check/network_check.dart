import 'package:flutter/foundation.dart';
import 'package:vexana/src/feature/network_check/network_check_io.dart'
    if (dart.library.js_interop) 'network_check_web.dart' as adapter;

@immutable

/// Ağ bağlantısı kontrolü.
///
/// Önceki sürümlerde bu kontrol `https://www.google.com` adresine tam bir
/// HTTPS isteği atıyordu. Bunun üç sorunu vardı: başarısız olan her istek
/// üçüncü bir tarafa haber veriyordu, Google'ın erişilemediği ağlarda
/// "internet yok" yanlış sonucunu üretiyordu ve isteğin zaman aşımı yoktu —
/// bağlantı asılı kaldığında kontrol de süresiz bekliyordu.
///
/// Şimdi kontrol platformun kendi araçlarıyla yapılır: IO'da DNS çözümlemesi
/// veya ağ arayüzü kontrolü, web'de `navigator.onLine`.
class NetworkCheck {
  const NetworkCheck._();

  /// Singleton instance
  static const NetworkCheck instance = NetworkCheck._();

  static const _defaultTimeout = Duration(seconds: 3);

  /// Ağ bağlantısının kullanılabilir olup olmadığını döndürür.
  ///
  /// [host] verilirse (ör. isteğin gittiği sunucunun adı) o sunucunun
  /// çözümlenebilirliği kontrol edilir — genel "internet var mı" sorusundan
  /// daha isabetli bir yanıttır. Verilmezse cihazın ağ bağlantısına bakılır.
  ///
  /// [timeout] aşılırsa `false` döner.
  Future<bool> isNetworkAvailable({
    String? host,
    Duration timeout = _defaultTimeout,
  }) {
    return adapter.createNetworkCheckAdapter().isReachable(
          host: host,
          timeout: timeout,
        );
  }
}
