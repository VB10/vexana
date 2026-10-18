import 'dart:convert';

import 'package:vexana_core/src/utility/compute/compute.dart';
import 'package:vexana_core/src/utility/http_status.dart';

/// Network manager utility class for general usage
final class NetworkManagerUtil {
  const NetworkManagerUtil._();

  /// status code for success check with 200 and 300
  static bool isRequestSucceeded(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= HttpStatus.ok &&
        statusCode <= HttpStatus.multipleChoices;
  }

  /// Decode body with isolate
  static Future<dynamic> decodeBodyWithCompute(String body) async {
    return runCompute(
      jsonDecode,
      body,
    );
  }
}
