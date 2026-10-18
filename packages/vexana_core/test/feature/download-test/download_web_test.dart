@TestOn('browser')
library;

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

/// `download`'ın web sınırındaki davranışı.
///
/// Bu testler PR #135'ten alındı; oradaki hâli `dio_web_adapter` 2.1.0'a göre
/// yazılmıştı ve web'de `download`'ın `UnsupportedError` fırlatmasını
/// bekliyordu. Paket 2.2.1'den itibaren web indirmesini gerçekten uyguluyor
/// (yanıtı getirip tarayıcı indirmesini tetikliyor); yalnızca
/// `FileAccessMode.append` desteklenmiyor. Testler güncel davranışa göre
/// yeniden yazıldı.
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

NetworkManager<EmptyModel> _managerWith(_ResponseAdapter adapter) {
  return NetworkManager<EmptyModel>(
    options: BaseOptions(baseUrl: 'https://example.test'),
  )..httpClientAdapter = adapter;
}

void main() {
  test('download web tarafında manager adapter\'ını kullanır', () async {
    final adapter = _ResponseAdapter();

    final response = await _managerWith(adapter).download(
      '/download',
      'probe.txt',
    );

    expect(
      adapter.requestSeen,
      isTrue,
      reason: 'Delege manager.httpClientAdapter ile kurulmalı',
    );
    expect(response.data, 'hello'.codeUnits);
  });

  test('append modu web\'de desteklenmez ve isteğe hiç çıkılmaz', () async {
    final adapter = _ResponseAdapter();

    await expectLater(
      _managerWith(adapter).download(
        '/download',
        'probe.txt',
        fileAccessMode: FileAccessMode.append,
      ),
      throwsA(isA<UnsupportedError>()),
    );

    expect(adapter.requestSeen, isFalse);
  });
}
