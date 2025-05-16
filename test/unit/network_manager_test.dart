import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/feature/compression/network_compression_type.dart';
import 'package:vexana/src/mixin/network_manager_cache.dart';
import 'package:vexana/src/mixin/network_manager_parameters.dart';
import 'package:vexana/vexana.dart';

void main() {
  test(' CustomNetworkManager test is valid', () async {
    final manager = CustomNetworkManager();
    expect(manager, isNotNull);

    final primitiveResponse = await manager.sendPrimitive<EmptyModel>('test');
    expect(primitiveResponse, isNull);

    final downloadFileResponse = await manager.downloadFile('test', null);
    expect(downloadFileResponse, isNotNull);

    final downloadFileSimpleResponse =
        await manager.downloadFileSimple('test', null);
    expect(downloadFileSimpleResponse, isNotNull);
  });
}

class CustomNetworkManager extends INetworkManager<EmptyModel> {
  @override
  NetworkManagerCache<INetworkModel<EmptyModel>> get cache =>
      throw UnimplementedError();

  @override
  Interceptors get dioInterceptors => throw UnimplementedError();

  @override
  Future<Response<List<int>?>> downloadFile(
    String path,
    ProgressCallback? callback, {
    RequestType? method,
    Options? options,
    data,
  }) {
    return Future.value(
      Response<List<int>>(requestOptions: RequestOptions(), data: [1, 2, 3]),
    );
  }

  @override
  Future<Response<List<int>?>> downloadFileSimple(
    String path,
    ProgressCallback? callback,
  ) {
    return Future.value(
      Response<List<int>>(requestOptions: RequestOptions(), data: [1, 2, 3]),
    );
  }

  @override
  NetworkManagerParameters get parameters => throw UnimplementedError();

  @override
  Future<IResponseModel<R?, EmptyModel?>> send<T extends INetworkModel<T>, R>(
    String path, {
    required T parseModel,
    required RequestType method,
    String? urlSuffix,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? expiration,
    data,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool isErrorDialog = false,
    NetworkCompressionType compressionType = NetworkCompressionType.none,
  }) {
    return Future.value(ResponseModel(data: const EmptyModel() as R));
  }

  @override
  Future<T?> sendPrimitive<T>(String path, {Map<String, dynamic>? headers}) {
    return Future.value();
  }

  @override
  Future<Response<T>> uploadFile<T>(
    String path,
    FormData data, {
    Map<String, dynamic>? headers,
  }) {
    return Future.value(Response<T>(requestOptions: RequestOptions()));
  }

  @override
  Future<NetworkResult<R, EmptyModel>>
      sendRequest<T extends INetworkModel<T>, R>(
    String path, {
    required T parseModel,
    required RequestType method,
    String? urlSuffix,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? expiration,
    data,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool isErrorDialog = false,
    NetworkCompressionType compressionType = NetworkCompressionType.none,
  }) {
    return Future.value(NetworkSuccessResult(const EmptyModel() as R));
  }
}
