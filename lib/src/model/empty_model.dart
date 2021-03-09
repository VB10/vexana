import '../interface/INetworkModel.dart';

class EmptyModel extends INetworkModel<EmptyModel> {
  String? name;

  EmptyModel({this.name});

  EmptyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return;
    }
    name = json['name'] as String?;
  }

  @override
  Map<String, Object> toJson() {
    final data = <String, Object>{};
    data['name'] = name ?? '';
    return data;
  }

  @override
  EmptyModel fromJson(Map<String, Object>? json) {
    return EmptyModel.fromJson(json);
  }
}
