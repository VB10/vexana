import 'package:vexana/src/interface/index.dart';

/// Error model for network response
abstract class IErrorModel<T extends INetworkModel<T>?> {
  /// Error status code as http result
  int? statusCode;

  /// Error message
  String? description;

  /// Error model
  T? model;
}
