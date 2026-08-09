import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

@immutable

/// Network checker class
class NetworkCheck {
  const NetworkCheck._();

  /// Singleton instance
  static const NetworkCheck instance = NetworkCheck._();

  static const _httpStatusOk = 200;

  /// Function to check network availability
  Future<bool> isNetworkAvailable() async {
    try {
      final response = await Dio().get<dynamic>('https://www.google.com');
      return response.statusCode == _httpStatusOk;
    } catch (e) {
      return false;
    }
  }
}
