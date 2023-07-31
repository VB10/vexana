import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

@immutable
class CustomLogger {
  CustomLogger({
    required this.data,
    this.isEnabled = false,
  }) {
    _printError(data);
  }
  final bool isEnabled;
  final String data;

  void _printError(String data) {
    if (!isEnabled) return;
    Logger().e('Error ⛔', error: data);
  }
}
