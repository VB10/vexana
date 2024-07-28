import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import 'common/index.dart';

void main() {
  final INetworkManager manager = MockNetworkManager();

  group('NetworkManager sendRequest tests', () {
    test('Success response parse - List', () async {
      final response = await manager.sendRequest<Post, List<Post>>(
        'posts',
        parseModel: const Post(),
        method: RequestType.GET,
      );

      expect(response.isSuccess, isTrue);
      expect(response.isError, isFalse);
      expect((response as NetworkSuccessResult).data is List<Post>, isTrue);

      final data = response.fold(
        onSuccess: (data) => data,
        onError: (_) => null,
      );

      expect(data, isNotNull);
    });

    test('Success response parse - Single', () async {
      final response = await manager.sendRequest<Post, Post>(
        'posts/1',
        parseModel: const Post(),
        method: RequestType.GET,
      );

      expect(response.isSuccess, isTrue);
      expect(response.isError, isFalse);
      expect((response as NetworkSuccessResult).data is Post, isTrue);

      final data = response.fold(
        onSuccess: (data) => data,
        onError: (_) => null,
      );

      expect(data, isNotNull);
    });

    test('Error response parse', () async {
      final response = await manager.sendRequest<Post, Post>(
        'posts',
        parseModel: const Post(),
        method: RequestType.GET,
      );

      expect(response.isError, isTrue);
      expect(response.isSuccess, isFalse);
      expect(
        (response as NetworkErrorResult).error.description,
        'JSON Decode Error ⛔',
      );

      final error = response.fold(
        onSuccess: (_) => null,
        onError: (error) => error,
      );

      expect(error, isNotNull);
    });
  });
}
