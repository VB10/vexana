import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vexana/src/mixin/index.dart';
import 'package:vexana/src/model/error/file_manager_not_foud.dart';
import 'package:vexana/src/utility/network_manager_util.dart';
import 'package:vexana/vexana.dart';

/// Manage your data caching with [NetworkManagerCache]
mixin NetworkManagerCache<E extends INetworkModel<E>>
    on NetworkManagerResponse<E>, NetworkManagerParameters {
  String _urlKeyOnLocalData(RequestType type) =>
      '${baseOptions.baseUrl}-${type.stringValue}';

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

  /// Write data to database
  Future<void> writeAll(
    Duration? expiration,
    dynamic body,
    RequestType type,
  ) async {
    if (expiration == null) return;
    if (fileManager == null) throw FileManagerNotFound();
    final stringValues = await compute(jsonEncode, body);
    await fileManager!.writeUserRequestDataWithTime(
      _urlKeyOnLocalData(type),
      stringValues,
      expiration,
    );
  }

  /// Remove all data from database
  Future<bool> removeAll() async {
    if (fileManager == null) return false;
    return fileManager!.removeUserRequestCache(baseOptions.baseUrl);
  }

  Future<String?> _fetchOnlyData(RequestType type) async {
    if (fileManager == null) return null;

    final data =
        await fileManager!.getUserRequestDataOnString(_urlKeyOnLocalData(type));
    if (data is String && data.isNotEmpty) {
      return data;
    } else {
      return null;
    }
  }
}
