import 'package:vexana/src/interface/INetworkModel.dart';

abstract class IErrorModel<T> {
  int statusCode;
  String description;
  INetworkModel model;
}
