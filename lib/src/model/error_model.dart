import 'package:vexana/src/interface/INetworkModel.dart';

import '../interface/IErrorModel.dart';

class ErrorModel<T> implements IErrorModel {
  @override
  int statusCode;

  @override
  String description;

  ErrorModel({this.statusCode, this.description});

  @override
  INetworkModel model;
}
