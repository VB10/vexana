import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vexana/vexana.dart';

class CustomFormData extends INetworkModel<CustomFormData>
    with Mock, IFormDataModel {
  @override
  Map<String, dynamic>? toJson() {
    return {'test': 'test'};
  }
}

void main() {
  setUp(() {});
  test('Form Data Model is valid', () {
    final customFromData = CustomFormData();

    expect(customFromData.toJson(), {'test': 'test'});

    final formDataModel = customFromData.toFormData();

    expect(formDataModel, isNotNull);
  });
}
