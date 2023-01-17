import '../../interface/IFileManager.dart';

import 'local_file_io.dart' if (dart.library.html) 'local_file_web.dart' as adapter;

class LocalFile extends IFileManager {
  // final _FileManager _fileManager = _FileManager.instance;
  final _customManager = adapter.createFileAdapter();
  @override
  Future<String?> getUserRequestDataOnString(String key) {
    return _customManager.getUserRequestDataOnString(key);
  }

  @override
  Future<bool> writeUserRequestDataWithTime(String key, String model, Duration? time) async {
    return _customManager.writeUserRequestDataWithTime(key, model, time);
  }

  @override
  Future<bool> removeUserRequestCache(String key) async {
    return _customManager.removeUserRequestCache(key);
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key) async {
    return _customManager.removeUserRequestSingleCache(key);
  }
}
