import 'package:dio/adapter_browser.dart';
import 'package:dio/dio.dart';

HttpClientAdapter get dioAdapter => BrowserHttpClientAdapter();
