import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexana/src/cache/file/local_file.dart';
import 'package:vexana/src/cache/shared/local_preferences.dart';
import 'package:vexana/vexana.dart';

import '../json=place=holder/todo.dart';
import 'mock_path.dart';

main() {
  INetworkManager networkManager;
  setUp(() {
    SharedPreferences.setMockInitialValues({}); //set values here
    PathProviderPlatform.instance = MockPathProviderPlatform();
    networkManager = NetworkManager(
        fileManager: LocalFile(),
        isEnableLogger: true,
        options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));
  });

  test("Json Place Shared Test Holder Todos", () async {
    await networkManager.fetch<Todo, List<Todo>>("/todos",
        parseModel: Todo(),
        expiration: Duration(seconds: 3),
        method: RequestType.GET);

    await Future.delayed(Duration(seconds: 2));
    networkManager.removeAllCache();

    final response2 = await networkManager.fetch<Todo, List<Todo>>("/todos",
        parseModel: Todo(),
        expiration: Duration(seconds: 3),
        method: RequestType.GET);
    expect(response2.data, isList);
  });

  test("Json Place Files Test Holder Todos", () async {
    await networkManager.fetch<Todo, List<Todo>>("/todos",
        parseModel: Todo(),
        expiration: Duration(seconds: 3),
        method: RequestType.GET);

    await Future.delayed(Duration(seconds: 1));
    networkManager.removeAllCache();

    final response2 = await networkManager.fetch<Todo, List<Todo>>("/todos",
        parseModel: Todo(),
        expiration: Duration(seconds: 2),
        method: RequestType.GET);

    expect(response2.data, isList);
  });
}
