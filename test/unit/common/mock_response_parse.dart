import 'package:mockito/mockito.dart';
import 'package:vexana/src/mixin/index.dart';
import 'package:vexana/vexana.dart';

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
