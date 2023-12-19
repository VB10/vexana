import 'package:vexana/src/interface/index.dart';

/// This response model is used to represent the response received from the
/// server. It contains a `data` field which represents the data received
/// from the server, and an `error` field which represents any errors that
/// occurred while receiving the data.
abstract class IResponseModel<T, E extends INetworkModel<E>?> {
  /// The `IResponseModel` constructor is used to create a new `IResponseModel`
  IResponseModel(this.data, this.error);

  /// [data] is a getter method that returns the data received from the server.
  T data;

  /// [error] is a getter method that returns any errors that occurred while
  IErrorModel<E>? error;
}
