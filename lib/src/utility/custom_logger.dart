import 'package:logger/logger.dart';

class CustomLogger {
  bool? isEnabled;
  final Logger _logger = Logger();
  CustomLogger({
    required this.isEnabled,
  });

  void printError(String data) {
    if (isEnabled ?? false) {
      _logger.e(data);
    }
    return;
  }
}
