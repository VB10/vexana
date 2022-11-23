import '../interface/IErrorModel.dart';
import '../interface/INetworkModel.dart';

class BaseErrorModel<T extends INetworkModel> {
  final T data;

  BaseErrorModel(this.data);
}

class ErrorModel<T extends INetworkModel<T>?> extends IErrorModel<T> {
  @override
  final int? statusCode;

  @override
  final String? description;

  ErrorModel({this.statusCode, this.description, this.model});

  @override
  final T? model;

  // Generic Response from Service
  @override
  dynamic response;

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
