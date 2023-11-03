import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html';

import 'package:flutter/foundation.dart';

final class NetworkManagerUtil {
  NetworkManagerUtil._();

  static bool isRequestHasSurceased(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= HttpStatus.ok &&
        statusCode <= HttpStatus.multipleChoices;
  }

  static Future<dynamic> decodeBodyWithCompute(String body) async {
    return compute(
      jsonDecode,
      body,
    );
  }
}
