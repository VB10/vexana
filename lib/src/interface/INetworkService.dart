import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../model/enum/request_type.dart';
import 'INetworkModel.dart';
import 'IResponseModel.dart';

abstract class INetworkManager {
  Future<IResponseModel<R>> fetch<T extends INetworkModel, R>(
    String path, {
    @required T parseModel,
    @required RequestType method,
    String urlSuffix,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    dynamic data,
    ProgressCallback onReceiveProgress,
  });
}
