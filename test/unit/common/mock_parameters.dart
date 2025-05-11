import 'package:mockito/mockito.dart';
import 'package:vexana/src/mixin/network_manager_parameters.dart';
import 'package:vexana/vexana.dart';

class MockNetworkManagerParameters extends Mock
    implements NetworkManagerParameters<EmptyModel, EmptyModel> {
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
    implements NetworkManagerParameters<EmptyModel, EmptyModel> {
  @override
  final BaseOptions baseOptions = BaseOptions(
    baseUrl: 'http://127.0.0.1:62052',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );
}
