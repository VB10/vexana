import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

// ignore: always_declare_return_types
main() {
  late INetworkManager networkManager;
  setUp(() {
    networkManager =
        NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: 'https://hwasampleapi.firebaseio.com'));
  });
  test('Primitve Type', () async {
    final response = await networkManager.send<EmptyModel, EmptyModel>('/dogs/0/code.json',
        parseModel: EmptyModel(), method: RequestType.GET);

    expect(response.data, isNotNull);
  });
}
