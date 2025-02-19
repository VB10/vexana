// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import '../utils/utils.dart';
import 'common/mock_network_manager.dart';

void main() {
  test('401 error test', () async {
    await startServer();
    var retryCount = 0;
    late MockErrorCustomNetworkManager errorNetworkManager;
    errorNetworkManager = MockErrorCustomNetworkManager(
      serverUrl.toString(),
      () async => retryCount++,
    );

    final response = await errorNetworkManager.send<EmptyModel, EmptyModel>(
      '/unAuthorized',
      parseModel: EmptyModel(),
      method: RequestType.GET,
    );
    stopServer();
    expect(retryCount, 5);
    expect(response.error?.statusCode, 401);
  });

  test('401 error test with parallel requests', () async {
    await startServer();
    late MockErrorCustomNetworkManager errorNetworkManager;
    var retryCount = 0;
    errorNetworkManager = MockErrorCustomNetworkManager(
      serverUrl.toString(),
      () async => retryCount++,
    );

    final cancelToken = CancelToken();
    await Future.wait<void>([
      errorNetworkManager.send<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        cancelToken: cancelToken,
        method: RequestType.GET,
      ),
      errorNetworkManager.send<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        cancelToken: cancelToken,
        method: RequestType.GET,
      ),
      errorNetworkManager.send<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        cancelToken: cancelToken,
        method: RequestType.GET,
      ),
    ]);
    stopServer();
    expect(retryCount, 5);
    expect(cancelToken.isCancelled, true);
  });

  test('401 error with refreshing', () async {
    await startServer();
    late MockErrorCustomNetworkManager errorNetworkManager;
    errorNetworkManager = MockErrorCustomNetworkManager(
      serverUrl.toString(),
      () async => _Helpers._addTokenOnRefresh(errorNetworkManager),
    );
    final response = await errorNetworkManager.send<EmptyModel, EmptyModel>(
      '/unAuthorized',
      parseModel: EmptyModel(),
      method: RequestType.GET,
    );
    stopServer();
    expect(response.data.runtimeType, EmptyModel);
  });

  test('401 error with parallel request and refreshing', () async {
    await startServer();
    late MockErrorCustomNetworkManager errorNetworkManager;
    errorNetworkManager = MockErrorCustomNetworkManager(
      serverUrl.toString(),
      () async => _Helpers._addTokenOnRefresh(errorNetworkManager),
    );
    final responses =
        await Future.wait<IResponseModel<EmptyModel?, EmptyModel?>>(
      [
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
      ],
    );
    stopServer();
    expect(responses.every((element) => element.error == null), true);
    expect(
      responses.every((element) => element.data.runtimeType == EmptyModel),
      true,
    );
  });
}

class _Helpers {
  static Future<void> _addTokenOnRefresh(
      NetworkManager<EmptyModel> manager) async {
    manager.options.headers.addEntries(
      [
        const MapEntry('Authorization', "New Token"),
      ],
    );
  }
}
