import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'todo.dart';

main() {
  INetworkManager networkManager;
  setUp(() {
    networkManager =
        NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: "https://jsonplaceholder.typicode.com/"));
  });
  test("Json Place Holder Todos", () async {
    final response =
        await networkManager.fetch<Todo, List<Todo>>("/todos", parseModel: Todo(), method: RequestType.GET);

    expect(response.data, isList);
  });
}
