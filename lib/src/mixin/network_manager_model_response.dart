import 'dart:convert';

import 'package:vexana/src/interface/index.dart';
import 'package:vexana/src/mixin/network_manager_paramaters.dart';
import 'package:vexana/src/utility/custom_logger.dart';
import 'package:vexana/src/utility/json_encode_util.dart';
import 'package:vexana/vexana.dart';

mixin NetworkManagerModelResponse<E extends INetworkModel<E>>
    on NetworkManagerParameters {
  INetworkManager<E> get instance;
  E? get errorModel;

  dynamic getBodyModel(dynamic data) {
    if (data is IFormDataModel) {
      return data.toFormData();
    } else if (data is INetworkModel) {
      return data.toJson();
    } else if (data != null) {
      return jsonEncode(data);
    } else {
      return data;
    }
  }

  ErrorModel<E> generateErrorModel(ErrorModel<E> error, dynamic data) {
    var generatedError = error;
    if (errorModel == null) return generatedError;

    if (data is String) {
      final jsonBody = JsonDecodeUtil.safeJsonDecode(data);
      if (jsonBody == null || jsonBody is! Map<String, dynamic>) return error;
      generatedError = error.copyWith(model: errorModel!.fromJson(jsonBody));
    }

    if (data is Map<String, dynamic>) {
      final jsonBody = data;
      generatedError = error.copyWith(model: errorModel!.fromJson(jsonBody));
    }

    return generatedError;
  }

  R? generateResponseModel<R, T extends INetworkModel<T>>(
    dynamic responseBody,
    T model,
  ) {
    try {
      if (R is EmptyModel || R == EmptyModel) {
        return EmptyModel(name: responseBody.toString()) as R;
      }

      if (responseBody is List) {
        return responseBody
            .map(
              (data) =>
                  model.fromJson(data is Map<String, dynamic> ? data : {}),
            )
            .cast<T>()
            .toList() as R;
      }

      if (responseBody is Map<String, dynamic>) {
        return model.fromJson(responseBody) as R;
      } else {
        CustomLogger(
          isEnabled: true,
          data:
              'Response body is not a List or a Map<String, dynamic> response:'
              '$responseBody',
        );
        return null;
      }
    } catch (e) {
      CustomLogger(
        isEnabled: isEnableLogger ?? false,
        data: 'Parse Error: $e - response body: $responseBody'
            'T model: $T , R model: $R ',
      );
    }
    return null;
  }
}
