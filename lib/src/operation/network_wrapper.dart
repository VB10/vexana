part of '../network_manager.dart';

extension _CoreServiceWrapperExtension on NetworkManager {
  void _addNetworkIntercaptors(dio.Interceptor? interceptor) {
    if (interceptor != null) interceptors.add(interceptor);
    interceptors.add(_onErrorWrapper());
  }

  dio.QueuedInterceptor _onErrorWrapper() {
    return dio.QueuedInterceptorsWrapper(
      onError: (DioError e, ErrorInterceptorHandler handler) async {
        final errorResponse = e.response;
        if (errorResponse == null) {
        } else {
          if (errorResponse.statusCode == HttpStatus.unauthorized && onRefreshToken != null) {
            if (_retryCount < _maxCount) {
              _retryCount++;
              final error = await onRefreshToken!(e, NetworkManager(options: options));
              final requestModel = error.requestOptions;
              final response = await request(
                requestModel.path,
                queryParameters: requestModel.queryParameters,
                data: requestModel.data,
                options: Options(method: requestModel.method, headers: requestModel.headers),
              );

              return handler.resolve(response);
            } else {
              if (onRefreshFail != null) onRefreshFail!();
              _retryCount = 0;
            }
          }
        }

        return handler.next(e);
      },
    );
  }
}
