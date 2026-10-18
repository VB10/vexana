import 'package:mockito/mockito.dart';
import 'package:vexana_core/src/mixin/index.dart';
import 'package:vexana_core/vexana_core.dart';

import './index.dart';

final class NetworkManagerResponseParseTest extends Mock
    with NetworkManagerResponse<EmptyModel>
    implements MockNetworkManagerParameters {
  INetworkManager<EmptyModel> get instance => MockNetworkManager();

  @override
  NetworkManagerParameters get parameters => MockNetworkManagerParameters();
  @override
  bool? get isEnableLogger => true;

  @override
  EmptyModel? get errorModel => const EmptyModel();
}

final class MockNetworkManager extends NetworkManager<EmptyModel> {
  MockNetworkManager()
      : super(
          options: MockNetworkManagerParameters().baseOptions,
          isEnableTest: true,
        );
}
