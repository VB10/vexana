import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexana/vexana.dart';

import '../json_place_holder/todo.dart';
import 'mock_path.dart';

void main() {
  late HttpServer server;
  late int requestCount;
  late INetworkManager<EmptyModel> networkManager;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PathProviderPlatform.instance = MockPathProviderPlatform();
    requestCount = 0;
    server = await HttpServer.bind('localhost', 0);
    server.listen((request) async {
      requestCount++;
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType('application', 'json')
        ..write('[{"userId":1,"id":1,"title":"cached","completed":true}]');
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
  });

  test('send serves the parsed body from cache on a hit', () async {
    final first = await networkManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
      expiration: const Duration(minutes: 5),
    );
    expect(first.error, isNull);
    expect(first.data, hasLength(1));

    final second = await networkManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
      expiration: const Duration(minutes: 5),
    );

    expect(requestCount, 1);
    expect(second.error, isNull);
    expect(second.data, hasLength(1));
    expect(second.data?.single.title, 'cached');
  });

  test('sendRequest returns success from cache on a hit', () async {
    final first = await networkManager.sendRequest<Todo, List<Todo>>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
      expiration: const Duration(minutes: 5),
    );
    expect(first, isA<NetworkSuccessResult<List<Todo>, EmptyModel>>());

    final second = await networkManager.sendRequest<Todo, List<Todo>>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
      expiration: const Duration(minutes: 5),
    );

    expect(requestCount, 1);
    expect(second, isA<NetworkSuccessResult<List<Todo>, EmptyModel>>());
    final data = (second as NetworkSuccessResult<List<Todo>, EmptyModel>).data;
    expect(data, hasLength(1));
    expect(data.single.completed, isTrue);
  });

  test('sendRequest with a nullable result type still parses the cache hit',
      () async {
    await networkManager.sendRequest<Todo, List<Todo>?>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
      expiration: const Duration(minutes: 5),
    );

    final second = await networkManager.sendRequest<Todo, List<Todo>?>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
      expiration: const Duration(minutes: 5),
    );

    expect(requestCount, 1);
    expect(second, isA<NetworkSuccessResult<List<Todo>?, EmptyModel>>());
    final data = (second as NetworkSuccessResult<List<Todo>?, EmptyModel>).data;
    expect(data, isNotNull);
    expect(data, hasLength(1));
  });
}
