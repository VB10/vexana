import 'package:flutter/foundation.dart';
import 'package:vexana/src/feature/logger/logger_io.dart'
    if (dart.library.html) '../feature/logger/logger_web.dart' as logger;

@immutable

/// Custom logger for Vexana
/// If you want to use it, you must set isEnableLogger true
/// Default value is false
/// ```dart
final class CustomLogger {
  /// data: Error message
  /// isEnabled: Default value is false
  const CustomLogger({
    required String? data,
    required bool? isEnabled,
  })  : _data = data ?? '',
        _isEnabled = isEnabled ?? false;

  final bool _isEnabled;
  final String _data;

  /// Print error message
  void printError() {
    if (!_isEnabled) return;
    if (!kDebugMode) return;
    logger.Logger().makeError('Error ⛔', error: _data);
  }
}
