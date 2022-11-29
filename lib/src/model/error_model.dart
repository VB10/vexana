import '../../vexana.dart';

class ErrorModel<E extends INetworkModel<E>?> extends IErrorModel<E> {
  @override
  final int? statusCode;

  @override
  final String? description;

  ErrorModel({this.statusCode, this.description, this.model});

  @override
  final E? model;

  // Generic Response from Service
  @override
  dynamic response;

  ErrorModel<E> copyWith({
    int? statusCode,
    String? description,
    E? model,
  }) {
    return ErrorModel<E>(
      statusCode: statusCode ?? this.statusCode,
      description: description ?? this.description,
      model: model ?? this.model,
    );
  }
}
