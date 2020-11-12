abstract class IFileManager {
  final Duration duration;

  IFileManager(this.duration);
  Future<bool> writeUserRequestDataWithTime(
      String key, String model, Duration time);
  Future<String> getUserRequestDataOnString(String key);
  Future<bool> removeUserRequestSingleCache(String key);
  Future<bool> removeUserRequestCache(String key);
}
