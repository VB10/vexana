import 'INetworkModel.dart';

abstract class IErrorModel<T> {
  int? statusCode;
  String? description;
  INetworkModel? model;
  dynamic response;
}
