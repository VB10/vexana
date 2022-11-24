import 'package:vexana/vexana.dart';

abstract class IResponseModel<T, E extends INetworkModel<E>?> {
  T data;
  IErrorModel<E>? error;

  IResponseModel(this.data, this.error);
}
