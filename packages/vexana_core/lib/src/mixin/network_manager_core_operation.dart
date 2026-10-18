import 'package:vexana_core/vexana_core.dart';

/// Manage network error situation
mixin NetworkManagerCoreOperation<E extends INetworkModel<E>> {
  /// Number of retries currently in flight; caps the retry chain at
  /// [NetworkManagerParameters.maxRetryCount].
  int _noNetworkTryCount = 0;

  /// Network manager parameters
  NetworkManagerParameters get parameters;

  /// E: Error Model for generic error
  INetworkManager<E> get instance;

  /// Bağlantı kontrolünün hedefleyeceği sunucu adı.
  ///
  /// `baseUrl` çözümlenemezse `null` döner; bu durumda kontrol genel ağ
  /// bağlantısına bakar.
  String? get _baseUrlHost {
    final host = Uri.tryParse(parameters.baseOptions.baseUrl)?.host;
    if (host == null || host.isEmpty) return null;
    return host;
  }

  Future<bool> _shouldRetry({required bool isErrorDialog}) async {
    final noNetwork = parameters.noNetwork;
    if (!isErrorDialog || noNetwork == null) return false;
    if (_noNetworkTryCount >= parameters.maxRetryCount) return false;

    var isRetry = false;
    await noNetwork.handle(
      onRetry: () async {
        isRetry = true;
      },
      host: _baseUrlHost,
    );
    return isRetry;
  }

  Future<T> _retry<T>(Future<T> Function() request) async {
    _noNetworkTryCount++;
    try {
      return await request();
    } finally {
      _noNetworkTryCount--;
    }
  }

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
    if (!await _shouldRetry(isErrorDialog: isErrorDialog)) {
      return onError.call(error);
    }

    return _retry(
      () => instance.send(
        path,
        parseModel: parseModel,
        method: method,
        data: data,
        queryParameters: queryParameters,
        options: options,
        expiration: expiration,
        isErrorDialog: isErrorDialog,
        urlSuffix: urlSuffix,
        cancelToken: cancelToken,
      ),
    );
  }

  /// The handleErrorResponse method handles network errors by either invoking
  /// an error callback or retrying the request based on certain conditions.
  /// If the network is unavailable and retries are enabled, it shows a custom
  /// no-network widget and retries the request if the user opts to retry.
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
    if (!await _shouldRetry(isErrorDialog: isErrorDialog)) {
      return onError.call(error);
    }

    return _retry(
      () => instance.sendRequest(
        path,
        parseModel: parseModel,
        method: method,
        data: data,
        queryParameters: queryParameters,
        options: options,
        expiration: expiration,
        isErrorDialog: isErrorDialog,
        urlSuffix: urlSuffix,
        cancelToken: cancelToken,
      ),
    );
  }
}
