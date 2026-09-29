import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:vexana/src/cache/file/local_file_io.dart';
import 'package:vexana/vexana.dart';

import '../../feature/cache-test/mock_path.dart';

void main() {
  late Directory documents;
  final fileManager = LocalFileIO();
  setUp(() {
    documents = Directory.systemTemp.createTempSync('vexana-cache-test-');
    PathProviderPlatform.instance = TempDocumentsPathProvider(documents.path);
  });

  tearDown(() => documents.deleteSync(recursive: true));

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
