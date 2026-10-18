import 'package:flutter_test/flutter_test.dart';
import 'package:vexana/vexana.dart';

void main() {
  setUp(() {});
  test('Empty model is valid', () {
    final emptyModel = EmptyModel().fromJson({'name': 'test', 'n': 'test'});

    expect(emptyModel.name, 'test');

    final data = emptyModel.toJson();

    expect(data, isNull);
  });
}
