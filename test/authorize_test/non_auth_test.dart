import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

// ignore: always_declare_return_types
main() {
  late INetworkManager networkManager;
  setUp(() {
    networkManager = NetworkManager(
        isEnableLogger: true,
        onRefreshToken: (error, newService) async {
          await Future.delayed(const Duration(seconds: 1));
          error.requestOptions.path = '/products.json';
          return error;
        },
        options: BaseOptions(
          baseUrl: 'https://fluttertr-ead5c.firebaseio.com',
        ));
  });

  test('Retry Auth Test', () async {
    networkManager.send<EmptyModel, EmptyModel>('/words.json', parseModel: EmptyModel(), method: RequestType.GET);

    networkManager.send<EmptyModel, EmptyModel>('/words2.json', parseModel: EmptyModel(), method: RequestType.GET);

    final response = await networkManager.send<EmptyModel, EmptyModel>('/words2.json',
        parseModel: EmptyModel(), method: RequestType.GET);

    expect(response.data, isNotNull);
  });
}
