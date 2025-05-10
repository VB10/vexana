import 'dart:convert';

import 'package:vexana/src/mixin/network_manager_parameters.dart';
import 'package:vexana/src/utility/custom_logger.dart';
import 'package:vexana/src/utility/json_encode_util.dart';
import 'package:vexana/src/utility/logger/log_items.dart';
import 'package:vexana/vexana.dart';

/// Parse response body for success and error
mixin NetworkManagerResponse<E extends INetworkModel<E>, P> {
  /// Network manager parameters
  NetworkManagerParameters<E, P> get parameters;

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

  /// The fetchSuccessResponse method parses the provided data into the
  /// specified model and returns a NetworkResult. If the parsing is successful,
  /// it returns a NetworkSuccessResult with the parsed model. If parsing fails,
  /// it returns a NetworkErrorResult with an error model.
  NetworkResult<R, E> fetchSuccessResponse<T extends INetworkModel<T>, R>({
    required dynamic data,
    required T parserModel,
  }) {
    final model = parseUserResponseData<R, T>(data, parserModel);
    if (model != null) return NetworkSuccessResult(model);
    return NetworkErrorResult(ErrorModel<E>.parseError());
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

  /// The fetchErrorResponse method handles a DioException,
  /// logs the error message if logging is enabled, and generates an error model
  /// based on the exception and its response data.
  /// It then returns a NetworkErrorResult containing the error model.
  NetworkResult<R, E> fetchErrorResponse<R>(DioException exception) {
    CustomLogger(
      isEnabled: parameters.isEnableLogger,
      data: exception.message,
    ).printError();

    final errorResponse = exception.response;
    var error = ErrorModel<E>.dioException(exception);
    if (errorResponse != null) {
      error = _generateErrorModel(error, errorResponse.data);
    }
    return NetworkErrorResult(error);
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
