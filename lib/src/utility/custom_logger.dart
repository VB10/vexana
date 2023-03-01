import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

@immutable
class CustomLogger {
  final bool isEnabled;
  final String data;
  CustomLogger({
    this.isEnabled = false,
    required this.data,
  }) {
    _printError(data);
  }

  void _printError(String data) {
    if (!isEnabled) return;
    Logger().e(data);
  }
}
