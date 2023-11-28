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
      onRequest: (options, handler) async => handler.next(options),
      onError: (DioException exception, ErrorInterceptorHandler handler) async {
        final errorResponse = exception.response;

        /// If error response is null, then return error
        if (errorResponse == null) return handler.next(exception);

        /// If callback for onRefreshToken is null, then return error
        if (errorResponse.statusCode == HttpStatus.unauthorized &&
            parameters.onRefreshToken == null) {
          return handler.next(exception);
        }

        /// Calling onRefreshToken first time;
        var error = await _createError(parameters, exception);
        error.requestOptions.cancelToken ??= CancelToken();
        try {
          /// lock();
          final response = await retry(
            () => _createNewRequest(error),
            onRetry: (_) async =>
                error = await _createError(parameters, exception),
            maxAttempts: NetworkManagerParameters.maxRetryCount,
            retryIf: _retryIf,
          );

          /// unlock();
          return handler.resolve(response);
        } catch (_) {
          /// unlock and cancel request & call onRefreshFail callback
          error.requestOptions.cancelToken?.cancel();
          parameters.onRefreshFail?.call();
          return handler.next(exception);
        }
      },
    );
  }

  Future<DioException> _createError(
    NetworkManagerParameters params,
    DioException exception,
  ) {
    return params.onRefreshToken!(
      exception,
      NetworkManager<EmptyModel>(
        isEnableLogger: params.isEnableLogger,
        isEnableTest: params.isEnableTest,
        options: parameters.baseOptions,
      ),
    );
  }

  Future<Response<dynamic>> _createNewRequest(DioException error) {
    final dioNewInstance = Dio(parameters.baseOptions);
    return dioNewInstance.request<dynamic>(
      error.requestOptions.path,
      queryParameters: error.requestOptions.queryParameters,
      data: error.requestOptions.data,
      cancelToken: error.requestOptions.cancelToken,
      options: Options(
        method: error.requestOptions.method,
        headers: error.requestOptions.headers,
      ),
    );
  }

  bool _retryIf(Exception e) {
    if (e is! DioException) return false;
    return e.response?.statusCode == HttpStatus.unauthorized;
  }
}
