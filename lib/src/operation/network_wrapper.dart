part of '../network_manager.dart';

extension _CoreServiceWrapperExtension on NetworkManager {
  void _addNetworkIntercaptors(dio.Interceptor? interceptor) {
    if (interceptor != null) interceptors.add(interceptor);
    interceptors.add(_onErrorWrapper());
  }

  QueuedInterceptorsWrapper _onErrorWrapper() {
    return QueuedInterceptorsWrapper(
      onError: (DioError e, ErrorInterceptorHandler handler) async {
        final errorResponse = e.response;
        if (errorResponse == null) {
        } else {
          if (errorResponse.statusCode == HttpStatus.unauthorized && onRefreshToken != null) {
            final error = await onRefreshToken!(e, NetworkManager(options: options));
            final requestModel = error.requestOptions;

            try {
              final response = await retry(
                () => dio.Dio(options).request(
                  requestModel.path,
                  queryParameters: requestModel.queryParameters,
                  data: requestModel.data,
                  options: Options(method: requestModel.method, headers: requestModel.headers),
                ),
                maxAttempts: _maxCount,
                retryIf: (e) {
                  return e is TimeoutException || e is DioError;
                },
              );
              return handler.resolve(response);
            } catch (_) {
              return handler.next(e);
            }
          }
        }

        return handler.next(e);
      },
    );
  }
}
