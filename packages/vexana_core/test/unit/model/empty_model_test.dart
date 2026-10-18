import 'package:test/test.dart';
import 'package:vexana_core/vexana_core.dart';

void main() {
  setUp(() {});
  test('Empty model is valid', () {
    final emptyModel =
        const EmptyModel().fromJson({'name': 'test', 'n': 'test'});

    expect(emptyModel.name, 'test');

    final data = emptyModel.toJson();

    expect(data, isNull);
  });
}
