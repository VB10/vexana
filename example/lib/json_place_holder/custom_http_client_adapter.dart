import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

class CustomHttpClientAdapter extends HttpClientAdapter {
  final DefaultHttpClientAdapter _adapter = DefaultHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future? cancelFuture) async {
    // example for turning off SSL checking:
    _adapter.onHttpClientCreate = (HttpClient client) {
      // config the http client
      client.findProxy = (uri) {
        //proxy all request to localhost:8888 or whatever you want
        return 'PROXY localhost:8888';
      };

      // and example for turning off SSL checking:
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    return _adapter.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    _adapter.close(force: force);
  }
}
