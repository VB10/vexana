import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

// ignore: always_declare_return_types
main() {
  late INetworkManager networkManager;
  setUp(() {
    networkManager = NetworkManager<EmptyModel>(
        isEnableLogger: true,
        interceptor: InterceptorsWrapper(
          onRequest: (options, handler) {
            print(options.data);
            handler.next(options);
          },
        ),
        options: BaseOptions(
          baseUrl: 'https://hwasampleapi.firebaseio.com',
        ));
  });
  test('Primitive Type', () async {
    final response = await networkManager.send<EmptyModel, EmptyModel>('/dogs/0/code.json',
        parseModel: EmptyModel(), method: RequestType.GET);

    expect(response.data, isNotNull);
  });

  test('Primitive List Type', () async {
    final response = await networkManager.send<EmptyModel, List<EmptyModel>>('/dogs.json',
        parseModel: EmptyModel(), method: RequestType.GET);

    expect(response.data, isNotNull);
  });
}
