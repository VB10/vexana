import 'dart:async';

import 'package:vexana/vexana.dart';

/// NetworkResult is a sealed class representing the result of a request.
/// It can either be a success or an error result.
/// This class provides utility methods to check the result type
/// and to handle the result using a functional approach.
sealed class NetworkResult<T, E extends INetworkModel<E>> {
  const NetworkResult();

  /// Returns true if the result is a NetworkSuccessResult, otherwise false.
  bool get isSuccess => this is NetworkSuccessResult<T, E>;

  /// Returns true if the result is a NetworkErrorResult, otherwise false.
  bool get isError => this is NetworkErrorResult<T, E>;

  /// Applies one of two functions based on the type of result.
  /// ```dart
  /// Future<void> handleNetworkResult() async {
  ///   final result = await networkManager.sendRequest<MyModel, MyResponse>(
  ///     '/api/v1/resource',
  ///     parseModel: MyModel(),
  ///     method: RequestType.GET,
  ///   );
  ///
  ///   result.fold(
  ///     onSuccess: (data) {
  ///       print('Success: $data');
  ///     },
  ///     onError: (error) {
  ///       print('Error: $error');
  ///     },
  ///   );
  /// }
  /// ```
  FutureOr<B?> fold<B>({
    required FutureOr<B> Function(T data) onSuccess,
    FutureOr<B> Function(IErrorModel<E>)? onError,
  }) {
    return switch (this) {
      NetworkSuccessResult<T, E>(:final data) => onSuccess.call(data),
      NetworkErrorResult<T, E>(:final error) => onError?.call(error),
    };
  }
}

/// NetworkSuccessResult is a class representing a successful network request.
final class NetworkSuccessResult<T, E extends INetworkModel<E>>
    extends NetworkResult<T, E> {
  /// NetworkSuccessResult is a class representing a successful network request.
  const NetworkSuccessResult(this.data);

  ///The data returned from the successful network request.
  final T data;
}

/// NetworkErrorResult is a class representing a failed network request.
final class NetworkErrorResult<T, E extends INetworkModel<E>>
    extends NetworkResult<T, E> {
  /// NetworkErrorResult is a class representing a failed network request.
  const NetworkErrorResult(this.error);

  /// The error model containing details about the failure.
  final IErrorModel<E> error;
}
