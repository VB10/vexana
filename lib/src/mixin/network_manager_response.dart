import 'dart:convert';

import 'package:vexana/src/mixin/network_manager_parameters.dart';
import 'package:vexana/src/utility/custom_logger.dart';
import 'package:vexana/src/utility/json_encode_util.dart';
import 'package:vexana/src/utility/logger/log_items.dart';
import 'package:vexana/vexana.dart';

/// Parse response body for success and error
mixin NetworkManagerResponse<E extends INetworkModel<E>> {
  /// Network manager parameters
  NetworkManagerParameters get parameters;

  /// E: Error Model for generic error
  E? get errorModel;

  /// Success response fetch to parse it
  ///
  /// R: Response Model for user want to parse
  /// T: Parser Model
  /// data: Response body
  ///
  /// Result:
  /// ResponseModel<R, E> -> R: Response Model, E: Error Model
  ResponseModel<R, E> successResponseFetch<T extends INetworkModel<T>, R>({
    required dynamic data,
    required T parserModel,
  }) {
    final model = parseUserResponseData<R, T>(data, parserModel);
    return ResponseModel<R, E>(
      data: model,
      error: model == null ? ErrorModel<E>.parseError() : null,
    );
  }

  /// Error response fetch to parse it
  ///
  /// R: void or null for only show error
  ///
  ///
  ResponseModel<R, E> errorResponseFetch<R>(DioException exception) {
    CustomLogger(
      isEnabled: parameters.isEnableLogger,
      data: exception.message,
    ).printError();

    final errorResponse = exception.response;
    var error = ErrorModel<E>.dioException(exception);
    if (errorResponse != null) {
      error = _generateErrorModel(error, errorResponse.data);
    }

    return ResponseModel<R, E>(
      error: ErrorModel<E>(
        description: error.description,
        model: error.model,
        statusCode: error.statusCode,
      ),
    );
  }

  ErrorModel<E> _generateErrorModel(ErrorModel<E> error, dynamic data) {
    if (errorModel == null) return error;

    if (data is String) {
      final jsonBody = JsonDecodeUtil.safeJsonDecode(data);
      if (jsonBody == null || jsonBody is! Map<String, dynamic>) return error;
      return error.copyWith(model: errorModel!.fromJson(jsonBody));
    }

    if (data is Map<String, dynamic>) {
      return error.copyWith(model: errorModel!.fromJson(data));
    }

    return error;
  }

  /// Parse response body
  /// R: Response Model for user want to parse
  /// T: Parser Model
  R? parseUserResponseData<R, T extends INetworkModel<T>>(
    dynamic responseBody,
    T model,
  ) {
    if (R is EmptyModel || R == EmptyModel) {
      return EmptyModel(name: responseBody.toString()) as R;
    }

    try {
      if (responseBody is List<dynamic>) {
        final items = responseBody.whereType<Map<String, dynamic>>().toList();
        return items
            .map((data) {
              return model.fromJson(data);
            })
            .cast<T>()
            .toList() as R;
      }

      if (responseBody is Map<String, dynamic>) {
        return model.fromJson(responseBody) as R;
      }

      LogItems.bodyParseErrorLog(
        data: responseBody,
        isEnableLogger: parameters.isEnableLogger,
      );
      return null;
    } catch (e) {
      LogItems.bodyParseGeneralLog<T, R>(
        data: e,
        responseBody: responseBody,
        isEnableLogger: parameters.isEnableLogger,
      );
    }
    return null;
  }

  /// Make a body for request
  ///
  /// data: dynamic data
  ///
  /// if data is IFormDataModel -> return data.toFormData()
  /// if data is INetworkModel -> return data.toJson()
  /// if data is not null -> return jsonEncode(data)
  dynamic makeRequestBodyData(dynamic data) {
    if (data is IFormDataModel) return data.toFormData();
    if (data is INetworkModel) return data.toJson();
    if (data != null) return jsonEncode(data);
    return data;
  }
}
