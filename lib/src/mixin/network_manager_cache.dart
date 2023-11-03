import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vexana/src/mixin/network_manager_model_response.dart';
import 'package:vexana/src/mixin/network_manager_paramaters.dart';
import 'package:vexana/src/model/error/file_manager_not_foud.dart';
import 'package:vexana/src/utility/network_manager_util.dart';
import 'package:vexana/vexana.dart';

mixin NetworkManagerCache<E extends INetworkModel<E>>
    on NetworkManagerModelResponse<E>, NetworkManagerParameters {
  String _urlKeyOnLocalData(RequestType type) =>
      '${baseOptions.baseUrl}-${type.stringValue}';

  Future<ResponseModel<R?, E>?>
      fetchDataFromCache<R, T extends INetworkModel<T>>(
    Duration? expiration,
    RequestType type,
    T responseModel,
  ) async {
    if (expiration == null) return null;
    final cacheDataString = await _fetchOnlyData(type);
    if (cacheDataString == null) return null;

    final model = generateResponseModel<R, T>(
      NetworkManagerUtil.decodeBodyWithCompute(cacheDataString),
      responseModel,
    );

    return ResponseModel<R, E>(
      data: model,
      error: model == null ? ErrorModel.parseError() : null,
    );
  }

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