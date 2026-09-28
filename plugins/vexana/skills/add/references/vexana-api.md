# vexana 6.x API used by the generated code

Import everything from `package:vexana/vexana.dart` (it re-exports `package:dio/dio.dart`). Never import `package:vexana/src/...` or `package:dio/src/...`.

## NetworkManager

```dart
NetworkManager<E extends INetworkModel<E>>({
  required BaseOptions options,
  E? errorModel,
  IFileManager? fileManager,        // LocalFile() or LocalPreferences(); omit for no cache
  bool? isEnableLogger,
  Interceptor? interceptor,
  RefreshTokenCallBack? onRefreshToken,
  VoidCallback? onRefreshFail,
  NoNetwork? noNetwork,
  int maxRetryCount = 3,
})
```
Type it as `INetworkManager<E>` everywhere except where it is built. `E` is the error model; use `EmptyModel` when the API has no error body.

## Models

```dart
abstract class INetworkModel<T> {
  const INetworkModel();
  Map<String, dynamic>? toJson();
  T fromJson(Map<String, dynamic> json);
}
```

## Requests

```dart
Future<NetworkResult<R, E>> sendRequest<T extends INetworkModel<T>, R>(
  String path, {
  required T parseModel,           // an instance of the element model, e.g. const Post()
  required RequestType method,     // RequestType.GET / POST / PUT / DELETE / PATCH
  Map<String, dynamic>? queryParameters,
  dynamic data,                    // request body: a model (sent via its toJson) or a Map
  Duration? expiration,            // cache lifetime; requires a fileManager
  CancelToken? cancelToken,
})
```
`R` is `T` for an object response and `List<T>` for an array response.

## Results

```dart
sealed class NetworkResult<T, E extends INetworkModel<E>>
final class NetworkSuccessResult<T, E ...>(T data)
final class NetworkErrorResult<T, E ...>(IErrorModel<E> error)   // error.statusCode, error.description, error.model
const ErrorModel<E>({int? statusCode, String? description, E? model})  // concrete IErrorModel, use in tests
```
Consume with `switch (result) { NetworkSuccessResult(:final data) => ..., NetworkErrorResult(:final error) => ... }` or `result.fold(onSuccess: ..., onError: ...)`.

## Not to be used in generated code

`send` / `IResponseModel` (older API, kept for compatibility), `sendPrimitive`, `downloadFileSimple` — generate `sendRequest` only.
