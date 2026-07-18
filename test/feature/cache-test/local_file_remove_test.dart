import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexana/vexana.dart';

import '../json_place_holder/todo.dart';
import 'mock_path.dart';

void main() {
  const body = '[{"userId":1,"id":1,"title":"cached","completed":true}]';
  late Directory documents;
  late HttpServer server;
  late INetworkManager<EmptyModel> networkManager;

  void serveTodos(HttpServer server) {
    server.listen((request) async {
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType('application', 'json')
        ..write(body);
      await request.response.close();
    });
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    documents = await Directory.systemTemp.createTemp('vexana-cache-test-');
    PathProviderPlatform.instance = _TestPathProviderPlatform(documents.path);
    server = await HttpServer.bind('localhost', 0);
    serveTodos(server);
    networkManager = NetworkManager<EmptyModel>(
      isEnableTest: true,
      fileManager: LocalFile(),
      options: BaseOptions(baseUrl: 'http://localhost:${server.port}'),
    );
  });

  tearDown(() async {
    await server.close(force: true);
    if (documents.existsSync()) documents.deleteSync(recursive: true);
  });

  test('removeAll keeps unrelated files in the documents directory', () async {
    await networkManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
      expiration: const Duration(minutes: 5),
    );
    final sentinel = File('${documents.path}/keep.txt')
      ..writeAsStringSync('user data');

    await networkManager.cache.removeAll();

    expect(sentinel.existsSync(), isTrue);
    expect(sentinel.readAsStringSync(), 'user data');
  });

  test(
    'removeAll deletes a malformed cache file but keeps other files',
    () async {
      final cacheFile = File('${documents.path}/vexana.json')
        ..writeAsStringSync('{not json');
      final sentinel = File('${documents.path}/keep.txt')
        ..writeAsStringSync('user data');

      await networkManager.cache.removeAll();

      expect(cacheFile.existsSync(), isFalse);
      expect(sentinel.existsSync(), isTrue);
      expect(sentinel.readAsStringSync(), 'user data');
    },
  );

  test('removeAll clears only the entries of the given base url', () async {
    await networkManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
      expiration: const Duration(minutes: 5),
    );
    final otherServer = await HttpServer.bind('localhost', 0);
    addTearDown(() => otherServer.close(force: true));
    serveTodos(otherServer);
    final otherManager = NetworkManager<EmptyModel>(
      isEnableTest: true,
      fileManager: LocalFile(),
      options: BaseOptions(baseUrl: 'http://localhost:${otherServer.port}'),
    );
    await otherManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
      expiration: const Duration(minutes: 5),
    );

    await networkManager.cache.removeAll();

    final cacheFile = File('${documents.path}/vexana.json');
    expect(cacheFile.existsSync(), isTrue);
    final content =
        jsonDecode(cacheFile.readAsStringSync()) as Map<String, dynamic>;
    expect(
      content.keys.where(
        (key) => key.contains('http://localhost:${server.port}'),
      ),
      isEmpty,
    );
    expect(
      content.keys.where(
        (key) => key.contains('http://localhost:${otherServer.port}'),
      ),
      isNotEmpty,
    );
  });
}

final class _TestPathProviderPlatform extends MockPathProviderPlatform {
  _TestPathProviderPlatform(this.documentsPath);

  final String documentsPath;

  @override
  Future<String> getApplicationDocumentsPath() async => documentsPath;
}
