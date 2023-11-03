abstract class INetworkModel<T> {
  Map<String, dynamic>? toJson();
  T fromJson(Map<String, dynamic> json);
}
