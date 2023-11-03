// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:vexana/vexana.dart';

class NetworkManagerParameters {
  final VoidCallback? onRefreshFail;

  static const int maxRetryCount = 3;

  final IFileManager? fileManager;

  final bool? isEnableTest;

  final bool? isEnableLogger;

  final NoNetwork? noNetwork;

  final int? noNetworkTryCount;

  final bool? skippingSSLCertificate;

  final Interceptor? interceptor;

  final BaseOptions baseOptions;

  Future<DioException> Function(
    DioException error,
    NetworkManager newService,
  )? onRefreshToken;

  NetworkManagerParameters({
    required BaseOptions options,
    this.onRefreshFail,
    this.fileManager,
    this.isEnableTest,
    this.isEnableLogger,
    this.noNetwork,
    this.noNetworkTryCount,
    this.skippingSSLCertificate,
    this.interceptor,
    this.onRefreshToken,
  }) : baseOptions = options;
}
