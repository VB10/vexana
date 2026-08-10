import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/feature/network_check/network_check.dart';

/// `NetworkCheck` artık üçüncü bir sunucuya (google.com) HTTP isteği atmıyor;
/// platformun kendi araçlarını kullanıyor.
void main() {
  test('çözümlenemeyen host için false döner', () async {
    /// `.invalid` IANA tarafından ayrılmıştır, hiçbir zaman çözümlenmez.
    final result = await NetworkCheck.instance.isNetworkAvailable(
      host: 'vexana-does-not-exist.invalid',
    );

    expect(result, false);
  });

  test('localhost internet olmadan da çözümlenir', () async {
    final result = await NetworkCheck.instance.isNetworkAvailable(
      host: 'localhost',
    );

    expect(result, true);
  });

  test('zaman aşımı çağıranı süresiz bekletmez', () async {
    final stopwatch = Stopwatch()..start();

    await NetworkCheck.instance.isNetworkAvailable(
      host: 'vexana-does-not-exist.invalid',
      timeout: const Duration(milliseconds: 300),
    );

    stopwatch.stop();
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 3)));
  });
}
