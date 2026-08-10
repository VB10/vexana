import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/feature/network_check/network_check.dart';

void main() {
  const networkCheck = NetworkCheck.instance;
  setUp(() {});
  test('Network Check is done', () async {
    final response = await networkCheck.isNetworkAvailable();
    expect(response, true);
  });
}
