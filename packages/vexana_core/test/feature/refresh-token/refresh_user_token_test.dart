import 'package:test/test.dart';
import 'package:vexana_core/vexana_core.dart';

import 'user.dart';

void main() {
  late INetworkManager<EmptyModel> networkManager;

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

  test('Json Place Holder Todos', skip: 'needs a local server on :3000',
      () async {
    final response = await networkManager.send<User, User>(
      '/user',
      parseModel: User(),
      method: RequestType.GET,
    );

    expect(response.data, isNotNull);
  });
}
