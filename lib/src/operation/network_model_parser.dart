part of '../network_manager.dart';

dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

dynamic _decodeBody(String body) async {
  return await compute(_parseAndDecode, body);
}

mixin CoreServiceMixin {
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

  R? parseBody<R, T extends INetworkModel>(dynamic responseBody, T model, bool? isEnableLogger) {
    try {
      if (responseBody is List) {
        if (model is EmptyModel) {
          return responseBody.map((e) => EmptyModel(name: e.toString())).toList() as R;
        }

        return responseBody.map((data) => model.fromJson(data)).cast<T>().toList() as R;
      } else if (responseBody is Map<String, dynamic>) {
        return model.fromJson(responseBody) as R;
      } else {
        if (R is EmptyModel || R == EmptyModel) {
          return EmptyModel(name: responseBody.toString()) as R;
        } else {
          CustomLogger(
              isEnabled: isEnableLogger ?? false, data: 'Be careful your data $responseBody, I could not parse it');
          return null;
        }
      }
    } catch (e) {
      CustomLogger(
          isEnabled: isEnableLogger ?? false,
          data: 'Parse Error: $e - response body: $responseBody T model: $T , R model: $R ');
    }
    return null;
  }
}
