// ignore_for_file: avoid_print

import 'package:vexana_core/vexana_core.dart';

import 'mock_parameters.dart';

final class MockErrorNetworkManager extends NetworkManager<EmptyModel> {
  MockErrorNetworkManager()
      : super(
          options: MockNetworkManagerLocalParameters().baseOptions,
          isEnableTest: true,
        );
}

final class MockErrorCustomNetworkManager extends NetworkManager<EmptyModel> {
  MockErrorCustomNetworkManager(
    String baseUrl,
    Future<void> Function() onRefresh,
  ) : super(
          options: BaseOptions(baseUrl: baseUrl),
          isEnableTest: true,
          maxRetryCount: 5,
          onRefreshFail: () => print('onRefreshFail Triggered'),
          onRefreshToken: (e, networkManager) async {
            await onRefresh.call();
            return e;
          },
        );
}
