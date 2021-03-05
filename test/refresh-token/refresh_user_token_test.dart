import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'user.dart';

// ignore: always_declare_return_types
main() {
  late INetworkManager networkManager;
  setUp(() {
    networkManager = NetworkManager(
        isEnableLogger: true,
        // onRefreshFail: () {  Navigate to login },
        onRefreshToken: (error, newService) async {
          // final refreshToken = await newService.send<Credantial, Credantial>("/token",
          //     parseModel: Credantial(), method: RequestType.GET);
          // error.request.headers = {HttpHeaders.authorizationHeader: "Bearer ${refreshToken.data.token}"};
          return error;
        },
        options: BaseOptions(baseUrl: 'http://localhost:3000'));
  });

  test('Json Place Holder Todos', () async {
    final response = await networkManager.send<User, User>('/user', parseModel: User(), method: RequestType.GET);

    expect(response.data, isNotNull);
  });
}
