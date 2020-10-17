part of "../network_manager.dart";

extension _CoreServiceWrapperExtension on NetworkManager {
  InterceptorsWrapper _onErrorWrapper() {
    return InterceptorsWrapper(
      onError: (e) async {
        if (e.response.statusCode == HttpStatus.unauthorized && onRefreshToken != null) {
          if (_retryCount < maxCount) {
            _retryCount++;
            interceptors.responseLock.lock();
            interceptors.requestLock.lock();
            final error = await onRefreshToken(e, NetworkManager(options: options));
            interceptors.responseLock.unlock();
            interceptors.requestLock.unlock();

            return await request(
              error.request.path,
              queryParameters: error.request.queryParameters,
              data: error.request.data,
              options: Options(method: error.request.method, headers: error.request.headers),
            );
          } else {
            if (onRefreshFail != null) onRefreshFail();
            _retryCount = 0;
          }
        }
        return e;
      },
    );
  }
}
