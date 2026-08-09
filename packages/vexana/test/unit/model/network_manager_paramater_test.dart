import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/mixin/index.dart';
import 'package:vexana/vexana.dart';

import '../common/mock_context.dart';

void main() {
  setUp(() {});
  test('Network Parameter is valid', () {
    final mockContext = MockBuildContext();
    final manager = NetworkManagerParameters(
      options: BaseOptions(),
      isEnableTest: true,
      isEnableLogger: true,
      noNetwork: NoNetwork(mockContext),
      noNetworkTryCount: 3,
      skippingSSLCertificate: true,
    );

    expect(manager.isEnableTest, true);
    expect(manager.isEnableLogger, true);
    expect(manager.noNetwork, isNotNull);
    expect(manager.noNetworkTryCount, 3);
    expect(manager.skippingSSLCertificate, true);
  });
}
