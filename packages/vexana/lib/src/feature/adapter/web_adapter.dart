import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// The function creates and returns an instance of the BrowserHttpClientAdapter
/// class, which implements the HttpClientAdapter
/// interface.
HttpClientAdapter createAdapter({bool isEnableTest = false}) {
  final adapter = HttpClientAdapter() as BrowserHttpClientAdapter;
  adapter.withCredentials = true;
  return adapter;
}
