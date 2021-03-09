abstract class INetworkModel<T> {
  Map<String, dynamic> toJson();
  T fromJson(Map<String, Object> json);
}
