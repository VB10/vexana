import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:retry/retry.dart';
import 'package:vexana/src/mixin/index.dart';
import 'package:vexana/vexana.dart';

/// Network manager error interceptor
mixin NetworkManagerErrorInterceptor {
  /// Network manager interceptors
  Interceptors get interceptors;

  /// Network manager base request options
  NetworkManagerParameters get parameters;

  /// Add your custom network interceptor
  void addNetworkInterceptors(Interceptor? interceptor) {
    if (interceptor != null) interceptors.add(interceptor);
    interceptors.add(_onErrorWrapper());
  }

  QueuedInterceptorsWrapper _onErrorWrapper() {
    return QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        return handler.next(options);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        final errorResponse = e.response;
        if (errorResponse == null) return handler.next(e);

        if (errorResponse.statusCode == HttpStatus.unauthorized &&
            parameters.onRefreshToken != null) {
          var error = await parameters.onRefreshToken!(
            e,
            NetworkManager<EmptyModel>(
              options: parameters.baseOptions,
              isEnableTest: parameters.isEnableTest,
            ),
          );

          try {
            final response = await retry(
              () {
                final dioNewInstance = Dio(parameters.baseOptions);
                // dioNewInstance.httpClientAdapter = httpClientAdapter;
                return dioNewInstance.request<dynamic>(
                  error.requestOptions.path,
                  queryParameters: error.requestOptions.queryParameters,
                  data: error.requestOptions.data,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                );
              },
              onRetry: (p0) async {
                error = await parameters.onRefreshToken!(
                  e,
                  NetworkManager<EmptyModel>(
                    options: parameters.baseOptions,
                  ),
                );
              },
              maxAttempts: NetworkManagerParameters.maxRetryCount,
              retryIf: (e) {
                if (e is DioException) {
                  return e.response?.statusCode == HttpStatus.unauthorized;
                }
                return false;
              },
            );
            // unlock();
            return handler.resolve(response);
          } catch (_) {
            parameters.onRefreshFail?.call();
            return handler.next(e);
          }
        }

        return handler.next(e);
      },
    );
  }
}
