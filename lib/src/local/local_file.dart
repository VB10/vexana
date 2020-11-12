import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../model/local_data.dart';
import 'IFileManager.dart';

part 'core/file.dart';

class LocalFile implements IFileManager {
  _FileManager _fileManager = _FileManager.instance;

  @override
  Future<String> getUserRequestDataOnString(String key) {
    return _fileManager.readOnlyKeyData(key);
  }

  @override
  Future<bool> writeUserRequestDataWithTime(
      String key, String model, Duration time) async {
    if (time == null)
      return false;
    else {
      final _localModel =
          BaseLocal(model: model, time: DateTime.now().add(time));
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
