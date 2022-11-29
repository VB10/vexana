import '../../vexana.dart';

abstract class IResponseModel<T, E extends INetworkModel<E>?> {
  // success case
  T data;

  // error case
  IErrorModel<E?>? error;

  IResponseModel(this.data, this.error);
}
