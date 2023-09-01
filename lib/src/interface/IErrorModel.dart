import 'package:vexana/src/interface/INetworkModel.dart';

abstract class IErrorModel<T extends INetworkModel?> {
  int? statusCode;
  String? description;
  T? model;
}
