part of '../network_manager.dart';

extension _CoreServiceWrapperExtension on NetworkManager {
  void _addNetworkIntercaptors(InterceptorsWrapper? interceptor) {
    if (interceptor != null) interceptors.add(interceptor);
    interceptors.add(_onErrorWrapper());
  }

  InterceptorsWrapper _onErrorWrapper() {
    return InterceptorsWrapper(
      onError: (e, handler) async {
        final errorResponse = e.response;
        if (errorResponse == null) {
        } else {
          if (errorResponse.statusCode == HttpStatus.unauthorized &&
              onRefreshToken != null) {
            if (retryCount < maxCount) {
              retryCount++;
              interceptors.responseLock.lock();
              interceptors.requestLock.lock();
              final error =
                  await onRefreshToken!(e, NetworkManager(options: options));
              interceptors.responseLock.unlock();
              interceptors.requestLock.unlock();
              final requestModel = error.requestOptions;

              final response = await request(
                requestModel.path,
                queryParameters: requestModel.queryParameters,
                data: requestModel.data,
                options: Options(
                    method: requestModel.method, headers: requestModel.headers),
              );

              return handler.resolve(response);
            } else {
              if (onRefreshFail != null) onRefreshFail!();
              retryCount = 0;
            }
          }
        }

        return handler.next(e);
      },
    );
  }
}
