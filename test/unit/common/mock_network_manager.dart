// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:vexana/vexana.dart';

import 'mock_parameters.dart';

final class MockErrorNetworkManager
    extends NetworkManager<EmptyModel, EmptyModel> {
  MockErrorNetworkManager()
      : super(
          options: MockNetworkManagerLocalParameters().baseOptions,
          isEnableTest: true,
        );
}

final class MockErrorCustomNetworkManager
    extends NetworkManager<EmptyModel, EmptyModel> {
  MockErrorCustomNetworkManager(String baseUrl, AsyncCallback onRefresh)
      : super(
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
