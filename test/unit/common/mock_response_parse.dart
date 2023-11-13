import 'package:mockito/mockito.dart';
import 'package:vexana/src/mixin/index.dart';
import 'package:vexana/vexana.dart';

import './index.dart';

final class NetworkManagerResponseParseTest extends Mock
    implements
        MockNetworkManagerParameters,
        NetworkManagerResponse<EmptyModel> {
  @override
  INetworkManager<EmptyModel> get instance => MockNetworkManager();

  @override
  EmptyModel? get errorModel => EmptyModel();
}
