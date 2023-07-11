part of 'local_file_io.dart';

@immutable
final class _FileManager {
  const _FileManager._init();
  final String fileName = 'fireball.json';
  static _FileManager? _instance;

  static _FileManager get instance {
    return _instance ??= const _FileManager._init();
  }

  Future<Directory> documentsPath() async {
    final tempPath = (await getApplicationDocumentsDirectory()).path;
    return Directory(tempPath).create();
  }

  /// Get application document  path from phone
  Future<String> _documentFilePath() async {
    final path = (await documentsPath()).path;
    return '$path/$fileName';
  }

  Future<File> getFile() async {
    final filePath = await _documentFilePath();
    final userDocumentFile = File(filePath);
    return userDocumentFile;
  }

  Future<Map<String, dynamic>?> fileReadAllData() async {
    final filePath = await _documentFilePath();
    final userDocumentFile = File(filePath);
    final data = await userDocumentFile.readAsString();
    final jsonData = JsonDecodeUtil.safeJsonDecode(data);

    if (jsonData == null) return null;
    if (jsonData is Map<String, dynamic>) return jsonData;
    return null;
  }

  Future<File> writeLocalModelInFile(String key, LocalModel local) async {
    final filePath = await _documentFilePath();
    final sample = local.toJson();
    final model = <String, dynamic>{key: sample};

    final oldData = await fileReadAllData();
    model.addAll(oldData ?? {});
    final newLocalData = jsonEncode(model);

    final userDocumentFile = File(filePath);
    return userDocumentFile.writeAsString(newLocalData, flush: true);
  }

  Future<String?> readOnlyKeyData(String key) async {
    final fileItems = await fileReadAllData();
    if (fileItems != null && fileItems.isNotEmpty && fileItems[key] != null) {
      final model = fileItems[key];

      if (model is! Map<String, dynamic>) return null;
      final item = LocalModel.fromJson(model);

      if (DateTime.now().isBefore(item.time!)) {
        return item.model;
      } else {
        await removeSingleItem(key);
        return null;
      }
    }
    return null;
  }

  /// Remove old key in  [Directory].
  Future<File?> removeSingleItem(String key) async {
    final tempDirectory = await fileReadAllData();
    if (tempDirectory == null) {
      return null;
    }
    final key0 = tempDirectory.keys.isNotEmpty
        ? tempDirectory.keys.singleWhereOrNull((element) => element == key)
        : '';
    tempDirectory.remove(key0);
    final filePath = await _documentFilePath();
    final userDocumentFile = File(filePath);
    return userDocumentFile.writeAsString(
      jsonEncode(tempDirectory),
      flush: true,
    );
  }

  /// Remove old [Directory].
  Future<void> clearAllDirectoryItems() async {
    final tempDirectory = await documentsPath();
    await tempDirectory.delete(recursive: true);
  }
}
