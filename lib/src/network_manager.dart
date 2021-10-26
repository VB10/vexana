import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
// ignore: implementation_imports
import 'package:dio/src/adapters/io_adapter.dart'
    if (dart.library.html) 'package:dio/src/adapters/browser_adapter.dart'
    as adapter;
// dart:io html, mobil
//       pwa html css js, apk ipa
// dart:html

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../vexana.dart';
import 'extension/request_type_extension.dart';
import 'interface/IFileManager.dart';
import 'interface/INetworkModel.dart';
import 'interface/INetworkService.dart';
import 'interface/IResponseModel.dart';
import 'model/empty_model.dart';
import 'model/enum/request_type.dart';
import 'model/error/file_manager_not_foud.dart';
import 'model/error_model.dart';
import 'model/response_model.dart';

part 'operation/network_cache.dart';
part 'operation/network_model_parser.dart';
part 'operation/network_wrapper.dart';

/// Network manager provide your requests with [Dio]
///
/// Example:
/// [NetworkManager(isEnableLogger: true, errorModel: UserErrorModel(),]
/// [options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));]
class NetworkManager with DioMixin implements Dio, INetworkManager {
  /// [Future<DioError> Function(DioError error, NetworkManager newService)] of retry service request with new instance
  ///
  /// Default value function is null until to define your business.
  late Future<DioError> Function(DioError error, NetworkManager newService)?
      onRefreshToken;

  /// [VoidCallback?] has send error if it has [onRefreshToken] callback after has problem.
  ///
  /// Default value function is null work with [onRefreshToken].
  late VoidCallback? onRefreshFail;

  /// [int?] retry maxiumum count at refresh function.
  final int _maxCount = 3;

  // ignore: prefer_final_fields
  int _retryCount = 0;

  /// [IFileManager?] manage cache operation with this.
  ///
  /// Example keep your data in json file:
  /// [NetworkManager(fileManager: LocalFile())]
  late IFileManager? fileManager;

  /// [INetworkModel?] is repsone model for every request.
  ///
  /// Example:
  /// [LoginModel()]
  late INetworkModel? errorModel;

  /// [Client] has be set deafult client adapter
  bool isEnableTest;

  /// [HttpClientAdapter] user can set custom client adapter
  /// If value is null, [DefaultHttpClientAdapter()] will be used
  HttpClientAdapter? customHttpClientAdapter;

  /// [Interceptors] return dio client interceptors list
  @override
  Interceptors get dioIntercaptors => interceptors;

  NetworkManager(
      {required BaseOptions options,
      bool? isEnableLogger,
      InterceptorsWrapper? interceptor,
      this.onRefreshToken,
      this.onRefreshFail,
      this.fileManager,
      this.errorModel,
      this.isEnableTest = false,
      this.customHttpClientAdapter}) {
    this.options = options;

    _addLoggerInterceptor(isEnableLogger ?? false);
    _addNetworkInterceptors(interceptor);

    httpClientAdapter = (!kIsWeb && customHttpClientAdapter != null)
        ? customHttpClientAdapter!
        : adapter.createAdapter();
  }

  void _addLoggerInterceptor(bool isEnableLogger) {
    if (isEnableLogger) interceptors.add(LogInterceptor());
  }

  @override

  /// [bool] clear all cache on network manager.
  Future<bool> removeAllCache() async => await _removeAllCache();

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

  /// [Future<IResponseModel<R?>> send<T extends INetworkModel, R>] will complete your request with paramaters
  ///
  /// [T parseModel] netwwork response parser model
  /// [RequestType method] network request type like [RequestType.GET]
  ///
  /// Example:
  /// ''
  /// await networkManager.send<Todo, List<Todo>>("/todosPost",
  ///  parseModel: Todo(), method: RequestType.POST, data: todoPostRequestBody);
  ///
  /// '''

  @override
  Future<IResponseModel<R?>> send<T extends INetworkModel, R>(
    String path, {
    required T parseModel,
    required RequestType method,
    String? urlSuffix = '',
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? expiration,
    CancelToken? cancelToken,
    dynamic data,
    ProgressCallback? onReceiveProgress,
  }) async {
    final cacheData = await _getCacheData<R, T>(expiration, method, parseModel);
    if (cacheData is ResponseModel<R>) {
      return cacheData;
    }
    options ??= Options();
    options.method = method.stringValue;
    final body = _getBodyModel(data);

    try {
      final response = await request('$path$urlSuffix',
          data: body, options: options, queryParameters: queryParameters);
      if (response.statusCode! >= HttpStatus.ok &&
          response.statusCode! <= HttpStatus.multipleChoices) {
        await writeCacheAll(expiration, response.data, method);
        return _getResponseResult<T, R>(response.data, parseModel);
      } else {
        return ResponseModel(
            error: ErrorModel(description: response.data.toString()));
      }
    } on DioError catch (e) {
      return _onError<R>(e);
    }
  }

  @override
  Future<Response<Uint8List>> downloadFileSimple(
      String path, ProgressCallback? callback) async {
    final response = await Dio().get<Uint8List>(path,
        options:
            Options(followRedirects: false, responseType: ResponseType.bytes),
        onReceiveProgress: callback);

    return response;
  }

  Future<ResponseModel<R>?> _getCacheData<R, T extends INetworkModel>(
      Duration? expiration, RequestType type, T responseModel) async {
    // TODO: Web Cache support
    if (kIsWeb) return null;
    if (expiration == null) return null;
    final cacheDataString = await getLocalData(type);
    if (cacheDataString == null) {
      return null;
    } else {
      return _getResponseResult<T, R>(
          jsonDecode(cacheDataString), responseModel);
    }
  }

  ResponseModel<R> _getResponseResult<T extends INetworkModel, R>(
      dynamic data, T parserModel) {
    final model = _parseBody<R, T>(data, parserModel);
    return ResponseModel<R>(data: model);
  }

  ResponseModel<R> _onError<R>(DioError e) {
    final errorResponse = e.response;
    _printErrorMessage(e.message);
    final error = ErrorModel(
        description: e.message,
        statusCode: errorResponse != null
            ? errorResponse.statusCode
            : HttpStatus.internalServerError);
    if (errorResponse != null) {
      _generateErrorModel(error, errorResponse.data);
    }
    return ResponseModel<R>(error: error);
  }

  void _printErrorMessage(String message) {
    Logger().e(message);
  }

  void _generateErrorModel(ErrorModel error, dynamic data) {
    if (errorModel == null) return;
    final _data = data is Map ? data : jsonDecode(data);
    error.model = errorModel!.fromJson(_data);
  }
}
