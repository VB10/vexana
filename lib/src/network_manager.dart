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

class NetworkManager with DioMixin implements Dio, INetworkManager {
  NetworkManager({BaseOptions options, bool isEnableLogger}) {
    this.options = options;
    if (isEnableLogger) _addLoggerInterceptor();
    httpClientAdapter = DefaultHttpClientAdapter();
  }

  void _addLoggerInterceptor() {
    if (kDebugMode) this.interceptors.add(LogInterceptor());
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
          return ResponseModel(error: ErrorModel(description: "description"));
      }
    } on DioError catch (e) {
      final error = ErrorModel(description: e.message, statusCode: e.response.statusCode);
      return ResponseModel(error: error);
    }
  }
}
