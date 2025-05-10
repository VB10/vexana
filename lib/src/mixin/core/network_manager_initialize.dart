part of '../../network_manager.dart';

/// Network manager provide your requests with [Dio]
mixin _NetworkManagerInitialize<E extends INetworkModel<E>, P>
    on dio.DioMixin, NetworkManagerErrorInterceptor<E, P> {
  @override
  late final NetworkManagerParameters<E, P> parameters;

  void _setup() {
    options = parameters.baseOptions;
    if (parameters.skippingSSLCertificate ?? false) ssl.createAdapter().make();
    if (parameters.isEnableLogger ?? false) interceptors.add(LogInterceptor());
    addNetworkInterceptors(parameters.interceptor);
    httpClientAdapter = adapter.createAdapter();
  }
}
