import 'dart:io' if (dart.library.html) 'dart:html' show HttpStatus;

import 'package:vexana/vexana.dart';

/// Error model for network response
class ErrorModel<T extends INetworkModel<T>?> extends IErrorModel<T> {
  /// Error model for network response
  /// [statusCode] Error status code as http result
  /// [description] Error message
  ErrorModel({super.statusCode, super.description, super.model});

  /// Null is returned after parsing a model
  factory ErrorModel.parseError() {
    return ErrorModel(description: 'JSON Decode Error ⛔');
  }

  /// Json Parse Error
  factory ErrorModel.jsonError() {
    return ErrorModel(description: 'Null is returned after parsing a model $T');
  }

  /// Error model for network response
  /// [exception] Dio exception
  ///
  /// return [ErrorModel]
  factory ErrorModel.dioException(DioException exception) {
    return ErrorModel<T>(
      description: exception.message,
      statusCode: exception.response != null
          ? exception.response!.statusCode
          : HttpStatus.internalServerError,
    );
  }

  /// Make a copy of this object with new values for some of its properties
  ErrorModel<T> copyWith({
    int? statusCode,
    String? description,
    T? model,
  }) {
    return ErrorModel<T>(
      statusCode: statusCode ?? this.statusCode,
      description: description ?? this.description,
      model: model ?? this.model,
    );
  }
}
