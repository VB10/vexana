import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:vexana/src/mixin/index.dart';
import 'package:vexana/src/utility/network_manager_util.dart';
import 'package:vexana/vexana.dart';

/// Network manager provide your requests with [Dio]
///
/// Example:
/// [NetworkManager(isEnableLogger: true, errorModel: UserErrorModel(),]
/// [options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));]
class NetworkManager<E extends INetworkModel<E>>
    extends NetworkManagerParameters
    with
        dio.DioMixin,
        NetworkManagerOperation,
        NetworkManagerCoreOperation<E>,
        NetworkManagerResponse<E>,
        NetworkManagerCache<E>,
        NetworkManagerErrorInterceptor,
        NetworkManagerInitialize
    implements INetworkManager<E> {
  ///
  ///
  NetworkManager({
    required super.options,
    this.errorModel,
    super.onRefreshToken,
    super.skippingSSLCertificate,
    super.noNetwork,
    super.isEnableLogger,
    super.isEnableTest,
    super.onRefreshFail,
    super.fileManager,
    super.interceptor,
  }) {
    setup();
  }

  @override
  NetworkManagerParameters get parameters => this;

  @override
  INetworkManager<E> get instance => this;

  @override
  NetworkManagerCache get cache => this;

  @override
  final E? errorModel;

  @override
  dio.Interceptors get dioInterceptors => interceptors;

  @override
  Future<IResponseModel<R?, E?>> send<T extends INetworkModel<T>, R>(
    String path, {
    required T parseModel,
    required RequestType method,
    String? urlSuffix = '',
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? expiration,
    dynamic data,
    ProgressCallback? onReceiveProgress,
    bool isErrorDialog = false,
    CancelToken? cancelToken,
  }) async {
    final cacheData = await fetchDataFromCache<R, T>(
      expiration: expiration,
      type: method,
      responseModel: parseModel,
    );
    if (cacheData is ResponseModel<R?, E>) return cacheData;
    options ??= Options();
    options.method = method.stringValue;
    final body = makeRequestBodyData(data);

    try {
      final response = await request<dynamic>(
        '$path$urlSuffix',
        data: body,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      if (NetworkManagerUtil.isRequestHasSurceased(response.statusCode)) {
        await cache.writeAll(expiration, response.data, method);
        return successResponseFetch<T, R>(
          data: response.data,
          parserModel: parseModel,
        );
      }

      return ResponseModel(
        error: ErrorModel(description: response.data.toString()),
      );
    } on dio.DioException catch (error) {
      return handleNetworkError<T, R>(
        path: path,
        cancelToken: cancelToken,
        data: data,
        isErrorDialog: isErrorDialog,
        options: options,
        urlSuffix: urlSuffix,
        queryParameters: queryParameters,
        parseModel: parseModel,
        method: method,
        error: error,
        onError: errorResponseFetch,
      );
    }
  }

  @override
  Future<dio.Response<List<int>>> downloadFileSimple(
    String path,
    ProgressCallback? callback,
  ) async {
    return dio.Dio().get<List<int>>(
      path,
      options: Options(followRedirects: true, responseType: ResponseType.bytes),
      onReceiveProgress: callback,
    );
  }

  @override
  Future<dio.Response<List<int>?>> downloadFile(
    String path,
    ProgressCallback? callback, {
    RequestType? method,
    Options? options,
    dynamic data,
  }) async {
    options ??= Options();
    options
      ..method = (method ?? RequestType.GET).stringValue
      ..followRedirects = true
      ..responseType = ResponseType.bytes;

    final body = makeRequestBodyData(data);

    return request<List<int>>(
      path,
      data: body,
      options: options,
      onReceiveProgress: callback,
    );
  }

  @override
  Future<dio.Response<T>> uploadFile<T>(
    String path,
    FormData data, {
    Map<String, dynamic>? headers,
  }) async {
    return post<T>(path, data: data, options: Options(headers: headers));
  }

  @override
  Future<T?> sendPrimitive<T>(
    String path, {
    Map<String, dynamic>? headers,
  }) async {
    final response = await dio.Dio().request<T>(
      options.baseUrl + path,
      options: dio.Options(headers: headers),
    );
    return response.data;
  }

  @override
  Future<dio.Response<dynamic>> download(
    String urlPath,
    dynamic savePath, {
    dio.ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    dio.CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    dio.Options? options,
  }) {
    return this.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }
}
