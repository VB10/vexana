import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexana/vexana.dart';

import '../json_place_holder/todo.dart';
import 'mock_path.dart';

void main() {
  late Directory documents;
  late HttpServer server;
  late int requestCount;
  late INetworkManager<EmptyModel> networkManager;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    documents = Directory.systemTemp.createTempSync('vexana-cache-test-');
    PathProviderPlatform.instance = TempDocumentsPathProvider(documents.path);
    requestCount = 0;
    server = await HttpServer.bind('localhost', 0);
    server.listen((request) async {
      requestCount++;
      final title = request.uri.toString();
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType('application', 'json')
        ..write('[{"userId":1,"id":1,"title":"$title","completed":true}]');
      await request.response.close();
    });
    networkManager = NetworkManager<EmptyModel>(
      isEnableTest: true,
      fileManager: LocalFile(),
      options: BaseOptions(baseUrl: 'http://localhost:${server.port}'),
    );
  });

  tearDown(() async {
    await server.close(force: true);
    documents.deleteSync(recursive: true);
  });

  Future<String?> fetchTitle(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final result = await networkManager.sendRequest<Todo, List<Todo>>(
      path,
      parseModel: const Todo(),
      method: RequestType.GET,
      queryParameters: queryParameters,
      expiration: const Duration(minutes: 5),
    );
    return (result as NetworkSuccessResult<List<Todo>, EmptyModel>)
        .data
        .single
        .title;
  }

  test('different paths get separate cache entries', () async {
    expect(await fetchTitle('/todos'), '/todos');
    expect(await fetchTitle('/posts'), '/posts');
    expect(requestCount, 2);

    expect(await fetchTitle('/todos'), '/todos');
    expect(await fetchTitle('/posts'), '/posts');
    expect(requestCount, 2);
  });

  test('different query parameters get separate cache entries', () async {
    expect(
      await fetchTitle('/todos', queryParameters: {'page': 1}),
      '/todos?page=1',
    );
    expect(
      await fetchTitle('/todos', queryParameters: {'page': 2}),
      '/todos?page=2',
    );
    expect(requestCount, 2);
  });

  test('query parameter order does not change the cache key', () async {
    await fetchTitle('/todos', queryParameters: {'a': 1, 'b': 2});
    await fetchTitle('/todos', queryParameters: {'b': 2, 'a': 1});
    expect(requestCount, 1);
  });

  test('send (IResponseModel API) keys the cache by path too', () async {
    Future<String?> sendTitle(String path) async {
      final response = await networkManager.send<Todo, List<Todo>>(
        path,
        parseModel: const Todo(),
        method: RequestType.GET,
        expiration: const Duration(minutes: 5),
      );
      return response.data?.single.title;
    }

    expect(await sendTitle('/todos'), '/todos');
    expect(await sendTitle('/posts'), '/posts');
    expect(requestCount, 2);
  });

  test('removeAll still clears path-keyed entries', () async {
    await fetchTitle('/todos');
    await fetchTitle('/posts');
    expect(requestCount, 2);

    await networkManager.cache.removeAll();

    await fetchTitle('/todos');
    await fetchTitle('/posts');
    expect(requestCount, 4);
  });
}
