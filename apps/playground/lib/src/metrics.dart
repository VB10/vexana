import 'package:vexana/vexana.dart';

/// Tek bir isteğin ölçümü.
class RequestMetric {
  RequestMetric({
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

  /// `sendRequest` çağrısının tamamı — ağ + parse + vexana ek yükü.
  final Duration total;

  /// Interceptor'ın ölçtüğü saf ağ süresi.
  ///
  /// Cache'ten dönen isteklerde `null` olur, çünkü hiç HTTP isteği çıkmaz.
  final Duration? network;

  final int? statusCode;
  final int? bytes;
  final String? errorType;
  final bool fromCache;

  /// Ağ dışında geçen süre: JSON parse + model map'leme + vexana ek yükü.
  ///
  /// Bu sütun vexana'nın rakiplerinde yok: Alice, dio_logger, Charles ağ
  /// süresini gösterir ama parse'ı onlar yapmadığı için ölçemez.
  Duration? get parseAndOverhead {
    final networkTime = network;
    if (networkTime == null) return null;
    final delta = total - networkTime;
    return delta.isNegative ? Duration.zero : delta;
  }

  bool get isError => errorType != null;
}

/// Ağ süresini ölçen interceptor.
///
/// Bu prototip **ağ süresini** ölçebiliyor ama **parse süresini** ölçemiyor:
/// parse, interceptor zinciri bittikten sonra vexana'nın içinde çalışıyor.
/// Playground bu farkı `total - network` ile tahmin ediyor. Gerçek ayrım için
/// hook'un çekirdekte olması gerekiyor — planın `NetworkObserver`'ı bu yüzden var.
class MetricsInterceptor extends Interceptor {
  MetricsInterceptor(this.onNetworkTime);

  /// (istek anahtarı, ağ süresi, statusCode, gövde boyutu, hata tipi)
  final void Function(
    String key,
    Duration elapsed,
    int? statusCode,
    int? bytes,
    String? errorType,
  ) onNetworkTime;

  static const _startKey = '_playground_start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().microsecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _report(
      response.requestOptions,
      response.statusCode,
      _sizeOf(response),
      null,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _report(
      err.requestOptions,
      err.response?.statusCode,
      err.response == null ? null : _sizeOf(err.response!),
      err.type.name,
    );
    handler.next(err);
  }

  void _report(
    RequestOptions options,
    int? statusCode,
    int? bytes,
    String? errorType,
  ) {
    final started = options.extra[_startKey];
    if (started is! int) return;
    final elapsed = Duration(
      microseconds: DateTime.now().microsecondsSinceEpoch - started,
    );
    onNetworkTime(
      '${options.method} ${options.path}',
      elapsed,
      statusCode,
      bytes,
      errorType,
    );
  }

  int? _sizeOf(Response<dynamic> response) {
    final headerLength = response.headers.value(Headers.contentLengthHeader);
    if (headerLength != null) return int.tryParse(headerLength);
    final data = response.data;
    if (data is String) return data.length;
    return null;
  }
}

/// Oturum boyunca biriken ölçümler ve özet.
class SessionMetrics {
  SessionMetrics({this.slowThreshold = const Duration(milliseconds: 800)});

  final Duration slowThreshold;
  final List<RequestMetric> entries = [];

  void add(RequestMetric metric) => entries.insert(0, metric);

  void clear() => entries.clear();

  bool isSlow(RequestMetric metric) => metric.total >= slowThreshold;

  /// Endpoint bazlı özet — p50/p95 için sıralı süre listesi tutulur.
  List<EndpointSummary> get summary {
    final grouped = <String, List<RequestMetric>>{};
    for (final entry in entries) {
      grouped.putIfAbsent('${entry.method} ${entry.path}', () => []).add(entry);
    }

    final result = grouped.entries.map((group) {
      final durations = group.value.map((e) => e.total).toList()..sort();
      return EndpointSummary(
        endpoint: group.key,
        count: group.value.length,
        p50: _percentile(durations, 0.50),
        p95: _percentile(durations, 0.95),
        max: durations.last,
        errorCount: group.value.where((e) => e.isError).length,
        cacheHitCount: group.value.where((e) => e.fromCache).length,
      );
    }).toList()
      ..sort((a, b) => b.p95.compareTo(a.p95));

    return result;
  }

  static Duration _percentile(List<Duration> sorted, double fraction) {
    if (sorted.isEmpty) return Duration.zero;
    final index = ((sorted.length - 1) * fraction).round();
    return sorted[index];
  }
}

/// Bir endpoint'in oturum özeti.
class EndpointSummary {
  EndpointSummary({
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
