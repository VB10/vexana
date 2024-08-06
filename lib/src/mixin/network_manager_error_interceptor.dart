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
      onError: (DioException exception, ErrorInterceptorHandler handler) async {
        final errorResponse = exception.response;

        /// If error response is null, then return error
        if (errorResponse == null) return handler.next(exception);

        /// If error response status code is not 401, then return error
        if (errorResponse.statusCode != HttpStatus.unauthorized) {
          return handler.next(exception);
        }

        /// If callback for onRefreshToken is null, then return error
        if (parameters.onRefreshToken == null) {
          return handler.next(exception);
        }

        /// Calling onRefreshToken first time;
        var error = await _createError(parameters, exception);
        try {
          /// lock();
          final response = await retry(
            () => _createNewRequest(error),
            onRetry: (_) async =>
                error = await _createError(parameters, exception),
            maxAttempts: NetworkManagerParameters.maxRetryCount,
            retryIf: _retryIf,
          );

          return handler.resolve(
            parameters.onResponseParse!(
              response,
            ),
          );
        } catch (_) {
          /// cancel request & call onRefreshFail callback and unlock
          error.requestOptions.cancelToken?.cancel();
          parameters.onRefreshFail?.call();
          return handler.next(exception);
        }
      },
    );
  }

  /// Creates a new [DioException] with [HttpStatus.unauthorized] status code
  /// It's retried if [exception] is [DioException] and status code is
  /// [HttpStatus.unauthorized].
  Future<DioException> _createError(
    NetworkManagerParameters params,
    DioException exception,
  ) async {
    final error = _parallelismGuard(params, exception);
    if (error != null) return error;
    return params.onRefreshToken!(
      exception,
      NetworkManager<EmptyModel>(
        isEnableLogger: params.isEnableLogger,
        isEnableTest: params.isEnableTest,
        options: parameters.baseOptions,
      ),
    );
  }

  /// Creates a new request with the same options of [error] and returns it.
  /// It's retried if [error] is [DioException] and status code is
  /// [HttpStatus.unauthorized].
  Future<Response<dynamic>> _createNewRequest(DioException error) {
    final dioNewInstance = Dio(parameters.baseOptions);
    final dataNewInstance = _createNewData(error.requestOptions.data);
    return dioNewInstance.request<dynamic>(
      error.requestOptions.path,
      queryParameters: error.requestOptions.queryParameters,
      data: dataNewInstance,
      cancelToken: error.requestOptions.cancelToken,
      options: Options(
        method: error.requestOptions.method,
        headers: error.requestOptions.headers,
      ),
    );
  }

  /// Creates a new data with the same type of [data] and returns it.
  /// It's required to FormData to be cloned before sending a new request.
  /// Otherwise, it throws an FormData has already been finalized error.
  /// If [data] is [FormData], then it's cloned and returned.
  /// Otherwise, it's returned as it is.
  dynamic _createNewData(dynamic data) {
    return switch (data) {
      FormData() => data.clone(),
      _ => data,
    };
  }

  /// Checks if [e] is [DioException] and
  ///  status code is [HttpStatus.unauthorized]
  /// and returns true, otherwise returns false.
  bool _retryIf(Exception e) {
    if (e is! DioException) return false;
    return e.response?.statusCode == HttpStatus.unauthorized;
  }

  /// Checks if cancel token is cancelled and returns a [DioException] with
  /// [HttpStatus.clientClosedRequest] status code.
  /// It's required to prevent parallel requests from being sent
  ///  to refresh token.
  DioException? _parallelismGuard(
    NetworkManagerParameters params,
    DioException exception,
  ) {
    final cancelToken = exception.requestOptions.cancelToken;
    if (cancelToken == null) return null;
    if (cancelToken.isCancelled == false) return null;
    return DioException(
      requestOptions: exception.requestOptions,
      response: exception.response
        ?..statusCode = HttpStatus.clientClosedRequest,
    );
  }
}
