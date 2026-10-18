import 'package:mockito/mockito.dart';
import 'package:vexana_core/vexana_core.dart';

class MockNetworkManagerParameters extends Mock
    implements NetworkManagerParameters {
  @override
  bool? get isEnableLogger => true;
  @override
  final BaseOptions baseOptions = BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com/',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );
}

class MockNetworkManagerLocalParameters extends Mock
    implements NetworkManagerParameters {
  @override
  final BaseOptions baseOptions = BaseOptions(
    baseUrl: 'http://127.0.0.1:62052',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );
}
