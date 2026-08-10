import 'package:flutter/foundation.dart';
import 'package:playground/src/model/endpoint.dart';
import 'package:playground/src/model/request_metric.dart';
import 'package:vexana/vexana.dart';

@immutable
class NetworkSample {
  const NetworkSample({
    this.elapsed,
    this.statusCode,
    this.bytes,
    this.errorType,
  });

  static const NetworkSample empty = NetworkSample();

  final Duration? elapsed;
  final int? statusCode;
  final int? bytes;
  final String? errorType;

  bool get isCacheHit => elapsed == null && errorType == null;

  RequestMetric toMetric({
    required Endpoint endpoint,
    required Duration total,
  }) {
    return RequestMetric(
      method: endpoint.methodLabel,
      path: endpoint.path,
      total: total,
      network: elapsed,
      statusCode: statusCode,
      bytes: bytes,
      errorType: errorType,
      fromCache: isCacheHit,
    );
  }
}

class MetricsInterceptor extends Interceptor {
  MetricsInterceptor(this.onSample);

  final ValueChanged<NetworkSample> onSample;

  static const String _startedAtKey = '_playground_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = DateTime.now().microsecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _emit(response.requestOptions, response.statusCode, _sizeOf(response));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    _emit(
      err.requestOptions,
      response?.statusCode,
      response == null ? null : _sizeOf(response),
      errorType: err.type.name,
    );
    handler.next(err);
  }

  void _emit(
    RequestOptions options,
    int? statusCode,
    int? bytes, {
    String? errorType,
  }) {
    final startedAt = options.extra[_startedAtKey];
    if (startedAt is! int) return;

    onSample(
      NetworkSample(
        elapsed: Duration(
          microseconds: DateTime.now().microsecondsSinceEpoch - startedAt,
        ),
        statusCode: statusCode,
        bytes: bytes,
        errorType: errorType,
      ),
    );
  }

  int? _sizeOf(Response<dynamic> response) {
    final headerLength = response.headers.value(Headers.contentLengthHeader);
    if (headerLength != null) return int.tryParse(headerLength);

    final data = response.data;
    return data is String ? data.length : null;
  }
}
