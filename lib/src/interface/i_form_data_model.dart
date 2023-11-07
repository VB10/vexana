import 'package:dio/dio.dart';
import 'package:vexana/src/interface/index.dart';
import 'package:vexana/src/utility/logger/log_items.dart';

/// The `IFormDataModel` interface is used to convert a model into a `FormData` object.
/// The `IFormDataModel` interface is implemented by the `INetworkModel` interface.
/// It uses the `toJson` method from the `INetworkModel` interface to convert the model into a Map<String, dynamic>.
mixin IFormDataModel<T extends INetworkModel<T>> on INetworkModel<T> {
  /// Converts the model into a `FormData` object.
  FormData? toFormData() {
    final formDataBody = toJson();
    if (formDataBody == null) return null;

    try {
      return FormData.fromMap(formDataBody);
    } catch (e) {
      LogItems.formDataLog<T>(isEnableLogger: true);
    }

    return null;
  }
}
