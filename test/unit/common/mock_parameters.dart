import 'package:mockito/mockito.dart';
import 'package:vexana/src/mixin/network_manager_parameters.dart';
import 'package:vexana/vexana.dart';

class MockNetworkManagerParameters extends Mock
    implements NetworkManagerParameters {
  @override
  final BaseOptions baseOptions = BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com/',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );
}
