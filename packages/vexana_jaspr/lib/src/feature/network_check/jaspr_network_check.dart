import 'package:meta/meta.dart';
import 'package:vexana_jaspr/src/feature/network_check/network_check_io.dart'
    if (dart.library.js_interop) 'package:vexana_jaspr/src/feature/network_check/network_check_web.dart'
    as platform;

/// Web network connectivity checker using `window.navigator.onLine`.
@immutable
final class JasprNetworkCheck {
  const JasprNetworkCheck._();

  /// Singleton instance of [JasprNetworkCheck].
  static const JasprNetworkCheck instance = JasprNetworkCheck._();

  /// Checks if the browser is currently online according to `navigator.onLine`.
  bool get isOnline => platform.getPlatformOnline();

  /// Async check for compatibility with other network checkers.
  Future<bool> isNetworkAvailable({
    String? host,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    return isOnline;
  }
}
