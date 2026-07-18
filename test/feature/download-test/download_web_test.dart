@TestOn('browser')
library;

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

final class _ResponseAdapter implements HttpClientAdapter {
  bool requestSeen = false;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestSeen = true;
    return ResponseBody.fromString(
      'hello',
      200,
      headers: {
        Headers.contentLengthHeader: ['5'],
        Headers.contentTypeHeader: ['text/plain'],
      },
    );
  }
}

void main() {
  test('download keeps dio web adapter unsupported behavior', () {
    final adapter = _ResponseAdapter();
    final manager = NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: 'https://example.test'),
    )..httpClientAdapter = adapter;

    expect(
      () => manager.download('/download', 'probe.txt'),
      throwsA(
        isA<UnsupportedError>().having(
          (error) => error.message,
          'message',
          'The download method is not available in the Web environment.',
        ),
      ),
    );

    expect(adapter.requestSeen, isFalse);
  });
}
