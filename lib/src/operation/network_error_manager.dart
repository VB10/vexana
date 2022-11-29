import 'dart:async';

import '../../vexana.dart';

extension NetworkErrorManager<E extends INetworkModel<E>?>
    on NetworkManager<E?> {
  Future<IResponseModel<R?, E?>> handleNetworkError<T extends INetworkModel, R>(
      String path,
      {required T parseModel,
      required RequestType method,
      String? urlSuffix = '',
      Map<String, dynamic>? queryParameters,
      Options? options,
      Duration? expiration,
      dynamic data,
      ProgressCallback? onReceiveProgress,
      bool isErrorDialog = false,
      CancelToken? cancelToken,
      bool? forceUpdateDecode,
      required DioError error,
      required ResponseModel<R, E> Function(DioError e) onError}) async {
    if (!isErrorDialog || noNetworkTryCount == maxCount) {
      noNetworkTryCount = null;
      return onError.call(error);
    }

    noNetworkTryCount ??= 0;
    bool isRetry = false;
    await NoNetworkManager(
            context: noNetwork?.context,
            customNoNetwork: noNetwork?.customNoNetwork,
            onRetry: () {
              isRetry = true;
            },
            isEnable: true)
        .show();

    if (isRetry) {
      noNetworkTryCount = noNetworkTryCount! + 1;
      return send(path,
          parseModel: parseModel,
          method: method,
          data: data,
          queryParameters: queryParameters,
          options: options,
          isErrorDialog: isErrorDialog,
          urlSuffix: urlSuffix);
    }

    noNetworkTryCount = null;
    return onError.call(error);
  }
}
