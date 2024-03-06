import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import '../unit/common/mock_context.dart';

void main() {
  group('NoNetworkManager Tests', () {
    testWidgets('should not show modal when isEnable is false',
        (WidgetTester tester) async {
      // Setup

      final mockContext = MockBuildContext();
      final model = NoNetwork(
        mockContext,
        customNoNetwork: (onRetry) {
          return const Text('test');
        },
      );

      expect(model.customNoNetwork!.call(() {}).runtimeType, Text);
      final noNetworkManager = NoNetworkManager(
        context: mockContext,
        customNoNetworkWidget: (onRetry) {
          return const Text('test');
        },
        onRetry: () {},
      );

      expect(noNetworkManager.isEnable, false);
      expect(noNetworkManager.customNoNetworkWidget, isNotNull);

      expect(noNetworkManager.onRetry, isNotNull);
      // Execute
      await noNetworkManager.show();

      expect(find.byType(Text), findsOneWidget);
      // Verify
    });
  });
}
