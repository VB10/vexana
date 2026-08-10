import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/src/utility/json_encode_util.dart';

void main() {
  setUp(() {});
  group('JsonDecodeUtil Tests', () {
    test('safeJsonDecode with valid JSON string', () {
      const jsonString = '{"name": "John", "age": 30}';
      final result = JsonDecodeUtil.safeJsonDecode(jsonString);
      expect(result, isA<Map<String, dynamic>>());
      final resultMap = result as Map<String, dynamic>;
      expect(resultMap['name'], 'John');
      expect(resultMap['age'], 30);
    });

    test('safeJsonDecode with invalid JSON string', () {
      const jsonString = 'invalid json';
      final result = JsonDecodeUtil.safeJsonDecode(jsonString);
      expect(result, isNull);
    });

    test('safeJsonDecode with empty JSON string', () {
      const jsonString = '';
      final result = JsonDecodeUtil.safeJsonDecode(jsonString);
      expect(result, isNull);
    });

    test('safeJsonDecodeCompute with valid JSON string', () async {
      const jsonString = '{"name": "John", "age": 30}';
      final result = await JsonDecodeUtil.safeJsonDecodeCompute(jsonString);
      expect(result, isA<Map<String, dynamic>>());
      final resultMap = result as Map<String, dynamic>;

      expect(resultMap['name'], 'John');
      expect(resultMap['age'], 30);
    });

    // Repeat similar tests for safeJsonDecodeCompute
  });
}
