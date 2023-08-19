part of 'local_file_io.dart';

@immutable
final class _FileManager {
  const _FileManager._init();
  final String fileName = 'fireball.json';
  static _FileManager? _instance;

  /// The `static _FileManager get instance` is a getter method that returns an instance of the
  /// `_FileManager` class. It follows the singleton design pattern, which ensures that only one
  /// instance of the class is created and shared across the application.
  static _FileManager get instance {
    return _instance ??= const _FileManager._init();
  }

  /// The function returns the path to the documents directory.
  Future<Directory> documentsPath() async {
    final tempPath = (await getApplicationDocumentsDirectory()).path;
    return Directory(tempPath).create();
  }

  /// The `_documentFilePath()` function returns the path to the file.
  /// File path is relative to the documents directory.
  Future<String> _documentFilePath() async {
    final path = (await documentsPath()).path;
    return '$path/$fileName';
  }

  /// The getFile function returns a Future object that represents a file.
  /// File is application documents directory.
  Future<File> getFile() async {
    final filePath = await _documentFilePath();
    final userDocumentFile = File(filePath);
    return userDocumentFile;
  }

  /// The function fileReadAllData reads all data from a file and returns it as a Map.
  /// If the file does not exist, it returns null.
  /// If the file is empty, it returns an empty Map.
  /// If the file contains data, it returns a Map with the data.
  /// If the file contains invalid data, it returns null.
  Future<Map<String, dynamic>?> fileReadAllData() async {
    final filePath = await _documentFilePath();
    final userDocumentFile = File(filePath);
    if (!userDocumentFile.existsSync()) return null;
    final data = await userDocumentFile.readAsString();
    final jsonData = JsonDecodeUtil.safeJsonDecode(data);

    if (jsonData == null) return null;
    if (jsonData is Map<String, dynamic>) return jsonData;
    return null;
  }

  /// The `writeLocalModelInFile` function is responsible for writing a `LocalModel` object to a file. It
  /// takes two parameters: `key`, which is a unique identifier for the data, and `local`, which is an
  /// instance of the `LocalModel` class.
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

  /// The `readOnlyKeyData` function is responsible for retrieving data from a file based on a given key.
  /// It takes a `key` parameter, which is a unique identifier for the data.
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
    final key0 = tempDirectory.keys.isNotEmpty ? tempDirectory.keys.singleWhereOrNull((element) => element == key) : '';
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
