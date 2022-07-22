import 'IErrorModel.dart';

abstract class IResponseModel<T> {
  T data;
  IErrorModel? error;
  int? statusCode;

  IResponseModel(this.data, this.error, {this.statusCode});
}
