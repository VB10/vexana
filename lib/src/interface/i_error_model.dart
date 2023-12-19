import 'package:vexana/src/interface/index.dart';

/// Error model for network response
abstract class IErrorModel<T extends INetworkModel<T>?> {
  /// Error model for network response
  IErrorModel({this.statusCode, this.description, this.model});

  /// Error status code as http result
  int? statusCode;

  /// Error message
  String? description;

  /// Error model
  T? model;
}
