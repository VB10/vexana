import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

HttpClientAdapter createAdapter({bool isEnableTest = false}) =>
    BrowserHttpClientAdapter();