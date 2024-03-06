import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'common/index.dart';

void main() {
  final testParseManager = NetworkManagerResponseParseTest();
  setUp(() {});
  test('Success response parse - List', () {
    const data = MockModels.posts;

    final response = testParseManager.successResponseFetch<Post, List<Post>>(
      data: data,
      parserModel: Post(),
    );

    expect(response.data, isNotEmpty);
    expect(response.data, isA<List<Post>>());

    const singleData = MockModels.post;

    final responseSingle = testParseManager.successResponseFetch<Post, Post>(
      data: singleData,
      parserModel: Post(),
    );

    expect(responseSingle.data, isNotNull);
    expect(responseSingle.data, isA<Post>());

    final responsePrimitive =
        testParseManager.successResponseFetch<EmptyModel, EmptyModel>(
      data: '1',
      parserModel: EmptyModel(),
    );

    expect(responsePrimitive.data?.name, '1');
    expect(responsePrimitive.data, isA<EmptyModel>());
  });

  test('Error response parse - Model', () {
    const singleData = MockModels.emptyModel;

    final response = testParseManager.errorResponseFetch<void>(MockException());

    expect(response.error?.model?.name, singleData.values.first);
    expect(response.error?.statusCode, HttpStatus.notFound);
    expect(response.error?.description, 'Not Found');
  });
}
