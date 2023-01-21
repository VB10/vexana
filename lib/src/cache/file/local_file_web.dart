import '../../interface/index.dart';

IFileManager createFileAdapter() => _LocalFileWeb();

class _LocalFileWeb extends IFileManager {
  @override
  Future<String?> getUserRequestDataOnString(String key) {
    // TODO: implement getUserRequestDataOnString
    throw UnimplementedError();
  }

  @override
  Future<bool> removeUserRequestCache(String key) {
    // TODO: implement removeUserRequestCache
    throw UnimplementedError();
  }

  @override
  Future<bool> removeUserRequestSingleCache(String key) {
    // TODO: implement removeUserRequestSingleCache
    throw UnimplementedError();
  }

  @override
  Future<bool> writeUserRequestDataWithTime(
      String key, String model, Duration? time) {
    // TODO: implement writeUserRequestDataWithTime
    throw UnimplementedError();
  }
}
