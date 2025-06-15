import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// The current server instance.
HttpServer? _server;

Encoding requiredEncodingForCharset(String charset) =>
    Encoding.getByName(charset) ??
    (throw FormatException('Unsupported encoding "$charset".'));

/// The URL for the current server instance.
Uri get serverUrl => Uri.parse('http://localhost:${_server?.port}');

const isWeb = bool.hasEnvironment('dart.library.js_util')
    ? bool.fromEnvironment('dart.library.js_util')
    : identical(0, 0.0);

/// Starts a new HTTP server.
Future<void> startServer() async {
  _server = (await HttpServer.bind('localhost', 0))
    ..listen((request) async {
      final path = request.uri.path;
      final response = request.response;

      return switch (path) {
        '/error' => () async {
            final content = path;
            response
              ..statusCode = 400
              ..contentLength = content.length
              ..write(content);
            await response.close();
          }(),
        '/loop' => () async {
            final n = int.parse(request.uri.query);
            response
              ..statusCode = 302
              ..headers.set(
                'location',
                serverUrl.resolve('/loop?${n + 1}').toString(),
              )
              ..contentLength = 0;
            await response.close();
          }(),
        '/unAuthorized' => () async {
            if (request.headers['Authorization'] != null) {
              response
                ..statusCode = 200
                ..write('vb work');
              await response.close();
              return;
            }
            response
              ..statusCode = 401
              ..write('vb work');
            await response.close();
            return;
          }(),
        '/test' => () async {
            response
              ..statusCode = 200
              ..write('success');
            await response.close();
          }(),
        '/redirect' => () async {
            response
              ..statusCode = 302
              ..headers.set('location', serverUrl.resolve('/').toString())
              ..contentLength = 0;
            await response.close();
          }(),
        '/no-content-length' => () async {
            response
              ..statusCode = 200
              ..contentLength = -1
              ..write('body');
            await response.close();
          }(),
        '/list' => () async {
            response.headers.contentType = ContentType('application', 'json');
            response
              ..statusCode = 200
              ..contentLength = -1
              ..write('[1,2,3]');
            await response.close();
          }(),
        '/multi-value-header' => () async {
            response.headers.contentType = ContentType('application', 'json');
            response.headers.add(
              'x-multi-value-request-header-echo',
              request.headers.value('x-multi-value-request-header').toString(),
            );
            response
              ..statusCode = 200
              ..contentLength = -1
              ..write('');
            await response.close();
          }(),
        '/download' => () async {
            const content = 'I am a text file';
            response.headers.set('content-encoding', 'plain');
            response
              ..statusCode = 200
              ..contentLength = content.length
              ..write(content);
            Future.delayed(const Duration(milliseconds: 300), response.close);
          }(),
        _ => () async {}(),
      };
    });
}

/// Stops the current HTTP server.
void stopServer() {
  if (_server != null) {
    _server!.close();
    _server = null;
  }
}

/// A matcher for functions that throw SocketException.
final Matcher throwsSocketException =
    throwsA(const TypeMatcher<SocketException>());

/// A matcher for functions that throw DioException of type connectionError.
final Matcher throwsDioExceptionConnectionError = throwsA(
  allOf([
    isA<DioException>(),
    (DioException e) => e.type == DioExceptionType.connectionError,
  ]),
);

/// A stream of chunks of bytes representing a single piece of data.
class ByteStream extends StreamView<List<int>> {
  ByteStream(super.stream);

  /// Returns a single-subscription byte stream that will emit the given bytes
  /// in a single chunk.
  factory ByteStream.fromBytes(List<int> bytes) =>
      ByteStream(Stream.fromIterable([bytes]));

  /// Collects the data of this stream in a [Uint8List].
  Future<Uint8List> toBytes() {
    final completer = Completer<Uint8List>();
    final sink = ByteConversionSink.withCallback(
      (bytes) => completer.complete(Uint8List.fromList(bytes)),
    );
    listen(
      sink.add,
      onError: completer.completeError,
      onDone: sink.close,
      cancelOnError: true,
    );
    return completer.future;
  }

  /// Collect the data of this stream in a [String], decoded according to
  /// [encoding], which defaults to `UTF8`.
  Future<String> bytesToString([Encoding encoding = utf8]) =>
      encoding.decodeStream(this);

  Stream<String> toStringStream([Encoding encoding = utf8]) =>
      encoding.decoder.bind(this);
}
