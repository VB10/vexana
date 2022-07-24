import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../model/enum/request_type.dart';
import 'INetworkModel.dart';
import 'IResponseModel.dart';

abstract class INetworkManager {
  Future<IResponseModel<R?>> send<T extends INetworkModel, R>(String path,
      {required T parseModel,
      required RequestType method,
      String? urlSuffix,
      Map<String, dynamic>? queryParameters,
      Options? options,
      Duration? expiration,
      dynamic data,
      ProgressCallback? onReceiveProgress,
      CancelToken? cancelToken,
      bool isErrorDialog = false,
      bool? forceUpdateDecode});

  Future<bool> removeAllCache();
  Interceptors get dioInterceptors;
  Future<Response<Uint8List?>> downloadFileSimple(String path, ProgressCallback? callback);

  Future<Response<T>> uploadFile<T>(String path, FormData data, {Map<String, dynamic>? headers});
  void addBaseHeader(MapEntry<String, String> key);
  void removeHeader(String key);
  void clearHeader();
  Future<T?> sendPrimitive<T>(String path, {Map<String, dynamic>? headers});
}
