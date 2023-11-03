import 'package:vexana/src/interface/index.dart';

class ResponseModel<T, E extends INetworkModel<E>?>
    extends IResponseModel<T?, E> {
  ResponseModel({T? data, IErrorModel<E>? error}) : super(data, error);
}
