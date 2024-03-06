import 'package:dio/dio.dart';
import 'package:vexana/src/interface/index.dart';
import 'package:vexana/src/utility/logger/log_items.dart';

/// FormData mixin for [INetworkModel]
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
