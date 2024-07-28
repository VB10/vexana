import 'package:vexana/vexana.dart';

sealed class NetworkResult<T, E extends INetworkModel<E>> {
  const NetworkResult();

  bool get isSuccess => this is NetworkSuccessResult<T, E>;

  bool get isError => this is NetworkErrorResult<T, E>;

  B fold<B>({
    required B Function(T data) onSuccess,
    required B Function(IErrorModel<E>) onError,
  }) {
    return switch (this) {
      NetworkSuccessResult<T, E>(:final data) => onSuccess.call(data),
      NetworkErrorResult<T, E>(:final error) => onError.call(error),
    };
  }
}

final class NetworkSuccessResult<T, E extends INetworkModel<E>>
    extends NetworkResult<T, E> {
  const NetworkSuccessResult(this.data);

  final T data;
}

final class NetworkErrorResult<T, E extends INetworkModel<E>>
    extends NetworkResult<T, E> {
  const NetworkErrorResult(this.error);

  final IErrorModel<E> error;
}
