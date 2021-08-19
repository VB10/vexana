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
  Future<Response<dynamic>> downloadFileSimple(String path, ProgressCallback? callback);

  void addBaseHeader(MapEntry<String, String> key);
  void removeHeader(String key);
  void clearHeader();
}
