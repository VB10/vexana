import 'package:vexana/src/interface/index.dart';

/// Response model for network response general
class ResponseModel<T, E extends INetworkModel<E>?>
    extends IResponseModel<T?, E> {
  /// T: success model
  /// E: error model
  const ResponseModel({T? data, IErrorModel<E>? error}) : super(data, error);
}
