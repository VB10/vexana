import 'package:vexana/src/mixin/index.dart';
import 'package:vexana/vexana.dart';

/// The `INetworkManager` interface is used to define the methods that are used
/// to send HTTP requests to a server. It extends the `NetworkManagerParameters`
abstract class INetworkManager<E extends INetworkModel<E>, P>
    with NetworkManagerOperation<E, P> {
  /// [super.options] is a getter method that returns the `BaseOptions` object
  INetworkManager();

  /// [parameters] is a getter method that returns
  ///  the `NetworkManagerParameters`for detail
  @override
  NetworkManagerParameters<E, P> get parameters;

  /// [cache] is a getter method that returns the `NetworkManagerCache`
  NetworkManagerCache<E, P> get cache;

  /// The `Interceptors get dioInterceptors;` is a getter method that returns
  /// the interceptors used by the Dio HTTP client.
  /// Interceptors are functions that can be registered to intercept and modify
  /// HTTP requests or responses before they are
  /// sent or received.
  Interceptors get dioInterceptors;

  /// The `send` method is used to send an HTTP request to a specified
  /// `path` with various parameters. Here is a breakdown of
  /// the parameters:
  Future<IResponseModel<R?, E?>> send<T extends INetworkModel<T>, R, O>(
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
    bool? handleRefreshToken,
    O? customParameter,
  });

  /// The sendRequest method is used to send an HTTP request
  /// and handle the response. It supports various HTTP methods and
  /// can parse the response into a specified model. This method also provides
  /// options for handling progress, cancellation, and caching.
  Future<NetworkResult<R, E>> sendRequest<T extends INetworkModel<T>, R>(
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
  });

  /// The `downloadFileSimple` method is used to download a file from a
  /// specified `path` using a simple HTTP GET request. It
  /// returns a `Future<Response<List<int>?>>` which represents the response
  ///  received from the server. The response contains
  /// the downloaded file as a list of integers.
  Future<Response<List<int>?>> downloadFileSimple(
    String path,
    ProgressCallback? callback,
  );

  /// The `downloadFile` method is used to download a file from a specified
  /// `path` using an HTTP request. It returns a
  /// `Future<Response<List<int>?>>` which represents the response received
  /// from the server. The response contains the
  /// downloaded file as a list of integers.

  Future<Response<List<int>?>> downloadFile(
    String path,
    ProgressCallback? callback, {
    RequestType? method,
    Options? options,
    dynamic data,
  });

  /// The `uploadFile` method is used to upload a file to a specified `path`
  ///  using an HTTP request. It takes the `path` of
  /// the file to be uploaded and a `FormData` object containing the file data
  ///  as parameters. Additionally, it can also
  /// accept an optional `headers` parameter to include any custom headers
  /// in the request.
  Future<Response<T>> uploadFile<T>(
    String path,
    FormData data, {
    Map<String, dynamic>? headers,
  });

  /// The `sendPrimitive` method is a generic method that is used to
  ///  send a primitive HTTP request to a specified `path`. It
  /// takes the `path` as a parameter and an optional `headers` parameter,
  ///  which is a map of additional headers to be
  /// included in the request.
  Future<T?> sendPrimitive<T>(String path, {Map<String, dynamic>? headers});
}
