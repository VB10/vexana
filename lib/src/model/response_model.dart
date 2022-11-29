import '../../vexana.dart';

class ResponseModel<T, E extends INetworkModel<E>?>
    extends IResponseModel<T?, E?> {
  ResponseModel({data, error}) : super(data, error);
}
