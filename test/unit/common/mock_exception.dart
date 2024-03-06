import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:vexana/vexana.dart';

import 'index.dart';

class MockException extends Mock implements DioException {
  @override
  // TODO: implement requestOptions
  RequestOptions get requestOptions =>
      RequestOptions(baseUrl: 'test', path: 'mock');
  @override
  Response<dynamic> get response => Response(
        requestOptions: requestOptions,
        data: MockModels.emptyModel,
        statusCode: HttpStatus.notFound,
        statusMessage: 'Not Found',
      );
}
