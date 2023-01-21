import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';

import '../../interface/index.dart';
import '../../model/index.dart';
part 'file.dart';

IFileManager createFileAdapter() => _LocalFileIO();

class _LocalFileIO extends IFileManager {
  final _FileManager _fileManager = _FileManager.instance;

  @override
  Future<String?> getUserRequestDataOnString(String key) {
    return _fileManager.readOnlyKeyData(key);
  }

  @override
  Future<bool> writeUserRequestDataWithTime(
      String key, String model, Duration? time) async {
    if (time == null) {
      return false;
    } else {
      final _localModel =
          LocalModel(model: model, time: DateTime.now().add(time));
      await _fileManager.writeLocalModelInFile(key, _localModel);
      return true;
    }
  }

  @override
  Future<bool> removeUserRequestCache(String key) async {
    await _fileManager.clearAllDirectoryItems();
    return true;
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key) async {
    await _fileManager.removeSingleItem(key);
    return true;
  }
}
