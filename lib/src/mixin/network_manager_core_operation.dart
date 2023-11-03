import 'package:vexana/src/mixin/network_manager_paramaters.dart';
import 'package:vexana/vexana.dart';

mixin NetworkManagerCoreOperation<E extends INetworkModel<E>>
    on NetworkManagerParameters {
  int _noNetworkTryCount = 0;

  INetworkManager<E> get instance;

  Future<IResponseModel<R?, E?>>
      handleNetworkError<T extends INetworkModel<T>, R>(
    String path, {
    required T parseModel,
    required RequestType method,
    required DioException error,
    required IResponseModel<R?, E?> Function(DioException e) onError,
    String? urlSuffix = '',
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? expiration,
    dynamic data,
    ProgressCallback? onReceiveProgress,
    bool isErrorDialog = false,
    CancelToken? cancelToken,
    bool? forceUpdateDecode,
  }) async {
    if (!isErrorDialog ||
        _noNetworkTryCount == NetworkManagerParameters.maxRetryCount) {
      return onError.call(error);
    }

    _noNetworkTryCount = 0;
    var isRetry = false;
    await NoNetworkManager(
      context: noNetwork?.context,
      customNoNetworkWidget: noNetwork?.customNoNetwork,
      onRetry: () {
        isRetry = true;
      },
      isEnable: true,
    ).show();

    if (isRetry) {
      _noNetworkTryCount = _noNetworkTryCount + 1;
      return instance.send(
        path,
        parseModel: parseModel,
        method: method,
        data: data,
        queryParameters: queryParameters,
        options: options,
        isErrorDialog: isErrorDialog,
        urlSuffix: urlSuffix,
      );
    }

    _noNetworkTryCount = 0;
    return onError.call(error);
  }
}
