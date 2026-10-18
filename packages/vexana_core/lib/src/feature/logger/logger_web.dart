import 'package:flutter/foundation.dart';

/// Custom logger for io
final class Logger {
  /// Print error message
  void makeError(String message, {Object? error}) {
    if (kDebugMode) print(message);
  }
}
