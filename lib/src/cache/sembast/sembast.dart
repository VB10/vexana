part of 'local_sembast.dart';

class _SembastManager {
  _SembastManager._init();

  final String dbName = 'fireball.db';
  final StoreRef store = stringMapStoreFactory.store('fireball');

  static _SembastManager? _instance;
  Database? _db;

  static _SembastManager get instance {
    return _instance ??= _SembastManager._init();
  }

  Future<String> dbPath() async {
    final path = await customPath.createPathProviderAdapter().applicationDirectoryPath();
    return '$path/$dbName';
  }

  Future<Database> openDb() async {
    final db = kIsWeb ? databaseFactoryWeb.openDatabase(dbName) : databaseFactoryIo.openDatabase(await dbPath());
    return db;
  }

  Future<Database> getDb() async {
    return _db ??= await openDb();
  }

  Future<void> writeLocalModelInStore(String key, LocalModel local) async {
    await store.record(key).put(await getDb(), local.toJson(), merge: true);
  }

  Future<String?> readOnlyKeyData(String key) async {
    final data = await store.record(key).getSnapshot(await getDb());
    if (data != null) {
      final jsonData = data.value;
      if (jsonData is Map<String, dynamic>) {
        final item = LocalModel.fromJson(jsonData);
        if (DateTime.now().isBefore(item.time!)) {
          return item.model;
        } else {
          await removeSingleItem(key);
          return null;
        }
      }
    }
    return null;
  }

  /// Remove old key in [store].
  Future<void> removeSingleItem(String key) async {
    await store.record(key).delete(await getDb());
  }

  /// Remove old [store].
  Future<void> clearAllStoreItems() async {
    await store.drop(await getDb());
  }
}
