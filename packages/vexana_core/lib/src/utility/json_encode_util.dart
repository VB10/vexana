import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:vexana_core/src/utility/compute/compute.dart';
import 'package:vexana_core/src/utility/logger/log_items.dart';

/// This class will help json encode operation with safety

@immutable
final class JsonDecodeUtil {
  const JsonDecodeUtil._();

  /// Decode your [jsonString] value or null
  static dynamic safeJsonDecode(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      LogItems.jsonDecodeError();
      return null;
    }
  }

  /// Decode your [jsonString] value or null
  static Future<dynamic> safeJsonDecodeCompute(String jsonString) async {
    try {
      return await runCompute<String, dynamic>(
        jsonDecode,
        jsonString,
      );
    } catch (e) {
      LogItems.jsonDecodeError();
      return null;
    }
  }
}
