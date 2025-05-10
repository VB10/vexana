import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vexana/src/mixin/index.dart';
import 'package:vexana/src/model/error/file_manager_not_foud_exception.dart';
import 'package:vexana/src/utility/extension/request_type_extension.dart';
import 'package:vexana/src/utility/network_manager_util.dart';
import 'package:vexana/vexana.dart';

/// Manage your data caching with [NetworkManagerCache]
mixin NetworkManagerCache<E extends INetworkModel<E>, P>
    on NetworkManagerResponse<E, P> {
  @override
  NetworkManagerParameters<E, P> get parameters;

  String _urlKeyOnLocalData(RequestType type) =>
      '${parameters.baseOptions.baseUrl}-${type.stringValue}';

  /// Fetch data from database
  Future<ResponseModel<R?, E>?>
      fetchDataFromCache<R, T extends INetworkModel<T>>({
    required Duration? expiration,
    required RequestType type,
    required T responseModel,
  }) async {
    if (expiration == null) return null;
    final cacheDataString = await _fetchOnlyData(type);
    if (cacheDataString == null) return null;

    final model = parseUserResponseData<R, T>(
      NetworkManagerUtil.decodeBodyWithCompute(cacheDataString),
      responseModel,
    );

    return ResponseModel<R, E>(
      data: model,
      error: model == null ? ErrorModel.parseError() : null,
    );
  }

  /// The loadFromCache method retrieves data from the cache based on the
  /// request type and expiration duration. If the data is found and not
  /// expired, it parses the data into the specified model and returns a
  /// success result. If the data is not found or is expired,
  /// it returns null or an error result.
  Future<NetworkResult<R, E>?> loadFromCache<R, T extends INetworkModel<T>>({
    required Duration? expiration,
    required RequestType type,
    required T responseModel,
  }) async {
    if (expiration == null) return null;
    final cacheDataString = await _fetchOnlyData(type);
    if (cacheDataString == null) return null;

    final model = parseUserResponseData<R, T>(
      NetworkManagerUtil.decodeBodyWithCompute(cacheDataString),
      responseModel,
    );

    if (model is R) return NetworkSuccessResult(model);
    final error = ErrorModel<E>.parseError();
    return NetworkErrorResult(error);
  }

  /// Write data to database
  Future<void> writeAll(
    Duration? expiration,
    dynamic body,
    RequestType type,
  ) async {
    if (expiration == null) return;
    if (parameters.fileManager == null) throw FileManagerNotFoundException();
    final stringValues = await compute(jsonEncode, body);
    await parameters.fileManager!.writeUserRequestDataWithTime(
      _urlKeyOnLocalData(type),
      stringValues,
      expiration,
    );
  }

  /// Remove all data from database
  Future<bool> removeAll() async {
    if (parameters.fileManager == null) return false;
    return parameters.fileManager!
        .removeUserRequestCache(parameters.baseOptions.baseUrl);
  }

  Future<String?> _fetchOnlyData(RequestType type) async {
    if (parameters.fileManager == null) return null;

    final data = await parameters.fileManager!
        .getUserRequestDataOnString(_urlKeyOnLocalData(type));
    if (data is String && data.isNotEmpty) {
      return data;
    } else {
      return null;
    }
  }
}
