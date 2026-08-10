import 'package:playground/src/model/endpoint_summary.dart';
import 'package:playground/src/model/request_metric.dart';

class SessionMetrics {
  SessionMetrics({this.slowThreshold = const Duration(milliseconds: 800)});

  final Duration slowThreshold;

  final List<RequestMetric> _entries = [];

  List<RequestMetric> get entries => List.unmodifiable(_entries);

  bool get isEmpty => _entries.isEmpty;

  void add(RequestMetric metric) => _entries.insert(0, metric);

  void clear() => _entries.clear();

  bool isSlow(RequestMetric metric) => metric.total >= slowThreshold;

  List<EndpointSummary> get summary {
    final grouped = <String, List<RequestMetric>>{};
    for (final entry in _entries) {
      grouped.putIfAbsent(entry.endpoint, () => []).add(entry);
    }

    return grouped.entries.map(_summarize).toList()
      ..sort((a, b) => b.p95.compareTo(a.p95));
  }

  EndpointSummary _summarize(MapEntry<String, List<RequestMetric>> group) {
    final durations = group.value.map((metric) => metric.total).toList()
      ..sort();

    return EndpointSummary(
      endpoint: group.key,
      count: group.value.length,
      p50: _percentile(durations, 0.50),
      p95: _percentile(durations, 0.95),
      max: durations.last,
      errorCount: group.value.where((metric) => metric.isError).length,
      cacheHitCount: group.value.where((metric) => metric.fromCache).length,
    );
  }

  static Duration _percentile(List<Duration> sorted, double fraction) {
    if (sorted.isEmpty) return Duration.zero;
    return sorted[((sorted.length - 1) * fraction).round()];
  }
}
