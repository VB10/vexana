import 'package:test/test.dart';
import 'package:vexana_jaspr/vexana_jaspr.dart';

void main() {
  late InMemoryStorageBackend backend;
  late JasprLocalStorageFileManager fileManager;

  setUp(() {
    backend = InMemoryStorageBackend();
    fileManager = JasprLocalStorageFileManager(storageBackend: backend);
  });

  test('write and read data with expiration', () async {
    final success = await fileManager.writeUserRequestDataWithTime(
      'user_key',
      '{"id": 1, "name": "Vexana Jaspr"}',
      const Duration(minutes: 5),
    );
    expect(success, isTrue);

    final data = await fileManager.getUserRequestDataOnString('user_key');
    expect(data, isNotNull);
    expect(data, contains('Vexana Jaspr'));
  });

  test('expired data returns null and is cleaned up', () async {
    await fileManager.writeUserRequestDataWithTime(
      'expired_key',
      'old_data',
      const Duration(milliseconds: -10),
    );

    final data = await fileManager.getUserRequestDataOnString('expired_key');
    expect(data, isNull);
    expect(backend.getItem('expired_key'), isNull);
  });

  test('remove single cache item', () async {
    await fileManager.writeUserRequestDataWithTime(
      'single_key',
      'data',
      const Duration(minutes: 1),
    );

    final removed =
        await fileManager.removeUserRequestSingleCache('single_key');
    expect(removed, isTrue);
    expect(await fileManager.getUserRequestDataOnString('single_key'), isNull);
  });

  test('remove prefixed cache items', () async {
    await fileManager.writeUserRequestDataWithTime(
      'api_users_1',
      'user 1',
      const Duration(minutes: 1),
    );
    await fileManager.writeUserRequestDataWithTime(
      'api_users_2',
      'user 2',
      const Duration(minutes: 1),
    );
    await fileManager.writeUserRequestDataWithTime(
      'other_key',
      'other',
      const Duration(minutes: 1),
    );

    final removed = await fileManager.removeUserRequestCache('api_users');
    expect(removed, isTrue);
    expect(await fileManager.getUserRequestDataOnString('api_users_1'), isNull);
    expect(await fileManager.getUserRequestDataOnString('api_users_2'), isNull);
    expect(
      await fileManager.getUserRequestDataOnString('other_key'),
      isNotNull,
    );
  });
}
