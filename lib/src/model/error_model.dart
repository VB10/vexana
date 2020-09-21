import '../interface/IErrorModel.dart';

class ErrorModel<T> implements IErrorModel {
  @override
  int statusCode;

  @override
  String description;

  ErrorModel({this.statusCode, this.description});
}
