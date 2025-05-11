import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'todo.dart';

void main() {
  late INetworkManager<EmptyModel, EmptyModel> networkManager;

  setUp(() {
    networkManager = NetworkManager<EmptyModel, EmptyModel>(
      isEnableLogger: true,
      options: BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com/'),
      isEnableTest: true,
    );
  });
  test('Json Place Holder Todos', () async {
    final response = await networkManager.send<Todo, List<Todo>, EmptyModel>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
    );

    expect(response.data, isList);
  });

  test('First value add to all every request headers.', () async {
    final response = await networkManager.send<Todo, List<Todo>, EmptyModel>(
      '/todos',
      parseModel: const Todo(),
      method: RequestType.GET,
    );

    expect(response.data, isList);

    networkManager
      ..addBaseHeader(
        MapEntry(
          HttpHeaders.authorizationHeader,
          response.data?.first.title ?? '',
        ),
      )
      // Clear single header
      ..removeHeader('${response.data?.first.id}')
      // Clear all hader
      ..clearHeader();
  });
}
