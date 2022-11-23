import 'INetworkModel.dart';

abstract class IErrorModel<T extends INetworkModel?> {
  int? statusCode;
  String? description;
  T? model;
  dynamic response;
}
