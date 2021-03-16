part of 'local_sembast.dart';

class _SembastManager {
  final String dbName = 'fireball.db';
  final StoreRef store = stringMapStoreFactory.store('fireball');

  static _SembastManager? _instance;
  Database? _db;

  _SembastManager._init();

  static _SembastManager get instance {
    return _instance ??= _SembastManager._init();
  }

  Future<String> dbPath() async {
    final path = (await getApplicationDocumentsDirectory()).path;
    return '$path/$dbName';
  }

  Future<Database> openDb() async {
    final db = databaseFactoryIo.openDatabase(await dbPath());
    return db;
  }

  Future<Database> getDb() async {
    return _db ??= await openDb();
  }

  Future writeLocalModelInStore(String key, LocalModel local) async {
    await store.record(key).put(await getDb(), local.toJson(), merge: true);
  }

  Future<String?> readOnlyKeyData(String key) async {
    final data = await store.record(key).getSnapshot(await getDb());
    if (data != null) {
      final item = LocalModel.fromJson(data.value);
      if (DateTime.now().isBefore(item.time!)) {
        return item.model;
      } else {
        await removeSingleItem(key);
        return null;
      }
    }
    return null;
  }

  /// Remove old key in  [Store].
  Future removeSingleItem(String key) async {
    await store.record(key).delete(await getDb());
  }

  /// Remove old [Store].
  Future clearAllStoreItems() async {
    await store.drop(await getDb());
  }
}
