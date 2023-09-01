// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexana/vexana.dart';

import '../json=place=holder/todo.dart';
import 'mock_path.dart';

// ignore: always_declare_return_types
void main() {
  late INetworkManager networkManager;
  setUp(() {
    SharedPreferences.setMockInitialValues({}); //set values here
    PathProviderPlatform.instance = MockPathProviderPlatform();
    networkManager = NetworkManager<EmptyModel>(
      fileManager: LocalFile(),
      isEnableLogger: true,
      options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com/'),
    );
  });

  test('Json Place Shared Test Holder Todos', () async {
    await networkManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: Todo(),
      expiration: Duration(seconds: 3),
      method: RequestType.GET,
    );

    await Future<void>.delayed(Duration(seconds: 2));
    await networkManager.removeAllCache();

    final response2 = await networkManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: Todo(),
      expiration: Duration(seconds: 3),
      method: RequestType.GET,
    );
    expect(response2.data, isList);
  });

  test('Json Place Files Test Holder Todos', () async {
    await networkManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: Todo(),
      expiration: Duration(seconds: 3),
      method: RequestType.GET,
    );

    await Future<void>.delayed(Duration(seconds: 1));
    await networkManager.removeAllCache();

    final response2 = await networkManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: Todo(),
      expiration: Duration(seconds: 2),
      method: RequestType.GET,
    );

    expect(response2.data, isList);
  });

  test('Json Place Sembast Database Test Holder Todos', () async {
    networkManager = NetworkManager<EmptyModel>(
      fileManager: LocalSembast(),
      isEnableLogger: true,
      options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com/'),
    );

    await networkManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: Todo(),
      expiration: const Duration(seconds: 3),
      method: RequestType.GET,
    );

    await Future<void>.delayed(const Duration(seconds: 1));
    await networkManager.removeAllCache();

    final response2 = await networkManager.send<Todo, List<Todo>>(
      '/todos',
      parseModel: Todo(),
      expiration: const Duration(seconds: 2),
      method: RequestType.GET,
    );

    expect(response2.data, isList);
  });
}
