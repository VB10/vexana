import '../../interface/index.dart';

IFileManager createFileAdapter() => _LocalFileWeb();

class _LocalFileWeb extends IFileManager {
  @override
  Future<String?> getUserRequestDataOnString(String key) => throw UnimplementedError();

  @override
  Future<bool> removeUserRequestCache(String key) => throw UnimplementedError();

  @override
  Future<bool> removeUserRequestSingleCache(String key) => throw UnimplementedError();

  @override
  Future<bool> writeUserRequestDataWithTime(String key, String model, Duration? time) => throw UnimplementedError();
}
