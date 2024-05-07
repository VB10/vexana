part of '../../network_manager.dart';

/// Network manager provide your requests with [Dio]
mixin _NetworkManagerInitialize on DioMixin, NetworkManagerErrorInterceptor {
  /// This method will be called when [NetworkManager] created
  ///
  ///   NetworkManagerParameters get parameters;
  @override
  NetworkManagerParameters get parameters;

  void _setup() {
    options = parameters.baseOptions;
    (transformer as BackgroundTransformer).jsonDecodeCallback =
        NetworkManagerUtil.decodeBodyWithCompute;
    if (parameters.skippingSSLCertificate ?? false) ssl.createAdapter().make();
    if (parameters.isEnableLogger ?? false) interceptors.add(LogInterceptor());
    addNetworkInterceptors(parameters.interceptor);
    httpClientAdapter = adapter.createAdapter();
  }
}
