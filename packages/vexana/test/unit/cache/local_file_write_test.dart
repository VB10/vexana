import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:vexana/src/cache/file/local_file_io.dart';

import '../../feature/cache-test/mock_path.dart';

void main() {
  late Directory documents;
  final fileManager = LocalFileIO();

  setUp(() {
    documents = Directory.systemTemp.createTempSync('vexana-cache-test-');
    PathProviderPlatform.instance = TempDocumentsPathProvider(documents.path);
  });

  tearDown(() => documents.deleteSync(recursive: true));

  Future<Map<String, dynamic>> readCacheFile() async =>
      jsonDecode(await File('${documents.path}/vexana.json').readAsString())
          as Map<String, dynamic>;

  test('writing a key again keeps the newer value', () async {
    await fileManager.writeUserRequestDataWithTime(
      'write-test-same-key',
      'old',
      const Duration(minutes: 5),
    );
    await fileManager.writeUserRequestDataWithTime(
      'write-test-same-key',
      'new',
      const Duration(minutes: 5),
    );

    expect(
      await fileManager.getUserRequestDataOnString('write-test-same-key'),
      'new',
    );
  });

  test('a write drops entries that have already expired', () async {
    await fileManager.writeUserRequestDataWithTime(
      'write-test-expired',
      'stale',
      const Duration(milliseconds: 1),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await fileManager.writeUserRequestDataWithTime(
      'write-test-fresh',
      'fresh',
      const Duration(minutes: 5),
    );

    final entries = await readCacheFile();
    expect(entries.containsKey('write-test-expired'), isFalse);
    expect(entries.containsKey('write-test-fresh'), isTrue);
  });
}
