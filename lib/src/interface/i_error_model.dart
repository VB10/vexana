import 'package:vexana/src/interface/index.dart';

/// Error model for network response
abstract class IErrorModel<T extends INetworkModel<T>?> {
  /// Error model for network response
  const IErrorModel({this.statusCode, this.description, this.model});

  /// Error status code as http result
  final int? statusCode;

  /// Error message
  final String? description;

  /// Error model
  final T? model;
}
