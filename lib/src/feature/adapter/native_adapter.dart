import 'package:dio/dio.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';

/// The function creates and returns an instance of the NativeAdapter class,
/// which implements the HttpClientAdapter
/// interface.
HttpClientAdapter createAdapter() => NativeAdapter();
