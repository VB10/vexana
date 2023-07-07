import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

@immutable
class JsonEncodeUtil {
  const JsonEncodeUtil._();

  // This method is used to encode json data
  static dynamic safeJsonDecode(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      Logger().e('Json decode error');
      return null;
    }
  }

  static Future<dynamic> safeJsonDecodeCompute(String jsonString) async {
    try {
      return await compute<String, dynamic>(
          (message) => jsonDecode(message), jsonString);
    } catch (e) {
      Logger().e('Json decode error');
      return null;
    }
  }
}
