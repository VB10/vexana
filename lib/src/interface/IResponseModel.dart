import 'IErrorModel.dart';

abstract class IResponseModel<T> {
  T data;
  IErrorModel error;
}
