/// Custom logger for web
final class Logger {
  /// Print error message
  void makeError(String message, {Object? error}) {
    if (error != null) {
      // ignore: avoid_print
      print('$message: $error');
    } else {
      // ignore: avoid_print
      print(message);
    }
  }
}
