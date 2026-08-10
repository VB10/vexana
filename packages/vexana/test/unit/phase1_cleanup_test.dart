import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/feature/network_check/network_check.dart';
import 'package:vexana/vexana.dart';

/// Faz 1 (A-5 + A-6) davranış testleri.
///
/// Hepsi yerel bir `HttpServer`'a karşı koşar — internet gerekmez, flaky değil.
void main() {
  group('A-6 · iç Dio() sızıntıları kapandı', () {
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

      /// Sondaki `/` kasıtlı: eski `sendPrimitive` `baseUrl + path` şeklinde
      /// elle birleştirdiği için `//ping` üretiyordu.
      baseUrl = 'http://${server.address.address}:${server.port}/';
    });

    tearDown(() async => server.close(force: true));

    test('sendPrimitive baseUrl ile path\'i doğru birleştirir (çift / yok)',
        () async {
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
        reason: 'Eskiden içeride yeni Dio() kurulduğu için interceptor atlanıyordu',
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

    test('downloadFileSimple mutlak URL ile hâlâ çalışır', () async {
      final manager = NetworkManager<EmptyModel>(
        options: BaseOptions(baseUrl: 'https://baska-bir-host.example/'),
      );

      final response =
          await manager.downloadFileSimple('${baseUrl}file.bin', null);

      expect(response.statusCode, 200);
      expect(
        receivedPaths.single,
        '/file.bin',
        reason: 'Mutlak URL verildiğinde baseUrl yok sayılmalı',
      );
    });

    test('download aynı delegeyi tekrar kullanır (yeni pool kurulmaz)',
        () async {
      final manager = NetworkManager<EmptyModel>(
        options: BaseOptions(baseUrl: baseUrl),
      );
      final target = '${Directory.systemTemp.path}/vexana_phase1';

      await manager.download('/a.bin', '$target-a.bin');
      await manager.download('/b.bin', '$target-b.bin');

      expect(receivedPaths, ['/a.bin', '/b.bin']);

      File('$target-a.bin').deleteSync();
      File('$target-b.bin').deleteSync();
    });
  });

  group('A-6 · NetworkCheck artık google.com\'a ping atmıyor', () {
    test('çözümlenemeyen host için false döner', () async {
      /// `.invalid` IANA tarafından ayrılmış, hiçbir zaman çözümlenmez.
      final result = await NetworkCheck.instance.isNetworkAvailable(
        host: 'vexana-does-not-exist.invalid',
      );

      expect(result, false);
    });

    test('localhost internet olmadan da çözümlenir', () async {
      final result = await NetworkCheck.instance.isNetworkAvailable(
        host: 'localhost',
      );

      expect(result, true);
    });

    test('zaman aşımı çağıranı süresiz bekletmez', () async {
      final stopwatch = Stopwatch()..start();

      await NetworkCheck.instance.isNetworkAvailable(
        host: 'vexana-does-not-exist.invalid',
        timeout: const Duration(milliseconds: 300),
      );

      stopwatch.stop();
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 3)));
    });
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
