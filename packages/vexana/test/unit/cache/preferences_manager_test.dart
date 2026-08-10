import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexana/vexana.dart';

void main() {
  final fileManager = LocalPreferences();
  setUp(() {
    SharedPreferences.setMockInitialValues({}); //set values here
  });
  test('File Manager general check ', () async {
    final file = await fileManager.writeUserRequestDataWithTime(
      'test',
      jsonEncode(EmptyModel(name: 'test')),
      const Duration(seconds: 5),
    );
    expect(file, isTrue);
    final data = await fileManager.getUserRequestDataOnString('test');
    expect(data, isNotNull);

    await fileManager.removeUserRequestSingleCache('test');
    final item = await fileManager.getUserRequestDataOnString('test');
    expect(item, isNull);

    await fileManager.writeUserRequestDataWithTime(
      'test',
      jsonEncode(EmptyModel(name: 'test')),
      const Duration(seconds: 5),
    );
    await fileManager.removeUserRequestCache('test');
    final latestData = await fileManager.getUserRequestDataOnString('test');
    expect(latestData, isNull);
  });
}
