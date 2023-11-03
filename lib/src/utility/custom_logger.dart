import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

@immutable
class CustomLogger {
  const CustomLogger({
    required this.data,
    this.isEnabled = false,
  });
  final bool isEnabled;
  final String data;

  void printError() {
    if (!isEnabled) return;
    Logger().e('Error ⛔', error: data);
  }
}
