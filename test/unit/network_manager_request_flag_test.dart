// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

import '../utils/utils.dart';

void main() {
  group('RequestFlag Tests', () {
    late NetworkManager<EmptyModel> networkManager;
    late int refreshTokenCallCount;

    setUp(() async {
      await startServer();
      refreshTokenCallCount = 0;
      
      networkManager = NetworkManager<EmptyModel>(
        options: BaseOptions(baseUrl: serverUrl.toString()),
        isEnableTest: true,
        maxRetryCount: 3,
        onRefreshFail: () => print('onRefreshFail Triggered'),
        onRefreshToken: (error, networkManager) async {
          refreshTokenCallCount++;
          print('Refresh token called. Count: $refreshTokenCallCount');
          
          // Simulate successful token refresh by adding new Authorization header
          error.requestOptions.headers['Authorization'] = 'Bearer new_token_$refreshTokenCallCount';
          
          return error;
        },
      );
    });

    tearDown(() {
      stopServer();
    });

    test('401 error without disableRefreshToken flag should trigger refresh token', () async {
      // Make request without disableRefreshToken flag
      final response = await networkManager.send<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        method: RequestType.GET,
      );

      // Refresh token should be called
      expect(refreshTokenCallCount, greaterThan(0));
      
      // Request should succeed after refresh
      expect(response.data, isNotNull);
      expect(response.error, isNull);
      
      print('Test passed: Refresh token was triggered $refreshTokenCallCount times');
    });

    test('401 error with disableRefreshToken flag should NOT trigger refresh token', () async {
      // Make request with disableRefreshToken flag
      final response = await networkManager.send<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        method: RequestType.GET,
        requestFlags: {RequestFlag.disableRefreshToken},
      );

      // Refresh token should NOT be called
      expect(refreshTokenCallCount, equals(0));
      
      // Request should fail with 401 error
      expect(response.data, isNull);
      expect(response.error, isNotNull);
      expect(response.error?.statusCode, equals(401));
      
      print('Test passed: Refresh token was NOT triggered, error status: ${response.error?.statusCode}');
    });

    test('Successful request with disableRefreshToken flag should work normally', () async {
      // Make successful request with disableRefreshToken flag
      final response = await networkManager.send<EmptyModel, EmptyModel>(
        '/test',
        parseModel: EmptyModel(),
        method: RequestType.GET,
        requestFlags: {RequestFlag.disableRefreshToken},
      );

      // Refresh token should NOT be called (because request was successful)
      expect(refreshTokenCallCount, equals(0));
      
      // Request should succeed
      expect(response.data, isNotNull);
      expect(response.error, isNull);
      
      print('Test passed: Successful request with disableRefreshToken flag worked normally');
    });

    test('Multiple requests with mixed flags should behave correctly', () async {
      // Reset counter
      refreshTokenCallCount = 0;
      
      // Make one request without flag (should trigger refresh)
      final response1 = await networkManager.send<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        method: RequestType.GET,
      );
      
      final firstRefreshCount = refreshTokenCallCount;
      
      // Make another request with flag (should NOT trigger refresh)
      final response2 = await networkManager.send<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        method: RequestType.GET,
        requestFlags: {RequestFlag.disableRefreshToken},
      );

      // First request should trigger refresh
      expect(firstRefreshCount, greaterThan(0));
      expect(response1.data, isNotNull);
      expect(response1.error, isNull);
      
      // Second request should NOT trigger additional refresh calls
      expect(refreshTokenCallCount, equals(firstRefreshCount));
      expect(response2.data, isNull);
      expect(response2.error, isNotNull);
      expect(response2.error?.statusCode, equals(401));
      
      print('Test passed: Mixed flag behavior worked correctly. Total refresh calls: $refreshTokenCallCount');
    });

    test('sendRequest method should also respect disableRefreshToken flag', () async {
      // Reset counter
      refreshTokenCallCount = 0;
      
      // Make request using sendRequest method with disableRefreshToken flag
      final response = await networkManager.sendRequest<EmptyModel, EmptyModel>(
        '/unAuthorized',
        parseModel: EmptyModel(),
        method: RequestType.GET,
        requestFlags: {RequestFlag.disableRefreshToken},
      );

      // Refresh token should NOT be called
      expect(refreshTokenCallCount, equals(0));
      
      // Request should fail with 401 error
      expect(response.isError, isTrue);
      expect(response.isSuccess, isFalse);
      
      response.fold(
        onSuccess: (data) {
          fail('Expected error but got success');
        },
        onError: (error) {
          expect(error.statusCode, equals(401));
        },
      );
      
      print('Test passed: sendRequest method with disableRefreshToken flag worked correctly');
    });
  });

  group('RequestFlag Extension Tests', () {
    test('RequestFlag set should correctly identify disableRefreshToken', () {
      final flags1 = <RequestFlag>{RequestFlag.disableRefreshToken};
      expect(flags1.shouldDisableRefreshToken, isTrue);
      
      final flags2 = <RequestFlag>{};
      expect(flags2.shouldDisableRefreshToken, isFalse);
      
      print('Test passed: RequestFlag extension methods work correctly');
    });

    test('RequestFlag set should convert to and from extra map correctly', () {
      final originalFlags = <RequestFlag>{RequestFlag.disableRefreshToken};
      
      // Convert to extra map
      final extraMap = originalFlags.toExtraMap();
      expect(extraMap, isNotEmpty);
      expect(extraMap['_flag_disableRefreshToken'], isTrue);
      
      // Convert back from extra map
      final convertedFlags = RequestFlagExtension.fromExtraMap(extraMap);
      expect(convertedFlags, equals(originalFlags));
      expect(convertedFlags.shouldDisableRefreshToken, isTrue);
      
      print('Test passed: RequestFlag conversion methods work correctly');
    });

    test('Empty RequestFlag set should handle conversion correctly', () {
      final emptyFlags = <RequestFlag>{};
      
      // Convert to extra map
      final extraMap = emptyFlags.toExtraMap();
      expect(extraMap, isEmpty);
      
      // Convert back from extra map
      final convertedFlags = RequestFlagExtension.fromExtraMap(extraMap);
      expect(convertedFlags, isEmpty);
      expect(convertedFlags.shouldDisableRefreshToken, isFalse);
      
      print('Test passed: Empty RequestFlag set conversion works correctly');
    });

    test('Null extra map should return empty RequestFlag set', () {
      final convertedFlags = RequestFlagExtension.fromExtraMap(null);
      expect(convertedFlags, isEmpty);
      expect(convertedFlags.shouldDisableRefreshToken, isFalse);
      
      print('Test passed: Null extra map handling works correctly');
    });
  });
}
