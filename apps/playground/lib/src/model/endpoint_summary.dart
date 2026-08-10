import 'package:flutter/foundation.dart';

@immutable
class EndpointSummary {
  const EndpointSummary({
    required this.endpoint,
    required this.count,
    required this.p50,
    required this.p95,
    required this.max,
    required this.errorCount,
    required this.cacheHitCount,
  });

  final String endpoint;
  final int count;
  final Duration p50;
  final Duration p95;
  final Duration max;
  final int errorCount;
  final int cacheHitCount;
}
