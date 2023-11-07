import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

@immutable

/// Custom logger for Vexana
/// If you want to use it, you must set isEnableLogger true
/// Default value is false
/// ```dart
class CustomLogger {
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
    Logger().e('Error ⛔', error: _data);
  }
}
