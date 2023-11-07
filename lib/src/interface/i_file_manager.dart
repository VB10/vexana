/// Interface for file manager
abstract class IFileManager {
  /// Write user request data with time
  /// [key] is unique identifier for the data
  /// [model] is an instance of the `LocalModel` class.
  /// [time] is an instance of the `Duration` class.
  ///
  /// Return [Future<bool>]
  Future<bool> writeUserRequestDataWithTime(
    String key,
    String model,
    Duration? time,
  );

  /// Read all data from file
  /// Return [Future<Map<String, dynamic>>]
  Future<String?> getUserRequestDataOnString(String key);

  /// Remove user request data
  /// Return [Future<bool>]
  Future<bool> removeUserRequestSingleCache(String key);

  /// Remove user request data
  /// Return [Future<bool>]
  Future<bool> removeUserRequestCache(String key);
}
