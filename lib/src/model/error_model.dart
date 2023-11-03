import 'dart:io';

import 'package:vexana/src/interface/index.dart';
import 'package:vexana/vexana.dart';

class ErrorModel<T extends INetworkModel<T>?> extends IErrorModel<T> {
  ErrorModel({this.statusCode, this.description, this.model});

  factory ErrorModel.parseError() {
    return ErrorModel(description: 'Null is returned after parsing a model $T');
  }

  factory ErrorModel.dioException(DioException exception) {
    return ErrorModel<T>(
      description: exception.message,
      statusCode: exception.response != null
          ? exception.response!.statusCode
          : HttpStatus.internalServerError,
    );
  }
  @override
  final int? statusCode;

  @override
  final String? description;

  @override
  final T? model;

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
