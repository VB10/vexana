// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:vexana/vexana.dart';

typedef RefreshTokenCallBack = Future<DioException> Function(
  DioException error,
  NetworkManager newService,
);

@immutable
class NetworkManagerParameters extends Equatable {
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

  final RefreshTokenCallBack? onRefreshToken;

  const NetworkManagerParameters({
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

  @override
  List<Object> get props => [baseOptions];
}
