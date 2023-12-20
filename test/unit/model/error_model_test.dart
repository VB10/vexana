import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

void main() {
  setUp(() {});
  test('Error model is valid', () {
    final errorModel =
        ErrorModel(description: 'test', statusCode: 200, model: EmptyModel());

    expect(errorModel.description, 'test');

    final errorModelJsonDecodeError = ErrorModel<EmptyModel>.parseError();

    expect(errorModelJsonDecodeError.description, 'JSON Decode Error ⛔');

    final errorModelDio = ErrorModel<EmptyModel>.dioException(
      DioException(
        requestOptions: RequestOptions(path: 'test'),
        message: 'test',
      ),
    );

    expect(errorModelDio.description, 'test');
    expect(errorModelDio.statusCode, HttpStatus.internalServerError);

    final errorModelJsonError = ErrorModel<EmptyModel>.jsonError();

    expect(
      errorModelJsonError.description,
      'Null is returned after parsing a model EmptyModel',
    );
  });
}
