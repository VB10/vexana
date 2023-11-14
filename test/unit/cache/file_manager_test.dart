import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:vexana/src/cache/file/local_file_io.dart';
import 'package:vexana/vexana.dart';

import '../../feature/cache-test/mock_path.dart';

void main() {
  final fileManager = LocalFileIO();
  setUp(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });
  test('File Manager get file ', () async {
    final file = await fileManager.instance.getFile();
    expect(file, isNotNull);
  });

  test('Local file remove single item ', () async {
    await fileManager.writeUserRequestDataWithTime(
      'test',
      jsonEncode(EmptyModel(name: 'test')),
      const Duration(seconds: 5),
    );

    await fileManager.removeUserRequestSingleCache('test');
    final item = await fileManager.getUserRequestDataOnString('test');

    expect(item, isNull);
  });
}
