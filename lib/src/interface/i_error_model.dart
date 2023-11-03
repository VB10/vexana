import 'package:vexana/src/interface/index.dart';

abstract class IErrorModel<T extends INetworkModel<T>?> {
  int? statusCode;
  String? description;
  T? model;
}
