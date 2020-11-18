import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexana/src/cache/shared/local_preferences.dart';
import 'package:vexana/vexana.dart';

import '../json=place=holder/todo.dart';

main() {
  INetworkManager networkManager;
  setUp(() {
    SharedPreferences.setMockInitialValues({}); //set values here

    networkManager = NetworkManager(
        fileManager: LocalPreferences(),
        isEnableLogger: true,
        options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));
  });
  test("Json Place Holder Todos", () async {
    final response = await networkManager.fetch<Todo, List<Todo>>("/todos",
        parseModel: Todo(),
        expiration: Duration(seconds: 10),
        method: RequestType.GET);

    expect(response.data, isList);
  });
}
