import 'dart:async';
import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:dio/src/adapters/io_adapter.dart'
    if (dart.library.html) 'package:dio/src/adapters/browser_adapter.dart'
    as adapter;
import 'package:flutter/foundation.dart' show compute;
import 'package:retry/retry.dart';
import 'package:vexana/src/feature/ssl/io_custom_override.dart'
    if (dart.library.html) 'package:vexana/src/feature/ssl/html_custom_override.dart'
    as ssl;
import 'package:vexana/src/interface/ICallback.dart';
import 'package:vexana/src/interface/IFileManager.dart';
import 'package:vexana/src/model/error/file_manager_not_foud.dart';
import 'package:vexana/src/operation/network_error_manager.dart';
import 'package:vexana/src/utility/custom_logger.dart';
import 'package:vexana/src/utility/json_encode_util.dart';
import 'package:vexana/vexana.dart';

part 'operation/network_cache.dart';
part 'operation/network_model_parser.dart';
part 'operation/network_wrapper.dart';

/// Network manager provide your requests with [Dio]
///
/// Example:
/// [NetworkManager(isEnableLogger: true, errorModel: UserErrorModel(),]
/// [options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));]
class NetworkManager<E extends INetworkModel<E>?>
    with dio.DioMixin
    implements INetworkManager<E> {
  /// The NetworkManager constructor initializes various properties and sets up interceptors for logging and network requests.
  ///
  /// Args:
  ///   options (BaseOptions): The `options` parameter is of type `BaseOptions` and is required. It contains the base
  /// configuration options for the network requests, such as the base URL, headers, and timeout.
  ///   : - `options`: Required parameter of type `BaseOptions` that contains the base configuration options for the network
  /// manager.
  ///   interceptor (dio): The `interceptor` parameter is an optional `dio.Interceptor` object that allows you to add custom
  /// interceptors to the network requests. Interceptors can be used to modify the request or response before they are sent or
  /// received.
  ///   : - `options`: Required parameter of type `BaseOptions` that contains the base configuration options for the network
  /// manager.
  ///   : - `options`: Required parameter of type `BaseOptions` that contains the base configuration options for the network
  /// manager.
  ///   : - `options`: Required parameter of type `BaseOptions` that contains the base configuration options for the network
  /// manager.
  ///   : - `options`: Required parameter of type `BaseOptions` that contains the base configuration options for the network
  /// manager.
  ///   : - `options`: Required parameter of type `BaseOptions` that contains the base configuration options for the network
  /// manager. Defaults to false
  ///   : - `options`: Required parameter of type `BaseOptions` that contains the base configuration options for the network
  /// manager. Defaults to false
  ///   : - `options`: Required parameter of type `BaseOptions` that contains the base configuration options for the network
  /// manager.
  ///   : - `options`: Required parameter of type `BaseOptions` that contains the base configuration options for the network
  /// manager.
  NetworkManager({
    required BaseOptions options,
    this.isEnableLogger,
    dio.Interceptor? interceptor,
    this.onRefreshToken,
    this.onRefreshFail,
    this.fileManager,
    this.errorModel,
    this.skippingSSLCertificate = false,
    this.isEnableTest = false,
    this.errorModelFromData,
    this.noNetwork,
  }) {
    this.options = options;
    (transformer as dio.BackgroundTransformer).jsonDecodeCallback = _decodeBody;
    if (skippingSSLCertificate) ssl.createAdapter().make();

    _addLoggerInterceptor(isEnableLogger ?? false);
    _addNetworkInterceptors(interceptor);
    httpClientAdapter = adapter.createAdapter();
  }

  /// [Future<DioException> Function(DioException error, NetworkManager newService)] of retry service request with new instance
  ///
  /// Default value function is null until to define your business.
  Future<dio.DioException> Function(
    dio.DioException error,
    NetworkManager newService,
  )? onRefreshToken;

  /// [VoidCallback?] has send error if it has [onRefreshToken] callback after has problem.
  ///
  /// Default value function is null work with [onRefreshToken].
  VoidEmptyCallBack? onRefreshFail;

  /// [int?] retry maximum count at refresh function.
  final int maxCount = 3;

  /// [IFileManager?] manage cache operation with this.
  ///
  /// Example keep your data in json file:
  /// [NetworkManager(fileManager: LocalFile())]
  IFileManager? fileManager;

  /// [INetworkModel?] is response model for every request.
  ///
  /// Example:
  /// [LoginModel()]
  E? errorModel;

  /// [Client] has be set default client adapter
  bool isEnableTest;

  bool skippingSSLCertificate;

  final bool? isEnableLogger;

  final NoNetwork? noNetwork;

  int? noNetworkTryCount;

  /// [Interceptors] return dio client interceptors list
  @override
  dio.Interceptors get dioInterceptors => interceptors;

  ///When an error occurred [NetworkManager] generates an errorModel.
  ///This function allows generate an errorModel using [data].
  ///This is optional. If this is null then default generator creates an error model.
  E Function(Map<String, dynamic> data)? errorModelFromData;

  void _addLoggerInterceptor(bool isEnableLogger) {
    if (isEnableLogger) interceptors.add(dio.LogInterceptor());
  }

  @override

  /// [bool] clear all cache on network manager.
  Future<bool> removeAllCache() async => _removeAllCache();

  @override
  //  Add key,value from base request.
  void addBaseHeader(MapEntry<String, String> mapEntry) {
    options.headers[mapEntry.key] = mapEntry.value;
  }

  @override
  // Remove base header every values.
  void clearHeader() {
    options.headers.clear();
  }

  @override
  // Remove base header value from key.
  void removeHeader(String key) {
    options.headers.remove(key);
  }

  /// Get all headers from [NetworkManager]
  @override
  Map<String, dynamic> get allHeaders => options.headers;

  /// [Future<IResponseModel<R?>> send<T extends INetworkModel, R>] will complete your request with paramaters
  ///
  /// [T parseModel] network response parser model
  /// [RequestType method] network request type like [RequestType.GET]
  ///
  /// Example:
  /// ''
  /// await networkManager.send<Todo, List<Todo>>("/todosPost",
  ///  parseModel: Todo(), method: RequestType.POST, data: todoPostRequestBody);
  ///
  /// '''

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
    bool? forceUpdateDecode,
  }) async {
    final cacheData = await _getCacheData<R, T>(expiration, method, parseModel);
    if (cacheData is ResponseModel<R?, E>) {
      return cacheData!;
    }
    options ??= Options();
    options.method = method.stringValue;
    final body = _getBodyModel(data);

    try {
      final response = await request(
        '$path$urlSuffix',
        data: body,
        options: options,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      final responseStatusCode = response.statusCode ?? HttpStatus.notFound;
      if (responseStatusCode >= HttpStatus.ok &&
          responseStatusCode <= HttpStatus.multipleChoices) {
        var response0 = response.data;

        if ((forceUpdateDecode ?? false) && response0 is String) {
          response0 = await _decodeBody(response0);
        }

        await writeCacheAll(expiration, response0, method);
        return _getResponseResult<T, R>(response0, parseModel);
      } else {
        return ResponseModel(
          error: ErrorModel(description: response.data.toString()),
        );
      }
    } on dio.DioException catch (error) {
      return handleNetworkError<T, R>(
        path,
        cancelToken: cancelToken,
        data: data,
        isErrorDialog: isErrorDialog,
        options: options,
        urlSuffix: urlSuffix,
        queryParameters: queryParameters,
        parseModel: parseModel,
        method: method,
        error: error,
        onError: _onError,
      );
    }
  }

  @override
  Future<dio.Response<List<int>>> downloadFileSimple(
    String path,
    ProgressCallback? callback,
  ) async {
    final response = await dio.Dio().get<List<int>>(
      path,
      options:
          Options(followRedirects: false, responseType: ResponseType.bytes),
      onReceiveProgress: callback,
    );

    return response;
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
    options.method = (method ?? RequestType.GET).stringValue;
    options.followRedirects = false;
    options.responseType = ResponseType.bytes;

    final body = _getBodyModel(data);

    final response = await request<List<int>>(
      path,
      data: body,
      options: options,
      onReceiveProgress: callback,
    );

    return response;
  }

  /// Simple file upload
  ///
  /// Path [String], Data [FormData], Headers [Map]
  /// It is file upload function then it'll be return primitive type.

  @override
  Future<dio.Response<T>> uploadFile<T>(
    String path,
    FormData data, {
    Map<String, dynamic>? headers,
  }) async {
    return await post<T>(path, data: data, options: Options(headers: headers));
  }

  Future<ResponseModel<R, E>?> _getCacheData<R, T extends INetworkModel>(
    Duration? expiration,
    RequestType type,
    T responseModel,
  ) async {
    if (expiration == null) return null;
    final cacheDataString = await getLocalData(type);
    if (cacheDataString == null) {
      return null;
    } else {
      return _getResponseResult<T, R>(
        jsonDecode(cacheDataString),
        responseModel,
      );
    }
  }

  ResponseModel<R, E> _getResponseResult<T extends INetworkModel, R>(
    dynamic data,
    T parserModel,
  ) {
    final model = _parseBody<R, T>(data, parserModel);

    return ResponseModel<R, E>(data: model);
  }

  ResponseModel<R, E> _onError<R>(dio.DioException e) {
    final errorResponse = e.response;
    CustomLogger(isEnabled: isEnableLogger ?? false, data: e.message ?? '');
    var error = ErrorModel<E>(
      description: e.message,
      statusCode: errorResponse != null
          ? errorResponse.statusCode
          : HttpStatus.internalServerError,
    );
    if (errorResponse != null) {
      error = _generateErrorModel(error, errorResponse.data);
    }
    return ResponseModel<R, E>(
      error: ErrorModel<E>(
        description: error.description,
        model: error.model,
        statusCode: error.statusCode,
      ),
    );
  }

  ErrorModel<E> _generateErrorModel(ErrorModel<E> error, dynamic data) {
    var generatedError = error;
    if (errorModel == null) {
      return generatedError;
    }

    if (data is String) {
      final jsonBody = JsonDecodeUtil.safeJsonDecode(data);
      if (jsonBody == null || jsonBody is! Map<String, dynamic>) return error;

      if (errorModelFromData != null) {
        generatedError =
            error.copyWith(model: errorModelFromData?.call(jsonBody));
      } else {
        generatedError = error.copyWith(model: errorModel!.fromJson(jsonBody));
      }
    }

    if (data is Map<String, dynamic>) {
      final jsonBody = data;

      if (errorModelFromData != null) {
        generatedError =
            error.copyWith(model: errorModelFromData!.call(jsonBody));
      } else {
        generatedError = error.copyWith(model: errorModel!.fromJson(jsonBody));
      }
    }

    return generatedError;
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
  Future<dio.Response> download(
    String urlPath,
    savePath, {
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
