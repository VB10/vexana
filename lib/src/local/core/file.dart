part of '../local_file.dart';

class _FileManager {
  final String fileName = "fireball.json";
  static _FileManager _instance;
  _FileManager._init();

  static _FileManager get instance {
    if (_instance == null) {
      _instance = _FileManager._init();
    }
    return _instance;
  }

  Future<Directory> documentsPath() async {
    String tempPath = (await getApplicationDocumentsDirectory())?.path;
    return Directory("$tempPath").create();
  }

  Future<String> filePath() async {
    final path = (await documentsPath()).path;
    return "$path/$fileName";
  }

  Future<File> getFile() async {
    String _filePath = await filePath();
    File userDocumentFile = File(_filePath);
    return userDocumentFile;
  }

  Future<Map> fileReadAllData() async {
    try {
      String _filePath = await filePath();
      File userDocumentFile = File(_filePath);
      final data = await userDocumentFile?.readAsString();
      final jsonData = jsonDecode(data);

      return jsonData;
    } catch (e) {
      return null;
    }
  }

  Future<File> writeLocalModelInFile(String key, BaseLocal local) async {
    String _filePath = await filePath();
    final sample = local.toJson();
    final Map<String, dynamic> model = {key: sample};

    final oldData = await fileReadAllData();
    model.addAll(oldData ?? {});
    var newLocalData = jsonEncode(model);

    File userDocumentFile = File(_filePath);
    return await userDocumentFile.writeAsString(newLocalData,
        flush: true, mode: FileMode.write);
  }

  Future<String> readOnlyKeyData(String key) async {
    Map datas = await fileReadAllData();
    if (datas != null && datas[key] != null) {
      final model = datas[key] ?? {};
      final item = BaseLocal.fromJson(model);
      if (DateTime.now().isBefore(item.time)) {
        return item.model;
      } else {
        await removeSingleItem(key);
        return null;
      }
    }
    return null;
  }

  /// Remove old key in  [Directory].
  Future removeSingleItem(String key) async {
    Map<String, Object> tempDirectory = await fileReadAllData();
    final _key = tempDirectory.keys.length > 0
        ? tempDirectory.keys
            .singleWhere((element) => element == key, orElse: () => null)
        : "";
    tempDirectory.remove(_key);
    String _filePath = await filePath();
    File userDocumentFile = File(_filePath);
    return await userDocumentFile.writeAsString(
      jsonEncode(tempDirectory),
      flush: true,
      mode: FileMode.write,
    );
  }

  /// Remove old [Directory].
  Future clearAllDirectoryItems() async {
    Directory tempDirectory = (await documentsPath());
    await tempDirectory.delete(recursive: true);
  }
}
