import 'dart:async';
import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:retry/retry.dart';
import 'package:vexana/src/mixin/index.dart';
import 'package:vexana/vexana.dart';

mixin NetworkManagerErrorInterceptor on NetworkManagerParameters {
  Interceptors get interceptors;

  void addNetworkInterceptors(Interceptor? interceptor) {
    if (interceptor != null) interceptors.add(interceptor);
    interceptors.add(_onErrorWrapper());
  }

  QueuedInterceptorsWrapper _onErrorWrapper() {
    return QueuedInterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        final errorResponse = e.response;
        if (errorResponse == null) {
        } else {
          if (errorResponse.statusCode == HttpStatus.unauthorized &&
              onRefreshToken != null) {
            final error = await onRefreshToken!(
              e,
              NetworkManager<EmptyModel>(options: baseOptions),
            );
            final requestModel = error.requestOptions;

            try {
              final response = await retry(
                () => Dio(baseOptions).request<dynamic>(
                  requestModel.path,
                  queryParameters: requestModel.queryParameters,
                  data: requestModel.data,
                  options: Options(
                    method: requestModel.method,
                    headers: requestModel.headers,
                  ),
                ),
                maxAttempts: NetworkManagerParameters.maxRetryCount,
                retryIf: (e) {
                  return e is TimeoutException || e is DioException;
                },
              );
              return handler.resolve(response);
            } catch (_) {
              onRefreshFail?.call();
              return handler.next(e);
            }
          }
        }

        return handler.next(e);
      },
    );
  }
}
