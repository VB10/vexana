import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
// ignore: implementation_imports
import 'package:dio/src/adapters/io_adapter.dart'
    if (dart.library.html) 'package:dio/src/adapters/browser_adapter.dart'
    as adapter;
// dart:io html, mobil
//       pwa html css js, apk ipa
// dart:html

import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:vexana/src/operation/network_error_manager.dart';
import 'package:vexana/src/utility/custom_logger.dart';

import '../vexana.dart';
import 'interface/IFileManager.dart';
import 'model/error/file_manager_not_foud.dart';

part 'operation/network_cache.dart';
part 'operation/network_model_parser.dart';
part 'operation/network_wrapper.dart';

/// Network manager provide your requests with [Dio]
///
/// Example:
/// [NetworkManager(isEnableLogger: true, errorModel: UserErrorModel(),]
/// [options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));]
class NetworkManager with dio.DioMixin implements dio.Dio, INetworkManager {
  NetworkManager(
      {required BaseOptions options,
      this.isEnableLogger,
      dio.Interceptor? interceptor,
      this.onRefreshToken,
      this.onRefreshFail,
      this.fileManager,
      this.errorModel,
      this.skippingSSLCertificate = false,
      this.isEnableTest = false,
      this.errorModelFromData,
      this.noNetwork}) {
    this.options = options;
    (transformer as DefaultTransformer).jsonDecodeCallback = _decodeBody;
    if (skippingSSLCertificate) HttpOverrides.global = MyHttpOverrides();

    _addLoggerInterceptor(isEnableLogger ?? false);
    _addNetworkInterceptors(interceptor);
    httpClientAdapter = adapter.createAdapter();
  }

  /// [Future<DioError> Function(DioError error, NetworkManager newService)] of retry service request with new instance
  ///
  /// Default value function is null until to define your business.

  Future<DioError> Function(DioError error, NetworkManager newService)? onRefreshToken;


  /// [VoidCallback?] has send error if it has [onRefreshToken] callback after has problem.
  ///
  /// Default value function is null work with [onRefreshToken].
  late VoidCallback? onRefreshFail;

  /// [int?] retry maxiumum count at refresh function.
  final int maxCount = 3;

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

  bool skippingSSLCertificate;

  final bool? isEnableLogger;

  final NoNetwork? noNetwork;

  int? noNetworkTryCount;

  /// [Interceptors] return dio client interceptors list
  @override
  dio.Interceptors get dioInterceptors => interceptors;

  ///When an error occured [NetworkManager] generates an errorModel.
  ///This function allows generate an errorModel using [data].
  ///This is optional. If this is null then default generator creates an error model.
  INetworkModel Function(dynamic data)? errorModelFromData;

  void _addLoggerInterceptor(bool isEnableLogger) {
    if (isEnableLogger) interceptors.add(dio.LogInterceptor());
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
  Future<IResponseModel<R?>> send<T extends INetworkModel, R>(String path,
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
      bool? forceUpdateDecode}) async {
    final cacheData = await _getCacheData<R, T>(expiration, method, parseModel);
    if (cacheData is ResponseModel<R>) {
      return cacheData;
    }
    options ??= Options();
    options.method = method.stringValue;
    final body = _getBodyModel(data);

    try {
      final response = await request('$path$urlSuffix',
          data: body, options: options, queryParameters: queryParameters, cancelToken: cancelToken);

      final responseStatusCode = response.statusCode ?? HttpStatus.notFound;
      if (responseStatusCode >= HttpStatus.ok &&
          responseStatusCode <= HttpStatus.multipleChoices) {
        var _response = response.data;

        if ((forceUpdateDecode ?? false) && _response is String) {
          _response = await _decodeBody(_response);
        }

        await writeCacheAll(expiration, _response, method);
        return _getResponseResult<T, R>(
            _response, parseModel, responseStatusCode);
      } else {
        return ResponseModel(
            statusCode: responseStatusCode,
            error: ErrorModel(
                description: response.data.toString(),
                statusCode: responseStatusCode));
      }
    } on DioError catch (e) {
      return await handleNetworkError<T, R>(path,
          cancelToken: cancelToken,
          data: data,
          isErrorDialog: isErrorDialog,
          options: options,
          urlSuffix: urlSuffix,
          queryParameters: queryParameters,
          parseModel: parseModel,
          method: method,
          error: e,
          onError: _onError);
    }
  }

  @override
  Future<dio.Response<Uint8List>> downloadFileSimple(
      String path, ProgressCallback? callback) async {
    final response = await dio.Dio().get<Uint8List>(path,
        options:
            Options(followRedirects: false, responseType: ResponseType.bytes),
        onReceiveProgress: callback);

    return response;
  }

  /// Simple file upload
  ///
  /// Path [String], Data [FormData], Headers [Map]
  /// It is file upload function then it'll be return primitive type.

  @override
  Future<dio.Response<T>> uploadFile<T>(String path, FormData data,
      {Map<String, dynamic>? headers}) async {
    return await post<T>(path, data: data, options: Options(headers: headers));
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
      dynamic data, T parserModel,
      [int statusCode = HttpStatus.ok]) {
    final model = _parseBody<R, T>(data, parserModel);
    return ResponseModel<R>(data: model, statusCode: statusCode);
  }

  ResponseModel<R> _onError<R>(DioError e) {
    final errorResponse = e.response;
    CustomLogger(isEnabled: isEnableLogger).printError(e.message);
    var error = ErrorModel(
        description: e.message,
        statusCode: errorResponse != null
            ? errorResponse.statusCode
            : HttpStatus.internalServerError);
    if (errorResponse != null) {
      error = _generateErrorModel(error, errorResponse.data);
    }
    return ResponseModel<R>(error: error, statusCode: error.statusCode);
  }

  ErrorModel _generateErrorModel(ErrorModel error, dynamic data) {
    if (errorModel == null) {
      error.response = data;
    } else if (data is String || data is Map<String, dynamic>) {
      final json =
          data is String ? jsonDecode(data) : data as Map<String, dynamic>;
      error.model =
          errorModelFromData?.call(data) ?? errorModel?.fromJson(json);
    }

    return error;
  }

  @override
  Future<T?> sendPrimitive<T>(String path,
      {Map<String, dynamic>? headers}) async {
    final response = await dio.Dio().request<T>(options.baseUrl + path,
        options: dio.Options(headers: headers));
    return response.data;
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
