import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// The function creates and returns an instance of the NativeAdapter class,
/// which implements the HttpClientAdapter
/// interface.
HttpClientAdapter createAdapter() => IOHttpClientAdapter();
