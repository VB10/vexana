import '../interface/IResponseModel.dart';

class ResponseModel<T> extends IResponseModel<T?> {
  ResponseModel({data, error, statusCode})
      : super(data, error, statusCode: statusCode);
}
