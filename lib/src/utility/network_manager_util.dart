import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:flutter/foundation.dart';

/// Network manager utility class for general usage
final class NetworkManagerUtil {
  NetworkManagerUtil._();

  /// status code for success check with 200 and 300
  static bool isRequestHasSurceased(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= HttpStatus.ok &&
        statusCode <= HttpStatus.multipleChoices;
  }

  /// Decode body with isolate
  static Future<dynamic> decodeBodyWithCompute(String body) async {
    return compute(
      jsonDecode,
      body,
    );
  }
}
