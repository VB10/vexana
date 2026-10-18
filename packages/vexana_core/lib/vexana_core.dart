/// Pure Dart networking core for Vexana.
///
/// Compiles without Flutter SDK (compatible with dart2js, Jaspr, and pure
/// Dart servers).
library vexana_core;

export 'package:dio/dio.dart';
export 'src/interface/index.dart';
export 'src/mixin/network_manager_parameters.dart';
export 'src/model/empty_model.dart';
export 'src/model/enum/request_type.dart';
export 'src/model/error/file_manager_not_found_exception.dart';
export 'src/model/error_model.dart';
export 'src/model/network_result.dart';
export 'src/model/response_model.dart';
export 'src/network_manager.dart';
