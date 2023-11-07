import 'package:vexana/vexana.dart';

import 'mock_parameters.dart';

final class MockNetworkManager extends NetworkManager<EmptyModel> {
  MockNetworkManager()
      : super(options: MockNetworkManagerParameters().baseOptions);
}
