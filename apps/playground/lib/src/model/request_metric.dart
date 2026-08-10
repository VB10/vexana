import 'package:flutter/foundation.dart';

@immutable
class RequestMetric {
  const RequestMetric({
    required this.method,
    required this.path,
    required this.total,
    this.network,
    this.statusCode,
    this.bytes,
    this.errorType,
    this.fromCache = false,
  });

  final String method;
  final String path;
  final Duration total;
  final Duration? network;
  final int? statusCode;
  final int? bytes;
  final String? errorType;
  final bool fromCache;

  String get endpoint => '$method $path';

  bool get isError => errorType != null;

  Duration? get parseAndOverhead {
    final networkTime = network;
    if (networkTime == null) return null;

    final delta = total - networkTime;
    return delta.isNegative ? Duration.zero : delta;
  }
}
