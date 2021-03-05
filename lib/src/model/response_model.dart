import '../interface/IResponseModel.dart';

class ResponseModel<T> extends IResponseModel<T?> {

  ResponseModel({data, error}) : super(data, error);
}
