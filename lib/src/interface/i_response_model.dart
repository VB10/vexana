import 'package:vexana/src/interface/index.dart';

abstract class IResponseModel<T, E extends INetworkModel<E>?> {
  IResponseModel(this.data, this.error);
  T data;
  IErrorModel<E>? error;
}
