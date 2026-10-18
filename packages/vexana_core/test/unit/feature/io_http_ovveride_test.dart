import 'dart:io';

import 'package:test/test.dart';
import 'package:vexana_core/src/feature/ssl/io_custom_override.dart'
    if (dart.library.js_interop) 'package:vexana_core/src/feature/ssl/html_custom_override.dart'
    as ssl;

void main() {
  setUp(() {});
  test('IO Http Override test', () {
    final manager = ssl.createAdapter();

    expect(manager, isNotNull);

    manager.make();

    final data = HttpOverrides.current;

    expect(data, isNotNull);
  });
}
