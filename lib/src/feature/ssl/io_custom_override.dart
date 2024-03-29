import 'dart:io';

import 'package:vexana/src/feature/ssl/http_custom_override.dart';

/// SSL certificate override
HttpCustomOverride createAdapter() => _GeneralCustomOverride();

final class _GeneralCustomOverride with HttpCustomOverride {
  @override
  void make() {
    HttpOverrides.global = _MyHttpOverrides();
  }
}

final class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
