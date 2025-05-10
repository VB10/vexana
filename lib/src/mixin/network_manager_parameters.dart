// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:vexana/vexana.dart';

typedef RefreshTokenCallBack<E extends INetworkModel<E>, P>
    = Future<DioException> Function(
  DioException error,
  NetworkManager<E, P> newService,
);

typedef OnReply = Response<dynamic> Function(
  Response<dynamic> e,
);

@immutable
class NetworkManagerParameters<E extends INetworkModel<E>, P extends Object?>
    extends Equatable {
  final VoidCallback? onRefreshFail;

  final IFileManager? fileManager;

  final bool? isEnableTest;

  final bool? isEnableLogger;

  final NoNetwork? noNetwork;

  final int? noNetworkTryCount;

  final bool? skippingSSLCertificate;

  final Interceptor? interceptor;

  final BaseOptions baseOptions;

  final RefreshTokenCallBack<E, P>? onRefreshToken;

  final OnReply? onResponseParse;

  final int maxRetryCount;

  final bool handleRefreshToken;

  final P? customParameter;

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
    bool? handleRefreshToken,
    this.customParameter,
  })  : assert(
          handleRefreshToken != true || onRefreshToken != null,
          'handleRefreshToken cannot be true if onRefreshToken is null',
        ),
        baseOptions = options,
        handleRefreshToken = handleRefreshToken ?? onRefreshToken != null;

  NetworkManagerParameters<E, P> copyWith({
    VoidCallback? onRefreshFail,
    IFileManager? fileManager,
    bool? isEnableTest,
    bool? isEnableLogger,
    NoNetwork? noNetwork,
    int? noNetworkTryCount,
    bool? skippingSSLCertificate,
    Interceptor? interceptor,
    BaseOptions? baseOptions,
    RefreshTokenCallBack<E, P>? onRefreshToken,
    OnReply? onResponseParse,
    int? maxRetryCount,
    bool? handleRefreshToken,
    P? customParameter,
  }) {
    return NetworkManagerParameters<E, P>(
      options: baseOptions ?? this.baseOptions,
      onRefreshFail: onRefreshFail ?? this.onRefreshFail,
      fileManager: fileManager ?? this.fileManager,
      isEnableTest: isEnableTest ?? this.isEnableTest,
      isEnableLogger: isEnableLogger ?? this.isEnableLogger,
      noNetwork: noNetwork ?? this.noNetwork,
      noNetworkTryCount: noNetworkTryCount ?? this.noNetworkTryCount,
      skippingSSLCertificate:
          skippingSSLCertificate ?? this.skippingSSLCertificate,
      interceptor: interceptor ?? this.interceptor,
      onRefreshToken: onRefreshToken ?? this.onRefreshToken,
      onResponseParse: onResponseParse ?? this.onResponseParse,
      maxRetryCount: maxRetryCount ?? this.maxRetryCount,
      handleRefreshToken: handleRefreshToken ?? this.handleRefreshToken,
      customParameter: customParameter ?? this.customParameter,
    );
  }

  @override
  List<Object?> get props => [baseOptions, handleRefreshToken, customParameter];
}
