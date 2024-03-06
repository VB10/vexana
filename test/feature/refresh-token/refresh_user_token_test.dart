import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'user.dart';

// ignore: always_declare_return_types
void main() {
  late INetworkManager<EmptyModel> networkManager;
  const isServiceOn = false;

  setUp(() {
    networkManager = NetworkManager<EmptyModel>(
      isEnableLogger: true,
      isEnableTest: true,
      // onRefreshFail: () {  Navigate to login },
      onRefreshToken: (error, newService) async {
        // final refreshToken = await newService.send<Credential, Credential>("/token",
        //     parseModel: Credential(), method: RequestType.GET);
        // error.request.headers = {HttpHeaders.authorizationHeader: "Bearer ${refreshToken.data.token}"};
        return error;
      },
      options: BaseOptions(baseUrl: 'http://localhost:3000'),
    );
  });

  test('Json Place Holder Todos', () async {
    if (!isServiceOn) return;

    final response = await networkManager.send<User, User>(
      '/user',
      parseModel: User(),
      method: RequestType.GET,
    );

    expect(response.data, isNotNull);
  });
}
