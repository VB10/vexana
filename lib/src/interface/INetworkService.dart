import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../model/enum/request_type.dart';
import 'INetworkModel.dart';
import 'IResponseModel.dart';

abstract class INetworkManager {
  Future<IResponseModel<R?>> send<T extends INetworkModel, R>(
    String path, {
    required T parseModel,
    required RequestType method,
    String? urlSuffix,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? expiration,
    CancelToken? cancelToken,
    dynamic data,
    ProgressCallback? onReceiveProgress,
  });

  Future<bool> removeAllCache();
  Interceptors get dioIntercaptors;
  Future<Response<Uint8List?>> downloadFileSimple(String path, ProgressCallback? callback);

  Future<Response<T>> uploadFile<T>(String path, FormData data, {Map<String, dynamic>? headers});
  void addBaseHeader(MapEntry<String, String> key);
  void removeHeader(String key);
  void clearHeader();
}
