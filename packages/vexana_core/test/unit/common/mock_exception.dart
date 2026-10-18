import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:vexana_core/vexana_core.dart';

import 'index.dart';

class MockException extends Mock implements DioException {
  @override
  RequestOptions get requestOptions =>
      RequestOptions(baseUrl: 'https://pub.dev/', path: 'mock');

  @override
  Response<dynamic> get response => Response(
        requestOptions: requestOptions,
        data: MockModels.emptyModel,
        statusCode: HttpStatus.notFound,
        statusMessage: 'Not Found',
      );

  @override
  Object? get error => 'Mock Error';

  @override
  String? get message => 'Mock Message';
}
