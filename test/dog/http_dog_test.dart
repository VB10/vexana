import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

main() {
  INetworkManager networkManager;
  setUp(() {
    networkManager = NetworkManager(isEnableLogger: true, options: BaseOptions(baseUrl: "https://hwasampleapi.firebaseio.com"));
  });
  test("Primitve Type", () async {
    final response = await networkManager.fetch<EmptyModel, EmptyModel>("/dogs/0/code.json", parseModel: EmptyModel(), method: RequestType.GET);

    expect(response.data, isList);
  });
}
