import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import '../utils/utils.dart';
import 'common/mock_network_manager.dart';

void main() {
  test('401 error test', () async {
    await startServer();
    late MockErrorCustomNetworkManager errorNetworkManager;
    errorNetworkManager = MockErrorCustomNetworkManager(
      serverUrl.toString(),
      () {
        errorNetworkManager.addBaseHeader(const MapEntry('vb10', 'vv'));
      },
    );

    await Future.wait([
      errorNetworkManager.send<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        method: RequestType.GET,
      ),
      errorNetworkManager.send<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        method: RequestType.GET,
      ),
      errorNetworkManager.send<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        method: RequestType.GET,
      ),
    ]);

    final response = await errorNetworkManager.send<EmptyModel, EmptyModel>(
      '/unAuthorized',
      parseModel: EmptyModel(),
      method: RequestType.GET,
    );

    expect(response.data, isNotNull);
  });
}
