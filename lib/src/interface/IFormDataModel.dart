import 'package:dio/dio.dart';
import 'package:vexana/src/interface/INetworkModel.dart';

mixin  IFormDataModel on INetworkModel {
  FormData? toFormData() {
    try {
      if (toJson() == null) return null;
      return FormData.fromMap(toJson()!);
    } catch (e) {
      throw Exception('Error in FormData $e');
    }
  }
}
