// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:vexana_core/vexana_core.dart';

typedef RefreshTokenCallBack = Future<DioException> Function(
  DioException error,
  NetworkManager newService,
);

typedef OnReply = Response<dynamic> Function(
  Response<dynamic> e,
);

@immutable
class NetworkManagerParameters extends Equatable {
  final void Function()? onRefreshFail;

  final IFileManager? fileManager;

  final bool? isEnableTest;

  final bool? isEnableLogger;

  final INoNetworkHandler? noNetwork;

  final int? noNetworkTryCount;

  final bool? skippingSSLCertificate;

  final Interceptor? interceptor;

  final BaseOptions baseOptions;

  final RefreshTokenCallBack? onRefreshToken;

  final OnReply? onResponseParse;

  final int maxRetryCount;

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
    this.onResponseParse,
    this.maxRetryCount = 3,
  }) : baseOptions = options;

  @override
  List<Object> get props => [baseOptions];
}
