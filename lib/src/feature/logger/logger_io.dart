import 'package:logger/logger.dart' as log;

/// Custom logger for io
final class Logger {
  /// Print error message
  void makeError(String message, {Object? error}) {
    log.Logger().e(message, error: error);
  }
}
