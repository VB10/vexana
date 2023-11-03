import 'package:vexana/src/feature/adapter/native_adapter.dart'
    if (dart.library.html) 'package:vexana/src/feature/adapter/web_adapter.dart'
    as adapter;
import 'package:vexana/src/feature/ssl/io_custom_override.dart'
    if (dart.library.html) 'package:vexana/src/feature/ssl/html_custom_override.dart'
    as ssl;
import 'package:vexana/src/mixin/network_manager_error_interceptor.dart';
import 'package:vexana/src/mixin/network_manager_paramaters.dart';
import 'package:vexana/src/utility/network_manager_util.dart';
import 'package:vexana/vexana.dart';

mixin NetworkManagerInitialize
    on DioMixin, NetworkManagerParameters, NetworkManagerErrorInterceptor {
  void setup() {
    options = baseOptions;
    (transformer as BackgroundTransformer).jsonDecodeCallback =
        NetworkManagerUtil.decodeBodyWithCompute;
    if (skippingSSLCertificate ?? false) ssl.createAdapter().make();
    if (isEnableLogger ?? false) interceptors.add(LogInterceptor());
    addNetworkInterceptors(interceptor);
    httpClientAdapter =
        adapter.createAdapter(isEnableTest: isEnableTest ?? false);
  }
}
