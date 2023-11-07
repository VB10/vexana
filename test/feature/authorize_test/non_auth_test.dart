import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

// ignore: always_declare_return_types
void main() {
  late INetworkManager networkManager;
  setUp(() {
    networkManager = NetworkManager<EmptyModel>(
      isEnableLogger: true,
      isEnableTest: true,
      onRefreshToken: (error, newService) async {
        await Future<void>.delayed(const Duration(seconds: 1));
        error.requestOptions.path = '/products.json';
        return error;
      },
      options: BaseOptions(
        baseUrl: 'https://fluttertr-ead5c.firebaseio.com',
      ),
    );

    networkManager.dioInterceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) {
          return handler.reject(e);
        },
      ),
    );
  });

  test('Retry Auth Test', () async {
    await networkManager.send<EmptyModel, EmptyModel>(
      '/words.json',
      parseModel: EmptyModel(),
      method: RequestType.GET,
    );

    await networkManager.send<EmptyModel, EmptyModel>(
      '/words2.json',
      parseModel: EmptyModel(),
      method: RequestType.GET,
    );

    final response = await networkManager.send<EmptyModel, EmptyModel>(
      '/words2.json',
      parseModel: EmptyModel(),
      method: RequestType.GET,
    );

    expect(response.data, isNotNull);
  });
}
