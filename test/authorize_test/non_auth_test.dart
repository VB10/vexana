import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

// ignore: always_declare_return_types
main() {
  late INetworkManager networkManager;
  setUp(() {
    networkManager = NetworkManager<EmptyModel>(
        isEnableLogger: true,
        onRefreshToken: (error, newService) async {
          await Future.delayed(const Duration(seconds: 1));
          error.requestOptions.path = '/products.json';
          return error;
        },
        options: BaseOptions(
          baseUrl: 'https://fluttertr-ead5c.firebaseio.com',
        ));

    networkManager.dioInterceptors.add(InterceptorsWrapper(
      onError: (e, handler) {
        return handler.reject(e);
      },
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
