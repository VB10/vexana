import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/mixin/index.dart';

import 'common/mock_parameters.dart';

final class NetworkManagerHeaderTest extends MockNetworkManagerParameters
    with NetworkManagerOperation {}

void main() {
  final testClass = NetworkManagerHeaderTest();

  group('NetworkManagerOperation Tests', () {
    test('addBaseHeader should add header', () {
      testClass.addBaseHeader(const MapEntry('vb10', '10'));
      expect(testClass.allHeaders.values, isNotEmpty);
    });

    test('clearHeader should clear headers', () {
      testClass.addBaseHeader(const MapEntry('key', 'value'));
      testClass.clearHeader();
      expect(testClass.allHeaders.isEmpty, true);
    });

    test('removeHeader should remove specific header', () {
      // Header ekleyin
      testClass.addBaseHeader(const MapEntry('key', 'value'));
      // Belirli bir header'ı kaldırın
      testClass.removeHeader('key');
      // Header'ın kaldırıldığını doğrulayın
      expect(testClass.allHeaders.containsKey('key'), false);
    });
  });
}
