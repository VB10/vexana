import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

/// `NetworkManager` içindeki metotların manager'ın kendi pipeline'ını
/// kullandığını doğrular.
///
/// `downloadFileSimple`, `sendPrimitive` ve `download` eskiden gövdelerinde
/// yeni bir `Dio()` kuruyordu; bu manager'ın interceptor'larını, adapter'ını ve
/// base options'ını sessizce atlıyor, her çağrıda yeni bir bağlantı havuzu
/// açıyordu.
///
/// Testler yerel bir `HttpServer`'a karşı koşar — internet gerekmez.
void main() {
  late HttpServer server;
  late String baseUrl;
  late List<String> receivedPaths;
  late List<String?> receivedHeaders;

  setUp(() async {
    receivedPaths = [];
    receivedHeaders = [];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      receivedPaths.add(request.uri.path);
      receivedHeaders.add(request.headers.value('x-from-interceptor'));

      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'ok': true}));
      await request.response.close();
    });

    /// Sondaki `/` kasıtlı: eski `sendPrimitive` `baseUrl + path` şeklinde elle
    /// birleştirdiği için `//ping` üretiyordu. Sunucu bunu scheme-relative bir
    /// istek satırı olarak yorumlar ve path boş kalır.
    baseUrl = 'http://${server.address.address}:${server.port}/';
  });

  tearDown(() async => server.close(force: true));

  test('sendPrimitive baseUrl ile path\'i doğru birleştirir', () async {
    final manager = NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: baseUrl),
    );

    await manager.sendPrimitive<Map<String, dynamic>>('/ping');

    expect(receivedPaths.single, '/ping');
  });

  test('sendPrimitive manager interceptor\'ından geçer', () async {
    final manager = NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: baseUrl),
      interceptor: _StampInterceptor(),
    );

    await manager.sendPrimitive<Map<String, dynamic>>('/ping');

    expect(
      receivedHeaders.single,
      'yes',
      reason: 'İçeride yeni Dio() kurulursa interceptor atlanır',
    );
  });

  test('downloadFileSimple manager interceptor\'ından geçer', () async {
    final manager = NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: baseUrl),
      interceptor: _StampInterceptor(),
    );

    await manager.downloadFileSimple('${baseUrl}file.bin', null);

    expect(receivedHeaders.single, 'yes');
    expect(receivedPaths.single, '/file.bin');
  });

  test('downloadFileSimple mutlak URL ile baseUrl\'i yok sayar', () async {
    final manager = NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: 'https://baska-bir-host.example/'),
    );

    final response =
        await manager.downloadFileSimple('${baseUrl}file.bin', null);

    expect(response.statusCode, 200);
    expect(receivedPaths.single, '/file.bin');
  });

  test('download delege üzerinden çalışır ve özyinelemeye girmez', () async {
    final manager = NetworkManager<EmptyModel>(
      options: BaseOptions(baseUrl: baseUrl),
    );
    final target = '${Directory.systemTemp.path}/vexana_delegation';

    await manager.download('/a.bin', '$target-a.bin');
    await manager.download('/b.bin', '$target-b.bin');

    expect(receivedPaths, ['/a.bin', '/b.bin']);

    File('$target-a.bin').deleteSync();
    File('$target-b.bin').deleteSync();
  });
}

/// İsteğe iz bırakan interceptor — manager'ın pipeline'ından geçilip
/// geçilmediğini kanıtlar.
class _StampInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['x-from-interceptor'] = 'yes';
    handler.next(options);
  }
}
