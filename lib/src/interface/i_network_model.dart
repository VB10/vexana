/// Interface for network model
abstract class INetworkModel<T> {
  /// Convert to json for request body
  Map<String, dynamic>? toJson();

  /// Parse json to model
  T fromJson(Map<String, dynamic> json);
}
