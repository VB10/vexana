import 'package:dio/dio.dart';
import 'package:vexana/src/interface/INetworkModel.dart';
import 'package:vexana/src/interface/IResponseModel.dart';
import 'package:vexana/src/model/enum/request_type.dart';

/// The INetworkManager class is an abstract class that defines a contract for managing network operations with models that
/// implement the INetworkModel interface.
abstract class INetworkManager<E extends INetworkModel<E>?> {
  /// The `send` method is used to send an HTTP request to a specified `path` with various parameters. Here is a breakdown of
  /// the parameters:
  Future<IResponseModel<R?, E?>> send<T extends INetworkModel<T>, R>(
    String path, {
    required T parseModel,
    required RequestType method,
    String? urlSuffix,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? expiration,
    dynamic data,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool isErrorDialog = false,
    bool? forceUpdateDecode,
  });

  /// The `removeAllCache()` method is used to remove all cached data from the network manager. This can be useful when you
  /// want to clear the cache and fetch fresh data from the server.
  Future<bool> removeAllCache();

  /// The `Interceptors get dioInterceptors;` is a getter method that returns the interceptors used by the Dio HTTP client.
  /// Interceptors are functions that can be registered to intercept and modify HTTP requests or responses before they are
  /// sent or received.
  Interceptors get dioInterceptors;

  /// The `downloadFileSimple` method is used to download a file from a specified `path` using a simple HTTP GET request. It
  /// returns a `Future<Response<List<int>?>>` which represents the response received from the server. The response contains
  /// the downloaded file as a list of integers.
  Future<Response<List<int>?>> downloadFileSimple(
    String path,
    ProgressCallback? callback,
  );

  /// The `downloadFile` method is used to download a file from a specified `path` using an HTTP request. It returns a
  /// `Future<Response<List<int>?>>` which represents the response received from the server. The response contains the
  /// downloaded file as a list of integers.

  Future<Response<List<int>?>> downloadFile(
    String path,
    ProgressCallback? callback, {
    RequestType? method,
    Options? options,
    dynamic data,
  });

  /// The `uploadFile` method is used to upload a file to a specified `path` using an HTTP request. It takes the `path` of
  /// the file to be uploaded and a `FormData` object containing the file data as parameters. Additionally, it can also
  /// accept an optional `headers` parameter to include any custom headers in the request.
  Future<Response<T>> uploadFile<T>(
    String path,
    FormData data, {
    Map<String, dynamic>? headers,
  });

  /// The `addBaseHeader` method is used to add a base header to the network manager. It takes a `MapEntry<String, String>`
  /// as a parameter, where the key represents the header name and the value represents the header value. This method allows
  /// you to include a common header that will be added to all HTTP requests made by the network manager.
  void addBaseHeader(MapEntry<String, String> key);

  /// The `removeHeader(String key)` method is used to remove a specific header from the network manager. It takes a
  /// `String` parameter `key` which represents the name of the header to be removed. This method allows you to remove a
  /// header that was previously added using the `addBaseHeader` method.
  void removeHeader(String key);

  /// The `Map<String, dynamic> get allHeaders;` is a getter method that returns a map of all the headers currently added to
  /// the network manager. It allows you to access and retrieve all the headers that have been added using the
  /// `addBaseHeader` method. The returned map has a key-value pair structure, where the key represents the header name and
  /// the value represents the header value.
  Map<String, dynamic> get allHeaders;

  /// The `clearHeader()` method is used to remove all headers that have been added to the network manager using the
  /// `addBaseHeader()` method. It clears the existing headers, so that no headers are included in the HTTP requests made by
  /// the network manager. This can be useful when you want to remove all headers and make requests without any additional
  /// headers.
  void clearHeader();

  /// The `sendPrimitive` method is a generic method that is used to send a primitive HTTP request to a specified `path`. It
  /// takes the `path` as a parameter and an optional `headers` parameter, which is a map of additional headers to be
  /// included in the request.
  Future<T?> sendPrimitive<T>(String path, {Map<String, dynamic>? headers});
}
