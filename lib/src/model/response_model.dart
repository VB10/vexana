import '../interface/IErrorModel.dart';
import '../interface/IResponseModel.dart';

class ResponseModel<T> extends IResponseModel<T> {
  T data;
  IErrorModel error;

  ResponseModel({this.data, this.error});
}
