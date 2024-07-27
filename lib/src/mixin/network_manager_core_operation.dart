import 'package:vexana/src/mixin/network_manager_parameters.dart';
import 'package:vexana/vexana.dart';

/// Manage network error situation
mixin NetworkManagerCoreOperation<E extends INetworkModel<E>> {
  int _noNetworkTryCount = 0;

  /// Network manager parameters
  NetworkManagerParameters get parameters;

  /// E: Error Model for generic error
  INetworkManager<E> get instance;

  /// Manage any error according from server
  ///
  /// R: Response Model for user want to parse
  /// T: Parser Model
  /// data: Response body
  Future<IResponseModel<R?, E?>>
      handleNetworkError<T extends INetworkModel<T>, R>({
    required String path,
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
      context: parameters.noNetwork?.context,
      customNoNetworkWidget: parameters.noNetwork?.customNoNetwork,
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

  Future<NetworkResult<R, E>>
      handleErrorResponse<T extends INetworkModel<T>, R>({
    required String path,
    required T parseModel,
    required RequestType method,
    required DioException error,
    required NetworkResult<R, E> Function(DioException e) onError,
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
      context: parameters.noNetwork?.context,
      customNoNetworkWidget: parameters.noNetwork?.customNoNetwork,
      onRetry: () {
        isRetry = true;
      },
      isEnable: true,
    ).show();

    if (isRetry) {
      _noNetworkTryCount = _noNetworkTryCount + 1;

      return instance.sendRequest(
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
