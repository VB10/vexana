import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'extension/request_type_extension.dart';
import 'interface/INetworkModel.dart';
import 'interface/INetworkService.dart';
import 'interface/IResponseModel.dart';
import 'model/empty_model.dart';
import 'model/enum/request_type.dart';
import 'model/error_model.dart';
import 'model/response_model.dart';

part 'operation/network_model_parser.dart';
part 'operation/network_wrapper.dart';

class NetworkManager with DioMixin implements Dio, INetworkManager {
  INetworkModel errorModel;
  Future<DioError> Function(DioError error, NetworkManager newService) onRefreshToken;
  VoidCallback onRefreshFail;
  int _retryCount = 0;

  NetworkManager({
    BaseOptions options,
    bool isEnableLogger,
    InterceptorsWrapper interceptor,
    this.onRefreshToken,
    this.onRefreshFail,
    INetworkModel errorModel,
  }) {
    this.options = options;
    _addLoggerInterceptor(isEnableLogger ?? false);
    _addNetworkIntercaptors(interceptor);
    _setBaseErrorModel(errorModel);
    httpClientAdapter = DefaultHttpClientAdapter();
  }

  Future<IResponseModel<R>> fetch<T extends INetworkModel, R>(
    String path, {
    @required T parseModel,
    @required RequestType method,
    String urlSuffix = "",
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    dynamic data,
    ProgressCallback onReceiveProgress,
  }) async {
    if (options == null) options = Options();
    options.method = method.stringValue;
    final body = _getBodyModel(data);

    try {
      Response response =
          await request("$path$urlSuffix", data: body, options: options, queryParameters: queryParameters);
      switch (response.statusCode) {
        case HttpStatus.ok:
          final model = _parseBody<R, T>(response.data, parseModel);
          return ResponseModel<R>(data: model);
        default:
          return ResponseModel(error: ErrorModel(description: response.data.toString()));
      }
    } on DioError catch (e) {
      final error = ErrorModel(
          description: e.message,
          statusCode: e.response != null ? e.response.statusCode : HttpStatus.internalServerError);
      _generateErrorModel(error, e.response.data);
      return ResponseModel(error: error);
    }
  }

  void _addLoggerInterceptor(bool isEnableLogger) {
    if (isEnableLogger) this.interceptors.add(LogInterceptor());
  }

  void _addNetworkIntercaptors(InterceptorsWrapper interceptor) {
    if (interceptor != null) this.interceptors.add(interceptor);

    interceptors.add(_onErrorWrapper());
  }

  void _setBaseErrorModel(INetworkModel model) {
    errorModel = model;
  }

  void _generateErrorModel(ErrorModel error, dynamic data) {
    if (errorModel != null) {
      final _data = data is Map ? data : jsonDecode(data);
      error.model = errorModel.fromJson(_data);
    }
  }
}
