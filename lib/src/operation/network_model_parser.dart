part of '../network_manager.dart';

dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

dynamic _decodeBody(String body) async {
  return await compute(_parseAndDecode, body);
}

extension _CoreServiceExtension on NetworkManager {
  /// The function `_getBodyModel` takes in a dynamic data and returns the appropriate body model based on
  /// its type.
  ///
  /// Args:
  ///   data (dynamic): The `data` parameter is a dynamic variable, which means it can hold values of any
  /// type. It is used as input to determine the type of data and convert it accordingly.
  ///
  /// Returns:
  ///   The method `_getBodyModel` returns a dynamic value. The specific value
  /// that is returned depends on the type of the `data` parameter.
  ///  If `data` is an instance of `IFormDataModel`, the method returns
  ///  the result of calling the `toFormData` method on `data`.
  ///  If `data` is an instance of `INetworkModel`,
  ///  the method returns the result of calling `toJson` method on `data`.
  ///  If `data` is not null, the method returns the
  ///  result of calling `jsonEncode` method on `data`.
  dynamic _getBodyModel(dynamic data) {
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

  /// The function `_parseBody` is used to parse a response body into a specified type `R` using a model
  /// `T` that implements the `INetworkModel` interface.
  ///
  /// Args:
  ///   responseBody (dynamic): The `responseBody` parameter is the dynamic data that needs to be parsed.
  /// It can be either a List or a Map<String, dynamic>.
  ///   model (T): The `model` parameter is an instance of a class that implements the `INetworkModel`
  /// interface. It is used to parse the response body into an object of type `T`.
  ///
  /// Returns:
  ///   The method returns an object of type R.
  R? _parseBody<R, T extends INetworkModel<T>>(dynamic responseBody, T model) {
    try {
      if (R is EmptyModel || R == EmptyModel) {
        return EmptyModel(name: responseBody.toString()) as R;
      }

      if (responseBody is List) {
        return responseBody
            .map(
              (data) => model.fromJson(data is Map<String, dynamic> ? data : {}),
            )
            .cast<T>()
            .toList() as R;
      }

      if (responseBody is Map<String, dynamic>) {
        return model.fromJson(responseBody) as R;
      } else {
        /// Throwing exception if the response body is not a List or a Map<String, dynamic>.
        throw Exception(
            'Response body is not a List or a Map<String, dynamic>',);
      }
    } catch (e) {
      CustomLogger(
        isEnabled: isEnableLogger ?? false,
        data: 'Parse Error: $e - response body: $responseBody T model: $T , R model: $R ',
      );
    }
    return null;
  }
}
