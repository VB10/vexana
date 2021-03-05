import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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

class NetworkManager with DioMixin implements Dio, INetworkManager {
  late Future<DioError> Function(DioError error, NetworkManager newService)? onRefreshToken;
  late VoidCallback? onRefreshFail;
  late final int maxCount = 3;
  late int _retryCount;
  late IFileManager? fileManager;
  late INetworkModel? errorModel;

  NetworkManager({
    required BaseOptions options,
    bool? isEnableLogger,
    InterceptorsWrapper? interceptor,
    this.onRefreshToken,
    this.onRefreshFail,
    this.fileManager,
    this.errorModel,
  }) {
    this.options = options;
    _addLoggerInterceptor(isEnableLogger ?? false);
    _addNetworkIntercaptors(interceptor);
    httpClientAdapter = DefaultHttpClientAdapter();
  }
  void _addLoggerInterceptor(bool isEnableLogger) {
    if (isEnableLogger) interceptors.add(LogInterceptor());
  }

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
    final cacheData = await getCacheData<R, T>(expiration, method, parseModel);
    if (cacheData is ResponseModel<R>) {
      return cacheData;
    }

    options ??= Options();
    options.method = method.stringValue;
    final body = _getBodyModel(data);

    try {
      final response = await request('$path$urlSuffix', data: body, options: options, queryParameters: queryParameters);
      switch (response.statusCode) {
        case HttpStatus.ok:
          await writeCache(expiration, response.data, method);
          return getResponseResult<T, R>(response.data, parseModel);
        default:
          return ResponseModel(error: ErrorModel(description: response.data.toString()));
      }
    } on DioError catch (e) {
      return _onError<R>(e);
    }
  }

  Future<ResponseModel<R>?> getCacheData<R, T extends INetworkModel>(Duration? expiration, RequestType type, T responseModel) async {
    if (expiration == null) return null;
    final cacheDataString = await getLocalData(type);
    if (cacheDataString == null) {
      return null;
    } else {
      return getResponseResult<T, R>(jsonDecode(cacheDataString), responseModel);
    }
  }

  ResponseModel<R> getResponseResult<T extends INetworkModel, R>(dynamic data, T parserModel) {
    final model = _parseBody<R, T>(data, parserModel);
    return ResponseModel<R>(data: model);
  }

  ResponseModel<R> _onError<R>(DioError e) {
    final errorResponse = e.response;

    final error = ErrorModel(description: e.message, statusCode: errorResponse != null ? errorResponse.statusCode : HttpStatus.internalServerError);
    if (errorResponse != null) {
      _generateErrorModel(error, errorResponse.data);
    }
    return ResponseModel<R>(error: error);
  }

  void _generateErrorModel(ErrorModel error, dynamic data) {
    if (errorModel == null) return;
    final _data = data is Map ? data : jsonDecode(data);
    error.model = errorModel!.fromJson(_data);
  }

  @override
  Future<bool> removeAllCache() async => await _removeAllCache();
}
